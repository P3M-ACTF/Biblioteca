# Chuleta: respuesta a incidentes

Fases típicas (preparar → detectar → contener → erradicar → recuperar) y qué registrar. Marco de **proceso**, sin procedimientos ofensivos.

---

## 1. Objetivo

Reducir impacto, restaurar servicio con seguridad y aprender. Prioriza **contención del daño** y **preservación de evidencia** cuando haga falta investigar.

---

## 2. Fases (ciclo)

| Fase | Pregunta clave | Acciones típicas |
|------|----------------|------------------|
| **1. Preparar** | ¿Estamos listos? | inventarios, contactos, runbooks, backups, canales, roles |
| **2. Detectar e identificar** | ¿Qué ocurre? | alertas, triage, alcance, severidad, clasificación |
| **3. Contener** | ¿Cómo paramos la hemorragia? | corto plazo (aislar) y largo (evitar rebrote) |
| **4. Erradicar** | ¿Cuál es la causa? | eliminar malware/persistencia, cerrar vector, parchear |
| **5. Recuperar** | ¿Volvemos al servicio? | restaurar desde limpio, monitorizar, validar |
| **6. Lecciones aprendidas** | ¿Qué mejoramos? | post-mortem sin culpa, acciones correctivas |

Algunos marcos insertan **análisis** explícito entre detectar y contener; lo importante es no saltarse contención ni registro.

---

## 3. Severidad y decisión rápida

| Severidad | Ejemplos orientativos | Prioridad |
|-----------|----------------------|-----------|
| Crítica | ransomware activo, exfiltración masiva, DC caído | equipo completo / dirección |
| Alta | cuenta admin comprometida, malware en servidor clave | contención inmediata |
| Media | phishing con clic, malware contenido en endpoint | ticket + playbook |
| Baja | escaneo ruidoso, falso positivo probable | documentar / afinar alertas |

Criterios: impacto en negocio, datos afectados (PII/secretos), explotabilidad activa, extensión (1 host vs flota).

---

## 4. Contención — ideas seguras

| Medida | Notas |
|--------|-------|
| Aislar host de la red | VLAN quarantine, reglas firewall, desconectar *con cuidado* |
| Revocar credenciales / sesiones | tokens, claves API, contraseñas, certs |
| Bloquear IoC conocidos | hashes, dominios, IPs en controles existentes |
| Preservar evidencia | no “limpiar en caliente” si hay investigación forense |

Evita apagar a ciegas si necesitas memoria volátil; coordina con quien lidere el incidente.

---

## 5. Qué registrar (cadena mínima)

Documenta **desde el primer minuto** (UTC):

| Campo | Ejemplo |
|-------|---------|
| Fecha/hora (UTC) | `2026-09-26T12:00:00Z` |
| Quién detectó / canal | alerta SIEM, usuario, monitor |
| Sistemas afectados | hostname, IP, owner |
| Síntomas | qué se vio |
| Acciones tomadas | quién / qué / cuándo |
| Evidencias | rutas de logs, capturas, tickets |
| Hipótesis | vector probable (actualizable) |
| Comunicaciones | a quién se avisó |

Mantén un **timeline** único. No alteres originales: copia evidencias, calcula hashes (SHA-256), anota cadena de custodia si aplica.

---

## 6. Evidencias habituales (host Linux)

| Fuente | Utilidad |
|--------|----------|
| `journalctl` / `/var/log` | auth, servicios, kernel |
| Listados de procesos / sockets | `ps`, `ss` (capturas en el momento) |
| Cuentas y cron/systemd | persistencia |
| Históricos de paquetes | cambios recientes |
| Copias forenses | disco/memoria según procedimiento interno |

---

## 7. Recuperación y cierre

| Paso | Comprobación |
|------|--------------|
| Restaurar | desde backup **conocido bueno** o rebuild |
| Credenciales | rotadas tras compromiso |
| Monitorización extra | periodo de vigilancia post-incidente |
| Post-mortem | causa raíz, gaps, acciones con dueño y fecha |
| Actualizar playbooks | lo aprendido vuelve a “Preparar” |

---

## 8. Checklist de preparación (antes del incidente)

| Ítem | ☐ |
|------|---|
| Lista de contactos y escalado | |
| Inventario de activos críticos | |
| Backups probados y offline/inmutables si aplica | |
| Acceso de emergencia (break-glass) documentado | |
| Canal de crisis (chat/llamada) | |
| Plantilla de timeline / informe | |

---

*Biblioteca — Ciberseguridad · respuesta a incidentes*
