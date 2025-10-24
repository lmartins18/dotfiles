-- lua/config/highlights.lua
-- Horizon-leaning highlights (red/orange bias), no changes to your tokyonight config

local P = {
  -- UI / base
  bg            = "#1C1E26",
  bg_alt        = "#232530",
  border        = "#1A1C23",
  accent        = "#2E303E",
  accentAlt     = "#6C6F93",
  lightText     = "#D5D8DA",
  gray          = "#BBBBBB",

  -- Horizon hues
  cranberry     = "#E95678", -- reddish pink
  apricot       = "#F09483",
  rosebud       = "#FAB795",
  tacao         = "#FAC29A",
  lavender      = "#B877DB",
  turquoise     = "#25B0BC",

  -- extras from theme
  cursorline_bg = "#21232D",
  visual_bg     = "#343647",
  match_paren   = "#44475D",
  active_ln     = "#fa8d1a",
  inactive_ln   = "#4d4242",
  string_fg     = "#E4A88A",
  type_fg       = "#E4B28E",
  tag_fg        = "#D55070",
  negative      = "#F43E5C",
  warning_ok    = "#27D797",
}

local overrides = {
  --------------------------------------------------------------------------
  -- CORE UI / TEXT
  --------------------------------------------------------------------------
  Normal        = { fg = P.gray, bg = P.bg },
  NormalNC      = { fg = P.gray, bg = P.bg },
  NormalFloat   = { fg = P.gray, bg = P.bg_alt },
  NormalSB      = { fg = P.active_ln, bg = P.bg_alt },

  Comment       = { fg = "#4C4D53", italic = true },
  CursorLine    = { bg = P.cursorline_bg },
  CursorLineNr  = { fg = P.active_ln, bold = true },
  LineNr        = { fg = P.inactive_ln },
  LineNrAbove   = { fg = P.inactive_ln },
  LineNrBelow   = { fg = P.inactive_ln },
  Visual        = { bg = P.visual_bg },
  VisualNOS     = { bg = P.visual_bg },
  MatchParen    = { fg = P.rosebud, bg = P.match_paren, bold = true },

  Search        = { fg = P.bg, bg = P.rosebud },
  IncSearch     = { fg = P.bg, bg = P.cranberry },

  -- push the syntax toward Horizon's reds/oranges/pinks
  String        = { fg = P.string_fg },
  Constant      = { fg = P.apricot },
  Type          = { fg = P.type_fg },
  Keyword       = { fg = P.lavender, italic = true },
  Identifier    = { fg = P.tag_fg },     -- pink identifiers/tags
  Function      = { fg = P.turquoise },  -- red-leaning funcs (less teal)
  Operator      = { fg = P.gray },
  Delimiter     = { fg = "#6C6D71" },
  
  ["@variable"]                = { fg = P.tag_fg },
  ["@lsp.type.variable"]       = { fg = P.tag_fg },
  ["@lsp.typemod.variable"]    = { fg = P.tag_fg },
  ["@variable.parameter"]      = { fg = P.tag_fg },
  ["@variable.member"]         = { fg = P.tag_fg },
  ["@property"]         = { fg = P.tag_fg },



  --------------------------------------------------------------------------
  -- DIAGNOSTICS
  --------------------------------------------------------------------------
  DiagnosticError            = { fg = P.negative },
  DiagnosticWarn             = { fg = P.rosebud },
  DiagnosticInfo             = { fg = P.cranberry },
  DiagnosticHint             = { fg = P.turquoise },

  DiagnosticUnderlineError   = { undercurl = true, sp = P.negative },
  DiagnosticUnderlineWarn    = { undercurl = true, sp = P.rosebud },
  DiagnosticUnderlineInfo    = { undercurl = true, sp = P.lavender },
  DiagnosticUnderlineHint    = { undercurl = true, sp = P.turquoise },

  DiagnosticVirtualTextError = { fg = P.negative, bg = "#4A2024" },
  DiagnosticVirtualTextWarn  = { fg = P.rosebud,  bg = "#3A2D21" },
  DiagnosticVirtualTextInfo  = { fg = P.lavender, bg = "#392636" },
  DiagnosticVirtualTextHint  = { fg = P.turquoise, bg = "#23383B" },

  --------------------------------------------------------------------------
  -- POPUPS / PMENU
  --------------------------------------------------------------------------
  FloatBorder   = { fg = P.bg_alt, bg = P.bg_alt },
  FloatTitle    = { fg = P.lavender, bg = P.bg_alt, bold = true },
  Pmenu         = { fg = P.gray, bg = P.bg_alt },
  PmenuSel      = { fg = P.cranberry, bg = P.accent },
  PmenuSbar     = { bg = "#242631" },
  PmenuThumb    = { bg = P.match_paren },

  --------------------------------------------------------------------------
  -- DASHBOARD / ALPHA
  --------------------------------------------------------------------------
  AlphaHeader   = { fg = P.tag_fg, bold = true },
  AlphaButtons  = { fg = P.tag_fg },
  AlphaFooter   = { fg = P.accentAlt, italic = true },
  AlphaShortcut = { fg = P.rosebud },

  --------------------------------------------------------------------------
  -- TELESCOPE
  --------------------------------------------------------------------------
  TelescopeNormal       = { fg = P.gray, bg = P.bg_alt },
  TelescopeBorder       = { fg = P.bg_alt, bg = P.bg_alt },
  TelescopePromptBorder = { fg = P.accent, bg = P.bg_alt },
  TelescopePromptTitle  = { fg = P.cranberry, bg = P.bg_alt, bold = true },
  TelescopeResultsComment = { fg = "#4C4D53" },
  TelescopeSelection    = { fg = P.lightText, bg = P.accent },
  TelescopeMatching     = { fg = P.cranberry, bold = true },

  --------------------------------------------------------------------------
  -- STATUS/TABS
  --------------------------------------------------------------------------
  StatusLine    = { fg = P.active_ln, bg = P.bg },
  StatusLineNC  = { fg = P.inactive_ln, bg = P.bg },
  TabLine       = { fg = P.accentAlt, bg = P.border },
  TabLineFill   = { bg = P.bg },
  TabLineSel    = { fg = P.lightText, bg = P.bg, bold = true },

  --------------------------------------------------------------------------
  -- MISC
  --------------------------------------------------------------------------
  Directory     = { fg = P.cranberry },
  Title         = { fg = P.tag_fg, bold = true },
  WarningMsg    = { fg = P.warning_ok },
  ErrorMsg      = { fg = P.negative, bold = true },
  Question      = { fg = P.lavender },
}

return overrides
