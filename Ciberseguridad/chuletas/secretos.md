# Chuleta: gestión de secretos

Principios para **proteger y rotar** secretos (claves API, contraseñas, tokens, certificados privados). No cubre técnicas para extraerlos.

---

## 1. Qué es un secreto

Cualquier dato que otorga acceso o descifra: contraseñas, API keys, tokens bearer, claves privadas SSH/TLS, cadenas de conexión, webhooks, etc.

Si está en un ticket, un chat o un repo, asume **comprometido** hasta rotarlo.

---

## 2. Principios

| Principio | Práctica |
|-----------|----------|
| **No en código** | Ni en git, ni en imágenes Docker en claro |
| **No en logs** | Enmascarar; cuidar dumps y traces |
| **Mínimo privilegio** | Secretos con alcance acotado (un servicio, un entorno) |
| **Un secreto, un uso** | Evitar la “llave maestra” compartida |
| **Rotación** | Caducidad y procedimiento de cambio |
| **Separación de entornos** | Dev ≠ staging ≠ prod |
| **Auditoría** | Quién leyó/cambió qué (si el vault lo permite) |

---

## 3. Dónde guardarlos (orientación)

| Sitio | Uso |
|-------|-----|
| **Vault / KMS / secret manager** | Preferido en producción (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault…) |
| Variables de entorno inyectadas en runtime | Aceptable si vienen del orquestador/vault, no de un `.env` en git |
| Ficheros con permisos estrictos | `chmod 600`, usuario dedicado; menos ideal que un vault |
| Almacén de CI (OIDC → cloud) | Evitar secrets estáticos largos en CI cuando se pueda |

Evitar: wikis, capturas, correo, repositorios “privados” como único control.

---

## 4. Ciclo de vida

```
Crear → Distribuir (canal seguro) → Usar → Rotar → Revocar → Auditar
```

| Fase | Notas |
|------|-------|
| Crear | Generar con suficiente entropía; no reutilizar |
| Distribuir | Fuera de banda segura / vault; no chat en claro |
| Rotar | Antes de caducar; tras salida de personal o sospecha |
| Revocar | Invalidar el valor antiguo, no solo “dejar de usarlo” |
| Auditar | Revisar accesos anómalos |

---

## 5. Repos y CI/CD

| Riesgo | Mitigación conceptual |
|--------|------------------------|
| Commit accidental | pre-commit / secret scanning; historial: rotar igual |
| `.env` en imagen | multi-stage; secretos en runtime |
| Secrets en variables CI | permisos de repo; preferir federación OIDC |
| Forks / PRs de terceros | no exponer secrets a workflows no confiables |

Si un secreto se filtró en git: **rótalo**; reescribir historia no basta si el repo se clonó.

---

## 6. Tipos y cuidados

| Tipo | Cuidado extra |
|------|----------------|
| Claves privadas SSH/TLS | passphrase; agent; HSM/KMS si aplica |
| Tokens de larga vida | Preferir cortos + refresh; scopes mínimos |
| Cadenas de BBDD | Usuario con privilegios mínimos; red privada |
| Webhooks | Firmar peticiones; secreto de verificación |

Complementa: [autenticación-autorización](autenticacion-autorizacion.md), [cifrado-hash-firma](cifrado-hash-firma.md).

---

## 7. Checklist

| Ítem | ☐ |
|------|---|
| Secretos de prod fuera del repo | |
| Distintos por entorno | |
| Rotación documentada y probada | |
| Escaneo de secretos en CI | |
| Acceso a vault con MFA / roles | |
| Plan de revocación ante fuga | |

---

*Biblioteca — Ciberseguridad · secretos*
