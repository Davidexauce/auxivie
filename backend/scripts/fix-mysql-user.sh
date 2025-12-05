#!/bin/bash

# Script pour créer/configurer l'utilisateur MySQL
# Usage: bash scripts/fix-mysql-user.sh

echo "🔧 Configuration de l'utilisateur MySQL..."
echo ""

# Lire les credentials depuis .env
if [ ! -f ".env" ]; then
    echo "❌ Fichier .env non trouvé"
    exit 1
fi

DB_USER=$(grep "^DB_USER=" .env | cut -d '=' -f2)
DB_PASSWORD=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2)
DB_NAME=$(grep "^DB_NAME=" .env | cut -d '=' -f2)

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
    echo "❌ Variables DB_* manquantes dans .env"
    exit 1
fi

echo "Configuration:"
echo "  User: $DB_USER"
echo "  Database: $DB_NAME"
echo ""

# Demander le mot de passe root MySQL
echo "📝 Entrez le mot de passe root MySQL (ou appuyez sur Entrée si pas de mot de passe):"
read -s ROOT_PASSWORD

echo ""
echo "🔍 Vérification de l'utilisateur..."

# Tester la connexion root
if [ -z "$ROOT_PASSWORD" ]; then
    MYSQL_CMD="mysql -u root"
else
    MYSQL_CMD="mysql -u root -p$ROOT_PASSWORD"
fi

# Créer un script SQL temporaire
SQL_FILE=$(mktemp)
cat > "$SQL_FILE" << EOF
-- Créer la base de données si elle n'existe pas
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Vérifier si l'utilisateur existe
SELECT user, host FROM mysql.user WHERE user = '$DB_USER';

-- Créer l'utilisateur s'il n'existe pas
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';

-- OU réinitialiser le mot de passe si l'utilisateur existe
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';

-- Donner tous les privilèges
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';

-- Appliquer les changements
FLUSH PRIVILEGES;

-- Vérifier les permissions
SHOW GRANTS FOR '$DB_USER'@'localhost';
EOF

echo "📋 Exécution des commandes SQL..."
if [ -z "$ROOT_PASSWORD" ]; then
    mysql -u root < "$SQL_FILE"
else
    mysql -u root -p"$ROOT_PASSWORD" < "$SQL_FILE"
fi

if [ $? -eq 0 ]; then
    echo "✅ Utilisateur MySQL configuré avec succès !"
    echo ""
    echo "🧪 Test de la connexion..."
    if mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; then
        echo "✅ Connexion testée avec succès !"
    else
        echo "⚠️  Connexion échouée, vérifiez le mot de passe"
    fi
else
    echo "❌ Erreur lors de la configuration"
    echo "   Essayez de vous connecter manuellement à MySQL"
fi

# Nettoyer
rm -f "$SQL_FILE"

echo ""
echo "✅ Configuration terminée"

