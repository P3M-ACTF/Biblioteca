# Chuleta: enrutamiento dinámico

La chuleta de [NAT y enrutado](nat-enrutado.md) explica la tabla de rutas: qué camino elige un equipo para cada destino. Esta explica **quién rellena esa tabla** cuando no la escribes a mano. RIP, OSPF y BGP son tres formas de que los routers se cuenten entre sí qué redes conocen. No hace falta memorizar la configuración de cada fabricante; sí hace falta saber qué anuncia cada uno y qué mirar cuando una red deja de ser alcanzable.

---

## 1. Ruta estática y ruta aprendida

Una ruta estática la escribe alguien: «para llegar a esta red, el siguiente salto es este». No cambia sola. Sirve para lo pequeño y para las excepciones (una red concreta que siempre sale por un sitio). Se rompe en silencio cuando el salto de al lado cae: la ruta sigue en la tabla y el tráfico se pierde.

Una ruta aprendida la instala un protocolo de enrutamiento porque un vecino la ha anunciado. Si ese anuncio desaparece, la ruta desaparece con él y el tráfico busca otro camino, si lo hay. El precio es que hay que entender de quién te fías: un router anuncia lo que sabe, y si sabe mal, los demás aprenden mal.

En la tabla de Linux se distinguen por el origen. `proto static` la pusiste tú o un fichero de configuración. `proto dhcp` vino con la concesión. `proto kernel` es la red directamente conectada. Una ruta de OSPF o BGP no la pone el kernel solo: la instala el demonio de enrutamiento (FRR, BIRD u otro) y aparece como protocolo propio.

```bash
ip route
ip route get 10.2.0.10
```

### Qué estás viendo

```text
default via 192.0.2.1 dev eth0 proto static
10.1.0.0/24 dev eth1 proto kernel scope link
10.2.0.0/24 via 10.1.0.1 dev eth1 proto ospf metric 20
```

La red `10.1.0.0/24` está en el cable de `eth1`: no hace falta que nadie la anuncie para alcanzarla. `10.2.0.0/24` no está en ningún cable de esta máquina; OSPF ha dicho que se llega a través de `10.1.0.1`. Si esa línea desaparece, o dejas de llegar, o pasa a usarse otra ruta menos específica (a menudo la de defecto, que lleva el tráfico al sitio equivocado).

---

## 2. Tres protocolos, tres alcances

| Protocolo | Qué anuncia | Dónde se usa | Cómo elige |
|-----------|-------------|--------------|------------|
| **RIP** | La lista de redes que conoce, con un contador de saltos. Cada router suma uno al recibirlo. A 16 saltos la red se considera inalcanzable. | Redes pequeñas y laboratorios. En una empresa actual es raro verlo en producción; aparece en equipos viejos y en ejercicios. | El camino con menos saltos, sin mirar si un salto es una línea de gigabit y otro un enlace lento. |
| **OSPF** | El estado de sus enlaces: qué vecinos tiene y qué redes cuelgan de él. Todos los routers del mismo área construyen el mismo mapa y calculan el camino más corto. | El interior de una organización (IGP). Es el habitual entre los routers de una sede o de una red corporativa. | Un coste por enlace, que se puede ajustar. No cuenta saltos: cuenta lo que tú hayas definido como coste. |
| **BGP** | Prefijos (redes) junto con atributos: por dónde se ha aprendido, qué sistema autónomo lo origina, qué preferencia le da el administrador. | Entre organizaciones, y entre sedes de una misma organización cuando cada sede es un sistema autónomo. Es el protocolo de Internet. | Políticas, no el camino más corto. La red se alcanza por donde la política dice, aunque haya un camino más breve. |

OSPF y RIP hablan de vecinos que están en el mismo enlace o a los que apuntas explícitamente, dentro de tu red. BGP habla de pares a los que te conectas a propósito, a menudo en otra organización, y la confianza es la de ese acuerdo: aceptas los prefijos que ese par te anuncia.

IS-IS hace un trabajo parecido al de OSPF (mapa de enlaces dentro de la red) y lo verás en redes de operador. EIGRP es el equivalente propietario de Cisco. Con RIP, OSPF y BGP se cubre casi cualquier diagnóstico; el resto se reconoce por el nombre y se lee igual: ¿quién anuncia esta red y por qué ha dejado de hacerlo?

---

## 3. Qué se rompe, y cómo se ve

| Síntoma | Lectura |
|---------|---------|
| Una sede no llega a una red interna y el resto sí. | El anuncio de esa red no está llegando a esa sede. En OSPF, un enlace caído o un área mal puesta. En BGP, un prefijo que ese par ya no anuncia, o un filtro que lo tira. |
| El tráfico sale por un camino absurdo. | Hay un anuncio más específico que gana a la ruta que tú esperabas, o la política BGP prefiere otro par. `ip route get` dice cuál se usa; el demonio dice quién la anunció. |
| Tras un corte, tarda minutos en volver. | RIP converge despacio a propósito. OSPF y BGP son más rápidos, pero un BGP con temporizadores largos también espera antes de retirar un prefijo. |
| Aparece una ruta a una red que no es tuya. | Alguien la está anunciando. En BGP eso es un incidente de enrutamiento: un prefijo ajeno no debería aceptarse sin filtro. No se «arregla» apagando el protocolo. |
| La red directamente conectada se ve, las remotas no. | El demonio de enrutamiento no está arrancado, no tiene vecinos, o los vecinos no pasan el cortafuegos (OSPF usa multicast en el enlace; BGP usa TCP 179). |

```bash
ip route get 10.8.0.20
# En el propio router, según el demonio:
vtysh -c 'show ip route'          # FRR
vtysh -c 'show ip ospf neighbor'
vtysh -c 'show bgp summary'
```

### Qué estás viendo en un vecino

```text
Neighbor ID     Pri   State           Dead Time   Address
10.1.0.2          1   FULL/DR         00:00:32    10.1.0.2
10.1.0.3          1   INIT/DROTHER    00:00:35    10.1.0.3
```

`FULL` significa que el intercambio con ese vecino OSPF terminó y os creéis el mapa mutuamente. `INIT` significa que oyes al otro pero el otro no te oye a ti: suele ser un cortafuegos en un sentido, una máscara distinta o una autenticación que no coincide. Mientras esté en `INIT`, sus redes no entran en tu tabla.

En BGP, `show bgp summary` enseña cada par y cuántos prefijos has aceptado de él. Un par en `Active` o `Idle` no está establecido: no hay sesión TCP en el 179, o la sesión se cayó. Cero prefijos con la sesión establecida significa que el par no te anuncia nada o que tu filtro se lo queda todo.

---

## 4. Qué no decide el protocolo

El protocolo elige el siguiente salto. No atraviesa un cortafuegos que tire el tráfico, no hace NAT y no arregla una VLAN mal asignada. Si `ip route get` ya dice que el paquete sale por la interfaz correcta hacia el salto correcto y aun así no llega, el fallo está después: en el enlace, en el filtrado o en el destino. Volver a mirar OSPF en ese punto no aporta.

Tampoco sustituye a la ruta de la red conectada. Si el servidor está en `10.1.0.0/24` y tú también, no interviene ningún protocolo: os veis por el enlace. El día que alguien «arregla» eso metiendo la red en OSPF y cambiando las máscaras, deja de verse.

---

## 5. Checklist

| Pregunta | Dónde se responde |
|----------|-------------------|
| ¿La ruta está, y quién la puso? | `ip route` y la columna `proto`, o la tabla del demonio. |
| ¿Qué salto se usaría ahora mismo? | `ip route get DESTINO`. |
| ¿El vecino está establecido? | OSPF en `FULL`; BGP con sesión establecida y prefijos aceptados. |
| ¿El anuncio debería existir? | Alguien, en el router que tiene esa red conectada, la está redistribuyendo o la tiene como red de OSPF. Si nadie la anuncia, nadie la aprende. |
| ¿Hay un filtro de por medio? | En BGP, los filtros de entrada y de salida son parte del diseño. Un prefijo que «no llega» a menudo está filtrado a propósito. |

---

## 6. Error típico

**Situación.** Tras añadir una red nueva de servidores, `10.9.0.0/24`, los de la sede A llegan y los de la sede B no. Desde B, `ping` a un servidor de esa red no responde. El switch de B está bien, el cortafuegos no tiene una regla nueva, y alguien propone abrir «todo» un rato para probar.

**Por qué ocurre.** La red se configuró en el router de A y se añadió a OSPF ahí. El router de B nunca la recibe: entre A y B el enlace va por BGP, y la redistribución de OSPF hacia BGP no incluye la red nueva (el filtro anuncia `10.1.0.0/16` y `10.9` se sale de ese rango, o simplemente nadie añadió el prefijo a la lista de lo que se anuncia). La tabla de B no tiene ruta a `10.9.0.0/24`. El tráfico hacia esa red, si acaso, sigue la ruta por defecto y sale a Internet, donde muere. No es un fallo de ping ni de cortafuegos.

**Cómo se ve.** En un equipo de B, `ip route get 10.9.0.10` devuelve la ruta por defecto, no un salto interno. En el router de A, la red está en OSPF. En el router de B, `show bgp` no tiene el prefijo `10.9.0.0/24`. Esa diferencia —A la conoce, B no la ha aprendido— es el diagnóstico entero.

**Cómo se arregla.** Anunciar el prefijo en el protocolo que une las dos sedes, con el mismo criterio que el resto de redes internas, y comprobar desde B que `ip route get` ya no sale por la ruta por defecto. No se abre el cortafuegos para compensar una ruta que no existe: el paquete ni siquiera va hacia el servidor.

---

Relacionado: [nat-enrutado](nat-enrutado.md) · [direccionamiento](direccionamiento.md) · [diagnostico](diagnostico.md) · [vlan-switching](vlan-switching.md) · [mapa de protocolos](../mapa-protocolos/README.md)

*Biblioteca — Redes · enrutamiento dinámico*
