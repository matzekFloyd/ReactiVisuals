import { mountSketch, type SerialVisualState } from "./sketch";
import { parseSerialFrame } from "./serialProtocol";
import { TuioInput } from "./tuioInput";
import { readSerialLines, requestSerialPort, serialSupported } from "./webSerial";

const serial: SerialVisualState = { b1in: 0, b2in: 0, poti: 0 };
const tuioInput = new TuioInput();

const app = document.getElementById("app");
if (!app) {
  throw new Error("Missing #app container");
}

mountSketch(app, tuioInput, () => serial);

const symbolSelect = document.getElementById("symbolId") as HTMLSelectElement;
const mockCheckbox = document.getElementById("mockTuio") as HTMLInputElement;
const wsUrl = document.getElementById("wsUrl") as HTMLInputElement;
const wsConnect = document.getElementById("wsConnect") as HTMLButtonElement;
const wsDisconnect = document.getElementById("wsDisconnect") as HTMLButtonElement;
const serialConnect = document.getElementById("serialConnect") as HTMLButtonElement;
const serialDisconnect = document.getElementById("serialDisconnect") as HTMLButtonElement;

symbolSelect.addEventListener("change", () => {
  tuioInput.mockSymbolId = Number(symbolSelect.value);
});

mockCheckbox.addEventListener("change", () => {
  tuioInput.mockEnabled = mockCheckbox.checked;
});

let ws: WebSocket | null = null;

wsConnect.addEventListener("click", () => {
  const url = wsUrl.value.trim();
  if (!url) {
    window.alert("Enter a WebSocket URL (e.g. ws://127.0.0.1:3333)");
    return;
  }
  ws?.close();
  ws = new WebSocket(url);
  ws.addEventListener("open", () => {
    tuioInput.wsConnected = true;
    wsConnect.disabled = true;
    wsDisconnect.disabled = false;
    mockCheckbox.disabled = true;
  });
  ws.addEventListener("message", (ev) => {
    if (typeof ev.data === "string") {
      tuioInput.applyBridgeJson(ev.data);
    }
  });
  ws.addEventListener("close", () => {
    tuioInput.wsConnected = false;
    tuioInput.bridgeObjects = [];
    wsConnect.disabled = false;
    wsDisconnect.disabled = true;
    mockCheckbox.disabled = false;
    ws = null;
  });
  ws.addEventListener("error", () => {
    ws?.close();
  });
});

wsDisconnect.addEventListener("click", () => {
  ws?.close();
});

let serialAbort: AbortController | null = null;

serialConnect.addEventListener("click", async () => {
  if (!serialSupported()) {
    window.alert("Web Serial is not supported in this browser. Try Chrome or Edge over HTTPS or localhost.");
    return;
  }
  const port = await requestSerialPort();
  if (!port) return;
  serialAbort = new AbortController();
  serialConnect.disabled = true;
  serialDisconnect.disabled = false;
  readSerialLines(
    port,
    (line) => {
      const parsed = parseSerialFrame(line);
      if (!parsed) return;
      serial.b1in = parsed.b1;
      serial.b2in = parsed.b2;
      serial.poti = parsed.poti;
    },
    serialAbort.signal,
  )
    .catch(() => {
      /* closed or aborted */
    })
    .finally(() => {
      serialAbort = null;
      serialConnect.disabled = false;
      serialDisconnect.disabled = true;
    });
});

serialDisconnect.addEventListener("click", () => {
  serialAbort?.abort();
});

if (!serialSupported()) {
  serialConnect.disabled = true;
  serialConnect.title = "Web Serial not available in this browser";
}
