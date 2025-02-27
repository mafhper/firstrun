# 🐧 Script Avançado de Configuração e Boas Práticas para Ubuntu

Um script completo para configurar, otimizar e proteger sistemas Ubuntu recém-instalados ou existentes, aplicando boas práticas de segurança, desempenho e manutenção.

![Ubuntu Setup](https://i.imgur.com/GfJD8n0.png)

## 📋 Sumário

- [Visão Geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Utilização](#utilização)
- [Personalização](#personalização)
- [Referência das Seções](#referência-das-seções)
- [Segurança](#segurança)
- [Solução de Problemas](#solução-de-problemas)
- [Contribuições](#contribuições)
- [Licença](#licença)

## 🔍 Visão Geral

Este script foi desenvolvido para automatizar a configuração de sistemas Ubuntu, aplicando configurações recomendadas de segurança, desempenho e manutenção. Ele é interativo, permitindo que você escolha quais componentes deseja instalar e configurar, além de fornecer feedback visual durante todo o processo.

O script é ideal para:
- Administradores de sistemas que precisam configurar múltiplos servidores Ubuntu
- Usuários que desejam otimizar e proteger seus sistemas Ubuntu recém-instalados
- Equipes de DevOps que buscam padronizar ambientes de desenvolvimento

## ✨ Funcionalidades

O script inclui as seguintes funcionalidades principais:

### 1. Sistema e Pacotes
- ✅ Atualização completa do sistema (apt update, upgrade, dist-upgrade)
- ✅ Instalação de pacotes essenciais organizados por categorias
- ✅ Configuração opcional do Docker

### 2. Segurança
- 🔒 Configuração de firewall (UFW) com regras básicas
- 🔒 Proteção contra ataques de força bruta (Fail2ban)
- 🔒 Configuração segura do SSH
- 🔒 Verificação de rootkits (RKHunter, Chkrootkit)
- 🔒 Auditoria de segurança com Lynis
- 🔒 Configuração de AppArmor

### 3. Otimizações
- ⚡ Ajustes de kernel para melhor desempenho
- ⚡ Otimização de swappiness e cache
- ⚡ Configuração de limites de recursos do sistema
- ⚡ Otimização do agendador de disco
- ⚡ Configuração de TLP para laptops (economia de bateria)

### 4. Backup e Manutenção
- 💾 Instalação e configuração de Timeshift para backup do sistema
- 💾 Configuração de rsync para backup de dados
- 💾 Script de manutenção periódica agendado via cron
- 💾 Atualizações automáticas de segurança

### 5. Extras
- 🔧 Aliases úteis para todos os usuários
- 🔧 Banner de segurança para SSH
- 🔧 Log detalhado de todas as operações

## 📋 Requisitos

- Sistema Ubuntu (testado nas versões 18.04, 20.04, 22.04 e 24.04)
- Acesso de superusuário (root) ou permissões sudo
- Conexão com a internet (para baixar pacotes)

## 📥 Instalação

1. Faça o download do script:

```bash
wget https://raw.githubusercontent.com/seu-usuario/seu-repositorio/main/setup_ubuntu.sh
```

2. Torne o script executável:

```bash
chmod +x setup_ubuntu.sh
```

3. Execute como superusuário:

```bash
sudo ./setup_ubuntu.sh
```

Alternativamente, clone o repositório completo:

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
sudo ./setup_ubuntu.sh
```

## 🚀 Utilização

Ao executar o script, você será guiado por um processo interativo:

1. O script verificará se você está executando como root
2. Serão exibidas informações sobre o sistema detectado
3. Para cada seção principal, você poderá decidir se deseja prosseguir
4. Em pontos críticos (como ativar firewall ou reiniciar SSH), o script pedirá confirmação
5. Ao final, será exibido um resumo das ações realizadas e recomendações

### 📊 Arquivo de Log

Todas as operações são registradas em um arquivo de log em:
```
/var/log/ubuntu_setup_[data-hora].log
```

Este log é útil para revisar as ações realizadas e diagnosticar problemas.

## ⚙️ Personalização

Você pode personalizar o script editando-o e modificando as seguintes seções:

### Pacotes Instalados

Edite as variáveis no início da seção `INSTALAÇÃO DE PACOTES ESSENCIAIS`:

```bash
BASIC_PKGS="build-essential software-properties-common apt-transport-https ca-certificates curl wget git vim"
SYSTEM_PKGS="htop net-tools unzip gnupg lsb-release iotop sysstat ntp"
# ...
```

### Configurações de Segurança

Ajuste as regras de firewall na seção `CONFIGURAÇÃO DE SEGURANÇA`:

```bash
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
# Adicione mais regras conforme necessário
```

### Script de Manutenção

Personalize o script de manutenção periódica em:

```bash
cat > /usr/local/bin/system_maintenance.sh <<'EOL'
# ... edite o conteúdo aqui ...
EOL
```

### Agendamento de Tarefas

Altere a frequência das tarefas de manutenção:

```bash
cat > /etc/cron.d/system_maintenance <<EOL
# Altere para diário, mensal ou outra frequência
0 3 * * 0 root /usr/local/bin/system_maintenance.sh
EOL
```

## 📚 Referência das Seções

### 1. ATUALIZAÇÃO DO SISTEMA
Atualiza o sistema operacional para a versão mais recente dos pacotes instalados.

### 2. INSTALAÇÃO DE PACOTES ESSENCIAIS
Instala ferramentas básicas para administração do sistema, utilitários e aplicativos de segurança.

### 3. CONFIGURAÇÃO DE SEGURANÇA
Configura firewall, proteção contra invasões e hardening do sistema.

### 4. OTIMIZAÇÕES DO SISTEMA
Aplica configurações para melhorar o desempenho e a eficiência do sistema.

### 5. CONFIGURAÇÃO DE ATUALIZAÇÕES AUTOMÁTICAS
Configura o sistema para instalar automaticamente atualizações de segurança.

### 6. CONFIGURAÇÃO DE BACKUP
Instala e configura ferramentas para backup do sistema e dados.

### 7. TAREFAS DE MANUTENÇÃO AGENDADAS
Configura scripts para executar tarefas de manutenção periodicamente.

### 8. LIMPEZA FINAL
Remove arquivos temporários e pacotes desnecessários.

### 9. PERSONALIZAÇÃO ADICIONAL
Configura aliases úteis e banner de segurança.

## 🛡️ Segurança

Este script aplica várias camadas de segurança, mas é importante observar:

- **ATENÇÃO**: Antes de ativar o firewall ou alterar configurações SSH, certifique-se de que não perderá acesso ao sistema.
- Mantenha cópias de segurança antes de executar o script em ambientes de produção.
- O script faz backup dos arquivos de configuração antes de modificá-los, mas é recomendável ter backups adicionais.
- Algumas configurações de segurança podem precisar de ajustes adicionais dependendo do seu caso de uso específico.

## ❓ Solução de Problemas

### Problemas comuns e soluções:

1. **O script não executa**
   - Verifique se o script tem permissão de execução: `chmod +x setup_ubuntu.sh`
   - Certifique-se de estar executando como root ou com sudo

2. **Perdi acesso SSH após configuração**
   - Se você configurou o SSH para usar apenas chaves e não configurou corretamente, acesse o sistema diretamente e reverta as alterações: `nano /etc/ssh/sshd_config.bak.[timestamp]` e copie o conteúdo de volta.

3. **O firewall está bloqueando meu acesso**
   - Acesse o sistema diretamente e desative o firewall: `ufw disable`

4. **Erro em algum pacote durante a instalação**
   - Verifique o arquivo de log para identificar qual pacote falhou
   - Execute manualmente: `apt install -y nome-do-pacote`

5. **O script de manutenção não está sendo executado**
   - Verifique os logs: `grep system_maintenance /var/log/syslog`
   - Verifique se o arquivo cron está corretamente configurado: `cat /etc/cron.d/system_maintenance`

## 🤝 Contribuições

Contribuições são bem-vindas! Se você tem sugestões para melhorar este script:

1. Faça um fork do projeto
2. Crie um branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para o branch (`git push origin feature/nova-funcionalidade`)
5. Crie um Pull Request

## 📄 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

Desenvolvido com ❤️ para a comunidade Ubuntu.
