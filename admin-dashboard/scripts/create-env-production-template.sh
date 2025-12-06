#!/bin/bash

# Script pour créer le fichier .env.production sur Hostinger
# Usage: bash create-env-production-template.sh

cat > .env.production << 'EOF'
# URL de l'API backend
NEXT_PUBLIC_API_URL=https://api.auxivie.org

# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://xhxmzxitabzybzrwzhvj.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhoeG16eGl0YWJ6eWJ6cnd6aHZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NDYxMDIsImV4cCI6MjA4MDIyMjEwMn0.OSsS0RQoZClpVN4Op5QMp5fLfYCXvBUIf-krCHK7XpA
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhoeG16eGl0YWJ6eWJ6cnd6aHZqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDY0NjEwMiwiZXhwIjoyMDgwMjIyMTAyfQ.tMwpVPi2sLOTBVH6gRQUkWh3m0rjo7OGHsZmWGHUJ2A

# Environment
NODE_ENV=production
PORT=3000
EOF

echo "✅ Fichier .env.production créé !"
echo ""
echo "📋 Contenu:"
cat .env.production

