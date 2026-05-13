import { defineConfig } from "vite";

// Use relative asset paths so static hosting (e.g. GitHub Pages in a subfolder) works when base is set.
export default defineConfig({
  base: "./",
});
