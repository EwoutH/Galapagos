window.RactiveSwitch = Ractive.extend({
  data: {
    dims:   undefined # String
  , id:     undefined # String
  , widget: undefined # SwitchWidget
  }

  isolated: true

  # `on` and `currentValue` should be synonymous for Switches.  It is necessary that we
  # update `on`, because that's what the widget reader looks at at compilation time in
  # order to determine the value of the Switch. --JAB (3/31/16)
  oninit: ->
    Object.defineProperty(@get('widget'), "on", {
      get:     -> @currentValue
      set: (x) -> @currentValue = x
    })

  template:
    """
    <label id="{{id}}"
           on-contextmenu="showContextMenu:{{id + '-context-menu'}}"
           class="netlogo-widget netlogo-switcher netlogo-input"
           style="{{dims}}">
      <input type="checkbox" checked={{ widget.currentValue }} />
      <span class="netlogo-label">{{ widget.display }}</span>
    </label>
    <div id="{{id}}-context-menu" class="netlogo-widget-editor-menu-items">
      <ul class="context-menu-list">
        <li class="context-menu-item" on-click="deleteWidget:{{id}},{{id + '-context-menu'}},{{widget.id}}">Delete</li>
      </ul>
    </div>
    """

})
