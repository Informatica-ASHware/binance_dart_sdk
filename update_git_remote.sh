#!/bin/bash

# =================================================================
#  Actualizador de Remote Git - binance_dart_sdk
#  Nueva Organización: Informatica-ASHware
# =================================================================

set -e

# Configuración
ORG_NAME="Informatica-ASHware"
REPO_NAME="binance_dart_sdk"

echo "🔄 Actualizando configuración de Git para: $REPO_NAME"

# 1. Verificar si estamos en un repositorio git
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "❌ Error: No estás dentro de un repositorio Git."
    exit 1
fi

# 2. Determinar el protocolo actual (SSH o HTTPS) para mantener la preferencia
CURRENT_URL=$(git remote get-url origin)

if [[ $CURRENT_URL == git@github.com* ]]; then
    NEW_URL="git@github.com:$ORG_NAME/$REPO_NAME.git"
    echo "📡 Detectado protocolo SSH."
else
    NEW_URL="https://github.com/$ORG_NAME/$REPO_NAME.git"
    echo "🌐 Detectado protocolo HTTPS."
fi

# 3. Cambiar la URL del remote origin
echo "🔗 Cambiando origin de:"
echo "   $CURRENT_URL"
echo "   a:"
echo "   $NEW_URL"

git remote set-url origin "$NEW_URL"

# 4. Verificar y Sincronizar
echo "⏳ Verificando conexión..."
git fetch origin

# 5. Informar al GitHub CLI (gh) del cambio
if command -v gh &> /dev/null; then
    echo "🤖 Sincronizando GitHub CLI..."
    # Esto refresca la caché de 'gh' para el nuevo repositorio
    gh repo view > /dev/null
fi

echo "✅ ¡Configuración actualizada con éxito!"
echo ""
echo "Resumen de remotes actuales:"
git remote -v