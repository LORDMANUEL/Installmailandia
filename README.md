# Mail-in-a-Box: Next Generation

## Visión General

Este proyecto tiene como objetivo crear una solución de servidor de correo auto-alojada, completa y fácil de desplegar. La plataforma permitirá a los usuarios instalar y configurar un servidor de correo robusto y seguro con solo unos pocos clics, a través de una interfaz web intuitiva. La filosofía principal es la flexibilidad y la elección, permitiendo al usuario seleccionar diferentes componentes open source para cada parte del stack (MTA, IMAP, Webmail, etc.).

## Arquitectura

La arquitectura se basa en microservicios contenerizados utilizando **Docker** y **Docker Compose**. Este enfoque garantiza:
- **Aislamiento:** Cada componente (Postfix, Dovecot, etc.) se ejecuta en su propio contenedor, evitando conflictos.
- **Portabilidad:** La misma configuración funciona en cualquier máquina con Docker.
- **Escalabilidad:** Se pueden escalar componentes individuales según sea necesario.
- **Facilidad de instalación:** Un simple `docker-compose up` es suficiente para levantar todo el stack.

## Puesta en Marcha

1.  **Configurar el Dominio:**
    - Antes de iniciar, abre el archivo `docker-compose.yml`.
    - Busca la línea `hostname: mail.example.com` y reemplázala con tu propio dominio de correo (ej. `mail.tudominio.com`). Este FQDN (Fully Qualified Domain Name) es esencial para que el servidor se identifique correctamente.

2.  **Generar Certificados SSL con Let's Encrypt:**
    - Para asegurar las conexiones, el servidor está configurado para usar certificados de Let's Encrypt.
    - Necesitas generar estos certificados antes de iniciar el servidor por primera vez. Para ello, puedes usar Certbot en un contenedor de Docker. Asegúrate de que el puerto 80 no esté en uso.
    - Ejecuta el siguiente comando, reemplazando `mail.tudominio.com` con tu FQDN:
      ```bash
      sudo docker run --rm -it \
        -v "$(pwd)/letsencrypt:/etc/letsencrypt" \
        -p 80:80 \
        certbot/certbot certonly --standalone -d mail.tudominio.com
      ```
    - Este comando guardará los certificados en el directorio `letsencrypt`, que será utilizado por el contenedor del servidor de correo.

3.  **Iniciar el Servidor:**
    - Una vez configurado el dominio y generados los certificados, inicia el stack con:
      ```bash
      sudo docker compose up -d
      ```

## Fases del Proyecto

### Fase 1: El Núcleo del Servidor de Correo
El objetivo es tener un servidor de correo funcional que pueda enviar y recibir emails.
- **MTA (Agente de Transferencia de Correo):** Postfix (con opciones para Exim, etc. en el futuro).
- **Servidor IMAP/POP3:** Dovecot (con opciones futuras).
- **Webmail:** SnappyMail por defecto, con la opción de elegir otros como Roundcube, Rainloop, etc.

### Fase 2: Capa de Seguridad Esencial
- **Antispam:** SpamAssassin
- **Antivirus:** ClamAV
- **Cifrado:** Configuración automática de TLS con Let's Encrypt.

### Fase 3: Herramientas de Colaboración (Groupware)
- **Calendario y Contactos (CalDAV/CardDAV):** Integrado con **Baïkal**.
  - Para configurar tus calendarios y contactos, accede a la interfaz de administración de Baïkal en `http://<IP_DEL_SERVIDOR>:8081`.
  - La primera vez que accedas, sigue el asistente de instalación.
  - Podrás crear usuarios y compartir calendarios y libretas de direcciones.
- **Chat Integrado:** Servidor XMPP (Prosody o Ejabberd).
- **Videollamadas:** Integración de Jitsi Meet.

### Fase 4: Automatización y Panel de Administración Web
- **Panel de Administración:** Una interfaz web para gestionar usuarios, dominios, backups y ver el estado del servidor.
- **Instalador Web:** Un asistente de configuración inicial que guíe al usuario en la elección de componentes y la configuración inicial.

### Fase 5: Funcionalidades Avanzadas e "IA"
- **Inteligencia de Seguridad:** Detección de anomalías y entrenamiento de filtros de spam.
- **Alta Disponibilidad:** Soporte para IPs redundantes y balanceo de carga.
- **Auditoría y Firmas Digitales:** Herramientas para auditoría forense y soporte para S/MIME o PGP.
