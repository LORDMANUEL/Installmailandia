-- Configuración de Prosody - /etc/prosody/prosody.cfg.lua

-- Dominio virtual para el chat. Es crucial que coincida con tu FQDN.
-- Dominio virtual para el chat. Este valor es reemplazado por el script setup.sh
VirtualHost "%%FQDN%%"

-- Módulos activados por defecto.
modules_enabled = {
    "roster"; -- Maneja la lista de contactos
    "saslauth"; -- Autenticación
    "tls"; -- Cifrado de conexión
    "dialback"; -- Conexión s2s
    "disco"; -- Descubrimiento de servicios
    "carbons"; -- Sincronización de mensajes entre clientes
    "pep"; -- Avatares y más
    "private"; -- Almacenamiento privado XML
    "vcard"; -- Tarjetas de contacto
    "version"; -- Versión del servidor
    "uptime"; -- Tiempo de actividad
    "time"; -- Hora del servidor
    "ping"; -- Ping XMPP
    "mam"; -- Archivo de mensajes
    "csi"; -- Indicadores de estado del cliente
}

-- Configuración de autenticación LDAP
authentication = "ldap2"

ldap = {
    hostname = "ldap.%%FQDN%%",
    basedn = "%%LDAP_SEARCH_BASE%%",
    -- El DN de enlace y la contraseña serán gestionados por variables de entorno
    -- en el docker-compose para mayor seguridad.
    user = {
        filter = "(&(objectClass=inetOrgPerson)(uid=%%user%%))",
        usernamefield = "uid"
    }
}

-- Ruta de los certificados SSL (usaremos los de Let's Encrypt del servidor de correo)
-- NOTA: Esto requiere compartir el volumen de letsencrypt con este contenedor.
certificates = "/etc/letsencrypt/live/%%FQDN%%/"
key = "/etc/letsencrypt/live/%%FQDN%%/privkey.pem"
cert = "/etc/letsencrypt/live/%%FQDN%%/fullchain.pem"

-- Configuración de almacenamiento (usa el por defecto, sqlite3)
storage = "internal"

-- Log
log = {
    info = "/var/log/prosody/prosody.log";
    error = "/var/log/prosody/prosody.err";
}
