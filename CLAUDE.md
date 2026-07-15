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
- **Nunca** dejar scripts PHP autoejecutables (ni ningún ejecutable) en el docroot de un sitio de producción para generar o extraer credenciales. Ese patrón es un *webshell* y crea una superficie RCE en el sitio del cliente — está prohibido aunque parezca la vía rápida, y el clasificador de permisos lo bloquea con razón. Para recuperar acceso usar siempre vías oficiales (WP Toolkit, reset de contraseña).
- Confirmar con el usuario antes de: borrar contenido, desactivar plugins en producción, cambios de DNS, suspender cuentas, migraciones, y **escribir archivos en un sitio de producción**.
- En sitios en producción, preferir operaciones de lectura para diagnóstico antes de tocar nada.

## Staging vs producción (¡verificar antes de asumir!)

- La cuenta cPanel del reseller **puede alojar solo el staging**, no el sitio principal. Ej.: `aybdental.es` en net1002 (cuenta `aybdentales`) es staging; la producción está en otro lado.
- El mapa "Cuentas del reseller (WHM)" de `registro.md` lista **cuentas cPanel**, que pueden ser entornos de staging, no los sitios en vivo. No tratar una cuenta WHM como el sitio de producción sin verificar (comparar el contenido/DNS del dominio real, o preguntar).
- Regla práctica: el dominio en producción y la cuenta cPanel homónima del reseller pueden ser cosas distintas. Ante la duda, confirmar con Heber cuál es cuál.

## Crear application passwords en WordPress (método correcto)

Se usan para el acceso `rest` (REST API con `curl -u "usuario:app_password"`). La mayoría de los sitios aún no las tienen. **Requisito:** hace falta una sesión válida de wp-admin — no se puede crear la primera app password con Basic Auth usando la contraseña normal (WordPress no lo permite).

**Cuando la contraseña wp-admin de la bóveda es válida** (flujo automatizable, sin dropear nada):
1. `GET /wp-login.php` con **headers de navegador** (setea el test cookie). Importante: el WAF del reseller (mod_security) devuelve **406** a requests sin pinta de navegador — mandar `User-Agent` de Chrome + `Accept: text/html,...` + `Accept-Language`.
2. `POST /wp-login.php` con `log`, `pwd`, `wp-submit=Log In`, `testcookie=1`, cookie jar (`-c`/`-b`).
3. Confirmar que quedó la cookie `wordpress_logged_in` en el jar.
4. `GET /wp-admin/profile.php`, extraer el nonce REST: `grep -oE '"nonce":"[a-f0-9]+"'` (viene en `wpApiSettings`).
5. `POST /wp-json/wp/v2/users/me/application-passwords` con header `X-WP-Nonce: <nonce>` + cookie, body JSON `{"name":"claude-<fecha>"}`. La respuesta trae `password` en claro **una sola vez**.
6. Guardar en la bóveda como `wp — dominio.com` (username + app password, note "application password REST API"). No pisar el item de la contraseña original.

**Cuando el login falla** (`ERROR: usuario o contraseña incorrectos`): la contraseña de la bóveda **está vencida** (pasa seguido). NO dropear PHP. Recuperar acceso por vía oficial y luego rehacer el flujo de arriba:
- Reseller / cualquier cPanel con **WP Toolkit** → botón "Iniciar sesión" (login de admin sin contraseña), o reset de contraseña desde ahí.
- Actualizar la contraseña vigente en la bóveda antes de continuar.

## Referencia API WHM / cPanel (sin SSH, puerto 2087)

Auth: `-H "Authorization: whm <usuario_reseller>:<TOKEN>"`. Servidores del reseller: `net1001.webcloud.es` (user `ftuluduf`) y `net1002.webcloud.es` (user `oggrinzn`); tokens en `whm — net100X.webcloud.es`.

- Listar cuentas: `GET /json-api/listaccts?api.version=1`
- Bridge a cPanel UAPI (v3): `GET/POST /json-api/cpanel` con `cpanel_jsonapi_user=<cuenta>&cpanel_jsonapi_apiversion=3&cpanel_jsonapi_module=<M>&cpanel_jsonapi_func=<F>`
- Docroot de una cuenta: módulo `DomainInfo`, func `domains_data`
- Leer archivo: `Fileman` / `get_file_content` (`dir`, `file`) → `.result.data.content`
- Escribir archivo: `Fileman` / `save_file_content` (`dir`, `file`, `content`) — **solo para tareas legítimas y confirmadas** (nunca webshells)
- Borrar archivo: **api2** (`cpanel_jsonapi_apiversion=2`) módulo `Fileman`, func `fileop`, `op=unlink`, `sourcefiles=<ruta-relativa-al-home>`, `doubledot=0` (las funcs UAPI v3 `remove_files`/`delete_files` NO existen)
- Entrar a cPanel sin la contraseña del cliente: func `create_user_session` (`service=cpaneld`)

## Convención de nombres en Bitwarden

- `wp — dominio.com` — login wp-admin o application password (campo custom `url`)
- `hosting — proveedor — cliente` — panel de hosting externo
- `whm — reseller` — token de API de WHM
- `ftp — dominio.com` / `dns — proveedor` / `ssh — dominio.com` — según aplique
