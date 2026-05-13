/// <reference types="vite/client" />

/** Minimal Web Serial surface used by this app (DOM lib coverage varies by TS version). */
interface SerialPort extends EventTarget {
  readonly readable: ReadableStream<Uint8Array> | null;
  open(options: { baudRate: number }): Promise<void>;
  close(): Promise<void>;
}

interface SerialPortRequestOptions {
  filters?: Array<{ usbVendorId?: number; usbProductId?: number }>;
}

interface SerialNavigator extends Navigator {
  serial: {
    requestPort(options?: SerialPortRequestOptions): Promise<SerialPort>;
  };
}
