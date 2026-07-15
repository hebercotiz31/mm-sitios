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

**Estado al 2026-07-15:** Bitwarden con 633 items importados del navegador (349 logins WP, ~200 dominios). `~/sitios/registro.md` autogenerado. Token WHM net1002 activo. Pendiente: token net1001, renombrar items a la convención `wp — dominio`, application passwords, piloto. **Portabilidad:** debe funcionar también en el server Ubuntu 192.168.1.3 (ver estrategia de sync abajo).

Usuario: [[heber-perfil]]. Ver también [[no-escanear-credenciales]].
