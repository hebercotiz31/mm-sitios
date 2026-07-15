---
name: no-escanear-credenciales
description: No escanear el sistema buscando gestores de credenciales/llaves SSH — el clasificador lo bloquea; preguntar al usuario
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e3533993-d32a-478f-9b01-915e04c76d11
---

En esta máquina, un comando que enumeraba gestores de contraseñas, `~/.ssh/` y configs fue bloqueado por el clasificador de permisos ("Credential Exploration").

**Why:** escanear dónde viven los secretos sin instrucción explícita parece exfiltración, aunque la intención sea ayudar.

**How to apply:** para saber dónde guarda credenciales el usuario, preguntarle (AskUserQuestion) en vez de escanear. Acceder a secretos solo por la vía acordada: `bw get` puntual según [[sistema-sitios]].
