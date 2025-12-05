#!/bin/bash

# Script de configuration GitHub pour Auxivie
# Usage: ./setup-github.sh

set -e

echo "🚀 Configuration GitHub pour Auxivie"
echo "======================================"
echo ""

# Vérifier si on est dans le bon répertoire
if [ ! -f "pubspec.yaml" ] || [ ! -d "backend" ] || [ ! -d "admin-dashboard" ]; then
    echo "❌ Erreur : Ce script doit être exécuté depuis la racine du projet"
    exit 1
fi

# Vérifier si Git est initialisé
if [ ! -d ".git" ]; then
    echo "❌ Erreur : Git n'est pas initialisé dans ce répertoire"
    exit 1
fi

# Vérifier si un remote existe déjà
if git remote | grep -q "^origin$"; then
    echo "⚠️  Un dépôt distant 'origin' existe déjà :"
    git remote -v | grep origin
    echo ""
    read -p "Voulez-vous le remplacer ? (o/N) : " replace
    if [[ ! $replace =~ ^[Oo]$ ]]; then
        echo "❌ Annulé"
        exit 0
    fi
    git remote remove origin
fi

# Demander l'URL du dépôt GitHub
echo "📝 Entrez l'URL de votre dépôt GitHub :"
echo "   Exemples :"
echo "   - HTTPS: https://github.com/VOTRE_USERNAME/auxivie.git"
echo "   - SSH:   git@github.com:VOTRE_USERNAME/auxivie.git"
echo ""
read -p "URL du dépôt : " repo_url

if [ -z "$repo_url" ]; then
    echo "❌ Erreur : URL vide"
    exit 1
fi

# Ajouter le remote
echo ""
echo "🔗 Ajout du dépôt distant..."
git remote add origin "$repo_url"

# Vérifier la branche actuelle
current_branch=$(git branch --show-current)
echo ""
echo "📌 Branche actuelle : $current_branch"

# Demander si on veut renommer master en main
if [ "$current_branch" = "master" ]; then
    read -p "Voulez-vous renommer 'master' en 'main' ? (O/n) : " rename
    if [[ ! $rename =~ ^[Nn]$ ]]; then
        git branch -M main
        current_branch="main"
        echo "✅ Branche renommée en 'main'"
    fi
fi

# Afficher un résumé
echo ""
echo "📋 Résumé de la configuration :"
echo "   Remote: origin -> $repo_url"
echo "   Branche: $current_branch"
echo ""

# Demander confirmation avant de pousser
read -p "Voulez-vous pousser les changements maintenant ? (O/n) : " push_now
if [[ $push_now =~ ^[Nn]$ ]]; then
    echo ""
    echo "✅ Configuration terminée !"
    echo "   Pour pousser plus tard, exécutez :"
    echo "   git push -u origin $current_branch"
    exit 0
fi

# Pousser les changements
echo ""
echo "📤 Envoi des changements vers GitHub..."
echo "   (Cela peut prendre quelques instants)"
echo ""

if git push -u origin "$current_branch"; then
    echo ""
    echo "✅ ✅ ✅ Succès !"
    echo ""
    echo "🎉 Votre projet est maintenant sauvegardé sur GitHub !"
    echo "   URL : $repo_url"
else
    echo ""
    echo "❌ Erreur lors du push"
    echo ""
    echo "💡 Solutions possibles :"
    echo "   1. Vérifiez votre authentification GitHub"
    echo "   2. Vérifiez que le dépôt existe bien sur GitHub"
    echo "   3. Pour HTTPS, utilisez un Personal Access Token"
    echo "   4. Pour SSH, vérifiez votre clé SSH"
    echo ""
    echo "   Vous pouvez réessayer plus tard avec :"
    echo "   git push -u origin $current_branch"
    exit 1
fi

