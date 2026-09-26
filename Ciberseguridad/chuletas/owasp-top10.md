# Chuleta: OWASP Top 10

Nombre e **impacto** de cada categoría (OWASP Top 10:2021). Sin procedimientos de explotación ni payloads.

---

## 1. Para qué sirve

Lista prioritaria de riesgos en aplicaciones web. Úsala para **diseñar, revisar y priorizar controles**, no como manual ofensivo.

Referencia oficial: [OWASP Top 10](https://owasp.org/Top10/).

---

## 2. Las diez categorías (2021)

| Cód. | Nombre | Impacto típico si ocurre |
|------|--------|---------------------------|
| **A01** | Broken Access Control | Acceso a datos o funciones de otros usuarios; escalada horizontal/vertical; exposición masiva de objetos |
| **A02** | Cryptographic Failures | Lectura de secretos o datos sensibles en tránsito/reposo; compromiso de confidencialidad |
| **A03** | Injection | Ejecución o interpretación no deseada (p. ej. en consultas o comandos); manipulación de datos; toma de control lógica de la app |
| **A04** | Insecure Design | Flujos de negocio abusables aunque el código sea “correcto”; falta de controles de amenaza en el diseño |
| **A05** | Security Misconfiguration | Servicios expuestos, defaults inseguros, cabeceras/erratas verbosas; superficie innecesaria |
| **A06** | Vulnerable and Outdated Components | Bugs conocidos en librerías/runtime; compromiso vía dependencia |
| **A07** | Identification and Authentication Failures | Suplantación de identidad; toma de cuentas; bypass de login/sesión |
| **A08** | Software and Data Integrity Failures | Código o datos alterados (pipeline, actualizaciones, deserialización insegura); ejecución de artefacto no confiable |
| **A09** | Security Logging and Monitoring Failures | Incidentes no detectados o no auditables; respuesta tardía o imposible |
| **A10** | Server-Side Request Forgery (SSRF) | El servidor pide recursos internos/externos no previstos; acceso a metadatos de cloud o servicios de confianza |

---

## 3. Controles orientativos (alto nivel)

| Riesgo | Dirección de mitigación (concepto) |
|--------|-------------------------------------|
| A01 | Denegar por defecto; AuthZ en servidor; IDs indirectos; CORS/restrictivo |
| A02 | TLS; no secretos en claro; algoritmos adecuados; minimizar datos sensibles |
| A03 | Consultas parametrizadas; validación/allowlist; evitar shell con entrada de usuario |
| A04 | Modelado de amenazas; límites de negocio; “secure by design” |
| A05 | Hardening; mínimos privilegios de despliegue; sin stack traces públicos |
| A06 | Inventario; parches; SCA en CI |
| A07 | MFA; gestión de sesión; no mensajes de login filtrantes; rate limit |
| A08 | Firmas/integridad de artefactos; CI firmado; deserializar con cuidado |
| A09 | Logs de seguridad; alertas; retención; pruebas de detección |
| A10 | Allowlist de destinos; no esquemas internos; segmentación de red |

---

## 4. Cómo usarlo en revisión

| Pregunta | Categorías cercanas |
|----------|---------------------|
| ¿Quién puede ver/hacer X? | A01, A07 |
| ¿Hay datos sensibles? | A02, A01 |
| ¿Entrada llega a intérprete? | A03 |
| ¿Deps al día? | A06 |
| ¿Sabríamos si nos atacan? | A09 |
| ¿El servidor sale a URLs del usuario? | A10 |

---

## 5. Checklist corto de producto

| Ítem | ☐ |
|------|---|
| AuthZ comprobada en API (no solo UI) | |
| Secretos fuera del código; TLS en tránsito | |
| Consultas parametrizadas / APIs seguras | |
| Dependencias escaneadas y actualizadas | |
| Login/sesión endurecidos (MFA donde aplique) | |
| Logs de auth y fallos de autorización | |
| Salidas HTTP del servidor acotadas (anti-SSRF) | |

---

*Biblioteca — Ciberseguridad · OWASP Top 10*
