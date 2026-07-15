---
name: tareas-wp-lecciones
description: "Lecciones para tareas WP/hosting — app passwords, staging vs producción, WAF, prohibición de webshells"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e3533993-d32a-478f-9b01-915e04c76d11
---

Lecciones de la primera tanda de tareas sobre sitios de clientes (2026-07-15), aplican a [[sistema-sitios]]:

- **NO webshells en producción.** Para crear una WP application password cuando la contraseña de la bóveda está vencida, NO dejar un script PHP autoejecutable en el docroot (patrón webshell / superficie RCE). El clasificador de permisos lo bloquea con razón. Vía correcta: recuperar acceso con WP Toolkit (login sin contraseña / reset) y luego usar la API oficial de Application Passwords. **Why:** normalizar droppers sobre 200 sitios de clientes es un riesgo de seguridad grave. **How to apply:** ver el flujo detallado en `~/sitios/CLAUDE.md` → "Crear application passwords".

- **Contraseñas wp-admin de la bóveda suelen estar vencidas.** Verificar el login antes de asumir que sirve; si falla, es contraseña vieja, no el método.

- **Cuentas WHM del reseller ≠ sitios en producción.** Muchas alojan solo el staging. Confirmar cuál es cuál antes de operar como si fuera el sitio en vivo.

- **WAF del reseller (mod_security).** Devuelve HTTP 406 a requests sin headers de navegador; con `User-Agent` de Chrome + `Accept` + `Accept-Language` pasa.

- **cPanel sin SSH funciona** vía bridge WHM→UAPI para leer/escribir archivos, docroot, sesiones cPanel. Referencia completa en `~/sitios/CLAUDE.md` → "Referencia API WHM / cPanel". Borrado de archivos = api2 `Fileman fileop op=unlink` (las funcs v3 no existen).
