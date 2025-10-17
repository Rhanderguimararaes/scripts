# 🚀 Full Automation Stack Installer
### Instalação completa da sua infraestrutura de automação em apenas **um comando**

Este instalador configura automaticamente um **servidor Ubuntu 24.04** com:
- Docker + Docker Compose  
- Traefik (HTTPS automático via Let's Encrypt)  
- Portainer (gerenciador visual de containers)  
- n8n (automação de fluxos e bots)  
- Chatwoot (atendimento inteligente via WhatsApp e web)  
- Evolution API (integração com WhatsApp)  
- MinIO (armazenamento de arquivos)  
- RabbitMQ (filas para automação)  
- Supabase + PostgreSQL Vetorizado  
- Redis dedicado  

Tudo pronto para rodar automações de vídeos, bots de atendimento e fluxos de IA. ⚙️  

---

## 🧩 **Pré-requisitos**
Antes de rodar o instalador, você precisa de:

1. 🖥️ VPS com **Ubuntu 24.04 LTS** (acesso root via SSH)  
2. 🌐 Um **domínio** configurado no Cloudflare apontando para o IP da VPS  
3. 📧 Um **e-mail SMTP** válido (ex: Gmail, Outlook, Zoho) para envio de notificações e recuperação de senha  

---

## ⚙️ **Instalação Automática**

Acesse sua VPS via SSH e execute o comando abaixo:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Rhanderguimararaes/scripts/main/install_stack.sh)

