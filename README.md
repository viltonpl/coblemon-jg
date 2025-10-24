# 🎮 Servidor Cobblemon - Guia de Inicialização

## 📋 Pré-requisitos

- **Java 21** ou superior (para Minecraft 1.21.1)
- **8GB de RAM** disponível (mínimo 4GB)
- **10GB de espaço em disco** livre
- **Conexão com internet** (apenas para primeira execução)

## 🚀 Como Iniciar o Servidor

### Método 1: Script de inicialização (RECOMENDADO)

```bash
./start-server.sh
```

Este script irá:
- ✅ Verificar se todos os requisitos estão instalados
- ✅ Verificar se o EULA foi aceito
- ✅ Verificar se as bibliotecas do Fabric estão instaladas
- ✅ Oferecer opção de fazer backup
- ✅ Iniciar o servidor com configurações adequadas

### Método 2: Comando direto

```bash
java -Xmx8G -Xms4G -jar fabric.jar --nogui
```

### Método 3: Personalizar memória

```bash
# Usar 12GB de RAM máximo
XMX=12G XMS=6G ./start-server.sh

# Ou diretamente
java -Xmx12G -Xms6G -jar fabric.jar --nogui
```

## ⚙️ Primeira Execução

### 1. Aceitar o EULA

Na primeira vez, o servidor irá parar e pedir para você aceitar o EULA:

```bash
# Edite o arquivo eula.txt
nano eula.txt

# Mude esta linha:
eula=false
# Para:
eula=true
```

### 2. Download das bibliotecas

**IMPORTANTE**: O servidor precisa baixar bibliotecas do Fabric na primeira execução.

Você precisa de **conexão com internet** para:
- Baixar bibliotecas do fabric-loader
- Baixar dependências do ASM e Mixin
- Fazer setup inicial do Fabric

Após a primeira execução bem-sucedida, você pode rodar o servidor offline.

## 🐛 Problemas Comuns

### ❌ "Detected incomplete install, reinstalling"

**Causa**: Bibliotecas do Fabric não foram baixadas

**Solução**: Execute o servidor em uma máquina com internet ou copie as bibliotecas de outro servidor.

Veja detalhes em: **[PROBLEMAS-E-SOLUCOES.md](./PROBLEMAS-E-SOLUCOES.md)**

### ❌ "Unknown registry key: terralith:cave/granite_caves"

**Causa**: Mundo foi gerado com Terralith, mas o mod não está instalado

**Solução**: 
1. Reinstale o mod Terralith no diretório `mods/`
2. Ou ignore (erro recuperável, não quebra o jogo)

Veja detalhes em: **[PROBLEMAS-E-SOLUCOES.md](./PROBLEMAS-E-SOLUCOES.md)**

### ❌ "Cannot assign requested address" ou "Port already in use"

**Causa**: Porta 25565 já está em uso

**Solução**:
```bash
# Ver qual processo está usando a porta
lsof -i :25565

# Mudar porta no server.properties
server-port=25566
```

## 📁 Estrutura de Arquivos

```
coblemon-jg/
├── fabric.jar              # Launcher do Fabric
├── start-server.sh         # Script de inicialização
├── server.properties       # Configurações do servidor
├── eula.txt               # EULA do Minecraft
├── config/                # Configurações dos mods
├── mods/                  # Mods do servidor (não commitado)
├── world/                 # Mundo do Minecraft (não commitado)
├── .fabric/               # Cache do Fabric (não commitado)
│   ├── libraries/         # Bibliotecas necessárias
│   └── server/            # JARs do servidor
└── logs/                  # Logs do servidor
```

## 🔧 Comandos Úteis

### Diagnosticar problemas do servidor
```bash
./diagnose-server.sh
```

Este script verifica:
- ✅ Arquivos essenciais do servidor
- ✅ Mods instalados (incluindo Terralith)
- ✅ Bibliotecas do Fabric
- ✅ Logs de erro
- ✅ Mundo do Minecraft

### Parar o servidor
```bash
# Digite no console do servidor:
stop

# Ou pressione Ctrl+C (força parada)
```

### Ver logs em tempo real
```bash
tail -f logs/latest.log
```

### Fazer backup do mundo
```bash
./backup-world.sh
```

### Restaurar backup
```bash
# Ver backups disponíveis
ls -lh /tmp/coblemon-world-backup-*.tar.gz

# Parar servidor
stop

# Restaurar
tar -xzf /tmp/coblemon-world-backup-YYYYMMDD.tar.gz
```

## 📊 Monitoramento

### Ver uso de memória
```bash
top -p $(pgrep -f fabric.jar)
```

### Ver jogadores online
```bash
# No console do servidor:
list
```

### Ver TPS (Ticks Per Second)
```bash
# No console do servidor (se tiver mod):
/tps
```

## 🌐 Configuração de Rede

Para permitir que outros jogadores se conectem:

1. **Abrir porta no firewall**:
   ```bash
   # UFW (Ubuntu)
   sudo ufw allow 25565/tcp
   
   # Firewalld (CentOS/RHEL)
   sudo firewall-cmd --permanent --add-port=25565/tcp
   sudo firewall-cmd --reload
   ```

2. **Configurar IP público** (se necessário):
   - Edite `server.properties`
   - Configure `server-ip=SEU_IP_PUBLICO`

3. **Port forwarding** (se atrás de NAT):
   - Configure roteador para encaminhar porta 25565

## 🔐 Segurança

### Whitelist
```bash
# Ativar whitelist
whitelist on

# Adicionar jogador
whitelist add NOME_DO_JOGADOR

# Listar jogadores
whitelist list
```

### OP (Operadores)
```bash
# No console do servidor:
op NOME_DO_JOGADOR
deop NOME_DO_JOGADOR
```

### Banir jogadores
```bash
# No console do servidor:
ban NOME_DO_JOGADOR
ban-ip IP_DO_JOGADOR

# Desbanir
pardon NOME_DO_JOGADOR
pardon-ip IP_DO_JOGADOR
```

## 📚 Documentação Adicional

- [PROBLEMAS-E-SOLUCOES.md](./PROBLEMAS-E-SOLUCOES.md) - Troubleshooting detalhado
- [BACKUP-GUIDE.md](./BACKUP-GUIDE.md) - Guia de backup completo
- [coblemon.md](./coblemon.md) - Comandos básicos

## 🆘 Suporte

Se você encontrar problemas:

1. ✅ Leia [PROBLEMAS-E-SOLUCOES.md](./PROBLEMAS-E-SOLUCOES.md)
2. ✅ Verifique os logs em `logs/latest.log`
3. ✅ Verifique se tem Java 21+: `java -version`
4. ✅ Verifique se tem RAM suficiente: `free -h`
5. ✅ Verifique se a porta está livre: `lsof -i :25565`

## ⚡ Performance

### Configurações recomendadas por número de jogadores

| Jogadores | RAM | CPU | 
|-----------|-----|-----|
| 1-5       | 4GB | 2 cores |
| 5-10      | 8GB | 4 cores |
| 10-20     | 12GB | 6 cores |
| 20+       | 16GB+ | 8+ cores |

### Otimizações no server.properties

```properties
# Reduzir distância de visualização
view-distance=8
simulation-distance=6

# Limitar chunks carregados
max-chained-neighbor-updates=1000000

# Network optimization
network-compression-threshold=256
```

---

**Desenvolvido para o servidor Cobblemon** 🎮✨
