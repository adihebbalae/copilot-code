import { defineConfig } from 'astro/config';

// When deploying to GitHub Pages at adihebbalae.github.io/Attacca
// set base: '/Attacca'
// For a custom domain (e.g. attacca.dev), remove the base option.
export default defineConfig({
  site: 'https://adihebbalae.github.io',
  base: '/Attacca',
  output: 'static',
});
