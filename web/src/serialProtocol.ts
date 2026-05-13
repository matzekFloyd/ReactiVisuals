/** Parses Arduino / Processing serial lines like `S100E`. */
export function parseSerialFrame(line: string): { b1: number; b2: number; poti: number } | null {
  const s = line.trim();
  if (s.length < 5 || s[0] !== "S" || s[4] !== "E") return null;
  const b1 = Number(s[1]);
  const b2 = Number(s[2]);
  const poti = Number(s[3]);
  if (![b1, b2, poti].every((n) => Number.isInteger(n) && n >= 0 && n <= 9)) return null;
  return { b1, b2, poti };
}
