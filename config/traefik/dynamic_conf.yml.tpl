# dynamic_conf.yml.tpl - Configuración dinámica de TLS para Traefik
# Este archivo es generado por el script setup.sh

tls:
  certificates:
    - certFile: "/etc/letsencrypt/live/%%FQDN%%/fullchain.pem"
      keyFile: "/etc/letsencrypt/live/%%FQDN%%/privkey.pem"
