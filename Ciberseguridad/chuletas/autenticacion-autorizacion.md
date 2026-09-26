# Chuleta: autenticación y autorización

Factores de autenticación, hashes de contraseña, sesiones y mínimo privilegio. Referencia defensiva.

---

## 1. Autenticación ≠ autorización

| Concepto | Pregunta |
|----------|----------|
| **Autenticación (AuthN)** | ¿Quién eres? |
| **Autorización (AuthZ)** | ¿Qué puedes hacer? |
| **Contabilidad / auditoría** | ¿Qué hiciste? |

Fallar al separarlas: “si entró, puede todo” → exceso de privilegio.

---

## 2. Factores

| Factor | Ejemplos |
|--------|----------|
| Algo que **sabes** | contraseña, PIN |
| Algo que **tienes** | llave hardware, TOTP, smartcard |
| Algo que **eres** | biometría |

**MFA / 2FA**: combinar al menos dos tipos distintos. SMS es mejor que nada, pero preferible TOTP o llave (WebAuthn/FIDO2).

---

## 3. Contraseñas y hashes

Regla: **nunca** guardar contraseñas en claro. Solo **hash** (idealmente con sal y algoritmo lento).

| Enfoque | Uso | Notas |
|---------|-----|-------|
| Argon2id | Elección moderna recomendada | Parametrizable (memoria/tiempo) |
| bcrypt | Muy extendido | Cost factor ajustable |
| scrypt | Alternativa memory-hard | |
| PBKDF2 | Legado / muchos estándares | Preferir Argon2 si puedes |
| SHA-256/512 “a pelo” | **No** para contraseñas | Demasiado rápido |

Otros:

- **Sal** única por usuario → evita rainbow tables.
- **Pepper** opcional (secreto de servidor) además de la sal.
- Políticas: longitud > complejidad absurda; check contra listas de filtraciones.

En Linux local: hashes en `/etc/shadow` (algoritmos tipo `yescrypt`/`sha512crypt` según distro).

---

## 4. Sesiones y tokens (visión general)

| Mecanismo | Idea |
|-----------|------|
| Sesión servidor | ID opaco en cookie; estado en servidor |
| JWT / tokens | Credencial autocontenida o referencia; cuidar firma y caducidad |
| Cookies | `Secure`, `HttpOnly`, `SameSite` en web |
| Timeout | absolutos e idle; renovar con cuidado |

Buenas prácticas: caducidad corta, rotación, invalidación al logout y al cambio de contraseña, amarre a contexto si aplica (IP/dispositivo con matices).

---

## 5. Autorización y mínimo privilegio

| Principio | Práctica |
|-----------|----------|
| Mínimo privilegio | Solo permisos necesarios para la tarea |
| Necesidad de saber | Separar roles/datos sensibles |
| Separación de deberes | Evitar un solo rol con todo el poder |
| Defensa en profundidad | AuthZ en app **y** en datos/infra |

Modelos: ACL, RBAC (roles), ABAC (atributos). En sistemas: grupos OS, sudo acotado, IAM cloud con políticas.

---

## 6. Fallos típicos a evitar

| Fallo | Mejor práctica |
|-------|----------------|
| Credenciales en código/repos | secretos en vault / env protegido |
| AuthZ solo en UI | validar siempre en servidor |
| Sesiones sin caducidad | TTL + revocación |
| Un usuario admin compartido | cuentas nominativas + auditoría |
| MFA solo en “parte” del acceso | cubrir VPN, correo, SSH, cloud |

---

## 7. Checklist

| Objetivo | Acción |
|----------|--------|
| Guardar secretos de usuario | hash lento + sal (Argon2id/bcrypt) |
| Acceso admin | MFA + cuentas individuales |
| Privilegios | revisar roles periódicamente |
| Sesión | cookies endurecidas + timeout |
| Auditoría | logs de login/fallos/cambios de privilegio |

---

*Biblioteca — Ciberseguridad · autenticación / autorización*
