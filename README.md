# scripts
#!/bin/bash
# ============================================
# Auto Installer - Full Stack Automation Server
# Ubuntu 24.04 LTS - By Rhander & GPT-5 💪
# ============================================

set -e

# -------- CONFIGURAÇÕES INICIAIS --------
echo "🚀 Iniciando instalação completa do servidor de automação..."
sleep 2

# Atualizar e instalar dependências básicas
apt update && apt upgrade -y
apt install -y curl git ufw fail2ban openssl apt-transport-https ca-certificates gnupg lsb-release

# Segurança básica
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Configuração do Fail2Ban
cat << EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
maxretry = 3
bantime = 3600
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# -------- DOCKER & COMPOSE --------
echo "🐳 Instalando Docker e Docker Compose..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -------- DIRETÓRIO DO PROJETO --------
mkdir -p /opt/stack && cd /opt/stack
docker network create web || true
docker network create internal --internal || true

# -------- GERAR CREDENCIAIS --------
echo "🔐 Gerando credenciais automáticas..."
gen_pass() { openssl rand -hex 16; }

DOMAIN="modela.click"
LE_EMAIL="rhander@gmail.com"
SMTP_USERNAME="rhander@gmail.com"
SMTP_PASSWORD="xwkdxorrrahqccoh"
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_FROM_EMAIL="rhander@gmail.com"

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
SMTP_FROM_EMAIL=$SMTP_FROM_EMAIL
YOUTUBE_API_KEY=sua_youtube_key
OPENAI_API_KEY=sua_openai_key
EOF

# -------- DOCKERFILE E COMPOSE --------
echo "⚙️ Criando Dockerfile e docker-compose..."
cat << 'DOCKER' > Dockerfile.n8n
FROM n8nio/n8n:latest
USER root
RUN apk add --no-cache ffmpeg
USER node
DOCKER

# (Aqui você pode inserir o docker-compose.yml original do manual — já testado.)

# -------- INICIAR STACK --------
docker compose build
docker compose up -d

echo "✅ Instalação concluída!"
echo "Acesse seus serviços via HTTPS: traefik.$DOMAIN, portainer.$DOMAIN, n8n.$DOMAIN etc."
