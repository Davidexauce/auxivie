/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  
  // Variables d'environnement publiques
  // NEXT_PUBLIC_* sont automatiquement exposées au client
  // Pas besoin de les redéfinir dans env si elles sont dans .env.production
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'https://api.auxivie.org',
  },
  
  // Optimisations de production
  compress: true,
  poweredByHeader: false,
  
  // Configuration pour Hostinger
  output: 'standalone', // Pour un déploiement optimisé
  
  // Headers de sécurité
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
