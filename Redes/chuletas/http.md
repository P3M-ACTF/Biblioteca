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

## 7. HTTP/3 y QUIC

HTTP/1.1 y HTTP/2 viajan sobre TCP, y ese TCP va dentro de TLS en el puerto 443. HTTP/3 no. Viaja sobre QUIC, y QUIC va sobre UDP, también en el 443. La aplicación sigue siendo HTTP: métodos, códigos y cabeceras no cambian. Cambia el transporte que hay debajo, y con él lo que hay que mirar cuando «la web no abre».

QUIC junta el transporte y el cifrado en un solo paso. No hay un apretón de manos TCP y luego otro de TLS: la primera ida y vuelta ya negocia las dos cosas. Por eso un sitio en HTTP/3 puede responder antes, y por eso un cortafuegos que solo entiende TCP ve un flujo UDP que no sabe inspeccionar. Si el UDP 443 no pasa, el cliente no se queda colgado para siempre: los navegadores vuelven a HTTP/2 sobre TCP. La página carga, más despacio, y nadie avisa de que el camino rápido se ha perdido.

| Qué miras | HTTP/1.1 y HTTP/2 | HTTP/3 |
|-----------|-------------------|--------|
| Puerto | TCP 443 | UDP 443, con TCP 443 de reserva |
| Qué establece la conexión | Primero TCP, después TLS | QUIC, que incluye el cifrado |
| Cómo se ve en un `curl` reciente | `curl -vI --http2 https://ejemplo.org` | `curl -vI --http3 https://ejemplo.org` (hace falta un curl compilado con HTTP/3) |
| Qué pasa si el camino está a medias | La conexión TCP no llega a establecerse y el fallo es visible | El navegador cae a TCP sin decirlo. El fallo queda escondido |

### Qué estás viendo

```text
$ curl -vI --http2 https://ejemplo.org
* ALPN: curl offers h2,http/1.1
* ALPN: server accepted h2
```

`ALPN` es la negociación, dentro de TLS, de qué versión de HTTP se va a hablar. `h2` es HTTP/2. `http/1.1` es la versión clásica. `h3` sería HTTP/3, y para ofrecerla el cliente tiene que poder hablar QUIC. Si el servidor anuncia HTTP/3 lo hace además con la cabecera `alt-svc: h3=":443"`, que le dice al navegador «la próxima vez, prueba por UDP».

### Error típico

Cierras en el cortafuegos todo lo que no sea TCP 443, convencido de que con eso el HTTPS queda permitido y lo demás fuera. Las webs cargan, así que das el cambio por bueno. Semanas después, una aplicación que solo habla HTTP/3 (o una medición que compara versiones) no conecta, y las que sí conectan van todas por el camino lento sin que el monitor lo señale, porque el monitor mira el código HTTP y el código es 200 igual.

La causa es que HTTPS ya no es solo TCP 443. El contenido va también por UDP 443, y al tirar el UDP has apagado HTTP/3 dejando el respaldo. Se ve en que `curl --http3` no completa el apretón QUIC mientras `curl --http2` sí, y en que no hay ningún rechazo TCP: el paquete UDP simplemente no vuelve. Se arregla permitiendo UDP 443 hacia los servidores web que anuncian HTTP/3, con el mismo criterio de origen con el que ya permites el TCP 443, no abriendo UDP en general.

---

*Biblioteca — Redes · HTTP*
