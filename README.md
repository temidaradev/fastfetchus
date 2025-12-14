# fastfetchus

A KDE Plasma (Plasma 6) widget that renders `fastfetch` output inside QML.

## How fastfetch output is rendered

`fastfetch` does not only print plain text:

- It prints **SGR** color/style sequences (e.g. `ESC[31m`).
- It also uses **cursor movement** sequences (e.g. `ESC[47C`, `ESC[1G`, `ESC[19A`) to place the right-hand “info” column next to the left-hand ASCII logo.

A QML `TextEdit` cannot interpret terminal control codes, so the widget implements a small ANSI interpreter in `package/contents/ui/main.qml` and converts the terminal stream into **Qt RichText**.

### Terminal model used

The widget builds an in-memory 2D grid of “cells”:

- Each cell stores: `ch` (character), `fg` (foreground color), `bg` (background color), `bold`.
- Normal printable characters write into the current cursor position and advance the cursor.
- Newlines/CR/tab update the cursor position.

After the stream is processed, each row is converted to HTML using `<pre>…</pre>` and runs of equal style are emitted as `<span style="…">…</span>`.

### Supported ANSI / CSI operations

The interpreter only implements what fastfetch uses for its default output:

Cursor movement (CSI):

- `ESC[nA` — cursor up `n`
- `ESC[nB` — cursor down `n`
- `ESC[nC` — cursor forward `n`
- `ESC[nD` — cursor back `n`
- `ESC[nG` — cursor horizontal absolute (1-based column)
- `ESC[row;colH` and `ESC[row;colf` — cursor position (1-based)
- `ESC[K` — erase-in-line (ignored)

Text attributes (SGR, CSI `m`):

- `0` reset
- `1` bold, `22` normal intensity
- `30–37`, `90–97` foreground (ANSI 16-color)
- `40–47`, `100–107` background (ANSI 16-color)
- `38;5;n` / `48;5;n` 256-color foreground/background
- `38;2;r;g;b` / `48;2;r;g;b` truecolor foreground/background
- `39` reset foreground, `49` reset background

Other handling:

- Tabs are expanded to 8-column tab stops.
- Other control characters are skipped.

### Color mapping

- ANSI 0–15 are mapped to an approximate standard palette.
- ANSI 16–231 are mapped as a 6×6×6 RGB cube.
- ANSI 232–255 are mapped as grayscale steps.

## Configuration

The widget exposes settings via KConfigXT:

- Refresh interval (ms)
- Font size (px)
- Use system colors or custom fg/bg colors
- Transparent background toggle
- Background opacity

Config schema: `package/contents/config/main.xml`
Config UI: `package/contents/ui/configGeneral.qml`

## Notes / limitations

- This is a lightweight terminal emulation focused on fastfetch; it is not a full terminal.
- Extremely long outputs may be truncated visually because the widget intentionally disables scrolling.
