import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/app/**/*.{ts,tsx}",
    "./src/components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Stacks brand purple (#5546FF)
        brand: {
          50: "#eef0ff",
          100: "#e0e2ff",
          200: "#c6c9ff",
          300: "#a3a4ff",
          400: "#837dff",
          500: "#5546ff",
          600: "#4a38e6",
          700: "#3d2ec0",
          800: "#33299a",
          900: "#2c277a",
        },
        surface: {
          DEFAULT: "#0d0e14",
          card: "#15151f",
          hover: "#1d1c2b",
          border: "#2a2840",
        },
      },
    },
  },
  plugins: [],
};

export default config;
