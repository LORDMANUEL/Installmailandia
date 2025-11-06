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

Este proyecto utiliza un script para automatizar la configuración. El proceso es muy simple:

**Paso 1: Configurar tu Dominio y Email**

1.  Copia la plantilla de configuración:
    ```bash
    cp .env.example .env
    ```
2.  Abre el archivo `.env` y configura las siguientes variables:
    *   `FQDN`: Tu dominio de correo real (ej. `mail.tudominio.com`).
    *   `LETSENCRYPT_EMAIL`: Tu dirección de email, para notificaciones de Let's Encrypt.

**Paso 2: Ejecutar el Asistente de Instalación**

Este script configurará los servicios, obtendrá los certificados SSL, iniciará el servidor y te guiará para crear tu primera cuenta de correo.

```bash
./setup.sh
```

¡Eso es todo! Una vez que el script finalice, tus servicios estarán disponibles en `https://tudominio.com` (webmail) y `https://dav.tudominio.com` (calendarios/contactos).

---

## Limitaciones Conocidas y Próximos Pasos

*   **Sistema de Usuarios Parcialmente Unificado:** Hemos dado el primer paso hacia una autenticación centralizada con OpenLDAP. Actualmente, el **servidor de correo** utiliza LDAP para la autenticación de usuarios. Sin embargo, los servicios de **Chat (Prosody)** y **Calendarios (Baïkal)** todavía utilizan sus propias bases de datos de usuarios. La unificación completa de todos los servicios con LDAP es el principal objetivo de la Fase 4.
*   **DNS:** Para que el correo funcione correctamente en Internet, debes configurar los registros DNS de tu dominio (MX, SPF, DKIM, DMARC). Consulta la documentación de `docker-mailserver` para obtener guías detalladas.

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
  - Puedes acceder a la interfaz de administración de Baïkal en `https://dav.TU_FQDN/admin`.
  - La primera vez que accedas, sigue el asistente de instalación para configurar la base de datos y tu usuario administrador.
- **Chat Integrado:** Integrado con **Prosody (XMPP)**.
  - El servidor de chat está configurado para permitir el registro de usuarios directamente desde un cliente XMPP compatible (como Gajim o Conversations). Conéctate a tu servidor y busca la opción "Registrar nueva cuenta".
  - Para conectar tu cliente, utiliza tu FQDN (ej. `mail.tudominio.com`) como dominio y el puerto 5222.
- **Videollamadas:** Integración de Jitsi Meet (Planificado).

### Fase 4: Autenticación Centralizada y Panel de Administración
- **Autenticación Centralizada (En Progreso):** Se ha implementado OpenLDAP como base. El servidor de correo ya lo utiliza. El objetivo principal de esta fase es migrar el resto de servicios (Prosody, Baïkal, etc.) para que se autentiquen contra LDAP.
- **Panel de Administración:** Una interfaz web para gestionar usuarios, dominios, backups y ver el estado del servidor.
- **Instalador Web:** Un asistente de configuración inicial que guíe al usuario en la elección de componentes y la configuración inicial.

### Fase 5: Funcionalidades Avanzadas e "IA"
- **Inteligencia de Seguridad:** Detección de anomalías y entrenamiento de filtros de spam.
- **Alta Disponibilidad:** Soporte para IPs redundantes y balanceo de carga.
- **Auditoría y Firmas Digitales:** Herramientas para auditoría forense y soporte para S/MIME o PGP.
