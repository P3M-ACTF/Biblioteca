# Chuleta: TLS

TLS es el protocolo que cifra una conexión y comprueba que estás hablando con quien crees. HTTPS es HTTP viajando dentro de TLS; el mismo TLS envuelve el correo, las VPN y la administración remota. Esta chuleta explica qué garantiza, cómo es el apretón de manos, qué hay dentro de un certificado y cómo comprobar uno. Es referencia defensiva: verificar y configurar, no atacar.

---

## 1. Qué garantiza y qué no

| Propiedad | Cómo la consigue |
|-----------|------------------|
| **Confidencialidad** | El contenido viaja cifrado. Quien capture el tráfico ve que hay una conexión y con qué servidor (el nombre va en el SNI), pero no el contenido. |
| **Integridad** | Cada bloque lleva una autenticación (AEAD). Si alguien modifica un byte por el camino, la conexión se corta en lugar de entregar datos alterados. |
| **Autenticación del servidor** | El servidor presenta un certificado firmado por alguien en quien el cliente confía, y el nombre del certificado coincide con el nombre al que te conectas. |
| **Autenticación del cliente** (opcional) | El cliente presenta su propio certificado. Se usa en VPNs y en accesos de administración; la web normal no lo hace. |

TLS no decide si lo que hay al otro lado es de fiar en el sentido humano: solo garantiza que el certificado es válido para ese nombre y lo emitió una autoridad reconocida. Un sitio de phishing con un certificado válido pasa TLS sin problema. Tampoco cifra el tráfico antes de llegar al servidor: quien controla el servidor lee el contenido en claro.

Las versiones que se usan son **TLS 1.2** y **TLS 1.3**. SSLv3, TLS 1.0 y TLS 1.1 tienen debilidades conocidas y se desactivan en cualquier servidor nuevo. TLS 1.3 es más corto y elimina opciones viejas; 1.2 sigue siendo aceptable cuando está bien configurado.

---

## 2. El apretón de manos

Antes de enviar datos, cliente y servidor acuerdan cómo van a cifrar y el cliente comprueba el certificado. A ese intercambio se le llama *handshake*.

**TLS 1.2** necesita dos viajes de ida y vuelta. El cliente envía un `ClientHello` con las versiones que acepta, las suites de cifrado y el nombre del servidor (SNI). El servidor responde con un `ServerHello` eligiendo una opción, envía su certificado y se intercambia el material para la clave. Al final, ambos envían un `Finished` ya cifrado y a partir de ahí van los datos.

**TLS 1.3** lo hace en un viaje. El cliente ya incluye en el `ClientHello` su parte del intercambio de claves, así que el servidor puede responder con su elección, el certificado y el `Finished` de una vez. Hay una variante, el 0-RTT, que permite enviar datos en el primer mensaje reutilizando una sesión anterior; es más rápida y tiene un riesgo de repetición, así que no se usa para peticiones que cambien algo.

En ambos casos el cifrado de los datos usa una clave **simétrica** recién negociada, distinta para cada conexión. Aunque alguien robe la clave privada del servidor meses después, no puede descifrar las conexiones pasadas si se usó secreto perfecto hacia adelante (*forward secrecy*), que en TLS 1.3 es obligatorio y en 1.2 depende de elegir suites ECDHE.

La guía [Cadena de confianza TLS](https://github.com/P3M-ACTF/Biblioteca/wiki/Cadena-de-confianza-TLS) dibuja el recorrido completo.

---

## 3. Qué hay dentro de un certificado

El certificado es un documento firmado que dice «esta clave pública pertenece a este nombre, y yo, la autoridad, lo certifico». Los campos que de verdad miras al diagnosticar:

| Campo | Qué mirar |
|-------|-----------|
| **Subject** | A quién se emitió. Hoy es informativo; la comprobación del nombre se hace por el SAN. |
| **Issuer** | Quién lo firmó. Tiene que ser una autoridad intermedia cuya cadena llegue a una raíz en la que el cliente confíe. |
| **SAN** (Subject Alternative Name) | La lista de nombres DNS (y a veces IPs) para los que el certificado vale. Si el nombre al que te conectas no está aquí, el cliente lo rechaza aunque todo lo demás sea perfecto. |
| **Validity** | `Not Before` y `Not After`. Fuera de ese intervalo el certificado no vale, da igual lo bien firmado que esté. |
| **Public key** | La clave pública del servidor y su algoritmo (ECDSA o RSA). La privada correspondiente nunca sale del servidor. |
| **Signature** | La firma de la autoridad sobre todo lo anterior. Es lo que impide modificar el certificado. |

La cadena se lee de abajo arriba: el certificado **hoja** (el del servidor) lo firma una autoridad **intermedia**, y esa intermedia la firma una **raíz** que el cliente tiene guardada en su almacén de confianza. El servidor debe enviar la hoja y las intermedias; la raíz no se envía, porque el cliente ya la tiene. Si falta una intermedia, algunos clientes resuelven la cadena solos y otros, más estrictos, fallan: el mismo certificado «funciona en el navegador y no en el script».

```bash
openssl s_client -connect ejemplo.org:443 -servername ejemplo.org </dev/null
openssl x509 -in cert.pem -noout -subject -issuer -dates -ext subjectAltName
```

### Qué estás viendo

```text
$ openssl x509 -in cert.pem -noout -subject -issuer -dates -ext subjectAltName
subject=CN = www.ejemplo.org
issuer=C = US, O = Let's Encrypt, CN = R3
notBefore=Sep 10 08:00:00 2026 GMT
notAfter=Dec  9 08:00:00 2026 GMT
X509v3 Subject Alternative Name:
    DNS:www.ejemplo.org, DNS:ejemplo.org
```

`issuer` dice quién lo firmó (aquí la intermedia R3 de Let's Encrypt). Las fechas marcan una validez de unos noventa días, que es lo normal con emisión automática. El SAN cubre el nombre con `www` y sin él; conectarte a `app.ejemplo.org` fallaría aunque apunte a la misma máquina. Si `openssl s_client` dice `Verify return code: 0 (ok)`, la cadena valida completa; cualquier otro código es la causa del fallo, escrita.

---

## 4. Nombres, SNI y confianza

| Concepto | Qué implica |
|----------|-------------|
| **SNI** | El cliente dice en el `ClientHello` a qué nombre quiere conectar, para que un mismo servidor con una sola IP pueda presentar certificados distintos. Sin SNI, el servidor solo puede ofrecer un certificado por dirección. |
| **Validación del nombre** | El cliente compara el nombre al que se conectó con el SAN. Coincidir la IP no basta, salvo que la IP esté en el SAN. |
| **Cadena incompleta** | El servidor envía la hoja pero no la intermedia. Navegadores con caché de intermedias lo perdonan; clientes nuevos y herramientas de línea de comandos, no. |
| **Autofirmado** | El certificado lo firma su propia clave. Nadie lo reconoce, así que todos los clientes avisarán. Vale para un laboratorio si lo instalas como confiable; no vale para nada expuesto. |
| **Autoridad privada** | La empresa tiene su propia raíz e instala esa raíz en sus equipos. Dentro de la red todo valida; fuera, todo falla. Es lo normal para servicios internos. |

---

## 5. Suites de cifrado

Una suite es la combinación de algoritmos que se usa en la conexión. El criterio actual cabe en una frase: cifrado autenticado (AES-GCM o ChaCha20-Poly1305) y secreto perfecto hacia adelante.

En TLS 1.3 no hay mucho que elegir: las suites viejas directamente no existen. En TLS 1.2 hay que mirarlo, porque el servidor puede estar ofreciendo opciones heredadas por compatibilidad. Se evitan las suites de exportación, el cifrado NULL, RC4, 3DES y las firmas MD5 o SHA-1.

```bash
openssl s_client -connect ejemplo.org:443 -tls1_2 </dev/null
openssl s_client -connect ejemplo.org:443 -tls1_3 </dev/null
```

La línea `Protocol` dice qué versión se negoció y `Cipher` la suite. Si `-tls1_3` falla y `-tls1_2` funciona, el servidor no ofrece 1.3; es compatible, pero se queda atrás. Si ambos fallan, no hay versión en común.

---

## 6. Cuando falla

| Síntoma | Causa habitual |
|---------|----------------|
| El nombre no coincide | El certificado es para otro nombre, o falta esa variante en el SAN. Conectarte por IP a un certificado emitido para un nombre da exactamente este error. |
| Caducado | Pasó el `Not After`. Renovar y recargar el servicio; el certificado nuevo no entra en uso hasta que el servicio lo vuelve a leer. |
| Autoridad desconocida | La cadena no llega a una raíz confiable, falta una intermedia, o es una autoridad privada no instalada en ese equipo. |
| El apretón de manos falla | Cliente y servidor no comparten ninguna versión o suite. Pasa con clientes viejos contra servidores endurecidos, y al revés. |
| «Todavía no válido» | El `Not Before` es futuro. Casi siempre es el reloj del cliente mal puesto, no el certificado. |

---

## 7. Checklist

| Objetivo | Cómo |
|----------|------|
| Ver caducidad | `openssl x509 -noout -dates` sobre el fichero, o `openssl s_client` contra el servicio. |
| Ver los nombres cubiertos | `-ext subjectAltName`. |
| Ver la cadena como la ve un cliente | `openssl s_client -connect host:443 -servername host` y leer el código de verificación. |
| Probar desde el puesto | `curl -vI https://nombre` enseña la negociación y el error concreto. |
| En el servidor | TLS 1.2 y 1.3, cadena completa, renovación automática y alarma antes del vencimiento. |
| HSTS | Solo cuando HTTPS ya funciona de forma estable: la cabecera obliga al navegador a no volver a HTTP. |

---

## 8. Error típico

**Situación.** Renuevas el certificado del servidor web, copias los ficheros nuevos a `/etc/ssl/` y no pasa nada: los navegadores siguen diciendo que el certificado caduca en dos días. Compruebas los ficheros y las fechas son correctas. Vuelves a copiarlos por si acaso.

**Por qué ocurre.** El servicio leyó el certificado al arrancar y trabaja con esa copia en memoria. Sustituir los ficheros en disco no cambia lo que ya cargó. nginx, Apache, HAProxy y la mayoría de los servicios necesitan un `reload` para volver a leerlos. Además es fácil renovar el fichero equivocado: el servicio puede estar usando una ruta distinta de la que tú actualizaste, sobre todo cuando hay un directorio `live/` con enlaces simbólicos y otro con copias.

**Cómo se ve.** `openssl x509 -in /etc/ssl/nuevo.pem -noout -dates` muestra fechas nuevas. `openssl s_client -connect servidor:443 </dev/null` muestra las viejas. Esa diferencia, fichero bien y servicio mal, es la firma del problema: lo que importa es lo que el servicio presenta, no lo que hay en el disco. `systemctl status` confirma que el proceso lleva días corriendo, desde antes de la renovación.

**Cómo se arregla.** Confirmar en la configuración del servicio la ruta exacta que usa, comprobar que esa ruta (siguiendo los enlaces) lleva al fichero nuevo, y recargar: `systemctl reload nginx`. Después repetir `openssl s_client` y ver el `Not After` nuevo. Si el servicio no soporta recarga en caliente, será un `restart`, con su corte. Y para que no dependa de acordarse, la renovación automática (el cliente de la autoridad, o un timer) tiene que incluir el reload en su script, no solo la descarga del fichero.

---

Relacionado: [cifrado-hash-firma](cifrado-hash-firma.md) · [http](../../Redes/chuletas/http.md) · nota [certificado-autofirmado-lab](../../Sistemas%20Operativos/notas/certificado-autofirmado-lab.md) · runbook [certificado-caducado](../../Sistemas%20Operativos/runbooks/certificado-caducado.md) · guía [Cadena de confianza TLS](https://github.com/P3M-ACTF/Biblioteca/wiki/Cadena-de-confianza-TLS)

*Biblioteca — Ciberseguridad · TLS*
