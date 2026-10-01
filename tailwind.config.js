module.exports = {
  future: {
    hoverOnlyWhenSupported: true
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: [
      {
        docuseal: {
          'color-scheme': 'light',
          primary: '#00873a',
          'primary-content': '#ffffff',
          secondary: '#8ba424',
          'secondary-content': '#ffffff',
          accent: '#afc524',
          'accent-content': '#1d1d1b',
          neutral: '#00873a',
          'neutral-content': '#ffffff',
          'base-100': '#ffffff',
          'base-200': '#f3f8ee',
          'base-300': '#e3edd9',
          'base-content': '#1d1d1b',
          '--rounded-btn': '1.9rem',
          '--tab-border': '2px',
          '--tab-radius': '.5rem'
        }
      }
    ]
  }
}
