# Plantilla LDIF para crear un nuevo usuario de correo

# Define el DN (Distinguished Name) del usuario.
# ou=users,{{ LDAP_SEARCH_BASE }} debe existir.
dn: uid=%%USERNAME%%,ou=users,{{ LDAP_SEARCH_BASE }}
objectClass: inetOrgPerson
objectClass: top
# Asegúrate de que el schema 'qmail' o similar esté disponible si usas estos atributos.
# Por simplicidad, usaremos atributos estándar.
cn: %%USERNAME%%
sn: %%USERNAME%%
mail: %%EMAIL%%
userPassword: %%PASSWORD%%
