# Mac's Simple Design
 Mac's Simple Design or MSD is a shared UI solution by other projects. More info soon
 
![logo](https://i.imgur.com/8xQJ45A.png)

## Created with love by our Team

Website: http://macnco.one/

MSD Documentation
===

**M**SD (MacNCo Simple Design) is the UI library shared by MacNCo addons such as MQS and MRS. It gives you ready-made menu elements, a layout list, drawing helpers, a config that is synced from the server, and a language system. This page covers the settings and every public function.

---

## Installation

1. Put the `msd_ui` folder in `garrysmod/addons/`.
1. Restart the server. The console prints `[MSD] Initialization done` when it has loaded.
1. Open the settings from the context menu (<kbd>C</kbd>) with the **Setup Menu** icon.

!! Only one copy of MSD can be loaded. If another addon ships a different version, the console prints `[MSD] Another version of MSD detacted` and the second copy is skipped.

---

## Settings

Settings are stored on the server in `data/msd_data/config.txt` and sent to every player. Only super admins can change them, using **Upload changes** in the settings menu. **Reset changes** restores the values the menu was opened with.

| Key                        | Type                  | Default            | Description |
| :------------------------- | :-------------------: | :----------------- | :---------- |
| `MSD.Config.Language`      | string                | `"en"`             | Language id, a file name from `lua/msd/language/` |
| `MSD.Config.Rounded`       | number                | `8`                | Corner radius in px. `0` is square, the slider goes from 4 to 20 |
| `MSD.Config.Blur`          | boolean               | `false`            | Blurred menu background instead of a solid color |
| `MSD.Config.Vignette`      | boolean               | `false`            | Vignette flag, read by modules that support it |
| `MSD.Config.BgrColor`      | Color                 | `45, 45, 45`       | Menu background color |
| `MSD.Config.ThemeColor`    | Color                 | `0, 5, 10`         | Tint of the translucent panels (`MSD.Theme` d, m, l) |
| `MSD.Config.MSDX`          | boolean               | `true`             | `true` draws with the MSDX shaders, `false` with stock `draw.RoundedBox` |
| `MSD.Config.UISounds`      | boolean               | `true`             | Click, enter and toggle sounds |
| `MSD.Config.SoundsVolume`  | number                | `0.3`              | UI sound volume, from 0 to 1 |
| `MSD.Config.MainColor`     | table                 | see below          | `p` main color, `r` red, `rd` dark red (errors) |
| `MSD.Config.HUD`           | table                 |                    | HUD settings used by modules that draw a HUD |

!!! Shadows, `MSD.DrawBlur` and `MSD.DrawBlurCircle` are shader only. With MSDX off they draw nothing. Use `MSD.Blur` or `MSD.BlurPanel` when the blur is needed in both modes.

---

## Theme colors

These tables are read every frame, so they can be used directly in `Paint` functions.

| Table                | Keys                        | Use |
| :------------------- | :-------------------------- | :-- |
| `MSD.Theme`          | `d`, `m`, `l`, `d_na`       | Dark, medium and light translucent panels; `d_na` is the opaque menu color |
| `MSD.Text`           | `a`, `n`, `d`, `s`, `m`, `l` | Text colors from dimmed (`n`) to white (`l`) |
| `MSD.Config.MainColor` | `p`, `r`, `rd`            | Main color and error reds |
| `MSD.Clr`            | `red`, `red_dark`, `green`, `blue_dark` | Fixed status colors |
| `MSD.ColorPresets`   | 1 - 8                       | Swatches shown in the color picker |

Use `MSD.MainShade` to get lighter or darker versions of the main color instead of hard-coding them.

---

## Layout

Most element functions take `parent, x, y, w, h` and work in two modes.

* **List mode**: `x = "static"`, `y = nil`. The element is added to an `MSDPanelList` and sized by the list.
    * `w` is a divider of the list width: `1` full width, `2` half, `3` a third, and so on.
    * `w` as a string takes the rest of the row: `"3"` is the width minus a third.
    * `h` is a fixed height in px.
* **Free mode**: `x` and `y` are numbers. The element is placed in `parent` at that position with the size `w` x `h`.

```lua
local list = vgui.Create("MSDPanelList", frame)
list:SetSize(400, 300)
list:EnableVerticalScrollbar()
list:EnableHorizontal(true)
list:SetSpacing(2)

MSD.Header(list, "Settings")
MSD.Button(list, "static", nil, 2, 50, "Left", function() end)
MSD.Button(list, "static", nil, 2, 50, "Right", function() end)
MSD.Button(frame, 10, 320, 200, 40, "Free placed", function() end)
```

Custom panels can use the same system by setting `panel.StaticScale = { w = 1, fixed_h = 50, minw = 50, minh = 50 }` before `list:AddItem(panel)`.

---

## Languages

Languages live in `lua/msd/language/<id>.lua` and are loaded automatically. A missing phrase falls back to English, and a missing English phrase returns the key itself.

```lua
-- lua/msd/language/pl.lua
MSD.Language["pl"] = {
	lang_name = "Polski",
	ok = "OK",
	time_sec = "%s sek.",
}
```

Addons can add their own phrases to an existing language:

```lua
MSD.Language["en"]["my_addon_title"] = "My addon"
```

---

## Modules

Addons add a tab to the MSD setup menu with `MSD.AddModule`.

```lua
MSD.AddModule("My addon", function(canvas, menu)
	local list = vgui.Create("MSDPanelList", canvas)
	list:SetSize(canvas:GetWide(), canvas:GetTall())
	list:EnableVerticalScrollbar()
	list:EnableHorizontal(true)

	MSD.Header(list, "My addon settings")
end, MSD.Icons48.cog)
```

---

## Core

#### MSD.AddModule

**Shared** MSD.AddModule( **[string][string]** name, **[function][function]** menu, **[IMaterial][IMaterial]** icon )

**Description**

Adds or replaces a tab in the MSD setup menu.

**Arguments**

1. **[string][string] name |** Tab name, also the module id
1. **[function][function] menu |** Builds the tab: `function(canvas, mainPanel)`
1. **[IMaterial][IMaterial] icon |** Tab icon

**Returns**

1. **[number][number] |** Module id

---

#### MSD.OpenMenuManager

**Client** MSD.OpenMenuManager( **[Panel][Panel]** parent, **[number][number]** module )

**Description**

Opens the MSD setup menu. Does nothing for players without `MSD.AdminAccess`.

**Arguments**

1. **[Panel][Panel] parent |** Optional parent, for example `g_ContextMenu`
1. **[number][number] module |** Optional module id to open first

**Returns**

1. **[Panel][Panel] |** The menu frame

---

#### MSD.AdminAccess

**Client** MSD.AdminAccess( **[Player][Player]** ply )

**Description**

Checks if a player can open the setup menu. Uses MQS editors or MRS administrators when those addons are installed, otherwise super admins.

**Returns**

1. **[boolean][boolean] |** Has access

---

#### MSD.SaveConfig

**Shared** MSD.SaveConfig()

**Description**

On the client, sends `MSD.Config` to the server (super admins only). On the server, saves the config to `data/msd_data/config.txt` and sends it to all players.

---

#### MSD.GetPhrase

**Shared** MSD.GetPhrase( **[string][string]** key, **[any][any]** ... )

**Description**

Returns a phrase in the selected language. Extra arguments are passed to `string.format`.

**Returns**

1. **[string][string] |** The phrase, or the key when it is missing

**Example**

```lua
local Ln = MSD.GetPhrase
print(Ln("time_sec", 30)) -- "30 sec."
```

---

#### MSD.GetAvatar

**Shared** MSD.GetAvatar( **[string][string]** steamid64 )

**Description**

Returns the Steam avatar image url of a player. The first call starts the request and returns an empty string until the url is loaded.

**Returns**

1. **[string][string] |** Avatar url or `""`

---

#### MSD:Icon

**Client** MSD:Icon( **[string][string]** name )

**Description**

Returns an icon from `MSD.Icons48` by name, or a fallback material when the icon is missing. All icons can be copied from the **MSD Icons 48** list in the settings menu.

**Returns**

1. **[IMaterial][IMaterial] |** Icon material

---

#### string.subUTF8

**Shared** string.subUTF8( **[string][string]** text, **[number][number]** start, **[number][number]** end )

**Description**

`string.sub` that counts UTF-8 characters instead of bytes, so Cyrillic and other non-Latin text is not cut in half. Negative indexes count from the end.

**Returns**

1. **[string][string] |** Part of the text

---

## Colors

#### MSD.ColorAlpha

**Client** MSD.ColorAlpha( **[Color][Color]** color, **[number][number]** alpha )

**Description**

Returns a copy of the color with a new alpha.

---

#### MSD.CrossColor

**Client** MSD.CrossColor( **[number][number]** t, **[Color][Color]** from, **[Color][Color]** to )

**Description**

Blends two colors by `t` (0 - 1). Use it for hover animations instead of drawing twice with opposite alphas. Returns the input color itself when `t` is 0 or 1.

**Example**

```lua
self.alpha = Lerp(FrameTime() * 5, self.alpha, self:IsHovered() and 1 or 0)
draw.DrawText("Hello", "MSDFont.22", 5, 5, MSD.CrossColor(self.alpha, MSD.Text.s, MSD.Config.MainColor.p))
```

---

#### MSD.ColorShade

**Client** MSD.ColorShade( **[Color][Color]** color, **[number][number]** level )

**Description**

Returns a lighter or darker version of a color. Results are cached.

**Arguments**

1. **[Color][Color] color |** Base color
1. **[number][number] level |** `5` the color itself, `4` - `1` lighter, `6` - `9` darker

**Returns**

1. **[Color][Color] |** Shaded color

---

#### MSD.MainShade

**Client** MSD.MainShade( **[number][number]** level )

**Description**

`MSD.ColorShade` of the main color (`MSD.Config.MainColor.p`).

**Example**

```lua
MSDX.Draw(0, 0, h - 5, w, 5, MSD.MainShade(8))      -- dark track
MSDX.Draw(0, 0, h - 5, w * progress, 5, MSD.MainShade(5)) -- main color fill
```

---

#### MSD.ApplyTheme

**Client** MSD.ApplyTheme()

**Description**

Rebuilds `MSD.Theme` d, m and l from `MSD.Config.ThemeColor`. Called automatically when the config is received and when the panel color is changed.

---

## Drawing

#### MSD.UseMSDX

**Client** MSD.UseMSDX()

**Description**

Checks if the MSDX shaders are used: the MSDX setting is on and the game runs on DirectX 9 or newer.

**Returns**

1. **[boolean][boolean] |** Shaders are used

---

#### MSDX.Draw

**Client** MSDX.Draw( **[number][number]** radius, **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[Color][Color]** color, **[number][number]** flags )

**Description**

Draws a rounded box. Replaces `draw.RoundedBox` and follows the MSDX setting. Sizes of 0 or less draw nothing.

**Arguments**

1. **[number][number] radius |** Corner radius, usually `MSD.Config.Rounded`
1. **[number][number] x, y, w, h |** Box position and size
1. **[Color][Color] color |** Box color
1. **[number][number] flags |** Optional corner flags: `MSDX.NO_TL`, `MSDX.NO_TR`, `MSDX.NO_BL`, `MSDX.NO_BR`

**Example**

```lua
-- only the top corners are rounded
MSDX.Draw(8, 0, 0, w, 40, MSD.Theme.d, MSDX.NO_BL + MSDX.NO_BR)
```

---

#### MSDX.DrawOutlined

**Client** MSDX.DrawOutlined( **[number][number]** radius, **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[Color][Color]** color, **[number][number]** thickness, **[number][number]** flags )

**Description**

Draws a box outline. Without MSDX the outline is square.

---

#### MSDX.DrawCircle

**Client** MSDX.DrawCircle( **[number][number]** x, **[number][number]** y, **[number][number]** diameter, **[Color][Color]** color )

**Description**

Draws a filled circle centred on `x, y`.

---

#### MSD.DrawArc

**Client** MSD.DrawArc( **[number][number]** x, **[number][number]** y, **[number][number]** diameter, **[number][number]** from, **[number][number]** to, **[Color][Color]** color, **[number][number]** thickness )

**Description**

Draws an arc on the edge of a circle centred on `x, y`, `thickness` px wide inwards. Angles are in degrees, `0` is right and they go clockwise. Works with MSDX on and off.

**Example**

```lua
-- progress ring
MSD.DrawArc(w / 2, h / 2, 64, 0, 360 * progress, MSD.Config.MainColor.p, 4)
```

---

#### MSD.CornerFlags

**Client** MSD.CornerFlags( **[boolean][boolean]** tl, **[boolean][boolean]** tr, **[boolean][boolean]** bl, **[boolean][boolean]** br )

**Description**

Turns `draw.RoundedBoxEx` corner booleans into MSDX flags.

**Returns**

1. **[number][number] |** Flags for `MSDX.Draw`

---

#### MSD.DrawBG

**Client** MSD.DrawBG( **[Panel][Panel]** panel, **[number][number]** w, **[number][number]** h )

**Description**

Draws the menu background from the settings: blur or the background color.

---

#### MSD.DrawTexturedRect

**Client** MSD.DrawTexturedRect( **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[IMaterial][IMaterial]** material, **[Color][Color]** color )

**Description**

Draws a material. `material` can also be a path string; the material is created once and cached. A missing material is skipped.

---

#### MSD.DrawTexturedRectRotated

**Client** MSD.DrawTexturedRectRotated( **[number][number]** rotation, **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[IMaterial][IMaterial]** material, **[Color][Color]** color )

**Description**

Draws a rotated material centred on `x, y`. `MSD.DrawTexturedRectOfRot` takes the same arguments with `x, y` as the top left corner.

---

#### MSD.DrawTexturedOutlined

**Client** MSD.DrawTexturedOutlined( **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[IMaterial][IMaterial]** material, **[Color][Color]** color, **[number][number]** outline, **[Color][Color]** outlineColor )

**Description**

Draws a material with an outline around it.

---

#### MSD.ShadowText

**Client** MSD.ShadowText( **[string][string]** text, **[string][string]** font, **[number][number]** x, **[number][number]** y, **[Color][Color]** color, **[number][number]** align, **[number][number]** offset, **[Color][Color]** shadowColor )

**Description**

Draws text with a drop shadow. `offset` defaults to 1 px and `shadowColor` to black.

---

#### MSD.DrawKey

**Client** MSD.DrawKey( **[number][number]** x, **[number][number]** y, **[string][string]** key, **[number][number]** alpha )

**Description**

Draws a keyboard key hint, for example `E`. `MSD.DrawKeyIcon(x, y, material, size, alpha)` draws the same hint with an icon.

**Returns**

1. **[number][number] |** Width of the hint, to place the next element

---

## Blur

#### MSD.Blur

**Client** MSD.Blur( **[Panel][Panel]** panel, **[number][number]** passes, **[number][number]** density, **[number][number]** alpha, **[number][number]** darken, **[number][number]** w, **[number][number]** h )

**Description**

Blurs the screen behind a panel and darkens it. Works with MSDX on and off. The blur strength is `(3 / passes) * density`.

**Arguments**

1. **[Panel][Panel] panel |** Panel being painted
1. **[number][number] passes, density |** Blur strength
1. **[number][number] alpha |** Blur opacity, 255 is full blur
1. **[number][number] darken |** Alpha of the black layer drawn on top
1. **[number][number] w, h |** Area size, usually the panel size

**Example**

```lua
panel.Paint = function(self, w, h)
	MSD.Blur(self, 1, 3, 255, 50, w, h)
end
```

---

#### MSD.BlurPanel

**Client** MSD.BlurPanel( **[Panel][Panel]** panel, **[number][number]** strength, **[number][number]** w, **[number][number]** h, **[number][number]** alpha )

**Description**

Blurs the area behind a panel, or the whole screen behind it when `w` and `h` are not given. Works with MSDX on and off.

---

#### MSD.DrawBlur

**Client** MSD.DrawBlur( **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[number][number]** strength, **[number][number]** radius, **[number][number]** alpha )

**Description**

Blurs a rounded rectangle. MSDX only. `MSD.DrawBlurCircle(x, y, diameter, strength, alpha)` blurs a circle.

---

## Text and time

#### MSD.TextWrap

**Client** MSD.TextWrap( **[string][string]** text, **[string][string]** font, **[number][number]** width )

**Description**

Adds line breaks so the text fits the width. Long words are split.

**Returns**

1. **[string][string] |** Wrapped text
1. **[number][number] |** Width of the last line
1. **[number][number] |** Total text height

---

#### MSD.NiceTime

**Client** MSD.NiceTime( **[number][number]** seconds )

**Description**

Returns a short duration in the selected language, for example `45 sec.`, `2 h. 15 min.` or `3 d.`.

**Example**

```lua
print(MSD.NiceTime(8100)) -- "2 h. 15 min."
```

---

## Sound

#### MSD.UISnd

**Client** MSD.UISnd( **[string][string]** sound )

**Description**

Plays a UI sound at the volume from the settings. Does nothing when UI sounds are off. MSD elements already call it on click.

**Example**

```lua
MSD.UISnd("msd/ui/click.wav") -- also enter.wav, error.wav, return.wav, toggle.wav
```

---

#### MSD.PlaySnd

**Client** MSD.PlaySnd( **[string][string]** sound, **[number][number]** volume )

**Description**

Plays a sound file from `sound/`, ignoring the UI sound settings.

---

## Utility

#### MSD.Anim

**Client** MSD.Anim( **[number][number]** time, **[string][string]** ease )

**Description**

Creates a simple animation object. Call `anim:Start()` once and `anim:Play()` every frame, then read `anim.Value`. `ease` is a `math.ease` function name.

**Example**

```lua
local anim = MSD.Anim(0.3, "OutQuad")
anim:Start()

panel.Paint = function(self, w, h)
	anim:Play()
	MSDX.Draw(8, 0, 0, w * anim.Value, h, MSD.Config.MainColor.p)
end
```

---

#### MSD.ImgLib.GetMaterial

**Client** MSD.ImgLib.GetMaterial( **[string][string]** url, **[boolean][boolean]** jpg )

**Description**

Downloads an image from a url, caches it in `data/msd_imgs/` and returns it as a material. Returns `MSD.ImgLib.NoMaterial` until the download is done.

---

## Elements

Element functions return the created panel. See **Layout** above for `parent, x, y, w, h`. Callbacks receive the element as the first argument.

#### MSD.Header

**Client** MSD.Header( **[Panel][Panel]** list, **[string][string]** text, **[function][function]** back, **[IMaterial][IMaterial]** icon, **[boolean][boolean]** alignLeft, **[function][function]** paint )

**Description**

Full width 50 px title bar for an `MSDPanelList`. When `back` is set, a back button is drawn on the left with `icon` (default arrow). `paint(self, w, h)` draws extra content.

---

#### MSD.InfoHeader

**Client** MSD.InfoHeader( **[Panel][Panel]** list, **[string][string]** text, **[number][number]** w )

**Description**

Small 25 px section title.

---

#### MSD.InfoText

**Client** MSD.InfoText( **[Panel][Panel]** list, **[string][string]** text, **[string][string]** font )

**Description**

Wrapped text block that grows to fit its text.

---

#### MSD.InfoTextIcon

**Client** MSD.InfoTextIcon( **[Panel][Panel]** list, **[string][string]** title, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[Color][Color]** iconColor )

**Description**

Text block with a 64 px icon and a title in the main color. Also available: `MSD.InfoTextF1(list, text, wide, font)` for plain help text, and `MSD.InfoTextButton(list, text, wide, func, font)` for clickable text.

---

#### MSD.PanelIcon

**Client** MSD.PanelIcon( **[Panel][Panel]** list, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[function][function]** paint )

**Description**

50 px info row with an icon. `paint(self, w, h)` is called every frame to draw extra content.

---

#### MSD.Button

**Client** MSD.Button( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[function][function]** func, **[boolean][boolean]** alignLeft )

**Description**

Standard button with an underline that turns to the main color on hover. Set `button.disabled = true` to disable it, `button.bg` to change its background.

**Example**

```lua
MSD.Button(list, "static", nil, 1, 50, MSD.GetPhrase("ok"), function(self)
	print("clicked")
end)
```

---

#### MSD.ButtonIcon

**Client** MSD.ButtonIcon( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[function][function]** func, **[function][function]** rightClick, **[Color][Color]** color, **[Color][Color]** hoverColor, **[function][function]** paint )

**Description**

Button with an icon on the left. Without `func` it is a static row. `paint(self, w, h)` draws extra content behind the text.

---

#### MSD.ButtonIconText

**Client** MSD.ButtonIconText( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[string][string]** rightText, **[IMaterial][IMaterial]** icon, **[function][function]** func, **[function][function]** rightClick, **[Color][Color]** color )

**Description**

`MSD.ButtonIcon` with a second text aligned to the right, for example a value or price. Set `button.text` to change it.

---

#### MSD.ButtonSimple

**Client** MSD.ButtonSimple( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[number][number]** fontSize, **[function][function]** func )

**Description**

Text-only button. Set `button.Check = function() return true end` to draw it as selected.

---

#### MSD.ButtonScr

**Client** MSD.ButtonScr( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[function][function]** func, **[boolean][boolean]** alignLeft, **[string][string]** workshopId )

**Description**

Square tile button with a centred title. With `workshopId` the addon preview image is downloaded and used as the background.

---

#### MSD.BigButton

**Client** MSD.BigButton( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[function][function]** func, **[Color][Color]** hoverColor, **[string][string]** id, **[function][function]** rightClick, **[string][string]** bottomText, **[function][function]** paint )

**Description**

Large tile with a 48 px icon and a title. `id` is shown in the top left corner, `bottomText` at the bottom. Set `button.disable = true` to disable it. `MSD.BigButtonClean` is the same tile without a background.

---

#### MSD.BigModelButton

**Client** MSD.BigModelButton( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[function][function]** func, **[string][string]** text2, **[boolean][boolean]** centerText, **[Color][Color]** hoverColor, **[function][function]** rightClick )

**Description**

`MSD.BigButton` that can show a model. Call `panel.SetCustomModel(model)` to replace the icon with the model.

---

#### MSD.IconButton

**Client** MSD.IconButton( **[Panel][Panel]** parent, **[IMaterial][IMaterial]** icon, **[any][any]** x, **[number][number]** y, **[number][number]** size, **[Color][Color]** color, **[Color][Color]** hoverColor, **[function][function]** func, **[function][function]** paint )

**Description**

Square icon button. Change `button.mat` to swap the icon. `paint(self, w, h)` draws a background.

**Example**

```lua
local close = MSD.IconButton(frame, MSD.Icons48.cross, frame:GetWide() - 34, 10, 25, nil, MSD.Config.MainColor.p, function()
	frame:Close()
end)
```

---

#### MSD.IconButtonText

**Client** MSD.IconButtonText( **[Panel][Panel]** parent, **[string][string]** text, **[IMaterial][IMaterial]** icon, **[any][any]** x, **[number][number]** y, **[number][number]** size, **[Color][Color]** color, **[Color][Color]** hoverColor, **[function][function]** func )

**Description**

Icon button with wrapped text under the icon, like a file in a file browser.

---

#### MSD.IconButtonBG

**Client** MSD.IconButtonBG( **[Panel][Panel]** parent, **[IMaterial][IMaterial]** icon, **[number][number]** x, **[number][number]** y, **[number][number]** size, **[Color][Color]** color, **[Color][Color]** hoverColor, **[function][function]** func )

**Description**

Icon button on a dark background that fills with the main color on hover.

---

#### MSD.CloseButtonIcon

**Client** MSD.CloseButtonIcon( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[function][function]** func, **[IMaterial][IMaterial]** icon )

**Description**

Text with a close icon on the right that turns red on hover.

---

#### MSD.MenuButton

**Client** MSD.MenuButton( **[Panel][Panel]** parent, **[IMaterial][IMaterial]** icon, **[number][number]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[function][function]** func, **[function][function]** rightClick, **[boolean][boolean]** smallIcon )

**Description**

Side menu button. Set `button.hovered = true` to mark it as selected. `MSD.MenuButtonTop` is the top bar version; pass `"auto"` as `w` to size it to its text.

---

#### MSD.TextEntry

**Client** MSD.TextEntry( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** placeholder, **[string][string]** label, **[string][string]** value, **[function][function]** func, **[boolean][boolean]** onType, **[boolean][boolean]** onFocusLost, **[boolean][boolean]** multiline, **[boolean][boolean]** numeric )

**Description**

Text field. `func(self, value)` runs on <kbd>Enter</kbd>, on every change when `onType` is set, and when the field loses focus when `onFocusLost` is set. Set `entry.error = "text"` to show a red error in place of the label.

**Example**

```lua
MSD.TextEntry(list, "static", nil, 1, 50, "Type a name...", "Name:", "", function(self, value)
	print(value)
end, true)
```

---

#### MSD.NumberWang

**Client** MSD.NumberWang( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[number][number]** min, **[number][number]** max, **[number][number]** value, **[string][string]** label, **[function][function]** func )

**Description**

Number field with a min and max. `func(self)` runs when the value changes.

---

#### MSD.VectorDisplay

**Client** MSD.VectorDisplay( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** label, **[Vector][Vector]** vector, **[function][function]** func )

**Description**

Shows a vector and opens x, y, z fields on click. `func(vector, self)` runs on change. `MSD.AngleDisplay` does the same for an Angle.

---

#### MSD.VectorSelectorList

**Client** MSD.VectorSelectorList( **[Panel][Panel]** list, **[string][string]** label, **[Vector][Vector]** vector, **[boolean][boolean]** showAngle, **[Angle][Angle]** angle, **[string][string]** angleLabel, **[boolean][boolean]** copyButtons, **[function][function]** func )

**Description**

Position picker for an `MSDPanelList`: a vector field, an optional angle field, and buttons to copy your position, aim position or the aimed entity. `func(vector, angle)` runs on change.

---

#### MSD.Binder

**Client** MSD.Binder( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[number][number]** key, **[function][function]** func )

**Description**

Key binder. `func(key)` receives the new `KEY_` enum. Mouse buttons are not accepted.

---

#### MSD.BoolSlider

**Client** MSD.BoolSlider( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[boolean][boolean]** value, **[function][function]** func )

**Description**

On / off switch. `func(self, value)` runs on toggle. Set `switch.disabled = true` to lock it.

---

#### MSD.DTextSlider

**Client** MSD.DTextSlider( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** textOn, **[string][string]** textOff, **[boolean][boolean]** value, **[function][function]** func )

**Description**

Switch between two options. The label shows `textOn` or `textOff` for the current state.

**Example**

```lua
MSD.DTextSlider(list, "static", nil, 1, 50, "Rounded", "Square", MSD.Config.Rounded > 0, function(self, value)
	MSD.Config.Rounded = value and 8 or 0
end)
```

---

#### MSD.VolumeSlider

**Client** MSD.VolumeSlider( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[number][number]** value, **[function][function]** func, **[Color][Color]** color, **[function][function]** format )

**Description**

Click slider from 0 to 1. `func(self, value)` runs on change. `format(value)` returns the value label; the default is a percentage. `MSD.VolumeScale` takes the same arguments and goes from 0 to 2.

**Example**

```lua
MSD.VolumeSlider(list, "static", nil, 1, 50, "Radius", 0.25, function(self, value)
	MSD.Config.Rounded = math.Round(4 + value * 16)
end, nil, function(value)
	return math.Round(4 + value * 16) .. " px"
end)
```

---

#### MSD.ComboBox

**Client** MSD.ComboBox( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** label, **[string][string]** value )

**Description**

Dropdown in MSD style. Use the standard `DComboBox` functions: `AddChoice`, `SetValue` and `OnSelect`.

**Example**

```lua
local combo = MSD.ComboBox(list, "static", nil, 1, 50, "Language:", MSD.GetPhrase("lang_name"))

for id, lang in pairs(MSD.Language) do
	combo:AddChoice(lang.lang_name, id)
end

combo.OnSelect = function(self, index, text, id)
	MSD.Config.Language = id
end
```

---

#### MSD.ColorSelector

**Client** MSD.ColorSelector( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** text, **[Color][Color]** color, **[function][function]** func, **[boolean][boolean]** alpha )

**Description**

Row with a color swatch that opens a color picker with RGB fields and presets. `func(self, color)` runs on every change. `alpha` adds an alpha bar. `MSD.ColorSelectBut(parent, x, y, w, h, color, func)` is a single swatch button.

---

#### MSD.NPCModelFrame

**Client** MSD.NPCModelFrame( **[Panel][Panel]** parent, **[any][any]** x, **[number][number]** y, **[number][number]** w, **[number][number]** h, **[string][string]** model, **[number][number]** sequence )

**Description**

Model preview that can be rotated with the mouse and zoomed with the mouse wheel.

---

#### MSD.DropIcon

**Client** MSD.DropIcon( **[Panel][Panel]** list, **[IMaterial][IMaterial]** material, **[number][number]** size, **[Color][Color]** outline, **[function][function]** func )

**Description**

Square image tile with a colored outline, for item or reward lists.

---

#### MSD.WorkSpacePanel

**Client** MSD.WorkSpacePanel( **[Panel][Panel]** parent, **[string][string]** title, **[number][number]** w, **[number][number]** h, **[boolean][boolean]** noFade, **[boolean][boolean]** opaque )

**Description**

Blurred overlay over the work space of an `MSDSimpleFrame`, with a centred window and a title. `w` and `h` are dividers of the frame size (default `1.1` and `1.3`); the window width stays between 500 and 900 px. Call `panel.Close()` to fade it out.

**Returns**

1. **[Panel][Panel] |** The overlay
1. **[Panel][Panel] |** The window, put your content here

---

## Popups

The popups fill the screen when `parent` is `nil`, or the work space of an `MSDSimpleFrame` when a frame is given.

#### MSD.AskPopup

**Client** MSD.AskPopup( **[Panel][Panel]** parent, **[string][string]** title, **[boolean][boolean]** noClose, **[table][table]** button1, **[table][table]** button2 )

**Description**

Question popup with up to two buttons. Each button is `{ text, function(button) end }`. `noClose` hides the close icon.

**Example**

```lua
MSD.AskPopup(nil, "Delete this quest?", false,
	{"Delete", function() print("deleted") end},
	{"Cancel", function() end}
)
```

---

#### MSD.AskPopupEntr

**Client** MSD.AskPopupEntr( **[Panel][Panel]** parent, **[string][string]** title, **[boolean][boolean]** noClose, **[table][table]** entry )

**Description**

Popup with a text field. `entry` is `{ placeholder, function(textEntry) end }`; the function runs on <kbd>Enter</kbd>.

**Returns**

1. **[Panel][Panel] |** Popup
1. **[Panel][Panel] |** Popup window
1. **[Panel][Panel] |** Text field

---

#### MSD.AskPopupCombo

**Client** MSD.AskPopupCombo( **[Panel][Panel]** parent, **[string][string]** title, **[boolean][boolean]** noClose, **[table][table]** combo )

**Description**

Popup with a dropdown and a confirm button. `combo` is `{ placeholder, buttonText, function(button) end }`. Store the selected value on the button in `OnSelect`.

**Returns**

1. **[Panel][Panel] |** Dropdown
1. **[Panel][Panel] |** Confirm button
1. **[Panel][Panel] |** Popup
1. **[Panel][Panel] |** Popup window

---

#### MSD.AskConfirmPopup

**Client** MSD.AskConfirmPopup( **[Panel][Panel]** parent, **[string][string]** question, **[string][string]** acceptText, **[string][string]** cancelText, **[function][function]** accept )

**Description**

Confirmation popup. The accept button has to be held for 2 seconds, which prevents accidental clicks.

---

## Menus

#### MSD.MenuOpen

**Client** MSD.MenuOpen( **[Panel][Panel]** parentMenu, **[Panel][Panel]** parent, **[boolean][boolean]** solid )

**Description**

Creates a right-click menu in MSD style. Add options with `menu:AddOption(text, func, icon, check)`; the option is skipped when `check()` returns false. `menu:AddSubMenu(text, func, icon)` adds a sub menu.

**Example**

```lua
local menu = MSD.MenuOpen(false, button)
menu:AddOption("Edit", function() end, MSD.Icons48.pencil)
menu:AddOption("Remove", function() end, MSD.Icons48.cross)
menu:Open()
```

---

## Panels

| Panel              | Base           | Description |
| :----------------- | :------------- | :---------- |
| `MSDSimpleFrame`   | EditablePanel  | Draggable frame. `frame:AddToWorkSpace(panel)` fits a panel into its work area |
| `MSDPanelList`     | DPanel         | Scrolling list with the `StaticScale` layout. `EnableHorizontal`, `EnableVerticalScrollbar`, `SetSpacing`, `SetPadding`, `AddItem`, `Clear` |
| `MSDModelPanel`    | DButton        | Model panel with mouse rotation |
| `MSD.DMenu`        | DMenu          | Menu created by `MSD.MenuOpen` |
| `MSD.RadialMenu`   | EditablePanel  | Radial menu, see below |
| `MSDProgressBar`   | Panel          | Progress bar, see below |

`MSDPanelList` options: set `list.IgnoreVbar = true` to keep the scrollbar out of the layout, and `list.HideVbar = true` to hide it.

#### MSD.RadialMenu

**Client** vgui.Create( "MSD.RadialMenu" )

**Description**

Radial menu around the screen centre. Fill `panel.actions` with `{ name, func, icon, check }` and call `panel:Build()`. Left click runs the hovered action. The mouse is kept near the centre while the menu is open.

**Example**

```lua
local radial = vgui.Create("MSD.RadialMenu")
radial:SetSize(400, 400)
radial:Center()
radial:MakePopup()

radial.actions = {
	{"Wave", function() RunConsoleCommand("act", "wave") radial:Remove() end, MSD.Icons48.hand_right},
	{"Close", function() radial:Remove() end, MSD.Icons48.cross},
}

radial:Build()
```

---

#### MSDProgressBar

**Client** vgui.Create( "MSDProgressBar" )

**Description**

Progress bar with `SetMin`, `SetMax` and `SetValue`. `SetAnimated(true)` eases the bar to the new value, `SetColor(color)` changes the bar color (default main color).

---

## Console commands

| Command        | Realm  | Description |
| :------------- | :----: | :---------- |
| `soundviewer`  | Client | Sound browser for the game, mounted games and addons. Click a file to play it and copy its path |

[string]: https://wiki.facepunch.com/gmod/string
[number]: https://wiki.facepunch.com/gmod/number
[boolean]: https://wiki.facepunch.com/gmod/boolean
[function]: https://wiki.facepunch.com/gmod/function
[table]: https://wiki.facepunch.com/gmod/table
[any]: https://wiki.facepunch.com/gmod/any
[Color]: https://wiki.facepunch.com/gmod/Color
[IMaterial]: https://wiki.facepunch.com/gmod/IMaterial
[Panel]: https://wiki.facepunch.com/gmod/Panel
[Player]: https://wiki.facepunch.com/gmod/Player
[Vector]: https://wiki.facepunch.com/gmod/Vector
[Angle]: https://wiki.facepunch.com/gmod/Angle
