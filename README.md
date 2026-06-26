# fastfetchus

A KDE Plasma (Plasma 6) widget that renders `fastfetch` output inside QML.

## Installation

You can directly install this widget from plasma get new widgets app and use it directly like this

<img width="793" height="563" alt="image" src="https://github.com/user-attachments/assets/1a97c86b-ca8b-4f3f-bdcf-afee89f222ec" />

<img width="1161" height="533" alt="image" src="https://github.com/user-attachments/assets/6d2a72a8-d7b0-407f-ae15-cf65023a58d9" />

### Manual Installation from Source

If you prefer to install from source or the widget is not available in the Plasma store:

1. Ensure you have KDE Plasma 6 and the necessary development tools installed. You may need `kpackagetool6` (part of plasma-framework).

2. Clone or download this repository.

3. Navigate to the project directory.

4. Install the plasmoid package:

   ```
   kpackagetool6 --install package/ --type Plasma/Applet
   ```

5. Restart Plasma or log out and back in to see the new widget in the widget list.

To uninstall:

```
kpackagetool6 --remove com.temidaradev.fastfetchus
```

Note: This project is written in QML and does not require compilation. The installation process packages the QML files into a plasmoid.

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

The widget exposes settings via KConfigXT, grouped into **General** and **Appearance**:

General:

- Command to run (default `fastfetch --pipe false`)
- Refresh interval (ms)
- Font size (px)
- Keep refreshing while collapsed
- Allow selecting and copying output

Appearance:

- Use system theme colors, or pick custom foreground/background colors
- Transparent background toggle
- Background opacity

Config schema: `package/contents/config/main.xml`
Config UI: `package/contents/ui/configGeneral.qml`

## Notes / limitations

- This is a lightweight terminal emulation focused on fastfetch; it is not a full terminal.
- Extremely long outputs may be truncated visually because the widget intentionally disables scrolling.
