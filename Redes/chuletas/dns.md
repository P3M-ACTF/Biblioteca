# Chuleta: DNS

El DNS traduce nombres a direcciones (y algunas cosas más: servidores de correo, texto de verificación, alias). Casi todo lo que falla «en la red» con el síntoma de que las IPs funcionan y los nombres no, es DNS. Esta chuleta explica qué pide un equipo cuando resuelve un nombre, qué tipos de respuesta hay y cómo preguntar con `dig` leyendo de verdad la respuesta.

---

## 1. Qué pasa cuando resuelves un nombre

Una aplicación pide al sistema «dame las direcciones de `ejemplo.org`». El sistema no recorre Internet por su cuenta: le pregunta a un **resolver**, una IP que tiene configurada (la del router, la del controlador de dominio, o una pública como `1.1.1.1`). Ese resolver busca la respuesta, la devuelve y ambos la guardan en caché durante el tiempo que indique el **TTL** del registro, expresado en segundos. Mientras el TTL no caduca, nadie vuelve a preguntar: por eso un cambio de DNS «no se ve» hasta que vence la caché, y por eso bajar el TTL antes de un cambio planificado es parte del cambio.

En Linux el camino tiene un paso más. La aplicación pregunta al resolver local del sistema (muchas veces `systemd-resolved`, escuchando en `127.0.0.53`), y ese es quien de verdad habla con los DNS configurados. `/etc/resolv.conf` a menudo solo contiene `nameserver 127.0.0.53`; los servidores reales están en la configuración de resolved, no en ese fichero. Editar `resolv.conf` en una máquina con systemd-resolved es escribir en un fichero que se regenera.

```bash
resolvectl status
cat /etc/resolv.conf
```

### Qué estás viendo en `resolvectl status`

```text
Global
         Protocols: +LLMNR +mDNS -DNSOverTLS DNSSEC=no/unsupported
  resolv.conf mode: stub

Link 2 (eth0)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 10.0.0.1
       DNS Servers: 10.0.0.1 10.0.0.2
        DNS Domain: empresa.local
```

`Current DNS Server` es el que se está usando ahora mismo. `DNS Servers` es la lista completa, en orden. `DNS Domain` es el dominio de búsqueda: si preguntas por `srv-ficheros` a secas, el sistema probará `srv-ficheros.empresa.local`. Esto importa en redes con Active Directory, donde los nombres cortos funcionan dentro del dominio y dejan de funcionar en cuanto te llevas el portátil fuera.

---

## 2. Tipos de registro

Un nombre no tiene «una» respuesta: tiene registros de distintos tipos, y cada tipo contesta una pregunta diferente. Pedir el tipo equivocado es la causa de muchas consultas que «no devuelven nada» estando todo bien.

| Tipo | Qué pregunta responde |
|------|------------------------|
| **A** | ¿Qué dirección IPv4 tiene este nombre? Es la consulta por defecto. |
| **AAAA** | ¿Qué dirección IPv6 tiene? Un nombre puede tener A y AAAA a la vez; el sistema elige cuál usar. |
| **CNAME** | Este nombre es un alias de este otro. La respuesta final se busca sobre el otro nombre. No puede convivir con otros registros en el mismo nombre: un CNAME ocupa el nombre entero. |
| **MX** | ¿Qué servidores reciben el correo de este dominio, y en qué orden? Lleva una prioridad: se prueba primero el número más bajo. |
| **NS** | ¿Qué servidores son autoritativos de esta zona? Son los que tienen la copia oficial de los datos. |
| **TXT** | Texto libre asociado al nombre. Se usa para SPF del correo, verificaciones de propiedad y políticas. |
| **SOA** | Metadatos de la zona: servidor primario, correo del responsable y los temporizadores que gobiernan la replicación. |
| **PTR** | La pregunta inversa: ¿qué nombre corresponde a esta IP? Vive en zonas especiales (`in-addr.arpa`) y a menudo no está configurado. |
| **SRV** | ¿En qué host y puerto está este servicio? Lo usan Active Directory y la mensajería para localizar controladores y servidores. |
| **CAA** | ¿Qué autoridades de certificación tienen permiso para emitir certificados de este dominio? |

---

## 3. Preguntar con dig

`dig` pregunta directamente y enseña la respuesta completa, sin la caché ni los atajos del sistema. Por eso es la herramienta de diagnóstico: si `dig` obtiene respuesta y el navegador no, el problema está en la configuración local; si `dig` tampoco, está en el servidor o más allá.

```bash
dig ejemplo.org
dig ejemplo.org A
dig ejemplo.org AAAA
dig ejemplo.org MX +short
dig ejemplo.org NS +short
dig ejemplo.org TXT
dig @10.0.0.1 ejemplo.org
dig @1.1.1.1 ejemplo.org
dig -x 192.0.2.10
dig ejemplo.org +trace
dig ejemplo.org +short
```

`@servidor` salta tu configuración y pregunta a ese DNS concreto. Es la comparación más útil que hay: preguntar al DNS interno y a uno público por el mismo nombre. Si el interno responde y el público no, es un nombre de la red interna (correcto). Si el público responde y el interno no, el DNS interno está mal o filtra. `+trace` recorre el camino desde la raíz, y enseña qué servidor de cada nivel responde. `-x` hace la consulta inversa.

### Qué estás viendo

```text
$ dig ejemplo.org

;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1234
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;ejemplo.org.                   IN      A

;; ANSWER SECTION:
ejemplo.org.            3600    IN      A       192.0.2.10

;; SERVER: 10.0.0.1#53(10.0.0.1)
;; WHEN: Sat Oct 10 11:05:00 UTC 2026
```

- `status` es lo primero que se lee. `NOERROR` significa que la consulta se procesó bien (aunque la respuesta puede estar vacía). `NXDOMAIN` significa que el nombre no existe. `SERVFAIL` significa que el servidor no pudo resolverlo: problema suyo, no del nombre. `REFUSED` significa que se negó a responderte.
- La sección **QUESTION** repite lo que pediste, para que confirmes que pediste lo que creías.
- **ANSWER** es la respuesta: nombre, TTL en segundos, clase `IN`, tipo y valor. Aquí el nombre existe, apunta a `192.0.2.10` y se puede cachear durante 3600 segundos.
- **AUTHORITY**, cuando aparece, trae los NS de la zona. **ADDITIONAL** trae datos de apoyo, como las direcciones de esos NS.
- La línea `SERVER` dice quién te contestó. Si esperabas preguntar al DNS interno y aquí sale `127.0.0.53`, estás hablando con el resolver local. Usa `@` para saltártelo.

Las banderas `rd` (recursion desired) y `ra` (recursion available) dicen que pediste búsqueda recursiva y que el servidor aceptó hacerla. Un servidor autoritativo que no recurese responderá sin `ra` y sin respuesta, devolviendo solo la sección AUTHORITY: no está roto, es que no es su trabajo buscar por ti.

---

## 4. La caché

La respuesta se guarda en varios sitios a la vez: en el resolver local, en el DNS de la red y en la propia aplicación (los navegadores cachean por su cuenta). Cuando cambias un registro y «no se ve», casi nunca es que el cambio no se hizo; es que alguien sigue sirviendo la versión anterior.

```bash
resolvectl query ejemplo.org
resolvectl flush-caches
sudo systemd-resolve --statistics
```

`resolvectl query` pregunta a través del resolver local y dice desde dónde vino la respuesta (`Data from cache`, `Data from network`). `flush-caches` vacía la caché local, no la del servidor DNS de la red ni la del navegador. En Windows el equivalente es `Clear-DnsClientCache` e `ipconfig /flushdns`.

Para ver qué hay cacheado en el servidor no hay un comando universal, porque depende del software. Lo que sí puedes hacer es comparar: `dig @dns-interno nombre` contra `dig @1.1.1.1 nombre`. Si difieren, o el cambio no se ha propagado, o son vistas distintas a propósito (un DNS interno que da IPs privadas para servicios internos: *split horizon*, lo normal en empresas).

---

## 5. DNS interno y Active Directory

En un dominio de Active Directory el DNS no es un servicio más: es el mecanismo por el que los equipos encuentran a los controladores de dominio. El equipo pregunta por registros SRV como `_ldap._tcp.dc._msdcs.empresa.local` y el DNS interno le dice qué controlador usar. Si el equipo tiene configurado un DNS público en lugar del interno, la sesión en el dominio se vuelve lenta o imposible, las GPO no se aplican y los nombres internos no resuelven, aunque Internet funcione perfectamente.

Por eso, en un equipo unido al dominio, los DNS configurados son los controladores de dominio y nada más. El controlador, a su vez, resuelve los nombres públicos reenviando la consulta. Poner `8.8.8.8` como DNS secundario «por si acaso» es un error clásico: cuando el primario tarda, el equipo pregunta al público, el público no conoce `empresa.local` y responde NXDOMAIN, y ese NXDOMAIN se cachea.

---

## 6. Checklist

| Pregunta | Cómo salir de dudas |
|----------|---------------------|
| ¿Qué DNS estoy usando de verdad? | `resolvectl status` en Linux; `Get-DnsClientServerAddress` en Windows. |
| ¿El nombre existe y qué vale? | `dig nombre` y leer `status` y la sección ANSWER. |
| ¿El DNS interno y el público responden igual? | `dig @interno nombre` frente a `dig @1.1.1.1 nombre`. |
| ¿Es la caché? | `resolvectl query` (dice si viene de caché) y `flush-caches`, recordando que hay más cachés. |
| ¿El inverso está configurado? | `dig -x IP`. Que no responda es frecuente y solo importa si alguna aplicación lo exige. |
| ¿El dominio de búsqueda añade lo que creo? | `resolvectl status`, línea `DNS Domain`, y prueba el nombre corto y el FQDN por separado. |

---

## 7. Error típico

**Situación.** Cambias la IP del servidor de ficheros en el DNS interno, de `10.0.0.20` a `10.0.0.30`. Desde el controlador, `ping srv-ficheros` ya va a la nueva IP. Desde tu puesto, una hora después, sigue yendo a la antigua. Compruebas el registro tres veces. Está bien.

**Por qué ocurre.** Tu puesto resolvió el nombre antes del cambio y guardó la respuesta durante el TTL, que estaba en 3600 segundos. El registro `A` antiguo sigue siendo válido para él hasta que pase esa hora. El controlador no tiene ese problema porque su consulta fue posterior al cambio, o porque al ser el servidor autoritativo no se guarda su propia respuesta igual. No hay nada roto: la caché está haciendo exactamente lo que se le pidió.

**Cómo se ve.** `dig srv-ficheros.empresa.local` contra el servidor devuelve `10.0.0.30` con TTL alto. `resolvectl query srv-ficheros.empresa.local` dice `Data from cache` y muestra `10.0.0.20`. `ping` resuelve a la vieja. El navegador, si entrabas por nombre a alguna consola de ese servidor, también.

**Cómo se arregla.** En el puesto, vaciar la caché local (`resolvectl flush-caches`, o `ipconfig /flushdns` en Windows) y cerrar el navegador si cachea por su cuenta. Para la próxima vez, el arreglo de verdad es de procedimiento: bajar el TTL del registro a unos minutos **antes** del cambio, esperar a que el TTL antiguo caduque en todos los clientes, hacer el cambio, comprobar, y subir el TTL de nuevo. Sin ese paso previo, cualquier cambio de DNS tarda tanto en propagarse como el TTL que tuviera, y no hay comando que vacíe la caché de todos los equipos de la red.

---

Relacionado: [direccionamiento](direccionamiento.md) · [diagnostico](diagnostico.md) · [dhcp-dns-windows-server](../../Sistemas%20Operativos/chuletas/dhcp-dns-windows-server.md) · [active-directory](../../Sistemas%20Operativos/chuletas/active-directory.md) · guía [Camino de un paquete](https://github.com/P3M-ACTF/Biblioteca/wiki/Camino-de-un-paquete)

*Biblioteca — Redes · DNS*
