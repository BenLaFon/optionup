const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ],
   purge: {
    safelist: [
      'bg-green-500',
      'bg-red-500',
      'bg-yellow-500',
      'bg-green-200',
      'bg-red-200',
      'bg-yellow-200',
      'text-green-500',
      'text-red-500',
      'text-yellow-500',
    ],
  }
}
