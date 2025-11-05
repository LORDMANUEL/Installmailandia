#!/bin/bash

# Aborta el script si cualquier comando falla.
set -e

# --- Verificaciones Iniciales ---
echo "--- Iniciando el Asistente de Configuración ---"

if [ ! -f .env ]; then
    echo "ERROR: No se encontró el archivo .env."
    echo "Por favor, copia .env.example a .env y define tu dominio (FQDN) antes de continuar."
    exit 1
fi

# Carga las variables de entorno desde el archivo .env
export $(grep -v '^#' .env | xargs)

if [ -z "$FQDN" ] || [ "$FQDN" == "mail.example.com" ]; then
    echo "ERROR: La variable FQDN no está configurada o sigue siendo el valor por defecto en tu archivo .env."
    echo "Por favor, edita el archivo .env y establece tu dominio real."
    exit 1
fi

if [ -z "$LETSENCRYPT_EMAIL" ] || [ "$LETSENCRYPT_EMAIL" == "admin@example.com" ]; then
    echo "ERROR: La variable LETSENCRYPT_EMAIL no está configurada o sigue siendo el valor por defecto en tu archivo .env."
    echo "Por favor, edita el archivo .env y establece tu email real."
    exit 1
fi

echo "Dominio configurado: $FQDN"
echo "Email de Let's Encrypt: $LETSENCRYPT_EMAIL"

# --- Configuración de Prosody (Chat) ---
echo "--- Configurando el servidor de chat (Prosody)... ---"
PROSODY_CONFIG_TPL="config/prosody/prosody.cfg.lua.tpl"
PROSODY_CONFIG_OUT="config/prosody/prosody.cfg.lua"

if [ ! -f $PROSODY_CONFIG_TPL ]; then
    echo "ERROR: No se encontró la plantilla de configuración de Prosody en $PROSODY_CONFIG_TPL"
    exit 1
fi

# Reemplaza el placeholder del dominio en la plantilla y crea el archivo de configuración final.
sed "s/%%FQDN%%/$FQDN/g" "$PROSODY_CONFIG_TPL" > "$PROSODY_CONFIG_OUT"
echo "Archivo de configuración de Prosody generado en $PROSODY_CONFIG_OUT"

# --- Configuración de Traefik (TLS) ---
echo "--- Configurando Traefik para TLS... ---"
TRAEFIK_DYN_CONFIG_TPL="config/traefik/dynamic_conf.yml.tpl"
TRAEFIK_DYN_CONFIG_OUT="config/traefik/dynamic_conf.yml"
sed "s/%%FQDN%%/$FQDN/g" "$TRAEFIK_DYN_CONFIG_TPL" > "$TRAEFIK_DYN_CONFIG_OUT"
echo "Archivo de configuración dinámica de Traefik generado."

# --- Generación de Certificados SSL ---
echo "--- Obteniendo certificados SSL con Let's Encrypt... ---"
echo "Certbot necesita usar el puerto 80. Asegúrate de que no esté bloqueado."

sudo docker run --rm -it \
  -v "$(pwd)/letsencrypt:/etc/letsencrypt" \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  --email $LETSENCRYPT_EMAIL \
  --agree-tos --no-eff-email \
  -d $FQDN -d dav.$FQDN

echo "¡Certificados SSL generados con éxito para $FQDN y dav.$FQDN!"

# --- Iniciar todos los servicios ---
echo "--- Levantando todos los servicios con Docker Compose... ---"
sudo docker compose up -d

echo "¡Servicios iniciados!"

# --- Creación de la primera cuenta de correo ---
echo "--- Creando la primera cuenta de correo... ---"
read -p "Introduce el nombre de usuario para tu primera cuenta de correo (ej. 'admin' para admin@$FQDN): " EMAIL_USER

sudo docker exec -ti mailserver setup email add "$EMAIL_USER@$FQDN"

echo "¡Cuenta de correo '$EMAIL_USER@$FQDN' creada con éxito!"

# --- Mensaje Final ---
echo ""
echo "--- ¡Configuración completada! ---"
echo "Tu servidor de correo está en funcionamiento."
echo ""
echo "Accede a tus servicios en:"
echo " - Webmail (SnappyMail): https://$FQDN"
echo " - Calendarios y Contactos (Baïkal): https://dav.$FQDN"
echo ""
echo "Recuerda configurar los registros DNS (MX, SPF, DKIM, DMARC) de tu dominio para que el correo funcione correctamente."
