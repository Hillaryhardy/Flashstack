import { beforeEach } from "vitest";
import { initSimnet } from "@hirosystems/clarinet-sdk";

declare global {
  var simnet: ReturnType<typeof initSimnet>;
}

beforeEach(async () => {
  globalThis.simnet = await initSimnet();
});
