# Chuleta: DNS

Tipos de registro, consulta con `dig`/`resolvectl` y nociones de caché.

---

## 1. Resolución en una frase

Nombre → consulta a resolvers → respuesta (IP, otro nombre, texto…) con **TTL** (tiempo en caché).

Orden típico en Linux: app → stub resolver (`systemd-resolved` / `nscd`) → `/etc/resolv.conf` → DNS configurado.

---

## 2. Tipos de registro habituales

| Tipo | Qué responde |
|------|----------------|
| **A** | IPv4 del nombre |
| **AAAA** | IPv6 del nombre |
| **CNAME** | Alias → otro nombre |
| **MX** | Servidores de correo (+ prioridad) |
| **NS** | Servidores autoritativos de la zona |
| **TXT** | Texto (SPF, verificación, etc.) |
| **SOA** | Inicio de autoridad (zona) |
| **PTR** | IP → nombre (DNS inverso) |
| **SRV** | Servicio (host + puerto) |
| **CAA** | CA autorizadas para certificados |

---

## 3. dig — consultas útiles

```bash
dig ejemplo.org
dig ejemplo.org A
dig ejemplo.org AAAA
dig ejemplo.org MX +short
dig ejemplo.org NS +short
dig ejemplo.org TXT

dig @1.1.1.1 ejemplo.org          # resolver concreto
dig -x 1.1.1.1                    # PTR (inverso)
dig ejemplo.org +trace            # recorrido desde raíz
dig ejemplo.org +short
dig ejemplo.org +noall +answer
```

Lectura de la respuesta:

| Sección | Contenido |
|---------|-----------|
| **QUESTION** | Lo pedido |
| **ANSWER** | Registros respuesta |
| **AUTHORITY** | NS autoritativos |
| **ADDITIONAL** | Datos extra (glue, etc.) |

Campos útiles: `STATUS` (`NOERROR`, `NXDOMAIN`, `SERVFAIL`), `TTL`.

---

## 4. resolvectl (systemd-resolved)

```bash
resolvectl status
resolvectl query ejemplo.org
resolvectl query -t MX ejemplo.org
resolvectl flush-caches
resolvectl statistics
```

`/etc/resolv.conf` a menudo apunta a `127.0.0.53` (stub). Los DNS reales salen en `resolvectl status`.

Sin systemd-resolved:

```bash
cat /etc/resolv.conf
# nameserver 192.0.2.1
```

---

## 5. Caché — dónde puede estar

| Capa | Ejemplo | Acción |
|------|---------|--------|
| Aplicación | navegador | recargar / vaciar caché app |
| Stub local | `systemd-resolved` | `resolvectl flush-caches` |
| Resolver de red | router, DNS corporativo | esperar TTL o flush admin |
| Autoritativo | no es caché: es origen | cambiar zona + TTL |

Si ves respuesta “vieja”: mira **TTL** y **qué servidor** te respondió (`dig` sin `@` vs `@autoritativo`).

---

## 6. Errores frecuentes

| Síntoma | Interpretación |
|---------|----------------|
| `NXDOMAIN` | El nombre no existe (en esa vista) |
| `SERVFAIL` | Fallo del resolver / zona rota / DNSSEC |
| `NOERROR` vacío | Nombre existe pero no ese tipo |
| Resuelve mal | Caché, split-DNS, `/etc/hosts` |
| Solo falla un sitio | registro o CDN; compara `@8.8.8.8` vs DNS interno |

```bash
getent hosts ejemplo.org     # lo que ve el sistema (nsswitch)
cat /etc/hosts               # excepciones locales
```

---

## 7. Checklist

| Objetivo | Comando |
|----------|---------|
| IP de un nombre | `dig +short nombre A` |
| ¿DNS interno o público? | `dig @…` + `resolvectl status` |
| Inverso | `dig -x IP` |
| Limpiar caché local | `resolvectl flush-caches` |
| Correo | `dig nombre MX +short` |

---

*Biblioteca — Redes · DNS*
