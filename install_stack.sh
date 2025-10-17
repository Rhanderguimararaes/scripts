#!/bin/bash
# ==========================================================
#  🚀 Instalador Automático - Full Automation Stack
#  Autor: Rhander Guimarães & GPT-5
#  Sistema: Ubuntu 24.04 LTS
# ==========================================================

set -e
clear
echo "==============================================="
echo "🔥 INSTALADOR AUTOMÁTICO DA SUA STACK DE AUTOMAÇÃO 🔥"
echo "==============================================="
sleep 2

# -------- INTERAÇÃO COM O USUÁRIO --------
read -p "🌐 Digite o domínio principal (ex: modela.click): " DOMAIN
read -p "📧 Digite o e-mail principal (Let's Encrypt e notificações): " LE_EMAIL
read -p "✉️  Digite o e-mail SMTP (ex: seuemail@gmail.com): " SMTP_USERNAME
read -p "🔑 Digite a senha do aplicativo SMTP: " SMTP_PASSWORD
read -p "📮 Digite o servidor SMTP (ex: smtp.gmail.com): " SMTP_SERVER
read -p "📡 Digite a porta SMTP (ex: 587): " SMTP_PORT

# -------- FUNÇÃO GERAR SENHA --------
gen_pass() { openssl rand -hex 16; }

# -------- ATUALIZA E INSTALA DEPENDÊNCIAS --------
echo "🧱 Preparando o ambiente..."
apt update && apt upgrade -y
apt install -y curl git ufw fail2ban openssl apt-transport-https ca-certificates gnupg lsb-release

# -------- SEGURANÇA --------
echo "🛡️ Configurando segurança..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
maxretry = 3
bantime = 3600
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# -------- INSTALA DOCKER E COMPOSE --------
echo "🐳 Instalando Docker e Docker Compose..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------- DIRETÓRIO E REDES --------
mkdir -p /opt/stack && cd /opt/stack
docker network create web || true
docker network create internal --internal || true

# -------- GERA CREDENCIAIS AUTOMÁTICAS --------
echo "🔐 Gerando credenciais automáticas..."
DB_PASSWORD=$(gen_pass)
JWT_SECRET=$(gen_pass)
MINIO_ROOT_USER="minioadmin"
MINIO_ROOT_PASSWORD=$(gen_pass)
SUPABASE_ANON_KEY=$(gen_pass)
SUPABASE_SERVICE_KEY=$(gen_pass)
CHATWOOT_SECRET_KEY_BASE=$(gen_pass)
N8N_BASIC_AUTH_USER="admin"
N8N_BASIC_AUTH_PASSWORD=$(gen_pass)
EVOLUTION_API_KEY=$(gen_pass)
DASHBOARD_USERNAME="admin"
DASHBOARD_PASSWORD=$(gen_pass)
RABBITMQ_DEFAULT_USER="rabbitadmin"
RABBITMQ_DEFAULT_PASSWORD=$(gen_pass)
REDIS_PASSWORD=$(gen_pass)

# -------- CRIA .env --------
echo "🧾 Criando arquivo .env..."
cat << EOF > .env
DOMAIN=$DOMAIN
LE_EMAIL=$LE_EMAIL
DB_PASSWORD=$DB_PASSWORD
JWT_SECRET=$JWT_SECRET
MINIO_ROOT_USER=$MINIO_ROOT_USER
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY
CHATWOOT_SECRET_KEY_BASE=$CHATWOOT_SECRET_KEY_BASE
N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER
N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD
EVOLUTION_API_KEY=$EVOLUTION_API_KEY
DASHBOARD_USERNAME=$DASHBOARD_USERNAME
DASHBOARD_PASSWORD=$DASHBOARD_PASSWORD
RABBITMQ_DEFAULT_USER=$RABBITMQ_DEFAULT_USER
RABBITMQ_DEFAULT_PASSWORD=$RABBITMQ_DEFAULT_PASSWORD
REDIS_PASSWORD=$REDIS_PASSWORD
SMTP_SERVER=$SMTP_SERVER
SMTP_PORT=$SMTP_PORT
SMTP_USERNAME=$SMTP_USERNAME
SMTP_PASSWORD=$SMTP_PASSWORD
SMTP_FROM_EMAIL=$SMTP_USERNAME
EOF

# -------- DOCKERFILE PARA n8n --------
echo "⚙️ Gerando Dockerfile customizado do n8n..."
cat << 'DOCKER' > Dockerfile.n8n
FROM n8nio/n8n:latest
USER root
RUN apk add --no-cache ffmpeg
USER node
DOCKER

# -------- AVISO FINAL --------
echo ""
echo "✅ Instalação do ambiente base concluída!"
echo "------------------------------------------------"
echo "🌐 Domínio base: $DOMAIN"
echo "🔑 Credenciais salvas em: /opt/stack/.env"
echo ""
echo "📦 Próximos passos:"
echo "1️⃣ Copie ou adicione o docker-compose.yml completo no diretório /opt/stack"
echo "2️⃣ Rode os comandos abaixo:"
echo "    docker compose build"
echo "    docker compose up -d"
echo ""
echo "Acesse depois:"
echo "➡️ https://n8n.$DOMAIN"
echo "➡️ https://portainer.$DOMAIN"
echo "➡️ https://chatwoot.$DOMAIN"
echo "➡️ https://traefik.$DOMAIN"
echo ""
echo "✨ Feito por Rhander & GPT-5"
echo "---------------------------
