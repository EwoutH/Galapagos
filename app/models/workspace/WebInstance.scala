package models.workspace

import
  collection.mutable.{ Map => MutableMap },
  language.implicitConversions

import
  concurrent.{ duration, Future },
    duration._

import
  java.io.File

import
  akka.{ actor, pattern, util },
    actor.{ Actor, Props },
    pattern.ask,
    util.Timeout

import
  org.nlogo.headless.HeadlessWorkspace

import
  play.api.{ libs, Logger },
    libs.{ concurrent => pconcurrent, json, iteratee },
      pconcurrent.Akka,
      iteratee.{ Done, Enumerator, Input, Iteratee, PushEnumerator },
      json.{ JsArray, JsObject, JsString, JsValue }

import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import models.remote.{ NetLogoController, NetLogoControllerMessages, WebWorkspace }

object WebInstance {

  import WebInstanceMessages._

  implicit val timeout = Timeout(1.second)

  //@ This strikes me as a poor implementation... (it will change when the multi-headless system is implemented)
  val roomMap = MutableMap(0 -> Akka.system.actorOf(Props[WebInstance]))


  def join() = ???

  def join(username: String, roomNum: Int) : Future[(Iteratee[JsValue, _], Enumerator[JsValue])] = {
    val room = roomMap(roomNum)
    (room ? Join(username)).map {
      case Connected(enumerator) =>
        val iteratee = Iteratee.foreach[JsValue] {
          event => room ! Command(username, (event \ "agentType").as[String], (event \ "cmd").as[String])
        } mapDone {
          _     => room ! Quit(username)
        }
        (iteratee, enumerator)
      case CannotConnect(error) =>
        val iteratee   = Done[JsValue, Unit]((), Input.EOF)
        val enumerator = Enumerator[JsValue](JsObject(Seq("error" -> JsString(error)))).andThen(Enumerator.enumInput(Input.EOF))
        (iteratee,enumerator)
      case x =>
        Logger.warn("Unknown event: " + x.toString)
        throw new IllegalArgumentException("An unknown event has occurred on user join: " + x.toString)
    }
  }

}

class WebInstance extends Actor with ChatPacketProtocol with EventManagerProtocol {

  import NetLogoControllerMessages._
  import WebInstanceMessages._

  private val NameLengthLimit = 10

  private val RoomContext     = "room"
  private val ObserverContext = "observer"
  private val TurtlesContext  = "turtles"
  private val LinksContext    = "links"
  private val PatchesContext  = "patches"
  private val ChatterContext  = "chatter"
  private val NetLogoUsername = "netlogo"

  private val Contexts = List(RoomContext, ObserverContext, TurtlesContext, LinksContext, PatchesContext, ChatterContext)

  private lazy val room  = self
  private val nlController = Akka.system.actorOf(Props[NetLogoController])

  private type MemberKey   = String
  private type MemberValue = PushEnumerator[JsValue]
  private type MemberTuple = (MemberKey, MemberValue)
  val members = MutableMap.empty[MemberKey, MemberValue]


  BizzleBot.start()
  Akka.system.scheduler.schedule(0.milliseconds, 30.milliseconds) {
    nlController ! RequestViewUpdate
  }

  def receive = {

    case Join(username) =>
      val channel = Enumerator.imperative[JsValue](onStart = () => room ! NotifyJoin(username))
      isValidUsername(username) match {
        case (true, _) =>
          members += username -> channel
          sender ! Connected(channel)
          nlController ! RequestViewState
        case (false, reason) =>
          sender ! CannotConnect(reason)
      }

    case NotifyJoin(username) =>
      notifyAll(generateMessage(JoinKey, RoomContext, username, "has entered the room"))

    case Chatter(username, message) =>
      if (BizzleBot.canFieldMessage(message))
        BizzleBot.offerAssistance(username, message) foreach {
          msg => notify(username, generateMessage(ChatterKey, ChatterContext, BizzleBot.BotName, msg))
        }
      else
        notifyAll(generateMessage(ChatterKey, ChatterContext, username, message))

    case Command(username, ChatterContext, message) =>
      self ! Chatter(username, message)

    case Command(username, agentType, cmd) if (Contexts.contains(agentType)) =>
      notifyAll(generateMessage(CommandKey, agentType, username, cmd))
      nlController ! Execute(agentType, cmd)

    case Command(username, agentType, cmd) =>
      Logger.warn(s"Unhandlable message from user '$username' in context '$agentType': $cmd")

    case CommandOutput(agentType, output) =>
      notifyAll(generateMessage(ResponseKey, NetLogoUsername, agentType, output))

    case Quit(username) =>
      quit(username)

    case ViewUpdate(serializedUpdate: String) =>
      notifyAll(generateMessage(ViewUpdateKey, RoomContext, NetLogoUsername, serializedUpdate))

  }

  private def quit(username: String) {
    members -= username
    notifyAll(generateMessage(QuitKey, RoomContext, username, "has left the room"))
  }

  // THIS IS WHY `Option` SHOULD SHARE A REASONABLE SUBTYPE WITH `Traversable`!
  // Also, why did my structural typing fail here...?
  implicit class Pushable[T <: Iterable[MemberTuple]](foreachable: T) {
    def pushForeach(msg: JsObject) {
      foreachable foreach { case (username, channel) =>
        // Note that push is being used for it's side effect here. The return
        // of push indicates success; ie, whether the server successfully sent
        // the message to the client.
        if (!channel.push(msg))
          quit(username)
      }
    }
  }

  private def notify(messageSets: (Iterable[String], JsObject)*) {
    messageSets foreach {
      case (memberNames, msg) => members filter { case (name, _) => memberNames.toSeq.contains(name) } pushForeach msg
    }
  }

  private def notify(memberName: String, msg: JsObject) {
    (members find (_._1 == memberName)).toIterable pushForeach msg
  }

  private def notifyBut(memberName: String, msg: JsObject) {
    members filterNot (_._1 == memberName) pushForeach msg
  }

  private def notifyAll(msg: JsObject) {
    members pushForeach msg
  }

  private def generateMessage(kind: String, context: String, user: String, text: String) =
    JsObject(
      Seq(
        KindKey    -> JsString(kind),
        ContextKey -> JsString(context),
        UserKey    -> JsString(user),
        MessageKey -> JsString(text),
        MembersKey -> JsArray(members.keySet.toList map (JsString))
      )
    )

  private def generateMultiMessage(kind: String, context: String, user: String, text: String, formats: String*) =
    formats map (f => generateMessage(kind, context, user, f.format(text)))

  protected def isValidUsername(username: String) : (Boolean, String) = {
    val reservedNames = Seq("me", "myself") ++ Contexts
    Seq(
      (reservedNames.contains(username.filter(_ != ' ')), "Username attempts to deceive others!"),
      (username.isEmpty,                                  "Username is empty"),
      (username.length >= NameLengthLimit,                "Username is too long (must be %d characters or less)".format(NameLengthLimit)),
      (members.contains(username),                        "Username already taken"),
      (username.matches(""".*[^ \w].*"""),                "Username contains invalid characters (must contain only alphanumeric characters and spaces)")
    ) collectFirst { case (cond, msg) if (cond) => (false, msg) } getOrElse (true, "Username approved")
  }

  protected def workspace(file: File) : WebWorkspace = {
    val wspace = HeadlessWorkspace.newInstance(classOf[WebWorkspace]).asInstanceOf[WebWorkspace]
    wspace.openString(io.Source.fromFile(file).mkString)
    wspace
  }

  /*
  Description:
    An automated bot for being a good samaritan towards NetLogo users
    Created by yours truly, J-Bizzle, botmaker extraordinaire
  */
  private object BizzleBot extends ChatPacketProtocol {

    implicit val timeout = Timeout(1.second)

    val BotName = "BizzleBot"

    private val Commands = List("commands", "help", "info", "whoami", "halt")

    def start() {
      room ? (Join(BotName)) map {
        case Connected(robotChannel) =>
          robotChannel |>> Iteratee.foreach[JsValue] {
          event =>
            Logger(BotName).info(event.toString())
            (event \ UserKey).asOpt[String].flatMap (user => (event \ MessageKey).asOpt[String] map ((user, _))).
              foreach { case (username, message) => handleChat(username, message) }
        }
      }
    }

    def canFieldMessage(message: String) = message.startsWith("/") && Commands.contains(message.tail)

    def offerAssistance(username: String, message: String) : Option[String] = {

      def preprocess(message: String) : Option[String] = {
        val trimmed = message.trim
        if (trimmed.startsWith("/")) Some(trimmed.tail.trim) else None
      }

      preprocess(message) map {

        case "commands" =>
          "here are the supported commands: " + Commands.mkString("[", ", ", "]")

        case "help" =>
          """|perhaps this can be of help to you:
             |
             |<ul><li>Press the Tab key to change agent contexts.</li>
             |<li>Press the Up Arrow/Down Arrow to navigate through previously-entered commands.</li>
             |<li>Press Control + L to clear the chat buffer.</li>
             |<li>Press Control + Shift + [any number key 1-5] to directly set yourself to use a specific agent context.</li>
             |<li>For information about how to use the NetLogo programming language, please consult  <a href=\"http://ccl.northwestern.edu/netlogo/docs/\">the official NetLogo user manual</a>.</li></ul>
          """.stripMargin

        case "info" =>
          """|NetLogo is a multi-agent programmable modeling environment,
             | authored by Uri Wilensky and developed at Northwestern University's Center for Connected Learning.
             |  For additional information, please visit <a href=\"http://ccl.northwestern.edu/netlogo/\">the NetLogo website</a>.
          """.stripMargin.replaceAll("""\n|\r""", "") // Remove the newlines; they're just in there to make the string presentable in the code here

        case "whoami" =>
          "you're @%s, obviously!".format(username)

        case "halt" =>
          nlController ! Halt
          "halting"

        case _ =>
          "you just sent me an unrecognized request.  I don't know how you did it, but shame on you!"

      } map ("@%s, ".format(username) + _)
    }

    // We can do stuff with this later, if we ever want to have the bot play with more-general chat
    protected def handleChat(username: String, message: String) {}

  }

}

