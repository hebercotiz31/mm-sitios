# Instrucciones globales

<!-- Este archivo es la fuente de verdad de ~/.claude/CLAUDE.md en todas las máquinas.
     ~/.claude/CLAUDE.md es un symlink a este archivo (lo crea bootstrap.sh).
     Editar acá + git push → git pull en la otra máquina lo sincroniza. -->

<!-- mm-sitios:pointer -->
## Trabajos sobre webs de clientes (WordPress / hosting)

Para **cualquier tarea sobre un sitio o cliente** (WordPress, hosting, cPanel, dominios, DNS), el manual operativo y el inventario viven en `/home/hebercot/sitios/` — **aplica desde cualquier directorio, no solo desde ahí**:

- Leer `/home/hebercot/sitios/CLAUDE.md` antes de actuar: escalera de acceso, reglas de seguridad, cómo delega Heber, referencia API cPanel/WHM.
- Inventario en `/home/hebercot/sitios/registro.md` (dominio → acceso → item Bitwarden). Backlog en `/home/hebercot/sitios/pendientes-apppass.md`.
- Credenciales: Bitwarden CLI (`bw`). Si la bóveda está bloqueada, pedir a Heber `! bw unlock` y usar `--session`.
- Regla de oro: secretos solo en Bitwarden; confirmar antes de mutar producción.
<!-- /mm-sitios:pointer -->
