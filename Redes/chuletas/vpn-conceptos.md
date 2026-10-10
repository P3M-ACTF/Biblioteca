# Chuleta: VPN, conceptos para administrar

Una VPN mete el tráfico de un equipo o de una sede dentro de un túnel cifrado hasta otro punto, de modo que por el camino nadie lo lee y, al salir, parece venir del otro extremo. Se usa para que la gente teletrabaje como si estuviera en la oficina y para unir dos sedes. Esta chuleta compara las tecnologías que te vas a encontrar y explica el efecto que tienen sobre la tabla de rutas, que es donde aparecen casi todos los problemas.

---

## 1. Qué es el túnel

Un túnel es una conexión entre dos extremos dentro de la cual viaja otro tráfico. El paquete original se cifra y se mete dentro de un paquete nuevo, dirigido al servidor VPN. El router de casa, la cafetería y el operador solo ven una conexión al servidor VPN; no ven a qué servidor interno iba el paquete ni qué llevaba. Al llegar, el servidor VPN lo descifra y lo entrega en la red interna.

Eso tiene dos consecuencias que explican el comportamiento entero. La primera: el túnel solo protege hasta el servidor VPN. De ahí a la oficina, el tráfico va por la red interna como cualquier otro. La segunda: hace falta una **ruta** que diga qué destinos deben meterse en el túnel. Sin esa ruta, tener la VPN «conectada» no cambia nada, porque el tráfico sigue saliendo por la ruta normal.

| Qué se mete en el túnel | Cómo se llama | Cuándo |
|-------------------------|---------------|--------|
| Solo las redes internas (por ejemplo `10.0.0.0/8`) | Túnel dividido (*split tunnel*) | Lo habitual en empresas. El correo interno va por la VPN; la navegación general sale directa, que es más rápido y no carga el servidor. |
| Todo el tráfico | Túnel completo | Cuando la política exige que nada salga sin pasar por los controles de la oficina. El equipo depende de la VPN incluso para resolver nombres públicos. |

---

## 2. Las tres tecnologías

Hacen lo mismo a grandes rasgos. Se diferencian en cómo se configuran y en qué traen ya integrado.

| | WireGuard | OpenVPN | IPsec (IKEv2) |
|--|-----------|---------|----------------|
| Qué es | Un túnel sencillo y rápido, con muy poca configuración: claves, direcciones y listo. | Un túnel muy extendido, sobre UDP o TCP, configurado con ficheros de texto y certificados. | El estándar de siempre para unir sedes y para el acceso remoto integrado en los sistemas operativos. |
| Dónde lo ves | Servidores Linux modernos, y cada vez más equipos de red. | Servidores de acceso remoto que llevan años, y clientes en cualquier sistema. | Entre sedes (site-to-site) en cortafuegos y routers, y como VPN nativa de Windows. |
| Cómo autentica | Claves públicas, una por extremo. No hay usuarios ni certificados: la identidad es la clave. | Certificados, usuario y contraseña, o ambos. | Certificados o clave compartida entre sedes; usuario y certificado en acceso remoto. |
| Qué mirar al diagnosticar | Que las claves coincidan con el extremo esperado y que el puerto UDP llegue. | El certificado del cliente, la hora de los dos extremos y que el puerto no esté filtrado. | La propuesta de cifrado (los dos extremos tienen que ofrecer algo en común) y los registros del intercambio IKE. |

Ninguna es «más segura» por el nombre. Las tres son sólidas si están actualizadas y bien configuradas, y las tres fallan igual si la cuenta de quien conecta no tiene segundo factor o si el servidor VPN queda expuesto con credenciales flojas. La elección suele estar hecha ya por lo que soporta el cortafuegos de la empresa.

---

## 3. Las rutas que aparecen al conectar

Aquí está el grueso de las incidencias. Al conectar, el cliente instala rutas nuevas, y a partir de ese momento la tabla de rutas decide qué va por el túnel y qué no. Puedes verlo comparando `ip route` (o `Get-NetRoute` en Windows) antes y después de conectar.

| Ruta que aparece | Efecto |
|------------------|--------|
| Una red concreta por la interfaz del túnel (`10.1.0.0/8 dev wg0`) | El túnel dividido funciona: esa red va por la VPN y el resto no. |
| Una ruta por defecto nueva con métrica mejor | Túnel completo: todo pasa a salir por la VPN, también lo que no debería. |
| Una ruta a tu propia LAN por el túnel | Te quedas sin acceso a la impresora y al NAS de casa, porque esos destinos ahora se intentan alcanzar a través de la oficina. |
| Un DNS nuevo empujado por la VPN | Tus resoluciones pasan a hacerlas el DNS de la oficina. Correcto para nombres internos; si ese DNS no resuelve lo público, pierdes Internet entero aunque el túnel esté bien. |

### Qué estás viendo

```text
$ ip route
default via 192.168.1.1 dev eth0 metric 100
10.0.0.0/8 dev wg0 scope link
192.168.1.0/24 dev eth0 proto kernel scope link
```

Esta tabla es un túnel dividido sano. La red de casa (`192.168.1.0/24`) sigue saliendo por `eth0` porque su ruta es más específica; la red de la oficina (`10.0.0.0/8`) sale por `wg0`; el resto de Internet usa la ruta por defecto, que no se ha tocado. `ip route get 10.1.5.5` debería responder `dev wg0`, y `ip route get 1.1.1.1` debería responder `via 192.168.1.1`. Si las dos respuestas salen por el mismo sitio, la VPN no está separando como crees.

---

## 4. Cuando la VPN conecta pero algo no va

| Síntoma | Causa probable |
|---------|----------------|
| Conecta y no llega a ningún servidor interno | Falta la ruta hacia esas redes, o el cortafuegos de la oficina no permite el rango de direcciones que la VPN reparte. La conexión del túnel y el permiso para usarlo son dos cosas. |
| Llega a la oficina pero pierde la LAN de casa | El cliente instaló una ruta que solapa con la red local, o empujó una ruta por defecto. Se ve en la tabla de antes y después. |
| Se cae la navegación entera al conectar | Túnel completo con un DNS interno que no resuelve nombres públicos, o una ruta por defecto que apunta a un túnel que no está reenviando. |
| Conecta desde el móvil y no desde el hotel | El hotel solo deja salir por los puertos 80 y 443. Una VPN sobre UDP en un puerto alto no tiene camino; una que pueda ir sobre TCP/443 sí. |
| Ayer funcionaba y hoy no, sin cambiar nada | El certificado del cliente o del servidor caducó, o la hora de uno de los dos se desvió y las comprobaciones de validez fallan. |

---

## 5. Checklist

| Pregunta | Cómo comprobarla |
|----------|------------------|
| ¿El túnel está realmente establecido? | La interfaz existe y tiene dirección (`ip addr show wg0`, adaptador de la VPN en Windows) y el extremo remoto responde. |
| ¿Qué redes mete en el túnel? | Comparar la tabla de rutas antes y después. `ip route get` para un destino interno y otro público. |
| ¿Qué DNS está usando ahora? | `resolvectl status` o `Get-DnsClientServerAddress`. Puede haber cambiado al conectar. |
| ¿El cortafuegos de destino permite el rango de la VPN? | Las direcciones que reparte la VPN son una red más, y suelen olvidarse en las reglas. |
| ¿La cuenta tiene el segundo factor? | Una VPN es una puerta a la red interna. Contraseña sola es poco para lo que hay detrás. |

---

## 6. Error típico

**Situación.** Configuras el cliente VPN de un portátil y marcas «enviar todo el tráfico por la VPN» porque suena más seguro. Conectas desde casa. A partir de ese momento no llegas a la impresora ni al disco de red de casa, la videollamada va a tirones y, al preguntar, varios compañeros tienen el mismo síntoma desde que se actualizó el perfil del cliente.

**Por qué ocurre.** El túnel completo instala una ruta por defecto que gana a la que ya tenías. Todo, incluido lo que está en tu propia casa, se evalúa contra esa ruta. La red de casa resulta estar dentro del rango que la VPN reclama (la oficina usa `192.168.1.0/24` y tu casa también, que es la coincidencia más común del mundo), así que esas direcciones se meten en el túnel, salen en la oficina y allí nadie sabe qué hacer con ellas. No es que la impresora se haya roto: es que has dejado de tener ruta hacia ella. Y todo tu tráfico de Internet cruza la oficina de ida y vuelta, de ahí los tirones.

**Cómo se ve.** `ip route` con la VPN conectada muestra una ruta `default` por la interfaz de la VPN con mejor métrica que la de tu router, o una ruta a `192.168.1.0/24` por el túnel que choca con la de tu LAN. `ip route get 192.168.1.50` responde con la interfaz de la VPN en lugar de la interfaz local. Al desconectar, todo vuelve.

**Cómo se arregla.** Usar túnel dividido: que el perfil empuje solo las rutas de las redes internas de la empresa, no una ruta por defecto. Y elegir para la VPN un rango de direcciones que no coincida con los que usa todo el mundo en casa (`192.168.0.0/24`, `192.168.1.0/24`); un rango dedicado tipo `10.90.0.0/16` evita la colisión. Después de cambiar el perfil, la comprobación es la de siempre: un destino interno sale por el túnel, la puerta de enlace de casa sigue saliendo por la interfaz local, y la navegación no depende de la VPN.

---

Relacionado: [nat-enrutado](nat-enrutado.md) · [direccionamiento](direccionamiento.md) · [dns](dns.md) · [cifrado-hash-firma](../../Ciberseguridad/chuletas/cifrado-hash-firma.md) · [tls](../../Ciberseguridad/chuletas/tls.md)

*Biblioteca — Redes · VPN*
