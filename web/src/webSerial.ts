/** Minimal Web Serial helpers (Chrome/Edge, HTTPS or localhost). */

export function serialSupported(): boolean {
  return typeof navigator !== "undefined" && "serial" in navigator;
}

export type SerialNavigator = Navigator & {
  serial: {
    requestPort(options?: SerialPortRequestOptions): Promise<SerialPort>;
  };
};

export async function requestSerialPort(): Promise<SerialPort | null> {
  if (!serialSupported()) return null;
  const nav = navigator as SerialNavigator;
  try {
    return await nav.serial.requestPort();
  } catch {
    return null;
  }
}

/**
 * Reads lines from the port until `signal` aborts. Decodes UTF-8 and splits on CR/LF.
 */
export async function readSerialLines(
  port: SerialPort,
  onLine: (line: string) => void,
  signal: AbortSignal,
): Promise<void> {
  await port.open({ baudRate: 9600 });
  const reader = port.readable!.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  try {
    while (!signal.aborted) {
      const { value, done } = await reader.read();
      if (done) break;
      if (value) {
        buffer += decoder.decode(value, { stream: true });
        const parts = buffer.split(/\r?\n/);
        buffer = parts.pop() ?? "";
        for (const line of parts) {
          if (line.length > 0) onLine(line);
        }
      }
    }
  } finally {
    reader.releaseLock();
    try {
      await port.close();
    } catch {
      /* ignore */
    }
  }
}
