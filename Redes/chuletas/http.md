# Chuleta: HTTP

Métodos, códigos de estado y cabeceras habituales. Referencia de protocolo (capa aplicación).

---

## 1. Petición y respuesta (esqueleto)

```
GET /ruta HTTP/1.1
Host: ejemplo.org
User-Agent: …
Accept: …

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: …
```

HTTPS = HTTP sobre **TLS** (ver chuleta TLS en Ciberseguridad).

```bash
curl -vI https://ejemplo.org
curl -X POST -H 'Content-Type: application/json' -d '{"a":1}' https://ejemplo.org/api
```

---

## 2. Métodos

| Método | Idea | ¿Idempotente?* | ¿Cuerpo típico? |
|--------|------|----------------|-----------------|
| **GET** | Leer recurso | Sí | No |
| **HEAD** | Como GET sin cuerpo | Sí | No |
| **POST** | Crear / acción / enviar datos | No | Sí |
| **PUT** | Reemplazar recurso | Sí | Sí |
| **PATCH** | Modificar parcial | No* | Sí |
| **DELETE** | Borrar | Sí | A veces |
| **OPTIONS** | Métodos soportados / CORS preflight | Sí | No |

\*Idempotente ≈ repetir la petición no cambia el resultado más allá de la primera. PATCH suele no serlo. La semántica exacta la define la API.

---

## 3. Códigos de estado (grupos)

| Rango | Significado |
|-------|-------------|
| **1xx** | Informativo |
| **2xx** | Éxito |
| **3xx** | Redirección |
| **4xx** | Error del cliente |
| **5xx** | Error del servidor |

### Códigos frecuentes

| Código | Nombre | Uso típico |
|--------|--------|------------|
| 200 | OK | Éxito con cuerpo |
| 201 | Created | Recurso creado |
| 204 | No Content | Éxito sin cuerpo |
| 301 | Moved Permanently | Redirección fija |
| 302 | Found | Redirección temporal |
| 304 | Not Modified | Caché válida |
| 400 | Bad Request | Petición mal formada |
| 401 | Unauthorized | Falta auth (aunque diga “unauthorized”) |
| 403 | Forbidden | Autenticado pero sin permiso |
| 404 | Not Found | No existe |
| 405 | Method Not Allowed | Método no permitido |
| 429 | Too Many Requests | Rate limit |
| 500 | Internal Server Error | Fallo del servidor |
| 502 | Bad Gateway | Proxy/upstream malo |
| 503 | Service Unavailable | Caído o en mantenimiento |
| 504 | Gateway Timeout | Upstream no respondió a tiempo |

---

## 4. Cabeceras habituales

### Petición

| Cabecera | Rol |
|----------|-----|
| `Host` | Virtual host (obligatoria en HTTP/1.1) |
| `User-Agent` | Cliente |
| `Accept` | Tipos MIME aceptados |
| `Accept-Language` | Idioma |
| `Authorization` | Credenciales (Bearer, Basic…) |
| `Cookie` | Cookies enviadas |
| `Content-Type` | Tipo del cuerpo |
| `Content-Length` | Tamaño del cuerpo |
| `If-None-Match` / `If-Modified-Since` | Caché condicional |
| `Origin` / `Referer` | Contexto web / CORS |

### Respuesta

| Cabecera | Rol |
|----------|-----|
| `Content-Type` | Tipo del cuerpo |
| `Content-Length` / `Transfer-Encoding` | Tamaño o chunked |
| `Set-Cookie` | Establecer cookie |
| `Location` | Destino en redirecciones |
| `Cache-Control` / `ETag` | Caché |
| `Strict-Transport-Security` | HSTS |
| `Content-Security-Policy` | CSP |
| `Access-Control-Allow-Origin` | CORS |
| `Server` | Identificación (a veces se omite) |
| `WWW-Authenticate` | Reto ante 401 |

---

## 5. URL y componentes

```
https://usuario:pass@host:443/ruta?query=1#frag
│       │             │    │   │    │        └ fragmento (no se envía al servidor)
│       │             │    │   │    └ query string
│       │             │    │   └ path
│       │             │    └ puerto
│       │             └ host
│       └ userinfo (evitar; preferir cabeceras)
└ esquema
```

---

## 6. Checklist de depuración

| Síntoma | Mirar |
|---------|-------|
| 401 / 403 | `Authorization`, cookies, permisos |
| 404 | path, `Host`, reverse proxy |
| 502 / 504 | upstream, timeouts, sockets |
| Redirect loop | `Location`, cookies Secure/HTTPS |
| CORS error en navegador | cabeceras `Access-Control-*` |

```bash
curl -vI https://ejemplo.org/ruta
curl -s -o /dev/null -w '%{http_code}\n' https://ejemplo.org/
```

---

*Biblioteca — Redes · HTTP*
