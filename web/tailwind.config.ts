import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/app/**/*.{ts,tsx}",
    "./src/components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Bitcoin orange (#F7931A)
        brand: {
          50: "#fff7ed",
          100: "#ffedd5",
          200: "#fed7aa",
          300: "#fdba74",
          400: "#fba53c",
          500: "#f7931a",
          600: "#e07d0e",
          700: "#b8620b",
          800: "#8f4d0f",
          900: "#743f10",
        },
        surface: {
          DEFAULT: "#0c0a08",
          card: "#151109",
          hover: "#1d1710",
          border: "#2a2016",
        },
      },
    },
  },
  plugins: [],
};

export default config;
