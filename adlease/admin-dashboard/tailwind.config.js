/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#e3f2fd',
          100: '#bbdefb',
          200: '#90caf9',
          300: '#64b5f6',
          400: '#42a5f5',
          500: '#1565C0',
          600: '#1565C0',
          700: '#0d47a1',
          800: '#0a3d8f',
          900: '#072e6f',
        },
      },
    },
  },
  plugins: [],
}
