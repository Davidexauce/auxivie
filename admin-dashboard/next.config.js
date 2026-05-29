const path = require('path');

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,

  // Évite l’avertissement « inferred workspace root » (autre package-lock à la maison).
  turbopack: {
    root: path.join(__dirname),
  },

  // À chaque build, nouveau préfixe sous `out/_next/static/<id>/` : les navigateurs/CDN
  // ne réutilisent plus d’anciens chunks après un déploiement sur hébergement statique.
  // Pour un build reproductible : NEXT_BUILD_ID=ma-valeur npm run build
  generateBuildId: async () =>
    process.env.NEXT_BUILD_ID || `export-${Date.now()}`,

  // Export statique uniquement si STATIC_EXPORT=1 (ex. déploiement fichiers sur Hostinger).
  // Sur le VPS, PM2 exécute `server.js` + `next prepare()` : ne pas activer `output: 'export'` par défaut.
  ...(process.env.STATIC_EXPORT === '1' ? { output: 'export' } : {}),

  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'https://api.auxivie.org',
  },

  compress: true,
  poweredByHeader: false,

  // Les en-têtes de sécurité sont en partie gérés par Hostinger / CDN.
  // `headers()` n’est pas pris en charge avec `output: 'export'`.
};

module.exports = nextConfig;
