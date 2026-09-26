# Chuleta: cifrado, hash y firma

Cuándo usar cada uno y algoritmos de referencia. Material de **criterio**, no de implementación ofensiva.

---

## 1. Tres ideas distintas

| Mecanismo | Objetivo | ¿Reversible? |
|-----------|----------|--------------|
| **Cifrado** | Confidencialidad | Sí, con clave |
| **Hash** | Integridad / huella | No (un solo sentido) |
| **Firma digital** | Integridad + autenticidad + no repudio* | Verificación con clave pública |

\*El no repudio depende del contexto legal y de la gestión de claves.

Relacionado: **MAC / HMAC** (integridad + autenticidad con clave compartida), distinto de firma asimétrica.

---

## 2. Cuándo usar cada uno

| Necesitas… | Usa |
|------------|-----|
| Ocultar datos en tránsito o en reposo | Cifrado (TLS, disco, vault) |
| Comprobar que un fichero no cambió | Hash (checksum) |
| Comprobar origen e integridad (autoría) | Firma (o MAC si hay secreto compartido) |
| Guardar contraseñas | Hash **lento** para passwords (Argon2/bcrypt), no cifrado |
| API autenticada con secreto compartido | HMAC |
| Certificados / identidad de servidor | PKI + TLS (firma de certs) |

---

## 3. Cifrado — referencia actual

### Simétrico (misma clave)

| Algoritmo | Notas |
|-----------|-------|
| **AES-256-GCM** | Estándar moderno AEAD (confidencialidad + integridad) |
| ChaCha20-Poly1305 | AEAD; excelente en software / móvil |
| AES-CBC sin MAC | Evitar diseños caseros; preferir AEAD |

### Asimétrico (par público/privado)

| Algoritmo | Uso típico |
|-----------|------------|
| **RSA** (2048+; 3072/4096 según política) | Firmas, encapsulación (legado) |
| **ECDSA** (P-256…) | Firmas eficientes |
| **Ed25519** | Firmas modernas (SSH, muchos ecosistemas) |
| **X25519** | Intercambio de claves (ECDH) |

TLS moderno combina asimétrico (handshake/autenticación) + simétrico (datos).

En reposo: cifrar con clave simétrica; proteger esa clave con KMS/HSM o wrapping asimétrico.

---

## 4. Hash — referencia

| Algoritmo | Uso |
|-----------|-----|
| **SHA-256** / **SHA-512** | Integridad general, huellas |
| SHA-3 / BLAKE2/BLAKE3 | Alternativas modernas |
| MD5 / SHA-1 | **Solo legado**; no para seguridad nueva |

```bash
sha256sum fichero
sha512sum fichero
```

Hash ≠ cifrado: cualquiera puede recalcular un hash; no oculta contenido.

---

## 5. Firma y verificación (flujo mental)

1. Hash del mensaje/documento.
2. Firma del hash con **clave privada**.
3. Cualquiera verifica con **clave pública**.

| Sistema | Ejemplo |
|---------|---------|
| OpenSSH | claves `ed25519` / certificados SSH |
| OpenSSL / CMS | firmas de ficheros |
| Paquetes | firmas de distro (apt/rpm) |
| Git | commits/tags firmados (GPG/SSH) |

HMAC: `HMAC-SHA256(clave, mensaje)` — ambas partes comparten la clave.

---

## 6. Errores frecuentes

| Error | Mejor |
|-------|-------|
| “Cifrar” contraseñas con AES y guardar la clave junto al dato | hash lento + sal |
| Usar MD5 para seguridad | SHA-256+ o firma/MAC |
| Inventar protocolos crypto | bibliotecas y modos AEAD de sobra probados |
| Reutilizar nonces en GCM | nonces únicos por clave |
| Confundir encoding (Base64) con cifrado | Base64 es solo representación |

---

## 7. Checklist

| Objetivo | Elección habitual |
|----------|-------------------|
| Tráfico web | TLS 1.2+ (1.3 preferible) |
| Disco/portátil | LUKS / FileVault / BitLocker |
| Firma de commits o artefactos | Ed25519 / RSA según ecosistema |
| Huella de fichero | SHA-256 |
| Password store | Argon2id / bcrypt |

---

*Biblioteca — Ciberseguridad · cifrado / hash / firma*
