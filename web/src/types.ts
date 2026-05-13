/** Normalized TUIO-style coordinates: x and y in [0,1], y measured from bottom edge. */
export interface TuioObjectState {
  symbolId: number;
  x: number;
  y: number;
  angleRad: number;
}
