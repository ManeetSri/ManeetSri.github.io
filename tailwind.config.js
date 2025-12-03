/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        lavender: {
          DEFAULT: '#b497ff',
          light: '#e0caff',
          deep: '#8a6ce8',
        },
        bg: {
          dark1: '#1d1b26',
          dark2: '#2c223d',
          dark3: '#332748',
        }
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'], // Assuming Inter or similar default
      }
    },
  },
  plugins: [],
}
