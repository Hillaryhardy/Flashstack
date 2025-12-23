import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["tests/**/*.ts"],
    exclude: ["tests/setup.ts"],
    setupFiles: ["tests/setup.ts"],
    singleThread: true,
    hookTimeout: 120000,
    testTimeout: 120000,
    isolate: false,
  },
});
