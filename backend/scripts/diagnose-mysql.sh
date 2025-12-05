#!/bin/bash

# Script de diagnostic MySQL pour le VPS
# Usage: bash scripts/diagnose-mysql.sh

echo "🔍 Diagnostic MySQL..."
echo ""

# Vérifier si MySQL est installé
echo "1️⃣ Vérification de MySQL..."
if command -v mysql &> /dev/null; then
    echo "✅ MySQL installé: $(mysql --version)"
else
    echo "❌ MySQL n'est pas installé"
    echo "   Installation: sudo apt install mysql-server"
    exit 1
fi

# Vérifier si MySQL est démarré
echo ""
echo "2️⃣ Vérification du service MySQL..."
if systemctl is-active --quiet mysql; then
    echo "✅ MySQL est démarré"
else
    echo "⚠️  MySQL n'est pas démarré"
    echo "   Démarrer: sudo systemctl start mysql"
fi

# Vérifier le fichier .env
echo ""
echo "3️⃣ Vérification du fichier .env..."
if [ -f ".env" ]; then
    echo "✅ Fichier .env trouvé"
    echo ""
    echo "Credentials MySQL dans .env:"
    grep "^DB_" .env | sed 's/PASSWORD=.*/PASSWORD=***/'
else
    echo "❌ Fichier .env non trouvé"
    exit 1
fi

# Tester la connexion MySQL
echo ""
echo "4️⃣ Test de connexion MySQL..."
DB_USER=$(grep "^DB_USER=" .env | cut -d '=' -f2)
DB_PASSWORD=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2)
DB_NAME=$(grep "^DB_NAME=" .env | cut -d '=' -f2)

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
    echo "❌ Variables DB_* manquantes dans .env"
    exit 1
fi

echo "   Tentative de connexion avec:"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo ""

# Tester avec mysql command
if mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" 2>/dev/null; then
    echo "✅ Connexion MySQL réussie !"
    
    # Vérifier la base de données
    if mysql -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; then
        echo "✅ Base de données '$DB_NAME' accessible"
        
        # Compter les tables
        TABLE_COUNT=$(mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -e "SHOW TABLES" 2>/dev/null | wc -l)
        echo "✅ $((TABLE_COUNT - 1)) table(s) trouvée(s)"
    else
        echo "❌ Base de données '$DB_NAME' non accessible"
        echo "   Créer la base: mysql -u root -p -e \"CREATE DATABASE $DB_NAME;\""
    fi
else
    echo "❌ Échec de la connexion MySQL"
    echo ""
    echo "💡 Solutions possibles:"
    echo "   1. Vérifier le mot de passe dans Hostinger hPanel"
    echo "   2. Tester: mysql -u $DB_USER -p"
    echo "   3. Vérifier que l'utilisateur existe: mysql -u root -p -e \"SELECT user FROM mysql.user;\""
    echo "   4. Créer/réinitialiser l'utilisateur si nécessaire"
fi

echo ""
echo "✅ Diagnostic terminé"

