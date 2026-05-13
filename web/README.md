# ReactiVisuals (web)

Browser port of the Processing sketch: **p5.js** in **TypeScript**, built with **Vite**. Visuals and particle rules mirror `tuif_P/`; input differs because browsers cannot receive TUIO/UDP directly.

## Scripts

| Command | Description |
|--------|-------------|
| `npm install` | Install dependencies |
| `npm run dev` | Local dev server (HMR) |
| `npm run build` | Typecheck + production bundle to `dist/` |
| `npm run preview` | Serve the built `dist/` locally |

## Assets

Triangle PNGs are served from `public/` (copied from the Processing sketch). After changing art, replace files under `web/public/`.

## Input

1. **Mock TUIO** (default): one virtual fiducial follows the pointer; choose symbol ID `0` / `1` / `2` in the UI. Coordinates are normalized like TUIO (y from bottom).

2. **WebSocket bridge**: connect to a server that forwards tracker data as **JSON** messages, one object per message:

   ```json
   { "objects": [{ "symbolId": 2, "x": 0.5, "y": 0.5, "a": 0 }] }
   ```

   - `x`, `y`: `0`–`1`, TUIO-style (origin bottom-left for y).
   - `a`: optional angle in radians (default `0`).
   - Empty list: `{ "objects": [] }` clears objects.

   A small Node or Python relay can subscribe to OSC/TUIO from reacTIVision and push this JSON over WebSockets for production setups.

3. **Web Serial** (Chrome/Edge, `https` or `localhost`): same `S…E` line protocol as the Arduino sketch (`serialProtocol.ts`), 9600 baud.

## Hosting

`vite.config.ts` sets `base: './'` so assets work when the site is deployed in a subpath (e.g. GitHub Pages). Build output is static files in `dist/`—upload to any static host (Netlify, Cloudflare Pages, S3, etc.).

### Netlify

The repo root [`netlify.toml`](../netlify.toml) sets **`base = "web"`**, runs **`npm ci && npm run build`**, and publishes **`dist`** (i.e. `web/dist`). In the Netlify UI, connect this repository and keep the default inferred settings; you do not need to set a separate base directory unless you remove or override that file.

- **Node** is pinned to **20** in `[build.environment]` for reproducible installs.
- **Web Serial** works on the deployed `https://` URL in supported browsers (the user must still choose a port via the button).

## Bundle size

p5 is large; the build warns about chunk size. For tighter pages later, consider lazy-loading p5 or switching to a lighter renderer while keeping the same simulation code.
