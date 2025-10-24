# 🔧 Problemas e Soluções do Servidor Cobblemon

## 🚨 Problema 1: Erro ao iniciar o servidor - "Detected incomplete install"

### **Sintoma**
```
Detected incomplete install, reinstalling
Installing Fabric Loader 0.17.3(1.21.1) on the server
Downloading required files
service FabricService{meta='https://meta.fabricmc.net/', maven='https://maven.fabricmc.net/'} failed
```

### **Causa**
O servidor Fabric precisa baixar bibliotecas necessárias na primeira execução, mas o ambiente atual não tem acesso à internet para baixá-las.

### **Solução**

#### Opção 1: Executar em ambiente com internet (RECOMENDADO)
1. Execute o servidor em uma máquina/VM com acesso à internet:
   ```bash
   java -Xmx8G -Xms4G -jar fabric.jar --nogui
   ```
2. Aguarde o download das bibliotecas (será criado o diretório `.fabric/libraries/`)
3. Após a primeira execução bem-sucedida, você pode commitar as bibliotecas:
   ```bash
   # Remova .fabric/ do .gitignore temporariamente
   git add .fabric/libraries/
   git commit -m "Add Fabric libraries for offline execution"
   ```

#### Opção 2: Download manual das bibliotecas
Se você tem acesso a outro servidor Fabric funcional:
1. Copie o diretório `.fabric/libraries/` de um servidor Fabric 0.17.3 funcional
2. Cole no seu servidor
3. Execute novamente

As bibliotecas necessárias são:
- `org/ow2/asm/asm/9.9/asm-9.9.jar`
- `org/ow2/asm/asm-analysis/9.9/asm-analysis-9.9.jar`
- `org/ow2/asm/asm-commons/9.9/asm-commons-9.9.jar`
- `org/ow2/asm/asm-tree/9.9/asm-tree-9.9.jar`
- `org/ow2/asm/asm-util/9.9/asm-util-9.9.jar`
- `net/fabricmc/sponge-mixin/0.16.5+mixin.0.8.7/sponge-mixin-0.16.5+mixin.0.8.7.jar`
- `net/fabricmc/intermediary/1.21.1/intermediary-1.21.1.jar`
- `net/fabricmc/fabric-loader/0.17.3/fabric-loader-0.17.3.jar`

---

## 🗺️ Problema 2: Erro de bioma do Terralith

### **Sintoma**
```
[Server thread/ERROR]: Recoverable errors when loading section [373, 0, 75]: 
(Unknown registry key in ResourceKey[minecraft:root / minecraft:worldgen/biome]: 
terralith:cave/granite_caves -> using default)
```

### **Causa**
Este erro ocorre quando:
1. O mundo foi gerado com o mod **Terralith** instalado
2. O mod Terralith foi removido ou está desatualizado
3. O servidor tenta carregar chunks que contêm biomas do Terralith que não existem mais

### **Impacto**
- ⚠️ **Erro recuperável** - o servidor continua funcionando
- Os biomas do Terralith são substituídos por biomas padrão do Minecraft
- Pode causar problemas visuais nos chunks afetados

### **Soluções**

#### Solução 1: Reinstalar o mod Terralith (RECOMENDADO)
1. Baixe o mod Terralith compatível com Minecraft 1.21.1:
   - https://modrinth.com/mod/terralith
   - ou https://www.curseforge.com/minecraft/mc-mods/terralith
2. Coloque o arquivo `.jar` no diretório `mods/`
3. Reinicie o servidor

#### Solução 2: Usar o Biome Replacer
O servidor já tem o mod **Biome Replacer** configurado. Você pode substituir biomas problemáticos:

1. Edite o arquivo `config/biome_replacer.properties`
2. Adicione regras para substituir biomas do Terralith:
   ```properties
   # Substituir cavernas de granito por cavernas normais
   terralith:cave/granite_caves > minecraft:dripstone_caves
   
   # Substituir todos os biomas Terralith por biomas normais
   #terralith:* > null
   ```
3. Reinicie o servidor

#### Solução 3: Ignorar o erro
Se você não se importa com os biomas Terralith:
- O erro é **recuperável** e não afeta a jogabilidade
- O Minecraft automaticamente substitui por biomas padrão
- Você pode continuar jogando normalmente

### **Prevenção futura**
- Sempre mantenha backup do mundo antes de remover mods de geração de terreno
- Se quiser remover o Terralith, considere gerar um novo mundo
- Mantenha uma lista dos mods usados na geração do mundo original

---

## 🔍 Diagnóstico de Problemas

### Verificar se o Terralith está instalado
```bash
ls -la mods/ | grep -i terralith
```

### Ver todos os erros do servidor
```bash
# Se o servidor estiver rodando
tail -f logs/latest.log

# Ver erros de sessões anteriores
grep ERROR logs/latest.log
```

### Verificar versão do Fabric
```bash
cat .fabric/server/fabric-loader-server-0.17.3-minecraft-1.21.1.jar
```

---

## 📞 Precisa de ajuda?

1. Verifique os logs em `logs/latest.log`
2. Certifique-se de que tem espaço em disco suficiente
3. Verifique se a versão do Java é compatível (Java 21+ para Minecraft 1.21.1):
   ```bash
   java -version
   ```

---

## ✅ Checklist de troubleshooting

Antes de reportar problemas, verifique:
- [ ] O arquivo `eula.txt` está com `eula=true`
- [ ] Você tem pelo menos 8GB de RAM disponível
- [ ] O Java 21 ou superior está instalado
- [ ] As bibliotecas do Fabric foram baixadas (`.fabric/libraries/` existe)
- [ ] Os mods necessários estão no diretório `mods/`
- [ ] Não há conflitos de porta (25565 está livre)

