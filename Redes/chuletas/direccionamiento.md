# Chuleta: direccionamiento IPv4, IPv6 y CIDR

Una dirección IP dice quién es un equipo; la máscara dice qué otros equipos están en su misma red. Con esas dos piezas se decide todo lo demás: si un destino se alcanza directamente o hay que pasar por la puerta de enlace, cuántos equipos caben en una red y cómo se parte una red en varias. Esta chuleta explica el cálculo y los rangos que conviene reconocer de memoria.

---

## 1. Las piezas de una dirección IPv4

Una dirección IPv4 son 32 bits, escritos como cuatro números del 0 al 255 por comodidad. Sola, no dice nada sobre la red: `192.168.1.10` puede ser un equipo de una red de 254 hosts o de una de 6, según la máscara que la acompañe.

| Pieza | Qué aporta |
|-------|------------|
| **Dirección** | Los 32 bits que identifican al interfaz. Un equipo con dos interfaces tiene dos direcciones y pertenece a dos redes. |
| **Máscara** | Qué parte de la dirección es la red y qué parte identifica al equipo dentro de ella. Se escribe como la dirección (`255.255.255.0`) o, más habitual hoy, como el número de bits de red. |
| **CIDR (`/n`)** | Ese número de bits. `/24` significa que los primeros 24 bits son la red y los 8 restantes identifican equipos. Es la misma información que la máscara, en menos sitio. |
| **Puerta de enlace** | La IP del router al que se envía todo lo que no está en la red propia. Tiene que estar en la misma red que el equipo: si no puedes hablar con tu puerta de enlace directamente, no puedes hablar con nadie de fuera. |
| **Broadcast** | La última dirección de la red, que significa «todos los equipos de esta red». Existe en IPv4; IPv6 no la usa. |
| **Dirección de red** | La primera dirección, donde la parte de equipo es todo ceros. Sirve para nombrar la red, no se asigna a ningún equipo. |

---

## 2. De la máscara al número de equipos

Cada bit que quitas de la máscara duplica el tamaño de la red. Como IPv4 tiene 32 bits, el número de direcciones de una red es `2^(32-n)`.

| CIDR | Máscara | Direcciones | Equipos útiles |
|------|---------|-------------|----------------|
| `/8` | `255.0.0.0` | 16 777 216 | Toda una clase A privada. |
| `/16` | `255.255.0.0` | 65 536 | 65 534 equipos. |
| `/24` | `255.255.255.0` | 256 | 254 equipos. La red de oficina clásica. |
| `/25` | `255.255.255.128` | 128 | 126 equipos. Parte un `/24` en dos. |
| `/26` | `255.255.255.192` | 64 | 62 equipos. |
| `/27` | `255.255.255.224` | 32 | 30 equipos. |
| `/28` | `255.255.255.240` | 16 | 14 equipos. |
| `/29` | `255.255.255.248` | 8 | 6 equipos. |
| `/30` | `255.255.255.252` | 4 | 2 equipos. El tamaño clásico de un enlace punto a punto entre routers. |
| `/32` | `255.255.255.255` | 1 | Una sola dirección. Se usa para nombrar un host concreto en una ruta o en una regla. |

«Útiles» descuenta la dirección de red y la de broadcast. En los enlaces punto a punto modernos se usa también `/31` (RFC 3021), donde las dos direcciones son utilizables y no hay broadcast, así que el descuento no se aplica.

---

## 3. Calcular la red de una dirección

El cálculo responde a una pregunta práctica: dado un equipo con su máscara, ¿cuál es su red, quiénes son sus vecinos y cuál es el broadcast? Se hace siempre igual.

1. Calcula el tamaño de bloque: `2^(32-n)`. Para `/26`, `2^6 = 64`.
2. La red empieza en un múltiplo de ese bloque. Para el tercer octeto si la máscara cae ahí, o para el cuarto en los `/24` y más largos.
3. El broadcast es la última dirección del bloque, y los equipos útiles son todo lo que queda en medio.

**Ejemplo.** `192.168.10.37/26`.

- Bloques de 64 en el último octeto: las redes posibles son `.0`, `.64`, `.128` y `.192`.
- 37 cae entre 0 y 64, así que su red es `192.168.10.0/26`.
- Primer equipo: `192.168.10.1`. Último: `192.168.10.62`. Broadcast: `192.168.10.63`.
- El equipo `.37` y el equipo `.70` **no** se ven directamente: están en redes distintas y necesitan un router, aunque los dos «empiecen por 192.168.10». Este es el error de cálculo que más horas hace perder.

**Otro.** `10.0.5.100/24`. Bloques de 256, así que la red es el octeto entero: red `10.0.5.0/24`, equipos `.1` a `.254`, broadcast `.255`.

```bash
ipcalc 192.168.10.37/26
sipcalc 192.168.10.37/26
```

`ipcalc` y `sipcalc` hacen la cuenta si están instalados. Conviene saber hacerla a mano de todos modos, porque la pregunta sale en sitios donde no hay esas herramientas: delante de un switch, en un examen, en un cortafuegos.

### Partir una red

Partir es lo mismo al revés. Si tienes `10.1.0.0/24` y necesitas cuatro redes, pasas de `/24` a `/26` (dos bits más, cuatro bloques) y obtienes `10.1.0.0/26`, `10.1.0.64/26`, `10.1.0.128/26` y `10.1.0.192/26`, con 62 equipos cada una. Si una de ellas se queda corta, se parte solo esa: las cuatro no tienen por qué ser iguales, aunque la cuenta sea más fácil si lo son.

---

## 4. Rangos que hay que reconocer

No todas las direcciones significan lo mismo, y confundirlas lleva a reglas de cortafuegos absurdas.

| Rango | Qué es |
|-------|--------|
| `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | Direcciones privadas (RFC 1918). Se usan dentro de la red y no se enrutan en Internet; para salir necesitan NAT. Ojo con `172.16.0.0/12`: cubre de `172.16` a `172.31`, no «todo lo que empieza por 172». |
| `127.0.0.0/8` | Loopback. `127.0.0.1` es el propio equipo. Nunca sale a la red. |
| `169.254.0.0/16` | Link-local. Un equipo se la asigna solo cuando pidió dirección por DHCP y nadie contestó. Ver una `169.254.x.x` es el síntoma, no la configuración. |
| `224.0.0.0/4` | Multidifusión. No se asigna a equipos. |
| `0.0.0.0` | «Cualquiera» en una ruta o en una regla, o «aún no tengo dirección» en un socket que escucha. |

---

## 5. IPv6 en lo que se usa de verdad

IPv6 son 128 bits, escritos en hexadecimal separados por dos puntos. La idea de red y equipo es la misma; cambian los tamaños y las costumbres.

| Concepto | Cómo funciona |
|----------|----------------|
| Escritura | Ocho grupos hexadecimales. Se pueden omitir los ceros a la izquierda de cada grupo y, una sola vez, una secuencia de grupos a cero: `2001:db8:0:0:0:0:0:1` se escribe `2001:db8::1`. |
| Tamaño de red habitual | `/64` en una red local. Deja 64 bits para los equipos, así que no se calcula el «número de hosts»: caben todos. Partir en algo más pequeño que `/64` rompe mecanismos que dan por hecho ese tamaño. |
| Loopback | `::1`. |
| Link-local | `fe80::/10`. Todo interfaz IPv6 tiene una, se configura sola y solo vale dentro del enlace. Como hay una por interfaz, al usarla hay que decir por cuál: `ping fe80::1%eth0`. |
| ULA | `fc00::/7` (en la práctica `fd00::/8`). Son las privadas de IPv6: para dentro de la organización, no enrutables fuera. |
| Documentación | `2001:db8::/32`. Reservado para ejemplos. Lo que ves en esta documentación. |
| Puerta de enlace | Igual que en IPv4, tiene que ser alcanzable directamente. A menudo se anuncia sola mediante *router advertisement* y el equipo la aprende sin DHCP. |

Una diferencia de operación: en IPv6 un interfaz tiene **varias** direcciones a la vez (link-local, más una o varias globales), y eso es normal. `ip -6 addr` mostrando tres direcciones no es un fallo.

---

## 6. Dónde se ve en el sistema

```bash
ip -4 addr show
ip -6 addr show
ip route
ip route get 10.1.0.20
```

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-NetRoute -DestinationPrefix "0.0.0.0/0"
```

### Qué estás viendo

```text
$ ip -4 addr show eth0
inet 192.168.10.37/26 brd 192.168.10.63 scope global eth0

$ ip route
default via 192.168.10.1 dev eth0
192.168.10.0/26 dev eth0 proto kernel scope link src 192.168.10.37
```

`inet` junta dirección y máscara, y `brd` es el broadcast: con eso ya puedes comprobar que la cuenta cuadra (`.37` está entre `.0` y `.63`). La ruta de red la creó el kernel al configurar la IP (`proto kernel`); la ruta por defecto la puso DHCP o la configuración estática. Si la puerta de enlace no cae dentro de `192.168.10.0/26`, el equipo no puede usarla, y el síntoma es que ni siquiera llega a su router.

---

## 7. Checklist

| Pregunta | Cómo responderla |
|----------|------------------|
| ¿En qué red estoy? | `ip addr`: dirección y `/n`. Calcula el bloque o usa `ipcalc`. |
| ¿Cuántos equipos caben? | `2^(32-n) - 2` en IPv4 con broadcast. |
| ¿Este destino es local o sale por el router? | `ip route get DESTINO`. Si devuelve la interfaz sin `via`, es local. |
| ¿La puerta de enlace está en mi red? | Su IP tiene que caer dentro del bloque. Si no, la configuración es imposible. |
| ¿Por qué tengo `169.254.x.x`? | No hubo respuesta DHCP. El problema está en el servidor DHCP, en la VLAN o en el enlace, no en la IP. |
| ¿Estas dos IP se ven entre sí? | Solo si caen en el mismo bloque. Calcúlalo; no te fíes del prefijo a ojo. |

---

## 8. Error típico

**Situación.** Hay que separar los servidores de los puestos. Decides dejar los puestos en `192.168.1.0/24` y pones los servidores en `192.168.1.0/25` «para que quepan en la misma red y no haga falta router». Configuras un servidor con `192.168.1.200/25` y un puesto con `192.168.1.50/24`. Desde el puesto no llegas al servidor ni haciendo ping, estando en el mismo switch.

**Por qué ocurre.** `/25` parte la red en dos: `192.168.1.0/25` (del `.0` al `.127`) y `192.168.1.128/25` (del `.128` al `.255`). El servidor `.200` con máscara `/25` cree que su red llega solo hasta `.255` desde `.128`, así que para hablar con `.50` intenta usar su puerta de enlace, que no existe. El puesto con `/24` cree que `.200` es local y le envía el paquete directo. Las máscaras no coinciden, así que cada uno toma una decisión distinta sobre el mismo destino y el tráfico solo funciona en un sentido, o en ninguno. «Estar en el mismo switch» no significa nada si las direcciones dicen que son redes distintas: el switch reenvía tramas, pero los equipos ni siquiera llegan a emitirlas hacia el destino correcto.

**Cómo se ve.** En el servidor, `ip route get 192.168.1.50` devuelve `via <puerta de enlace>` en lugar de `dev eth0`. En el puesto devuelve `dev eth0`. `ipcalc 192.168.1.200/25` muestra la red `192.168.1.128/25`, que no contiene a `.50`. El ping sale y no vuelve, o no sale.

**Cómo se arregla.** Decidir una máscara y usarla en los dos lados. Si de verdad deben estar en la misma red, los dos con `/24`. Si de verdad deben estar separados, que lo estén de verdad: servidores en `192.168.1.128/25`, puestos en `192.168.1.0/25`, y un router (o un switch de capa 3) entre medias con una interfaz en cada red. La separación a medias, misma VLAN y máscaras distintas, no aísla nada y rompe la conectividad.

---

Relacionado: [nat-enrutado](nat-enrutado.md) · [diagnostico](diagnostico.md) · [modelo-puertos](modelo-puertos.md) · [vlan-switching](vlan-switching.md) · [red-linux-configuracion](../../Sistemas%20Operativos/chuletas/red-linux-configuracion.md)

*Biblioteca — Redes · direccionamiento*
