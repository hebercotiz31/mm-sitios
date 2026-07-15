# Gestión de sitios WordPress / Hosting

Este directorio es la base de operaciones para tareas sobre los sitios de clientes. El inventario vive en `registro.md`.

## Flujo para cualquier tarea sobre un sitio

1. Buscar el sitio en `registro.md` (por dominio o nombre de cliente) y ver su tipo de acceso.
2. Obtener la credencial puntual desde Bitwarden — nunca pedirla al usuario si ya está en la bóveda:
   - `bw get password "wp — dominio.com"` → contraseña/application password
   - `bw get username "wp — dominio.com"` → usuario
   - `bw get item "wp — dominio.com"` → item completo (JSON) para campos custom como URLs o tokens
3. Si `bw` responde que la bóveda está bloqueada, pedir al usuario que corra `! bw unlock` — la clave de sesión que imprime queda en la conversación. Como las shells de Claude no comparten env vars, pasarla con `--session '<clave>'` en cada comando `bw` (hay reglas de permiso para `bw get/list/sync/status/lock` en settings). Al terminar la jornada, sugerir `! bw lock` para invalidar la clave.
4. Ejecutar la tarea con la herramienta que indica la columna Acceso.
5. Reportar el resultado. Si algo del registro estaba desactualizado (PHP, hosting, acceso), actualizar la fila.

## Herramientas por tipo de acceso

- **`rest`** — WordPress REST API: `curl -u "usuario:app_password" https://dominio.com/wp-json/wp/v2/...`. Plugins: `/wp/v2/plugins`, posts: `/wp/v2/posts`, usuarios: `/wp/v2/users`.
- **`whm`** — API de WHM del reseller: `curl -H "Authorization: whm usuario_reseller:TOKEN" "https://servidor:2087/json-api/..."`. El token está en el item `whm — reseller` de Bitwarden. Para operar dentro de una cuenta puntual, usar `create_user_session` de WHM para obtener acceso cPanel/UAPI sin la contraseña del cliente.
- **`ftp`** — `lftp` con credenciales del item `ftp — dominio.com`.
- **`browser`** — Chrome DevTools MCP con `--isolated`; login manual del usuario si hay 2FA.
- **`ssh`** — excepción; alias en `~/.ssh/config` si existe.

## Reglas de seguridad (no negociables)

- **Nunca** escribir contraseñas, tokens ni application passwords en archivos de este directorio, en la memoria persistente, en planes, ni en commits. Solo nombres de items de Bitwarden.
- **Nunca** volcar la bóveda completa (`bw list items --raw` con secretos) a un archivo. `bw list items | jq '.[].name'` (solo nombres) está bien.
- Confirmar con el usuario antes de: borrar contenido, desactivar plugins en producción, cambios de DNS, suspender cuentas, migraciones.
- En sitios en producción, preferir operaciones de lectura para diagnóstico antes de tocar nada.

## Convención de nombres en Bitwarden

- `wp — dominio.com` — login wp-admin o application password (campo custom `url`)
- `hosting — proveedor — cliente` — panel de hosting externo
- `whm — reseller` — token de API de WHM
- `ftp — dominio.com` / `dns — proveedor` / `ssh — dominio.com` — según aplique
