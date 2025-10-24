#!/bin/bash

# Script de inicialização do servidor Cobblemon com verificações

set -e

echo "🎮 Iniciando servidor Cobblemon..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do servidor
SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SERVER_DIR"

# Função para verificar requisitos
check_requirements() {
    echo "🔍 Verificando requisitos..."
    
    # Verificar Java
    if ! command -v java &> /dev/null; then
        echo -e "${RED}❌ Java não encontrado!${NC}"
        echo "Instale Java 21 ou superior para Minecraft 1.21.1"
        exit 1
    fi
    
    # Verificar versão do Java
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -lt 21 ]; then
        echo -e "${YELLOW}⚠️  Aviso: Java $JAVA_VERSION detectado. Recomendado Java 21+${NC}"
    else
        echo -e "${GREEN}✅ Java $JAVA_VERSION detectado${NC}"
    fi
    
    # Verificar EULA
    if [ ! -f "eula.txt" ]; then
        echo -e "${RED}❌ Arquivo eula.txt não encontrado!${NC}"
        exit 1
    fi
    
    if ! grep -q "eula=true" eula.txt; then
        echo -e "${RED}❌ EULA não aceita!${NC}"
        echo "Edite o arquivo eula.txt e mude 'eula=false' para 'eula=true'"
        exit 1
    fi
    echo -e "${GREEN}✅ EULA aceita${NC}"
    
    # Verificar fabric.jar
    if [ ! -f "fabric.jar" ]; then
        echo -e "${RED}❌ fabric.jar não encontrado!${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ fabric.jar encontrado${NC}"
    
    # Verificar bibliotecas do Fabric
    if [ ! -d ".fabric/libraries" ] || [ -z "$(ls -A .fabric/libraries 2>/dev/null)" ]; then
        echo -e "${YELLOW}⚠️  Bibliotecas do Fabric não encontradas em .fabric/libraries/${NC}"
        echo ""
        echo "Este é o primeiro inicio ou as bibliotecas estão faltando."
        echo "O Fabric tentará baixá-las automaticamente."
        echo ""
        echo "Se você estiver em um ambiente sem internet, você precisa:"
        echo "1. Executar em uma máquina com internet primeiro"
        echo "2. Ou copiar o diretório .fabric/libraries/ de outro servidor"
        echo ""
        echo "Consulte PROBLEMAS-E-SOLUCOES.md para mais informações."
        echo ""
        read -p "Deseja continuar mesmo assim? (s/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Bibliotecas do Fabric encontradas${NC}"
    fi
    
    echo ""
}

# Função para verificar recursos
check_resources() {
    echo "💾 Verificando recursos do sistema..."
    
    # Verificar RAM disponível (Linux)
    if command -v free &> /dev/null; then
        AVAILABLE_RAM=$(free -g | awk '/^Mem:/{print $7}')
        if [ "$AVAILABLE_RAM" -lt 8 ]; then
            echo -e "${YELLOW}⚠️  RAM disponível: ${AVAILABLE_RAM}GB (recomendado: 8GB+)${NC}"
        else
            echo -e "${GREEN}✅ RAM disponível: ${AVAILABLE_RAM}GB${NC}"
        fi
    fi
    
    # Verificar espaço em disco
    AVAILABLE_DISK=$(df -h . | awk 'NR==2 {print $4}')
    echo -e "${GREEN}✅ Espaço em disco disponível: $AVAILABLE_DISK${NC}"
    
    echo ""
}

# Função para backup rápido
quick_backup() {
    if [ -d "world" ]; then
        echo "💾 Deseja fazer backup do mundo antes de iniciar? (s/N)"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[SsYy]$ ]]; then
            if [ -x "./backup-world.sh" ]; then
                ./backup-world.sh
            else
                BACKUP_FILE="/tmp/world-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
                echo "Criando backup em $BACKUP_FILE..."
                tar -czf "$BACKUP_FILE" world/
                echo -e "${GREEN}✅ Backup criado: $BACKUP_FILE${NC}"
            fi
        fi
    fi
}

# Parâmetros de memória
XMX=${XMX:-8G}
XMS=${XMS:-4G}

# Verificações
check_requirements
check_resources

# Perguntar sobre backup (apenas se world existir)
if [ -d "world" ] && [ -t 0 ]; then
    quick_backup
fi

echo "🚀 Iniciando servidor Minecraft Fabric..."
echo "   Memória: -Xmx$XMX -Xms$XMS"
echo "   Para parar o servidor, digite 'stop' ou pressione Ctrl+C"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Executar servidor
exec java -Xmx$XMX -Xms$XMS -jar fabric.jar --nogui "$@"
