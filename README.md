# ReactiVisuals

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Processing sketch plus Arduino firmware for a **TUIO tabletop** experience: fiducials drive a shared particle system while **serial** data from an Arduino toggles colors and a “poti” channel used for particle size. A **browser build** in [`web/`](web/) (p5.js + TypeScript + Vite) is suitable for static hosting, with mock TUIO, optional WebSocket JSON, and Web Serial.

## Repository layout

| Path | Role |
|------|------|
| `tuif_P/` | Processing 3 sketch (main file `tuif_P.pde`, particle classes in extra tabs) |
| `tuif_A/` | Arduino sketch: buttons, encoder-as-poti, LEDs, serial protocol |
| `web/` | p5.js + TypeScript (Vite) browser build; see [`web/README.md`](web/README.md) |
| [`netlify.toml`](netlify.toml) | Netlify: `base = web`, publish `web/dist` |

## Web

From `web/`: `npm install`, `npm run dev` for local preview; `npm run build` emits static assets to `web/dist/` for deployment. **Netlify:** [`netlify.toml`](netlify.toml) at the repo root builds from `web/` and publishes `web/dist`. See [`web/README.md`](web/README.md) for TUIO bridge JSON and hosting notes.

## Requirements

### Processing (`tuif_P`)

- [Processing 3 or 4](https://processing.org/download)
- **TUIO client library (manual install):** this library is **not** in the Contributions Manager, so “Add Library…” will not find a package named `TUIO`. Install it by hand:
  1. Download the library archive, e.g. **[TUIO_Processing-1.1.5.zip](http://prdownloads.sourceforge.net/reactivision/TUIO_Processing-1.1.5.zip?download)** (linked from [TUIO.org — Processing](https://www.tuio.org/?processing=)) or clone **[mkalten/TUIO11_Processing](https://github.com/mkalten/TUIO11_Processing)** and use the packaged release if you prefer GitHub.
  2. Unzip it. You should get a folder named **`TUIO`** (containing `library` and the `.jar` files, same layout as other Processing libraries). If the zip adds an extra wrapper folder (e.g. `TUIO_Processing-1.1.5`), open it and move the **inner** `TUIO` folder into `libraries`, not the whole zip root.
  3. Move that **`TUIO`** folder into your **sketchbook `libraries` directory**: Processing → **File → Preferences** → note **Sketchbook location** → open that folder → open **`libraries`** (create `libraries` if it does not exist) → put **`TUIO`** here so the path is like `…/libraries/TUIO/library/...`.
  4. **Quit Processing completely** and reopen the sketch (required so the classpath picks up the new library).
- Assets in `tuif_P/`: `triangle_white.png`, `triangle_red.png`, `triangle_green.png`, `triangle_yellow.png`

### Arduino (`tuif_A`)

- [Bounce2](https://www.arduino.cc/reference/en/libraries/bounce2/)
- [Encoder](https://www.arduino.cc/reference/en/libraries/encoder/) (Paul Stoffregen)

Install both from the Arduino Library Manager.

## Serial protocol

The Arduino sends one line per update (via `Serial.println`), for example `S100E` then newline. Payload format:

- `S` + one digit **button 1** + one digit **button 2** + one digit **poti** + `E` → **five** payload characters, e.g. `S010E`

After `trim()`, the sketch requires at least five characters with `S` at index `0` and `E` at index `4`. Digits at indices 1–3 are `B1in`, `B2in`, and `poti` (`0`–`9` each).

The sketch maps **`poti` in the range 0–2** for `map()` calls. If you use a rotary encoder that returns large step counts, normalize or map that value on the Arduino before sending a single digit.

## TUIO symbol IDs

Particles behave by **fiducial / object symbol ID**:

- **0** — ellipse size scales with `poti`
- **1** — random binary `0` / `1` text, size scales with `poti`
- **2** — draws `curTriangle` (white / green / red / yellow from button state)

## Configuration notes

### Serial port index

In `tuif_P.pde`, `setup()` picks `Serial.list()[min(2, ports.length - 1)]` so missing index 2 does not crash on smaller machines. **Adjust `portIndex`** to match your USB serial device.

### Full screen and TUIO

The sketch uses `fullScreen()` and `noCursor()`. TUIO must be provided by your table or bridge (e.g. reacTIVision → TUIO) on the port Processing expects for your environment.

### Arduino pins (`tuif_A.ino`)

- Buttons (with internal pull-ups): pins **2** and **4**, debounced with Bounce2, **toggle** on each press edge
- Encoder: pins **12** and **24**
- LEDs: **6** green, **8** yellow, **10** red

Comments in the `.ino` file may still mention older pin numbers; trust the `const` / `pinMode` values above.

## Development

Open the folder `tuif_P` as a sketch folder in Processing (all `.pde` tabs in that folder load together). Open `tuif_A.ino` in the Arduino IDE, select your board, upload, then run the Processing sketch with TUIO and serial connected.

## License

This project is licensed under the [MIT License](LICENSE). See that file for the full text.
