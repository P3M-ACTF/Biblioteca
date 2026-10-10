# Chuleta: NAT y enrutado

Cada equipo decide a dónde enviar un paquete mirando su tabla de rutas: si el destino está en una red que conoce, lo manda directo; si no, lo manda a su puerta de enlace. Cuando ese paquete sale de una red privada hacia Internet, el router además le cambia la dirección de origen, porque las direcciones privadas no se enrutan fuera. Esa reescritura es el NAT. Esta chuleta explica las dos cosas, cómo verlas en Linux y cómo distinguir, ante un fallo, si el problema es de ruta o de traducción.

---

## 1. Enrutado: elegir el siguiente salto

Un equipo no sabe el camino completo hasta el destino. Solo sabe cuál es el **siguiente salto**: la IP del router al que le entrega el paquete, o la interfaz si el destino está en su propia red. Esa decisión sale de la tabla de rutas, y la regla es simple: gana la entrada cuyo prefijo coincide con más bits del destino. Una ruta a `10.1.2.0/24` gana a una ruta a `10.0.0.0/8` para un destino `10.1.2.5`, porque es más específica. Si ninguna coincide, se usa la ruta por defecto (`default`), que es la que dice «todo lo demás, por aquí». Si no hay ruta por defecto y nada coincide, el paquete se tira y el programa recibe «red inalcanzable».

```bash
ip route
ip -6 route
ip route get 1.1.1.1
sysctl net.ipv4.ip_forward
```

| Entrada | Qué significa |
|---------|----------------|
| `default via 192.168.1.1 dev eth0` | Todo lo que no encaje en otra ruta sale por `eth0` hacia `192.168.1.1`. Es la puerta de enlace. |
| `192.168.1.0/24 dev eth0 proto kernel scope link` | La red local de esa interfaz. El kernel la crea solo al configurar la IP. Los destinos de aquí se alcanzan directamente, sin router. |
| `10.8.0.0/24 via 10.0.0.1 dev eth1` | Una red remota: para llegar a `10.8.0.0/24` hay que pasar por `10.0.0.1`. |
| `blackhole 10.9.0.0/16` | Descartar expresamente. Se usa para que una red interna nunca salga por la ruta por defecto. |

`ip route get` es la pregunta directa: «¿qué harías tú con un paquete hacia esta IP?». Responde con la ruta elegida, la interfaz y la IP de origen que usaría. Es mejor que leer la tabla entera cuando hay muchas entradas.

`ip_forward` a `1` permite que la máquina reenvíe paquetes que no van dirigidos a ella, es decir, que haga de router. En un servidor normal está a `0` y así debe seguir: un servidor que reenvía tráfico sin querer es un camino que nadie vigila.

### Qué estás viendo

```text
$ ip route
default via 192.168.1.1 dev eth0 proto dhcp metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.50 metric 100
10.8.0.0/24 dev wg0 proto static scope link

$ ip route get 10.8.0.15
10.8.0.15 dev wg0 src 10.8.0.2 uid 1000
    cache
```

La primera ruta la puso el DHCP (`proto dhcp`): la puerta de enlace del router de casa. La segunda es la red local, automática. La tercera es de una VPN (`wg0`) y es estática. Cuando preguntas por `10.8.0.15`, el kernel elige `wg0` porque su prefijo es más específico que `default`, y anuncia que saldrá con origen `10.8.0.2`. Si esa consulta devolviera `dev eth0`, el tráfico de la VPN se estaría escapando por la red normal.

### Varias tablas

Linux puede tener más de una tabla de rutas y reglas que eligen cuál usar según el origen, la interfaz o una marca del paquete. Es el *policy routing*, habitual con dos salidas a Internet o con VPN.

```bash
ip rule list
ip route show table main
ip route show table 100
```

`ip rule` se evalúa por orden de prioridad. La regla que casa decide la tabla, y dentro de la tabla se aplica la lógica de siempre. Si `ip route` muestra una cosa y el tráfico hace otra, casi siempre hay una regla que estás pasando por alto: mira `ip rule` antes de dar la tabla por buena.

---

## 2. NAT: reescribir direcciones en la frontera

Las direcciones privadas (RFC 1918: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`) no se enrutan en Internet. Un paquete que salga con origen `192.168.1.50` será descartado por el primer router que no sea el tuyo, y aunque no lo fuera, la respuesta no tendría cómo volver. El **NAT** (Network Address Translation) reescribe las direcciones cuando el paquete cruza el router de borde, y apunta la correspondencia en una tabla de conexiones (*conntrack*) para que la respuesta encuentre el camino de vuelta.

| Tipo | Qué reescribe | Cuándo se usa |
|------|----------------|---------------|
| **SNAT** | La dirección de origen, cambiándola por una IP pública fija. | El router tiene una IP pública estática y la LAN sale a Internet con ella. |
| **Masquerade** | También el origen, pero usando la IP que tenga en ese momento la interfaz de salida, sea cual sea. | La IP pública la da el proveedor por DHCP y puede cambiar. Con SNAT fijo habría que reescribir la regla en cada cambio; masquerade lo consulta cada vez. |
| **DNAT** | La dirección de destino: lo que llega a una IP pública y un puerto se reenvía a un host interno. | Publicar un servicio que está en la red privada (un servidor web, un escritorio remoto). |
| **NAT 1:1** | Una IP pública corresponde siempre a la misma IP privada, en ambos sentidos. | Un servidor interno que debe ser alcanzable sin andar con puertos. |

El flujo de cabeza:

```text
Host LAN ── SNAT o masquerade ──> Internet
Internet ── DNAT de un puerto ──> Host LAN
```

Sin la tabla de conexiones, el NAT no sabe devolver la respuesta: le llega un paquete de Internet destinado a su IP pública y no tiene forma de saber a qué equipo interno pertenece. Por eso las reglas de NAT van siempre acompañadas de reglas que aceptan el tráfico `established,related`. Si alguien «limpia» esas reglas al ordenar el cortafuegos, la navegación se rompe aunque el NAT siga en su sitio.

---

## 3. Dónde vive el NAT en Linux

En el kernel, el NAT se aplica en dos momentos del recorrido del paquete. El DNAT ocurre en cuanto el paquete llega, antes de decidir la ruta, porque la ruta depende del destino y el DNAT cambia el destino: es la cadena `prerouting`. El SNAT ocurre al final, cuando ya se sabe por qué interfaz va a salir: es la cadena `postrouting`.

Quien escribe esas reglas es el mismo frontal del cortafuegos de la máquina. En nftables se ven como reglas `dnat`, `snat` y `masquerade`. firewalld tiene opciones propias (`--add-masquerade`, `--add-forward-port`). ufw no cubre bien el NAT: cuando una máquina necesita enrutar y traducir, ufw se queda corto y toca nftables o firewalld.

```bash
sudo nft list ruleset
sudo firewall-cmd --list-all
```

No hace falta memorizar la sintaxis para diagnosticar. Sí hace falta saber **en qué sentido** falla: si la LAN no sale, el problema está en la salida (ruta por defecto, IP forwarding, masquerade); si Internet no entra hacia un servicio publicado, está en la entrada (DNAT, el servicio escuchando, el cortafuegos del host de destino).

### Qué estás viendo

```text
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        ip saddr 192.168.1.0/24 oifname "eth0" masquerade
    }
    chain prerouting {
        type nat hook prerouting priority -100; policy accept;
        iifname "eth0" tcp dport 443 dnat to 192.168.1.20:443
    }
}
```

La regla de `postrouting` dice: lo que venga de la LAN y salga por `eth0`, que salga con la IP de `eth0`. La de `prerouting`: lo que entre por `eth0` hacia el puerto 443, entrégalo a `192.168.1.20`. Fíjate en que el DNAT no abre el puerto por sí mismo: además, el cortafuegos tiene que aceptar ese tráfico y el servidor interno tiene que estar escuchando.

---

## 4. Síntomas

| Síntoma | Dónde mirar |
|---------|-------------|
| La LAN no tiene Internet, pero el router sí navega. | Ruta por defecto en los clientes, `ip_forward` en el router, y que exista masquerade o SNAT. El DNS también: mucha «falta de Internet» es un DNS que no responde. |
| Se navega, pero desde fuera no entra nada. | DNAT del puerto, cortafuegos del perímetro y cortafuegos del host interno. Comprueba el sentido: la salida funciona, la entrada no. |
| Un puerto publicado concreto falla y el resto va. | Que el DNAT apunte a la IP y al puerto correctos, que el servicio escuche (`ss -tlnp` en el destino) y que el host de destino acepte ese puerto. |
| La VPN conecta pero se pierde el acceso a la LAN. | La VPN ha metido una ruta que solapa con la red local, o ha sustituido la ruta por defecto. Compara `ip route` antes y después. |
| La ida llega y la vuelta no. | Ruta de ida y ruta de vuelta distintas: el destino responde por otro camino y el conntrack no casa la respuesta. Pasa con routers redundantes mal configurados. |

```bash
ping -c 2 192.168.1.1
ping -c 2 1.1.1.1
ip route get 1.1.1.1
ss -tlnp
```

La secuencia del ping separa las causas: si no llegas a tu puerta de enlace, el problema es local (cable, interfaz, VLAN); si llegas a la puerta de enlace pero no a `1.1.1.1`, es el salto siguiente (ruta, NAT o el proveedor); si llegas a `1.1.1.1` por IP pero no se abren páginas, es DNS.

---

## 5. Checklist

| Pregunta | Dónde se responde |
|----------|-------------------|
| ¿Por dónde salgo a Internet? | `ip route`: la línea `default via`. |
| ¿Esta máquina reenvía tráfico? | `sysctl net.ipv4.ip_forward`. En un servidor de aplicación debe ser 0; en el router, 1. |
| ¿Hay traducción de salida? | Regla `masquerade` o `snat` en postrouting, o `--list-all` de firewalld. |
| ¿Qué ruta se usaría hacia un destino? | `ip route get DESTINO`. |
| ¿El servicio publicado escucha donde el DNAT apunta? | `ss -tlnp` en el host interno, en el puerto de destino. |
| ¿La vuelta tiene camino? | Ruta por defecto del host interno apuntando al router que hizo el DNAT. |

---

## 6. Error típico

**Situación.** Montas un router Linux entre una LAN de laboratorio (`192.168.50.0/24` en `eth1`) y la red del aula (`eth0`). Activas `ip_forward`, los clientes tienen como puerta de enlace la IP del router, y no hay forma de salir. Desde el propio router sí se navega. El ping desde un cliente llega al router y no pasa de ahí.

**Por qué ocurre.** Reenviar no es traducir. Con `ip_forward=1` el router entrega en `eth0` los paquetes tal cual, con origen `192.168.50.20`. Esa dirección es privada: la red del aula no tiene ruta de vuelta hacia `192.168.50.0/24`, así que la respuesta se pierde. El router navega porque su propio tráfico ya sale con la IP de `eth0`, que sí es conocida. Falta el paso que reescribe el origen.

**Cómo se ve.** En el cliente, `ping 1.1.1.1` no vuelve. En el router, `tcpdump -i eth0 host 1.1.1.1` muestra los paquetes saliendo con origen `192.168.50.20` y las respuestas llegando... o ni siquiera llegando, porque el router del aula las descartó. `nft list ruleset` no tiene ninguna regla `masquerade`. `ip route get 1.1.1.1 from 192.168.50.20 iif eth1` confirma que la ida está bien encaminada: el fallo no es la ruta.

**Cómo se arregla.** Añadir masquerade para lo que salga de esa LAN por la interfaz de salida, y permitir el tráfico reenviado en el cortafuegos (la cadena `forward`, que es distinta de `input`: el tráfico que atraviesa el router no va destinado a él y `input` no lo ve).

```nft
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        ip saddr 192.168.50.0/24 oifname "eth0" masquerade
    }
}
```

Después, el mismo `tcpdump` debe mostrar los paquetes saliendo con la IP de `eth0`, y el ping del cliente recibe respuesta. Y queda escrito en el fichero de nftables, no solo cargado en memoria: si no, el próximo reinicio lo olvida.

---

Relacionado: [direccionamiento](direccionamiento.md) · [diagnostico](diagnostico.md) · [firewall-linux](../../Sistemas%20Operativos/chuletas/firewall-linux.md) · [vpn-conceptos](vpn-conceptos.md) · guía [Camino de un paquete](https://github.com/P3M-ACTF/Biblioteca/wiki/Camino-de-un-paquete) · guía [Capas de firewall en la empresa](https://github.com/P3M-ACTF/Biblioteca/wiki/Capas-de-firewall-en-la-empresa)

*Biblioteca — Redes · NAT / enrutado*
