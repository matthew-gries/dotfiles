-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 14
config.color_scheme = "Gruvbox dark, hard (base16)"
config.font = wezterm.font("3270 Nerd Font")

-- Leader key configuration
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Key mappings
config.keys = {
  -- Send "CTRL+B" to the terminal when pressing CTRL+B, CTRL+B
  {
    key = 'b',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendKey { key = 'b', mods = 'CTRL' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '\\',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 's',
    mods = 'LEADER',
    action = wezterm.action.PaneSelect { mode = 'SwapWithActive' },
  },
  {
    key = 'z',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = 'c',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'H',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'J',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'K',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'L',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Right', 5 },
  },
  {
    key = '1',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(0),
  },
  {
    key = '2',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(1),
  },
  {
    key = '3',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(2),
  },
  {
    key = '4',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(3),
  },
  {
    key = '5',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(4),
  },
  {
    key = '6',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(5),
  },
  {
    key = '7',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(6),
  },
  {
    key = '8',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(7),
  },
  {
    key = '9',
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(8),
  },
  -- Activate resize mode
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },
  -- Activate pane selection mode for closing
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable {
      name = 'close_pane',
      one_shot = true,
    },
  },
}

-- Key tables for resize mode
config.key_tables = {
  -- Defines the keys that are active in the "resize_pane" mode
  resize_pane = {
    { key = 'h',      action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = 'j',      action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    { key = 'k',      action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
    { key = 'l',      action = wezterm.action.AdjustPaneSize { 'Right', 1 } },
    { key = 'LeftArrow',  action = wezterm.action.AdjustPaneSize { 'Left', 1 } },
    { key = 'DownArrow',  action = wezterm.action.AdjustPaneSize { 'Down', 1 } },
    { key = 'UpArrow',    action = wezterm.action.AdjustPaneSize { 'Up', 1 } },
    { key = 'RightArrow', action = wezterm.action.AdjustPaneSize { 'Right', 1 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },

  -- Key table for pane closing confirmation
  close_pane = {
    { key = 'y', action = wezterm.action.CloseCurrentPane { confirm = false } },
    { key = 'n', action = 'PopKeyTable' },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

-- Finally, return the configuration to wezterm:
return config
