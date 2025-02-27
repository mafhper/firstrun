t# Ubuntu Setup Script - README

## Visão Geral
Este script foi desenvolvido para automatizar a configuração de um sistema Ubuntu recém-instalado, implementando boas práticas de segurança, desempenho e manutenção. O objetivo é fornecer uma base sólida e segura para o seu sistema, economizando tempo e garantindo que configurações importantes não sejam esquecidas.

## Funcionalidades Principais

### 1. Atualização do Sistema
**Propósito:** Manter o sistema atualizado é fundamental para segurança e estabilidade.
```bash
apt update && apt upgrade -y
```
Esta função atualiza a lista de pacotes disponíveis e, em seguida, atualiza todos os pacotes instalados para suas versões mais recentes.

### 2. Instalação de Pacotes Essenciais
**Propósito:** Instalar um conjunto básico de ferramentas úteis para administração do sistema.
```bash
apt install -y build-essential software-properties-common apt-transport-https ca-certificates curl wget git vim htop net-tools unzip gnupg lsb-release ufw fail2ban
```
Inclui:
- `build-essential`: Ferramentas para compilação de software
- `git`, `vim`: Ferramentas para desenvolvimento
- `htop`, `net-tools`: Monitoramento do sistema
- `ufw`, `fail2ban`: Ferramentas de segurança

### 3. Configuração do Firewall (UFW)
**Propósito:** Implementar uma barreira de segurança básica para proteger contra acessos não autorizados.
```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
```
Esta configuração:
- Bloqueia todas as conexões de entrada por padrão
- Permite todas as conexões de saída
- Abre apenas as portas necessárias (SSH, HTTP, HTTPS)

### 4. Configuração do Fail2ban
**Propósito:** Proteger contra tentativas de força bruta e outros ataques persistentes.
```bash
systemctl enable fail2ban
systemctl start fail2ban
```
O Fail2ban monitora logs do sistema e bloqueia temporariamente IPs que mostram comportamento malicioso (como múltiplas tentativas de login falhas).

### 5. Atualizações Automáticas
**Propósito:** Garantir que patches de segurança sejam aplicados sem intervenção manual.
```bash
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```
Configura o sistema para baixar e instalar atualizações de segurança automaticamente.

### 6. Otimizações do Sistema
**Propósito:** Melhorar desempenho ajustando parâmetros do kernel.
```bash
echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf
```
- `vm.swappiness=10`: Reduz o uso de swap quando há memória RAM disponível
- `vm.vfs_cache_pressure=50`: Ajusta o equilíbrio entre cache de arquivos e memória disponível

### 7. Limpeza do Sistema
**Propósito:** Remover pacotes desnecessários para liberar espaço em disco.
```bash
apt autoremove -y
apt autoclean
```
Remove pacotes que não são mais necessários e limpa o cache de pacotes APT.

### 8. Configuração de Backup (Timeshift)
**Propósito:** Permitir a recuperação do sistema em caso de falhas.
```bash
add-apt-repository -y ppa:teejee2008/ppa
apt update
apt install -y timeshift
```
O Timeshift cria snapshots do sistema, facilitando a restauração em caso de problemas.

### 9. Ferramentas Adicionais
**Propósito:** Instalar utilitários específicos para melhorar a usabilidade e segurança.

Inclui:
- Suporte a arquivos compactados (`p7zip-full`, `rar`, etc.)
- Ferramentas de detecção de rootkits (`rkhunter`, `chkrootkit`)
- Ferramentas de monitoramento (`sysstat`, `iotop`)

### 10. Manutenção Programada
**Propósito:** Automatizar tarefas de manutenção periódicas.
```bash
# Cria script de manutenção e agenda execução semanal
echo "0 2 * * 0 root /usr/local/bin/system_maintenance.sh > /var/log/system_maintenance.log 2>&1" > /etc/cron.d/system_maintenance
```
Configura uma tarefa cron para executar semanalmente:
- Atualização do sistema
- Limpeza de pacotes
- Verificação de segurança

## Como Usar
1. Salve o script como `setup_ubuntu.sh`
2. Torne-o executável com `chmod +x setup_ubuntu.sh`
3. Execute-o como superusuário: `sudo ./setup_ubuntu.sh`
4. Reinicie o sistema após a conclusão

## Personalização
O script foi projetado para ser modificado de acordo com necessidades específicas:
- Comente ou descomente seções conforme necessário
- Adicione pacotes específicos para seu caso de uso
- Ajuste as regras de firewall para seus serviços

## Considerações de Segurança
- Revise cuidadosamente as regras do firewall antes de ativá-lo
- Ao usar em servidores de produção, considere medidas de segurança adicionais
- Teste o script em um ambiente controlado antes de aplicá-lo em sistemas críticos

## Manutenção
Após a instalação inicial, é recomendado:
- Verificar periodicamente se as tarefas de manutenção estão sendo executadas
- Conferir os backups do Timeshift
- Revisar logs do sistema em `/var/log/` para quaisquer problemas
