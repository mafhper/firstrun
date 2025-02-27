#!/bin/bash
#================================================================
# TÍTULO: Script Avançado de Configuração e Boas Práticas para Ubuntu
# DESCRIÇÃO: Instala pacotes essenciais, configura segurança e otimiza o sistema
# AUTOR: [Seu Nome]
# VERSÃO: 2.0
# DATA: $(date +%d-%m-%Y)
#================================================================

# Verificar se está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script precisa ser executado como root (sudo)." 
   exit 1
fi

# Definição de cores para melhor visualização
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir cabeçalhos de seção
function print_section() {
    echo -e "\n${BOLD}${BLUE}===${NC} ${BOLD}$1${NC} ${BOLD}${BLUE}===${NC}\n"
}

# Função para exibir tarefas
function print_task() {
    echo -e "${YELLOW}➤ $1...${NC}"
}

# Função para verificar sucesso ou falha
function check_status() {
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Concluído com sucesso${NC}"
    else
        echo -e "  ${RED}✗ Falha na operação${NC}"
        # Perguntar se deseja continuar mesmo com erro
        read -p "  Continuar mesmo com erro? (s/n): " choice
        if [[ "$choice" != "s" && "$choice" != "S" ]]; then
            echo -e "${RED}Script interrompido pelo usuário.${NC}"
            exit 1
        fi
    fi
}

# Função para criar backup do arquivo antes de modificá-lo
function backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
        echo -e "  ${GREEN}✓ Backup criado: $1.bak.$(date +%Y%m%d%H%M%S)${NC}"
    fi
}

# Registro de log
LOG_FILE="/var/log/ubuntu_setup_$(date +%Y%m%d%H%M%S).log"
touch $LOG_FILE
exec > >(tee -a $LOG_FILE)
exec 2>&1

# Banner inicial
echo -e "${GREEN}"
echo "  _    _ _                 _           _____      _               "
echo " | |  | | |               | |         / ____|    | |              "
echo " | |  | | |__  _   _ _ __ | |_ _   _ | (___   ___| |_ _   _ _ __  "
echo " | |  | | '_ \| | | | '_ \| __| | | | \___ \ / _ \ __| | | | '_ \ "
echo " | |__| | |_) | |_| | | | | |_| |_| | ____) |  __/ |_| |_| | |_) |"
echo "  \____/|_.__/ \__,_|_| |_|\__|\__,_||_____/ \___|\__|\__,_| .__/ "
echo "                                                            | |    "
echo "                                                            |_|    "
echo -e "${NC}"
echo -e "${BOLD}Script Avançado de Configuração e Boas Práticas - Ubuntu${NC}"
echo -e "Log sendo salvo em: ${BOLD}$LOG_FILE${NC}\n"

# Perguntar se quer continuar
read -p "Deseja continuar com a configuração? (s/n): " proceed
if [[ "$proceed" != "s" && "$proceed" != "S" ]]; then
    echo "Script cancelado pelo usuário."
    exit 0
fi

# Início do script principal
print_section "DETECÇÃO DO SISTEMA"
OS_VERSION=$(lsb_release -ds)
KERNEL_VERSION=$(uname -r)
echo -e "Sistema detectado: ${BOLD}$OS_VERSION${NC}"
echo -e "Versão do kernel: ${BOLD}$KERNEL_VERSION${NC}"
echo -e "Arquitetura: ${BOLD}$(uname -m)${NC}"
echo -e "Nome do host: ${BOLD}$(hostname)${NC}"

#================================================================
# 1. ATUALIZAÇÃO DO SISTEMA
#================================================================
print_section "1. ATUALIZAÇÃO DO SISTEMA"

print_task "Atualizando repositórios"
apt update
check_status

print_task "Atualizando pacotes do sistema"
apt upgrade -y
check_status

print_task "Atualizando distribuição (se houver nova versão)"
apt dist-upgrade -y
check_status

#================================================================
# 2. INSTALAÇÃO DE PACOTES ESSENCIAIS
#================================================================
print_section "2. INSTALAÇÃO DE PACOTES ESSENCIAIS"

# Pacotes divididos por categorias para melhor organização
BASIC_PKGS="build-essential software-properties-common apt-transport-https ca-certificates curl wget git vim"
SYSTEM_PKGS="htop net-tools unzip gnupg lsb-release iotop sysstat ntp"
SECURITY_PKGS="ufw fail2ban rkhunter chkrootkit lynis auditd apparmor apparmor-utils"
COMPRESSION_PKGS="p7zip-full p7zip-rar rar unrar zip unzip"
MONITORING_PKGS="glances ncdu tlp powertop lm-sensors smartmontools"

print_task "Instalando pacotes básicos"
apt install -y $BASIC_PKGS
check_status

print_task "Instalando pacotes de sistema"
apt install -y $SYSTEM_PKGS
check_status

print_task "Instalando pacotes de segurança"
apt install -y $SECURITY_PKGS
check_status

print_task "Instalando pacotes de compressão"
apt install -y $COMPRESSION_PKGS
check_status

print_task "Instalando ferramentas de monitoramento"
apt install -y $MONITORING_PKGS
check_status

# Perguntar se deseja instalar Docker
read -p "Deseja instalar Docker? (s/n): " install_docker
if [[ "$install_docker" == "s" || "$install_docker" == "S" ]]; then
    print_task "Instalando Docker"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    check_status
    
    print_task "Configurando Docker para iniciar no boot"
    systemctl enable docker
    systemctl start docker
    check_status
    
    print_task "Adicionando usuário atual ao grupo docker"
    usermod -aG docker $(logname)
    check_status
fi

#================================================================
# 3. CONFIGURAÇÃO DE SEGURANÇA BÁSICA
#================================================================
print_section "3. CONFIGURAÇÃO DE SEGURANÇA"

print_task "Configurando firewall UFW"
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

read -p "Deseja ativar o firewall UFW agora? (s/n): " enable_ufw
if [[ "$enable_ufw" == "s" || "$enable_ufw" == "S" ]]; then
    echo "y" | ufw enable
    check_status
fi

print_task "Configurando Fail2ban"
# Backup da configuração original
backup_file "/etc/fail2ban/jail.conf"

# Criar arquivo de configuração personalizado
cat > /etc/fail2ban/jail.local <<EOL
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = %(sshd_log)s
maxretry = 3
bantime = 6h
EOL

systemctl enable fail2ban
systemctl restart fail2ban
check_status

print_task "Configurando SSH mais seguro"
backup_file "/etc/ssh/sshd_config"

# Ajustar configurações SSH para maior segurança
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

read -p "Deseja reiniciar SSH para aplicar as configurações? (ATENÇÃO: Certifique-se de ter configurado acesso por chave) (s/n): " restart_ssh
if [[ "$restart_ssh" == "s" || "$restart_ssh" == "S" ]]; then
    systemctl restart ssh
    check_status
fi

print_task "Executando verificação inicial de rootkits"
rkhunter --update
rkhunter --propupd
rkhunter --check --sk
check_status

print_task "Executando varredura com Lynis"
if command -v lynis &> /dev/null; then
    lynis audit system --quick
    check_status
fi

print_task "Configurando AppArmor"
aa-enforce /etc/apparmor.d/*
check_status

#================================================================
# 4. OTIMIZAÇÕES DO SISTEMA
#================================================================
print_section "4. OTIMIZAÇÕES DO SISTEMA"

print_task "Ajustando parâmetros do kernel"
backup_file "/etc/sysctl.conf"

cat >> /etc/sysctl.conf <<EOL
# Melhorias de performance e segurança
# Reduzir uso de swap
vm.swappiness=10
# Melhorar cache do sistema de arquivos
vm.vfs_cache_pressure=50
# Aumentar limite de arquivos abertos
fs.file-max=100000
# Habilitar proteção contra execução em pilha
kernel.exec-shield=1
# Proteções de rede
net.ipv4.conf.all.rp_filter=1
net.ipv4.tcp_syncookies=1
# Proteção contra ataques ICMP
net.ipv4.icmp_echo_ignore_broadcasts=1
# Ignorar pings (opcional, descomente se desejar)
# net.ipv4.icmp_echo_ignore_all=1
EOL

print_task "Aplicando configurações do kernel"
sysctl -p
check_status

print_task "Configurando limites de recursos do sistema"
backup_file "/etc/security/limits.conf"

cat >> /etc/security/limits.conf <<EOL
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
* soft nproc 65535
* hard nproc 65535
EOL
check_status

print_task "Otimizando o agendador de disco"
if [ -b /dev/sda ]; then
    cat > /etc/udev/rules.d/60-scheduler.rules <<EOL
# Set deadline scheduler for non-rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"
# Set cfq scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
EOL
    check_status
fi

print_task "Configurando TLP para otimizar bateria (para laptops)"
if command -v tlp &> /dev/null; then
    tlp start
    check_status
fi

#================================================================
# 5. CONFIGURAÇÃO DE ATUALIZAÇÕES AUTOMÁTICAS
#================================================================
print_section "5. CONFIGURAÇÃO DE ATUALIZAÇÕES AUTOMÁTICAS"

print_task "Instalando e configurando atualizações automáticas"
apt install -y unattended-upgrades apt-listchanges

cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOL
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOL

cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOL
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}:\${distro_codename}-updates";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Mail "root";
EOL

systemctl restart unattended-upgrades
check_status

#================================================================
# 6. CONFIGURAÇÃO DE BACKUP
#================================================================
print_section "6. CONFIGURAÇÃO DE BACKUP"

print_task "Instalando Timeshift para backups do sistema"
add-apt-repository -y ppa:teejee2008/ppa
apt update
apt install -y timeshift
check_status

print_task "Configurando Rsync para backups de dados"
apt install -y rsync
check_status

#================================================================
# 7. TAREFAS DE MANUTENÇÃO AGENDADAS
#================================================================
print_section "7. TAREFAS DE MANUTENÇÃO AGENDADAS"

print_task "Criando script de manutenção periódica"
cat > /usr/local/bin/system_maintenance.sh <<'EOL'
#!/bin/bash
# Script de manutenção automática do sistema Ubuntu
# Criado por: [Seu Nome]

# Configurar log
LOG_FILE="/var/log/system_maintenance_$(date +%Y%m%d).log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "========== Manutenção do Sistema - $(date) =========="

echo "1. Atualizando o sistema..."
apt update && apt upgrade -y

echo "2. Limpando pacotes desnecessários..."
apt autoremove -y && apt autoclean

echo "3. Limpando caches..."
rm -rf /home/*/.cache/thumbnails/* 2>/dev/null
journalctl --vacuum-time=7d

echo "4. Verificando integridade do sistema..."
echo "4.1. Verificando por rootkits..."
rkhunter --update
rkhunter --check --skip-keypress

echo "4.2. Verificando espaço em disco..."
df -h

echo "4.3. Verificando os 10 maiores arquivos/diretórios..."
find / -type f -not -path "/proc/*" -not -path "/sys/*" -printf '%s %p\n' 2>/dev/null | sort -nr | head -10

echo "4.4. Verificando processos que consomem mais recursos..."
ps aux --sort=-%mem | head -10

echo "5. Verificando atualizações de segurança pendentes..."
apt list --upgradable 2>/dev/null | grep -i security

echo "6. Verificando saúde dos discos..."
if command -v smartctl &> /dev/null; then
    for disk in $(lsblk -d -o name | grep -v NAME); do
        smartctl -H /dev/$disk
    done
fi

echo "7. Verificando logs do sistema para erros críticos..."
grep -i 'error\|critical\|warning\|fail' /var/log/syslog | tail -20

echo "8. Reiniciando serviços críticos..."
systemctl restart fail2ban
systemctl restart ufw

echo "========== Manutenção Concluída - $(date) =========="
EOL

chmod +x /usr/local/bin/system_maintenance.sh
check_status

print_task "Configurando execução semanal da manutenção"
cat > /etc/cron.d/system_maintenance <<EOL
# Executar manutenção do sistema semanalmente (domingo às 3h da manhã)
0 3 * * 0 root /usr/local/bin/system_maintenance.sh
EOL
check_status

#================================================================
# 8. LIMPEZA FINAL
#================================================================
print_section "8. LIMPEZA FINAL"

print_task "Limpando pacotes órfãos e caches"
apt autoremove -y
apt autoclean
check_status

print_task "Limpando arquivos temporários"
rm -rf /tmp/*
check_status

#================================================================
# 9. PERSONALIZAÇÃO ADICIONAL
#================================================================
print_section "9. PERSONALIZAÇÃO ADICIONAL"

print_task "Criando aliases úteis para todos os usuários"
cat > /etc/profile.d/00-aliases.sh <<EOL
# Aliases úteis para todos os usuários
alias update='sudo apt update && sudo apt upgrade'
alias clean='sudo apt autoremove && sudo apt autoclean'
alias ports='sudo netstat -tulanp'
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias diskinfo='df -h'
alias running='ps aux | grep'
alias myip='curl http://ipecho.net/plain; echo'
alias logs='find /var/log -type f -name "*.log" | xargs tail -f'
EOL
chmod +x /etc/profile.d/00-aliases.sh
check_status

print_task "Configurando banner de login SSH"
cat > /etc/issue.net <<EOL
***************************************************************************
                          SISTEMA RESTRITO
    Acesso não autorizado é proibido e será processado conforme a lei.
         Todas as atividades neste sistema são monitoradas.
***************************************************************************
EOL
check_status

#================================================================
# CONCLUSÃO
#================================================================
print_section "CONCLUSÃO DA CONFIGURAÇÃO"

echo -e "${GREEN}✓ Configuração do sistema concluída com sucesso!${NC}"
echo -e "\n${BOLD}Resumo das ações realizadas:${NC}"
echo -e "  ${BLUE}•${NC} Sistema atualizado e pacotes essenciais instalados"
echo -e "  ${BLUE}•${NC} Segurança básica configurada (firewall, fail2ban, AppArmor, etc.)"
echo -e "  ${BLUE}•${NC} Otimizações de sistema aplicadas"
echo -e "  ${BLUE}•${NC} Backup configurado com Timeshift"
echo -e "  ${BLUE}•${NC} Tarefas de manutenção agendadas"
echo -e "  ${BLUE}•${NC} Arquivo de log da execução: ${BOLD}$LOG_FILE${NC}"

echo -e "\n${YELLOW}➤ Recomendações:${NC}"
echo -e "  ${BLUE}•${NC} Reinicie o sistema para aplicar todas as alterações"
echo -e "  ${BLUE}•${NC} Verifique e ajuste as configurações de firewall conforme necessário"
echo -e "  ${BLUE}•${NC} Configure o Timeshift para realizar backups regulares"
echo -e "  ${BLUE}•${NC} Verifique o arquivo de log para possíveis erros ou avisos"

echo -e "\n${RED}ATENÇÃO:${NC} Algumas configurações de segurança podem requerer ajustes adicionais."
echo -e "         Sempre mantenha seu sistema atualizado e monitore regularmente os logs."

read -p "Deseja reiniciar o sistema agora? (s/n): " reboot_now
if [[ "$reboot_now" == "s" || "$reboot_now" == "S" ]]; then
    echo -e "\n${YELLOW}Reiniciando o sistema em 5 segundos...${NC}"
    sleep 5
    reboot
else
    echo -e "\n${YELLOW}Lembre-se de reiniciar o sistema posteriormente para aplicar todas as alterações.${NC}"
fi

# Fim do script
