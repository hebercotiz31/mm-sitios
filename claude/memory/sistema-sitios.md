---
name: sistema-sitios
description: "Sistema de delegación de tareas WP/hosting — inventario en ~/sitios/registro.md, credenciales en Bitwarden CLI"
metadata: 
  node_type: memory
  type: project
  originSessionId: e3533993-d32a-478f-9b01-915e04c76d11
---

Sistema montado el 2026-07-15 para que Claude resuelva accesos a sitios sin que Heber busque credenciales:

- **Inventario:** `~/sitios/registro.md` (dominio, cliente, tipo de acceso, item de Bitwarden — SIN secretos). Convenciones y flujo completo en `~/sitios/CLAUDE.md`.
- **Credenciales:** Bitwarden CLI (`bw`, instalada global via npm). Obtener secretos puntuales con `bw get password/username/item "<nombre>"`. Si la bóveda está bloqueada, pedir a Heber que corra `! bw unlock`.
- **Convención de items:** `wp — dominio.com`, `whm — <host>` (token API por servidor), `hosting — proveedor — cliente`, `ftp — dominio.com`.
- **Sin SSH:** usar REST API de WP (application passwords), API WHM/cPanel (puertos 2087/2083 con token), FTP, o navegador como último recurso.
- **Regla de oro:** secretos SOLO en Bitwarden — nunca en registro.md, memoria, planes ni commits.
- **Reseller:** dos servidores WHM, `net1001.webcloud.es` y `net1002.webcloud.es` (webcloud.es / usuario reseller `oggrinzn`). Token de net1002 guardado en Bitwarden como `whm — net1002.webcloud.es` (59 cuentas, probado OK 2026-07-15). net1001 pendiente de token. Para entrar a una cuenta sin su contraseña: `create_user_session` de WHM.

**Portabilidad (repo git):** `~/sitios/` es un repo git (commit inicial hecho, sin secretos). Sincroniza laptop Fedora ↔ server Ubuntu 192.168.1.3 vía repo privado en GitHub. `gh` está en el server (no en la laptop), así que el repo remoto se crea desde el server. `bootstrap.sh` prepara una máquina nueva (instala bw CLI, fusiona permisos bw en settings.json, copia memoria). Claude corre **sobre todo en el server** (headless, ideal para multi-agente con Chrome). Cerebro operativo portable = `~/sitios/CLAUDE.md` (se lee al correr claude desde ese dir).

**Repo remoto:** `github.com/hebercotiz31/mm-sitios` (privado). Laptop y server Ubuntu (`hebercotserver`, /home/hebercot/sitios) clonan y trackean `origin/main`. Auth GitHub por SSH en ambas (cuenta hebercotiz31). `gh` NO está instalado en ninguna de las dos (el remoto se creó por web + push desde laptop). Flujo de sync: `git pull` antes de trabajar, `git push` después.

**Estado al 2026-07-15:** Portabilidad COMPLETA — laptop y server espejados (commit 91f5bb0). Bitwarden con 633 items (349 logins WP, ~200 dominios), token WHM net1002 en bóveda y probado (59 cuentas). Pendiente: token WHM net1001; renombrar items a convención `wp — dominio`; application passwords WP; piloto con 2 sitios. En el server falta confirmar que Claude Code esté instalado (bootstrap no lo instala).

**Workflow diario:** `cd ~/sitios && git pull` → `bw unlock` (copiar clave) → correr Claude desde ahí → pedir tareas en lenguaje natural → `git push` si cambió el registro → `bw lock` al terminar.

Usuario: [[heber-perfil]]. Ver también [[no-escanear-credenciales]].
