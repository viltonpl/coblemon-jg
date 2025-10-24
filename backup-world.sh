#!/bin/bash
# Script de Backup do Mundo Cobblemon para Google Drive
# Uso: ./backup-world.sh

echo "🔧 Iniciando backup do mundo Cobblemon..."

# Configurações
WORLD_PATH="/workspaces/coblemon-jg/world"
BACKUP_NAME="coblemon-world-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
TEMP_BACKUP="/tmp/$BACKUP_NAME"

# Criar arquivo compactado
echo "📦 Compactando mundo..."
tar -czf "$TEMP_BACKUP" -C /workspaces/coblemon-jg world/

# Mostrar tamanho do backup
BACKUP_SIZE=$(du -h "$TEMP_BACKUP" | cut -f1)
echo "✅ Backup criado: $BACKUP_SIZE"
echo "📁 Arquivo: $TEMP_BACKUP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📤 PRÓXIMOS PASSOS PARA ENVIAR AO GOOGLE DRIVE:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Configure o rclone (primeira vez):"
echo "    rclone config"
echo ""
echo "2️⃣  Envie para o Google Drive:"
echo "    rclone copy $TEMP_BACKUP gdrive:Minecraft-Backups/"
echo ""
echo "3️⃣  Ou use este comando direto:"
echo "    rclone copy $TEMP_BACKUP seu-remote:/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 DICA: Configure o rclone uma vez e depois use:"
echo "   ./backup-world.sh && rclone copy /tmp/$BACKUP_NAME gdrive:/"
echo ""
