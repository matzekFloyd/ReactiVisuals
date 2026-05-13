import type p5 from "p5";
import type { TuioObjectState } from "./types";

/** Wire format for optional WebSocket bridge (one JSON object per message). */
export interface TuioBridgeMessage {
  objects?: Array<{
    symbolId: number;
    x: number;
    y: number;
    /** angle in radians */
    a?: number;
  }>;
}

export class TuioInput {
  mockEnabled = true;
  mockSymbolId = 2;
  wsConnected = false;
  bridgeObjects: TuioObjectState[] = [];

  /** Objects to render this frame (TUIO normalized coords). */
  getObjects(p: p5): TuioObjectState[] {
    if (this.wsConnected) {
      return this.bridgeObjects;
    }
    if (!this.mockEnabled) {
      return [];
    }
    const w = Math.max(1, p.width);
    const h = Math.max(1, p.height);
    const x = p.constrain(p.mouseX / w, 0, 1);
    const y = p.constrain(1 - p.mouseY / h, 0, 1);
    return [{ symbolId: this.mockSymbolId, x, y, angleRad: 0 }];
  }

  applyBridgeJson(text: string): void {
    let data: unknown;
    try {
      data = JSON.parse(text) as unknown;
    } catch {
      return;
    }
    if (!data || typeof data !== "object") return;
    const msg = data as TuioBridgeMessage;
    if (!Array.isArray(msg.objects)) {
      this.bridgeObjects = [];
      return;
    }
    this.bridgeObjects = msg.objects
      .map((o) => ({
        symbolId: Number(o.symbolId),
        x: Number(o.x),
        y: Number(o.y),
        angleRad: typeof o.a === "number" ? o.a : 0,
      }))
      .filter(
        (o) =>
          Number.isFinite(o.x) &&
          Number.isFinite(o.y) &&
          Number.isFinite(o.angleRad) &&
          Number.isInteger(o.symbolId),
      );
  }
}
