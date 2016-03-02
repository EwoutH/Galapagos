window.RactiveSwitch = Ractive.extend({
  data: {
    dims:   undefined # String
  , id:     undefined # String
  , widget: undefined # SwitchWidget
  }

  isolated: true

  template:
    """
    <label id="{{id}}"
           class="netlogo-widget netlogo-switcher netlogo-input"
           style="{{dims}}">
      <input type="checkbox" checked={{ widget.currentValue }} />
      <span class="netlogo-label">{{ widget.display }}</span>
    </label>
    """

})