import RactiveModalDialog from "./modal-dialog.js"

RactiveHelpDialog = RactiveModalDialog.extend({

  data: () -> {
    extraClasses: 'ntb-confirm-overlay' # String
    showApprove:  false                 # String
    deny:         { text: "Done" }      # EventOptions
  }

  partials: {
    headerContent: "Help and Hotkeys"
    dialogContent:
      """
      <div class="ntb-dialog-text">
        NetTango Web is an app that lets you define blocks that snap together to create NetLogo code for use in a NetLogo Web model.
        <h2>Main App Menu</h2>
        There is a main menu bar that floats into view at the top of the screen with the following options:
        <ul>
          <li><strong>Files</strong>: Contains options to import or export NetTango Web project files, to import or export the NetLogo model of the project, and to load models or projects from the preset libraries.</li>
          <li><strong>Undo</strong> and <strong>Redo</strong>: Undoes the last change to the project or redoes the last undone change to the project.</li>
          <li><strong>Options...</strong>: Opens the options for the project, including visual style options for the NetLogo model and project-wide block colors.</li>
          <li><strong>Add New Block Space</strong>: Adds a new, separate block workspace to the project.</li>
          <li><strong>Help</strong>: Links to help documents and the NetTango Web tutorial.</li>
        </ul>
        <h2>Workspace Buttons and Settings</h2>
        Each workspace has these buttons just under the editable name:
        <ul>
          <li><strong>Add Block</strong>: Contains a list of new block defaults to add to a workspace.</li>
          <li><strong>Modify Block</strong>: Lists all blocks in a workspace to be edited, deleted, or duplicated.</li>
          <li><strong>Delete Block Space</strong>: Deletes the workspace from the project, with confirmation.</li>
          <li><strong>Width</strong> and <strong>Height</strong>: Sets the size of the workspace in pixels.  Height acts as a minimum, as block chains in a workspace can grow longer than the initial value.</li>
        </ul>
        Additionally, in the blocks menu of each workspace, you can right-click on the group headers to edit the block groupings or sort the blocks.
        <h2>Block Interactions and Hotkeys</h2>
        Block chains are created by dragging blocks from the menu into the space beside it, either stand-alone or as part of an existing chain.
        When a drag starts, any valid locations for the dragged blocks will show with flashing, light-blue arrows.
        <ul>
          <li><strong>Right click or long-press</strong> on a block in a chain to see a popup code tip that displays the NetLogo code the block adds to the model.</li>
          <li>Press <strong>Shift</strong> when dragging a block in a chain to grab only that block without its followers</li>
        </ul>
       </div>
      """
  }
})

export default RactiveHelpDialog
