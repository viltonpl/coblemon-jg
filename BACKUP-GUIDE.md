# 📦 Backup do Mundo Cobblemon no Google Drive

## 🚀 Configuração Inicial (só precisa fazer UMA VEZ)

### 1️⃣ Configurar rclone com Google Drive

```bash
rclone config
```

**Siga estes passos:**

1. Escolha: `n` (New remote)
2. Nome: `gdrive` (ou qualquer nome)
3. Storage: `drive` (Google Drive)
4. Client ID/Secret: **deixe em branco** (pressione Enter)
5. Scope: `1` (Full access)
6. Root folder ID: **deixe em branco**
7. Service Account: **deixe em branco**
8. Auto config: `N` (porque está em servidor remoto)

**IMPORTANTE:** O rclone vai mostrar um link. Você precisa:
- Copiar o link
- Abrir no navegador
- Fazer login no Google
- Autorizar o rclone
- Copiar o código que aparecer
- Colar de volta no terminal

9. Configure como Team Drive?: `n`
10. Confirme: `y` (Yes)
11. Saia: `q` (Quit)

---

## 💾 Como Fazer Backup

### Método Automático (Recomendado)

```bash
# Fazer backup e enviar para Google Drive
./backup-world.sh && rclone copy /tmp/coblemon-world-backup-*.tar.gz gdrive:/Minecraft-Backups/
```

### Método Manual

```bash
# 1. Criar backup compactado
cd /workspaces/coblemon-jg
tar -czf /tmp/world-backup-$(date +%Y%m%d).tar.gz world/

# 2. Enviar para Google Drive
rclone copy /tmp/world-backup-*.tar.gz gdrive:/Minecraft-Backups/

# 3. Verificar se foi enviado
rclone ls gdrive:/Minecraft-Backups/
```

---

## 📥 Como Restaurar Backup

```bash
# 1. Baixar do Google Drive
rclone copy gdrive:/Minecraft-Backups/coblemon-world-backup-YYYYMMDD.tar.gz /tmp/

# 2. Parar servidor
pkill -f fabric-server

# 3. Fazer backup do mundo atual
mv world world_old_$(date +%Y%m%d)

# 4. Extrair backup
tar -xzf /tmp/coblemon-world-backup-YYYYMMDD.tar.gz -C /workspaces/coblemon-jg/

# 5. Reiniciar servidor
./start-server.sh
```

---

## 📋 Comandos Úteis

### Listar backups no Google Drive
```bash
rclone ls gdrive:/Minecraft-Backups/
```

### Ver tamanho dos backups
```bash
rclone size gdrive:/Minecraft-Backups/
```

### Deletar backups antigos (mais de 7 dias)
```bash
rclone delete gdrive:/Minecraft-Backups/ --min-age 7d
```

### Sincronizar pasta inteira (cuidado!)
```bash
rclone sync world/ gdrive:/Minecraft-World/
```

---

## ⚙️ Backup Automático (Cron)

Para fazer backup automático todo dia às 3h da manhã:

```bash
# Editar crontab
crontab -e

# Adicionar linha:
0 3 * * * cd /workspaces/coblemon-jg && ./backup-world.sh && rclone copy /tmp/coblemon-world-backup-*.tar.gz gdrive:/Minecraft-Backups/
```

---

## 🔍 Verificar Tamanho do Mundo

```bash
du -sh world/
```

---

## ⚠️ IMPORTANTE

- **Sempre pare o servidor antes de restaurar backup**
- **Mantenha pelo menos 3 backups diferentes**
- **Teste restauração periodicamente**
- **Backups completos podem ser grandes (>1GB)**

---

## 📞 Problemas?

### "Remote not found"
→ Execute `rclone config` novamente

### "Unauthorized"
→ Token expirado. Execute `rclone config reconnect gdrive:`

### Backup muito lento
→ Comprima apenas pastas essenciais:
```bash
tar -czf backup.tar.gz world/region world/playerdata world/cobblemonplayerdata
```
