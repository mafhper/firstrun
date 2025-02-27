#!/bin/bash
# Script de configuração e boas práticas para Ubuntu recém-instalado
# Salve este arquivo como setup_ubuntu.sh e execute com: sudo bash setup_ubuntu.sh

# Define cores para melhor visualização no terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando configuração do Ubuntu...${NC}"

# 1. Atualizar o sistema
echo -e "${YELLOW}1. Atualizando o sistema...${NC}"
apt update && apt upgrade -y

# 2. Instalar pacotes essenciais
echo -e "${YELLOW}2. Instalando pacotes essenciais...${NC}"
apt install -y \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    unzip \
    gnupg \
    lsb-release \
    ufw \
    fail2ban

# 3. Configurar firewall básico
echo -e "${YELLOW}3. Configurando firewall básico...${NC}"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
# Descomente a linha abaixo para ativar o firewall (só faça isso se tiver acesso SSH garantido)
# ufw enable

# 4. Configurar Fail2ban (proteção contra tentativas de invasão)
echo -e "${YELLOW}4. Configurando Fail2ban...${NC}"
systemctl enable fail2ban
systemctl start fail2ban

# 5. Configurar atualizações automáticas
echo -e "${YELLOW}5. Configurando atualizações automáticas...${NC}"
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# 6. Otimizações do sistema
echo -e "${YELLOW}6. Aplicando otimizações do sistema...${NC}"

# Ajustar o swappiness (reduz o uso de swap quando há RAM disponível)
echo "vm.swappiness=10" >> /etc/sysctl.conf

# Melhorar o cache do sistema de arquivos
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# Aplicar as alterações
sysctl -p

# 7. Limpar pacotes desnecessários
echo -e "${YELLOW}7. Limpando pacotes desnecessários...${NC}"
apt autoremove -y
apt autoclean

# 8. Configurar snapshots com Timeshift (backup do sistema)
echo -e "${YELLOW}8. Instalando Timeshift para backups...${NC}"
add-apt-repository -y ppa:teejee2008/ppa
apt update
apt install -y timeshift

# 9. Instalando ferramentas adicionais úteis (descomente as que desejar)
echo -e "${YELLOW}9. Instalando ferramentas adicionais...${NC}"

# Suporte a arquivos compactados
apt install -y p7zip-full p7zip-rar rar unrar

# Verificação de integridade do sistema
apt install -y rkhunter chkrootkit

# Monitoramento do sistema
apt install -y sysstat iotop

# 10. Configurando agendamento de tarefas de manutenção
echo -e "${YELLOW}10. Configurando tarefas de manutenção periódicas...${NC}"

# Criar script de manutenção
cat > /usr/local/bin/system_maintenance.sh << 'EOL'
#!/bin/bash
# Atualizar o sistema
apt update && apt upgrade -y
# Limpar pacotes desnecessários
apt autoremove -y && apt autoclean
# Verificar por rootkits
rkhunter --update
rkhunter --check --sk
EOL

# Tornar o script executável
chmod +x /usr/local/bin/system_maintenance.sh

# Configurar execução semanal
echo "0 2 * * 0 root /usr/local/bin/system_maintenance.sh > /var/log/system_maintenance.log 2>&1" > /etc/cron.d/system_maintenance

echo -e "${GREEN}Configuração do sistema concluída!${NC}"
echo -e "${YELLOW}Reinicie o sistema para aplicar todas as alterações.${NC}"

# Fim do script
