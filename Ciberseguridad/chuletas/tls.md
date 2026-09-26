# Chuleta: TLS — handshake y certificados

Idea del handshake TLS y lectura de certificados. Referencia defensiva (configuración y verificación), no explotación.

---

## 1. Para qué sirve TLS

| Propiedad | Cómo |
|-----------|------|
| Confidencialidad | Cifrado del canal |
| Integridad | AEAD / MAC del record |
| Autenticación del servidor | Certificado + cadena de confianza |
| (Opcional) Auth del cliente | Certificado de cliente |

HTTPS = HTTP sobre TLS. Versiones actuales a preferir: **TLS 1.2** y **1.3** (deshabilitar SSLv3/TLS 1.0/1.1 en servidores nuevos).

---

## 2. Handshake (visión simplificada)

### TLS 1.2 (clásico)

1. **ClientHello** — versiones, cipher suites, extensiones (SNI…).
2. **ServerHello** — elección de parámetros.
3. **Certificate** (+ clave / key exchange).
4. **Finished** — canal de aplicación cifrado.

### TLS 1.3 (más corto)

1. **ClientHello** (ya con key share).
2. **ServerHello** + Certificate + Finished (menos idas y vueltas).
3. Datos de aplicación antes / justo después según 0-RTT (cuidado: replay).

En Wireshark: filtros `tls.handshake.type == 1` (Client Hello), etc. (ver chuleta de captura).

---

## 3. Certificados X.509 — campos clave

| Campo | Significado |
|-------|-------------|
| **Subject** | A quién se emitió |
| **Issuer** | Quién firmó (CA) |
| **SAN** (Subject Alternative Name) | DNS/IP válidos para el cert (lo importante hoy) |
| **Validity** | `Not Before` / `Not After` |
| **Public key** | RSA/ECDSA… |
| **Signature** | Firma de la CA |

Cadena: **hoja (leaf)** → intermedias → **raíz** (en almacén de confianza del cliente).

```bash
# Ver certificado de un servidor
openssl s_client -connect ejemplo.org:443 -servername ejemplo.org </dev/null 2>/dev/null | openssl x509 -noout -text

openssl x509 -in cert.pem -noout -subject -issuer -dates -ext subjectAltName
```

---

## 4. SNI, nombres y confianza

| Concepto | Notas |
|----------|-------|
| **SNI** | El cliente indica el hostname en el ClientHello (virtual hosting HTTPS) |
| Validación de nombre | El hostname debe coincidir con SAN (o CN legado) |
| Cadena incompleta | Clientes estrictos fallan; servir intermediarias |
| Autofirmado | Útil en lab; los clientes lo rechazan sin excepción explícita |
| Let’s Encrypt / PKI pública | Cadena anclada a raíces públicas |

---

## 5. Cipher suites (criterio)

Preferir suites **AEAD** (GCM, ChaCha20-Poly1305) y forward secrecy (ECDHE en 1.2; 1.3 lo lleva de serie).

Evitar: exportación, NULL, RC4, 3DES, MD5/SHA1 en firmas nuevas.

```bash
# Prueba rápida de handshake (salida verbosa)
openssl s_client -connect ejemplo.org:443 -tls1_2
openssl s_client -connect ejemplo.org:443 -tls1_3
```

---

## 6. Fallos frecuentes

| Síntoma | Causa probable |
|---------|----------------|
| Name mismatch | Cert para otro hostname / falta SAN |
| Expired | Fuera de validity; renovar |
| Unknown CA / untrusted | Cadena rota o CA privada no importada |
| Handshake failure | versiones/ciphers sin solape |
| Hora incorrecta del cliente | “aún no válido” / expirado falso |

---

## 7. Checklist operativo

| Objetivo | Acción |
|----------|--------|
| Ver caducidad | `openssl x509 -dates` / monitorizar |
| Comprobar SAN | `-ext subjectAltName` |
| Probar desde cliente | `curl -vI https://…` |
| Servidor | TLS 1.2+ / 1.3, cadena completa, renovación automática |
| HSTS | cabecera tras HTTPS estable (ver HTTP) |

---

*Biblioteca — Ciberseguridad · TLS*
