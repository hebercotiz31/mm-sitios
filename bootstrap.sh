#!/usr/bin/env bash
# Prepara una máquina nueva (ej. el server Ubuntu 192.168.1.3) para el sistema de
# delegación de sitios. Idempotente: se puede correr varias veces sin romper nada.
# NO instala secretos — las credenciales viven en Bitwarden (bw login).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

say(){ printf '\n\033[1;36m==>\033[0m %s\n' "$1"; }
warn(){ printf '\033[1;33m[!]\033[0m %s\n' "$1"; }

# 1. Requisitos base
say "Verificando requisitos"
command -v node >/dev/null || { warn "Node.js no está instalado. Instalá Node 18+ (ej: 'sudo apt install nodejs npm' o nvm) y volvé a correr."; exit 1; }
command -v jq   >/dev/null || { warn "jq no está instalado. Instalá con 'sudo apt install jq' y volvé a correr."; exit 1; }
echo "node $(node --version), jq OK"

# 2. Bitwarden CLI
if command -v bw >/dev/null; then
  echo "bw ya instalado ($(bw --version 2>/dev/null))"
else
  say "Instalando @bitwarden/cli"
  if npm i -g @bitwarden/cli 2>/dev/null; then
    echo "instalado"
  else
    warn "npm global falló (probablemente permisos). Probá: 'sudo npm i -g @bitwarden/cli' o configurá un prefix de usuario (npm config set prefix ~/.npm-global)."
  fi
fi

# 3. Fusionar reglas de permiso de bw en ~/.claude/settings.json (sin pisar lo existente)
say "Fusionando permisos de bw en $SETTINGS"
mkdir -p "$CLAUDE_DIR"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
PERMS="$REPO_DIR/claude/settings-permissions.json"
tmp="$(mktemp)"
jq -s '
  .[0] as $cur | .[1] as $add
  | $cur
  | .permissions.allow = (((.permissions.allow // []) + ($add.permissions.allow // [])) | unique)
' "$SETTINGS" "$PERMS" > "$tmp" && mv "$tmp" "$SETTINGS"
echo "reglas allow ahora:"; jq -r '.permissions.allow[]' "$SETTINGS" | sed 's/^/  - /'

# 3b. Instalar el puntero global en ~/.claude/CLAUDE.md (para que el contexto de sitios
#     esté disponible desde CUALQUIER directorio, no solo desde ~/sitios). Idempotente.
say "Instalando puntero global en $CLAUDE_DIR/CLAUDE.md"
GLOBAL_MD="$CLAUDE_DIR/CLAUDE.md"
if grep -q "mm-sitios:pointer" "$GLOBAL_MD" 2>/dev/null; then
  echo "puntero ya presente"
else
  { [ -s "$GLOBAL_MD" ] || echo "# Instrucciones globales"; echo ""; cat "$REPO_DIR/claude/global-pointer.md"; } >> "$GLOBAL_MD"
  echo "puntero agregado"
fi

# 4. Copiar archivos de memoria (referencia; el cerebro operativo real es ./CLAUDE.md)
say "Copiando memoria de referencia"
MEMDIR="$CLAUDE_DIR/projects/$(echo "$HOME/sitios" | sed 's#/#-#g')/memory"
mkdir -p "$MEMDIR"
cp -n "$REPO_DIR"/claude/memory/*.md "$MEMDIR"/ 2>/dev/null && echo "memoria en $MEMDIR" || echo "(sin archivos de memoria nuevos que copiar)"

cat <<EOF

\033[1;32mListo.\033[0m Pasos que quedan a mano en esta máquina:
  1) bw login                 # una vez, con tu cuenta Bitwarden
  2) bw unlock                # cada sesión de trabajo; copiá la clave BW_SESSION
  3) Ejecutá Claude Code desde este directorio ($REPO_DIR) para que lea CLAUDE.md
EOF
