# mm-sitios — sistema de delegación WordPress / Hosting

Base de operaciones para delegar tareas sobre los sitios de clientes a Claude Code, sin perder tiempo buscando credenciales. Funciona igual en la laptop (Fedora) y en el server (Ubuntu 192.168.1.3).

## Qué hay acá

- **`registro.md`** — inventario de sitios (dominios, usuarios, tipo de acceso). **Sin secretos.**
- **`CLAUDE.md`** — instrucciones que Claude lee solo al trabajar desde este directorio: cómo sacar credenciales de Bitwarden y qué herramienta usar por sitio.
- **`bootstrap.sh`** — prepara una máquina nueva (instala `bw` CLI, fusiona permisos, copia memoria).
- **`claude/`** — permisos de `bw` para `settings.json` + copia de la memoria persistente.

## Modelo de seguridad

Los secretos viven **solo en Bitwarden** (bóveda cloud). Este repo puede ser privado y no contiene ni una contraseña. Bitwarden se encarga de que las credenciales estén disponibles en cualquier máquina con `bw login`.

## Setup en una máquina nueva

```bash
git clone <URL-del-repo> ~/sitios
cd ~/sitios
./bootstrap.sh        # instala bw CLI, fusiona permisos, copia memoria
bw login              # una vez, con la cuenta Bitwarden
```

Después, para trabajar: `bw unlock` (cada sesión) y ejecutar Claude Code **desde `~/sitios`**.

## Sincronizar cambios entre máquinas

```bash
git pull      # traer lo último antes de trabajar
git add -A && git commit -m "..." && git push   # subir cambios del registro
```
