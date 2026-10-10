# Runbook: certificado caducado

Úsalo cuando un servicio deja de aceptar conexiones con un error de certificado, cuando un aviso te dice que un certificado caduca en pocos días, o cuando un navegador empieza a avisar de golpe en un sitio que ayer funcionaba. El orden es: confirmar que el problema es la fecha y no el nombre o la cadena, localizar qué fichero está sirviendo el servicio, renovar, recargar y comprobar desde fuera.

Chuleta de referencia: [tls](../../Ciberseguridad/chuletas/tls.md). Para un certificado de laboratorio, la nota [certificado-autofirmado-lab](../notas/certificado-autofirmado-lab.md).

## 1. Confirmar qué falla

**Por qué este paso.** «Error de certificado» cubre caducidad, nombre que no coincide, cadena incompleta y reloj mal puesto. Cada una se arregla distinto, y renovar no cura ninguna salvo la primera.

```bash
openssl s_client -connect servidor:443 -servername servidor </dev/null
echo | openssl s_client -connect servidor:443 -servername servidor 2>/dev/null | openssl x509 -noout -dates -ext subjectAltName
```

### Qué estás viendo

```text
notBefore=Jul  1 00:00:00 2026 GMT
notAfter=Oct  1 00:00:00 2026 GMT
```

Si `Not After` ya pasó, es caducidad: sigue. Si la fecha es futura, el certificado del servicio está bien y el fallo es otro (el reloj del cliente, el nombre, la cadena). `Verify return code: 10 (certificate has expired)` lo dice explícitamente. Un código 9 (`not yet valid`) apunta al reloj, no al certificado: comprueba la hora antes de renovar nada (nota [hora-ntp-chrony](../notas/hora-ntp-chrony.md)).

## 2. Encontrar el fichero que sirve el servicio

**Por qué este paso.** En el disco suele haber varios certificados: el nuevo, el viejo, una copia en otro directorio y un enlace simbólico. Renovar el que el servicio no lee es el arreglo que no arregla nada. La ruta sale de la configuración del servicio, no de buscar `*.crt` por el sistema.

| Servicio | Dónde dice la ruta |
|----------|--------------------|
| nginx | `ssl_certificate` y `ssl_certificate_key` en el `server`. |
| Apache | `SSLCertificateFile` y `SSLCertificateKeyFile`. |
| HAProxy | Línea `crt` del `bind`. |
| Windows / IIS | El almacén de certificados de la máquina, y el enlace del sitio con su certificado. |

Anota la ruta del certificado y la de la clave, y si es un enlace simbólico, adónde apunta (`readlink -f`).

## 3. Renovar

**Por qué este paso.** La renovación depende de quién emitió el certificado, y hacerlo a mano cuando hay un mecanismo automático es dejar el mismo problema programado para dentro de noventa días.

- Si lo emite Let's Encrypt u otra autoridad con cliente propio, la renovación es el comando de ese cliente, que además deja el fichero donde el servicio lo lee.
- Si lo emite la autoridad interna de la empresa, se genera una petición nueva (reutilizando la clave solo si vuestra política lo permite) y se lleva a la autoridad.
- Si es autofirmado de laboratorio, se regenera con el mismo SAN que el anterior.

No borres el certificado viejo hasta que el nuevo esté comprobado. Renombrar a `.viejo` basta para poder volver atrás.

## 4. Hacer que el servicio lo lea

**Por qué este paso.** El servicio cargó el certificado al arrancar. Sustituir el fichero no cambia lo que tiene en memoria.

```bash
sudo nginx -t && sudo systemctl reload nginx
sudo apachectl configtest && sudo systemctl reload apache2
```

`reload` vuelve a leer la configuración sin cortar las conexiones ya abiertas. Si el servicio no lo soporta, será un `restart` y habrá un corte breve: mejor saberlo antes. En IIS, el enlace del sitio tiene que apuntar al certificado nuevo si el antiguo y el nuevo son distintos en el almacén; cambiar el fichero no existe ahí.

## 5. Comprobar desde fuera

**Por qué este paso.** Comprobar el fichero en disco ya sabes que sale bien, porque acabas de ponerlo. Lo que importa es lo que recibe un cliente.

```bash
echo | openssl s_client -connect servidor:443 -servername servidor 2>/dev/null | openssl x509 -noout -dates
curl -vI https://servidor
```

### Qué estás viendo

El `Not After` tiene que ser el nuevo, y `curl` tiene que terminar sin error de verificación. Si `openssl s_client` sigue mostrando la fecha vieja, el servicio no se recargó o sigue leyendo otra ruta: vuelve al paso 2, no repitas la renovación.

## 6. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| El cliente ve el certificado nuevo | `s_client` desde otra máquina muestra la fecha nueva y verifica la cadena. |
| Sabes cuándo caduca el siguiente | La fecha está apuntada, o la renovación automática cubre este certificado e incluye el reload. |
| No quedó el viejo en uso en otro sitio | El mismo certificado suele estar en varios servicios (el web y el correo). Buscar por la fecha vieja evita el segundo aviso dentro de una semana. |
| El mecanismo automático funciona | Si hay cliente de renovación, un simulacro (`renew --dry-run` o equivalente) termina bien. Renovar a mano hoy sin eso es aplazar el incidente. |

---

*Biblioteca — runbook · certificado caducado*
