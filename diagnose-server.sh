#!/bin/bash

# Script para verificar e diagnosticar problemas com mods do servidor Cobblemon

set -e

echo "🔍 Diagnóstico do Servidor Cobblemon"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório do servidor
SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SERVER_DIR"

# 1. Verificar estrutura básica
echo "📁 Verificando estrutura de arquivos..."
echo ""

FILES_TO_CHECK=(
    "fabric.jar:Fabric Launcher"
    "server.properties:Configuração do servidor"
    "eula.txt:EULA do Minecraft"
    ".fabric/server/1.21.1-server.jar:Minecraft Server JAR"
)

for item in "${FILES_TO_CHECK[@]}"; do
    IFS=':' read -r file desc <<< "$item"
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $desc ($file)"
    else
        echo -e "${RED}❌${NC} $desc ($file) - NÃO ENCONTRADO"
    fi
done

echo ""

# 2. Verificar diretório de mods
echo "🎮 Verificando mods instalados..."
echo ""

MOD_COUNT=0
if [ ! -d "mods" ]; then
    echo -e "${YELLOW}⚠️  Diretório 'mods/' não existe${NC}"
    echo "   Criando diretório..."
    mkdir -p mods
    echo -e "${GREEN}✅ Diretório criado${NC}"
else
    MOD_COUNT=$(find mods -maxdepth 1 -name "*.jar" 2>/dev/null | wc -l)
    
    if [ "$MOD_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Nenhum mod encontrado em mods/${NC}"
        echo "   O diretório 'mods/' está vazio"
    else
        echo -e "${GREEN}✅ $MOD_COUNT mods encontrados${NC}"
        echo ""
        echo "   Lista de mods instalados:"
        find mods -maxdepth 1 -name "*.jar" -exec basename {} \; | sort | while read -r mod; do
            echo "   • $mod"
        done
    fi
fi

echo ""

# 3. Verificar especificamente Terralith
echo "🗺️  Verificando mod Terralith..."
echo ""

TERRALITH_FOUND=0
if [ -d "mods" ]; then
    TERRALITH_FILES=$(find mods -maxdepth 1 -iname "*terralith*.jar" 2>/dev/null)
    
    if [ -n "$TERRALITH_FILES" ]; then
        echo -e "${GREEN}✅ Terralith encontrado:${NC}"
        echo "$TERRALITH_FILES" | while read -r file; do
            FILE_SIZE=$(du -h "$file" | cut -f1)
            echo "   • $(basename "$file") ($FILE_SIZE)"
        done
        TERRALITH_FOUND=1
    else
        echo -e "${RED}❌ Terralith NÃO encontrado${NC}"
        echo ""
        echo "   O mod Terralith não está instalado, mas o mundo pode ter sido"
        echo "   gerado com ele. Isso pode causar erros de bioma como:"
        echo "   'Unknown registry key: terralith:cave/granite_caves'"
        echo ""
        echo "   💡 Solução:"
        echo "   1. Baixe Terralith de: https://modrinth.com/mod/terralith"
        echo "   2. Coloque o arquivo .jar no diretório mods/"
        echo "   3. Reinicie o servidor"
    fi
else
    echo -e "${RED}❌ Diretório mods/ não encontrado${NC}"
fi

echo ""

# 4. Verificar bibliotecas do Fabric
echo "📚 Verificando bibliotecas do Fabric..."
echo ""

if [ ! -d ".fabric/libraries" ]; then
    echo -e "${RED}❌ Diretório .fabric/libraries/ não existe${NC}"
    echo "   As bibliotecas não foram baixadas ainda"
    LIBS_OK=0
else
    LIB_COUNT=$(find .fabric/libraries -name "*.jar" 2>/dev/null | wc -l)
    
    if [ "$LIB_COUNT" -eq 0 ]; then
        echo -e "${RED}❌ Nenhuma biblioteca encontrada em .fabric/libraries/${NC}"
        echo "   As bibliotecas precisam ser baixadas"
        LIBS_OK=0
    else
        echo -e "${GREEN}✅ $LIB_COUNT bibliotecas encontradas${NC}"
        
        # Verificar bibliotecas essenciais
        ESSENTIAL_LIBS=(
            "fabric-loader"
            "asm-9.9.jar"
            "sponge-mixin"
            "intermediary"
        )
        
        MISSING_LIBS=()
        for lib in "${ESSENTIAL_LIBS[@]}"; do
            if ! find .fabric/libraries -name "*$lib*" 2>/dev/null | grep -q .; then
                MISSING_LIBS+=("$lib")
            fi
        done
        
        if [ ${#MISSING_LIBS[@]} -gt 0 ]; then
            echo -e "${YELLOW}⚠️  Algumas bibliotecas essenciais podem estar faltando:${NC}"
            for lib in "${MISSING_LIBS[@]}"; do
                echo "   • $lib"
            done
            LIBS_OK=0
        else
            echo -e "${GREEN}✅ Todas as bibliotecas essenciais encontradas${NC}"
            LIBS_OK=1
        fi
    fi
fi

echo ""

# 5. Verificar logs recentes
echo "📝 Verificando logs recentes..."
echo ""

if [ -f "logs/latest.log" ]; then
    echo -e "${GREEN}✅ Log encontrado: logs/latest.log${NC}"
    
    # Procurar por erros do Terralith
    TERRALITH_ERRORS=$(grep -i "terralith" logs/latest.log 2>/dev/null | grep -i "error\|unknown" | wc -l)
    if [ "$TERRALITH_ERRORS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $TERRALITH_ERRORS erros relacionados ao Terralith encontrados${NC}"
        echo ""
        echo "   Últimos erros do Terralith:"
        grep -i "terralith" logs/latest.log | grep -i "error\|unknown" | tail -5 | sed 's/^/   /'
    else
        echo -e "${GREEN}✅ Nenhum erro do Terralith encontrado nos logs${NC}"
    fi
    
    echo ""
    
    # Procurar por outros erros
    ERROR_COUNT=$(grep -i "\[ERROR\]" logs/latest.log 2>/dev/null | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $ERROR_COUNT erros encontrados no log${NC}"
        echo ""
        echo "   Use este comando para ver todos os erros:"
        echo "   grep -i ERROR logs/latest.log"
    else
        echo -e "${GREEN}✅ Nenhum erro encontrado nos logs${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Log não encontrado (servidor ainda não foi executado)${NC}"
fi

echo ""

# 6. Verificar mundo
echo "🌍 Verificando mundo..."
echo ""

if [ -d "world" ]; then
    WORLD_SIZE=$(du -sh world 2>/dev/null | cut -f1)
    echo -e "${GREEN}✅ Mundo encontrado (tamanho: $WORLD_SIZE)${NC}"
    
    # Verificar arquivos importantes
    if [ -f "world/level.dat" ]; then
        echo -e "${GREEN}✅ level.dat encontrado${NC}"
    else
        echo -e "${RED}❌ level.dat não encontrado (mundo corrompido?)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Mundo não encontrado (será gerado na primeira execução)${NC}"
fi

echo ""

# 7. Resumo e recomendações
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMO E RECOMENDAÇÕES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ISSUES_FOUND=0

if [ "$TERRALITH_FOUND" -eq 0 ] && [ -d "world" ]; then
    echo -e "${RED}🔴 PROBLEMA: Terralith não instalado mas mundo existe${NC}"
    echo "   Ação: Instale o mod Terralith para evitar erros de bioma"
    echo "   Veja: PROBLEMAS-E-SOLUCOES.md"
    echo ""
    ISSUES_FOUND=1
fi

if [ "$LIBS_OK" -eq 0 ]; then
    echo -e "${RED}🔴 PROBLEMA: Bibliotecas do Fabric incompletas${NC}"
    echo "   Ação: Execute o servidor em ambiente com internet"
    echo "   Veja: PROBLEMAS-E-SOLUCOES.md"
    echo ""
    ISSUES_FOUND=1
fi

if [ "$MOD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}🟡 AVISO: Nenhum mod instalado${NC}"
    echo "   Ação: Adicione mods ao diretório mods/ se necessário"
    echo ""
    ISSUES_FOUND=1
fi

if [ "$ISSUES_FOUND" -eq 0 ]; then
    echo -e "${GREEN}🎉 Tudo parece OK!${NC}"
    echo ""
    echo "   Você pode iniciar o servidor com:"
    echo "   ./start-server.sh"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📚 Para mais informações, consulte:"
echo "   • README.md - Guia de inicialização"
echo "   • PROBLEMAS-E-SOLUCOES.md - Troubleshooting"
echo ""
