# Chuleta: VLAN y conmutación

Una VLAN parte un único switch físico en varias redes distintas, de modo que los equipos de una no reciben el tráfico de la otra aunque estén enchufados al mismo aparato. Es la herramienta básica para separar puestos, servidores, invitados y gestión sin comprar un switch por cada red. Esta chuleta explica cómo se separa el tráfico, qué diferencia hay entre un puerto de acceso y un enlace troncal, y cómo se ve una VLAN desde Linux.

---

## 1. Qué separa una VLAN

Un switch normal reenvía las tramas a todos los puertos de la misma red. Una VLAN le dice que solo reenvíe dentro del grupo de puertos que pertenecen a esa VLAN: los puestos en la VLAN 10 y los servidores en la VLAN 20 están aislados entre sí igual que si hubiera dos switches. Para que hablen hace falta un router o un switch de capa 3 con una interfaz en cada VLAN, exactamente igual que entre dos redes físicas.

Cada VLAN lleva un identificador del 1 al 4094 y, en la práctica, su propia subred IP. La VLAN 10 será `10.1.10.0/24` y la 20 será `10.1.20.0/24`. Mezclar las dos cosas (misma subred en dos VLAN, o dos subredes en la misma) funciona a medias y se depura muy mal: la correspondencia una VLAN, una subred, es la que hace que el diagnóstico sea directo.

---

## 2. Puertos de acceso y enlaces troncales

| Tipo de puerto | Qué hace | Dónde se usa |
|----------------|----------|--------------|
| **Acceso** | Pertenece a una sola VLAN. El equipo que se enchufa no sabe nada de VLAN: envía y recibe tramas normales, y el switch les pone y les quita la etiqueta. | Puestos, impresoras, servidores que solo están en una red. |
| **Troncal** (*trunk*) | Transporta varias VLAN a la vez, marcando cada trama con su número mediante la etiqueta 802.1Q. | El enlace entre dos switches, o entre un switch y un router o un hipervisor que necesitan ver varias redes. |

La etiqueta 802.1Q es un campo añadido a la trama con el número de VLAN. En un puerto de acceso el switch lo añade al entrar y lo quita al salir, así que el equipo ni se entera. En un troncal la etiqueta viaja, porque al otro lado hay que saber a qué VLAN pertenece cada trama.

Dos conceptos más que salen al configurar:

| Concepto | Qué decide |
|----------|------------|
| **VLAN nativa** | La VLAN cuyas tramas viajan por el troncal **sin** etiqueta. Tiene que ser la misma en los dos extremos; si no, el tráfico de una VLAN se cuela en la otra sin que ninguna alarma salte. Se elige una VLAN dedicada y no se usa para datos. |
| **STP** | Spanning Tree evita los bucles: si hay dos caminos entre switches, bloquea uno para que las tramas no circulen eternamente. No se desactiva. Cuando un puerto tarda unos segundos en empezar a pasar tráfico al enchufar un equipo, normalmente es STP haciendo su comprobación. |

---

## 3. Cómo se ve desde Linux

Un servidor Linux puede necesitar estar en varias VLAN a la vez (un hipervisor, un cortafuegos, un proxy). Para eso su interfaz se conecta a un puerto troncal y se crean interfaces virtuales, una por VLAN.

```bash
sudo ip link add link eth0 name eth0.10 type vlan id 10
sudo ip link set eth0.10 up
sudo ip addr add 10.1.10.5/24 dev eth0.10
ip -d link show eth0.10
```

`eth0.10` es una interfaz como cualquier otra, cuyo tráfico sale por `eth0` con la etiqueta de la VLAN 10. Se le pone dirección, rutas y cortafuegos igual que a una interfaz física. El nombre es convención; lo que importa es `id 10`.

### Qué estás viendo

```text
$ ip -d link show eth0.10
eth0.10@eth0: <BROADCAST,UP,LOWER_UP> mtu 1500
    vlan protocol 802.1Q id 10
$ ip -4 addr show eth0.10
inet 10.1.10.5/24 scope global eth0.10
```

`vlan protocol 802.1Q id 10` confirma que esta interfaz mete y saca la etiqueta 10, y `@eth0` dice que viaja sobre `eth0`. `LOWER_UP` significa que el enlace de debajo está activo. Si la interfaz está `UP` pero no llegas a nadie de la VLAN 10, el problema está al otro lado: el puerto del switch no es troncal, o no tiene permitida la VLAN 10. El síntoma es indistinguible de un cable desconectado, porque las tramas etiquetadas que el switch no espera se descartan en silencio.

Para que sobreviva al reinicio, la interfaz VLAN va donde vaya el resto de la configuración de red: un perfil de NetworkManager, un fichero de netplan o un `.netdev` de systemd-networkd (chuleta [red-linux-configuracion](../../Sistemas%20Operativos/chuletas/red-linux-configuracion.md)).

---

## 4. Diagnosticar de qué lado está el fallo

Como hay dos extremos (el equipo y el switch), conviene saber cuál de los dos hablar.

| Síntoma | Dónde está la causa probable |
|---------|------------------------------|
| El equipo en un puerto de acceso no recibe DHCP y se queda en `169.254.x.x` | El puerto está en una VLAN distinta de la que tiene el servidor DHCP, o falta el relay DHCP hacia esa VLAN. |
| Dos equipos de la misma VLAN y la misma subred no se ven, en el mismo switch | El aislamiento de puertos está activo, o uno de los dos puertos no está en la VLAN que crees. La VLAN se comprueba en el switch, no se adivina. |
| Funciona dentro del switch y no hacia el de la otra sala | El troncal entre ambos no transporta esa VLAN. Hay que permitirla explícitamente en los dos extremos. |
| Al pasar por el troncal, los equipos aparecen en la VLAN equivocada | Las VLAN nativas no coinciden. Cada extremo está interpretando las tramas sin etiqueta como de su propia nativa. |
| Linux tiene la interfaz VLAN arriba y no llega a nadie | El puerto del switch es de acceso en lugar de troncal, así que descarta las tramas etiquetadas. |

---

## 5. Checklist

| Pregunta | Dónde se responde |
|----------|-------------------|
| ¿En qué VLAN está este puerto? | En la configuración del switch, como puerto de acceso de esa VLAN. |
| ¿Este enlace transporta varias? | Es troncal, y la lista de VLAN permitidas incluye las que necesitas, en los dos extremos. |
| ¿La VLAN nativa coincide? | Mismo número en ambos extremos, y es una VLAN que no llevas datos. |
| ¿Cada VLAN tiene su subred? | Una correspondencia limpia, así el diagnóstico por IP te dice la VLAN. |
| ¿Hay camino entre VLAN? | Un router o switch de capa 3 con interfaz en cada una, y las reglas de cortafuegos que deciden qué puede cruzar. Sin eso, la separación es total. |

---

## 6. Error típico

**Situación.** Añades un hipervisor y quieres que sus máquinas virtuales estén unas en la VLAN de servidores y otras en la de puestos. Creas en Linux las interfaces `eth0.10` y `eth0.20`, les pones direcciones correctas, las pones arriba, y ninguna de las dos llega a su puerta de enlace. El cable está bien: si quitas las VLAN y pones una IP normal en `eth0`, funciona.

**Por qué ocurre.** El puerto del switch donde enchufaste el hipervisor es un puerto de acceso de la VLAN por defecto. Un puerto de acceso espera tramas sin etiqueta y descarta las etiquetadas, que son precisamente las que envían `eth0.10` y `eth0.20`. Cuando configuras `eth0` directamente, las tramas van sin etiqueta, el puerto las acepta y por eso «el cable funciona». El fallo no está en Linux: está en que el puerto no es troncal y nadie le ha dicho que deje pasar las VLAN 10 y 20.

**Cómo se ve.** En Linux, `ip -d link` muestra las interfaces VLAN en `UP` y `LOWER_UP`, con su `id` correcto, y `ping` a la puerta de enlace de cada una no responde. En el switch, el puerto figura como acceso. Un `tcpdump -e -i eth0` en el hipervisor muestra tus tramas saliendo con la etiqueta `vid 10`; no vuelve ninguna.

**Cómo se arregla.** En el switch, configurar ese puerto como troncal y permitir en él las VLAN 10 y 20 (y ninguna más de la cuenta). Acordar la VLAN nativa con la configuración de Linux, que por defecto no usa nativa si todas tus interfaces van etiquetadas. En cuanto el puerto deja pasar las etiquetas, los mismos ping empiezan a responder sin tocar nada en el hipervisor. Queda documentado qué puerto es troncal y por qué: un puerto troncal enchufado a un puesto normal pone al puesto en situación de recibir tráfico de todas las VLAN, que es justo lo contrario de lo que se pretendía.

---

Relacionado: [direccionamiento](direccionamiento.md) · [nat-enrutado](nat-enrutado.md) · [diagnostico](diagnostico.md) · [red-linux-configuracion](../../Sistemas%20Operativos/chuletas/red-linux-configuracion.md) · guía [Capas de firewall en la empresa](https://github.com/P3M-ACTF/Biblioteca/wiki/Capas-de-firewall-en-la-empresa)

*Biblioteca — Redes · VLAN y conmutación*
