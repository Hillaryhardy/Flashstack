import { fileURLToPath } from "url";
import path from "path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // The repo root (one level up) also has a package-lock.json (for the
  // Clarity contracts/tests workspace), which made Turbopack infer the wrong
  // workspace root. Pin it explicitly to this directory.
  turbopack: {
    root: __dirname,
  },
};

export default nextConfig;
