# Chuleta: redes de las máquinas virtuales

El punto que más tiempo hace perder con una máquina virtual no es instalarla: es entender por qué tiene red o por qué no la tiene. El hipervisor (KVM, Hyper-V, VirtualBox) conecta la máquina virtual a la red del anfitrión de una de varias formas, y cada forma da un resultado distinto sobre quién puede hablar con quién. Esta chuleta explica esas formas. Sirve para laboratorio y para leer la configuración de un servidor de virtualización; no entra en el diseño de una plataforma completa.

---

## 1. Los tres modos que importan

| Modo | Qué ve la máquina virtual | Cuándo se usa |
|------|---------------------------|---------------|
| **NAT** | Sale a la red a través del anfitrión, que traduce sus direcciones. Recibe una IP de un rango privado que crea el propio hipervisor. Desde fuera nadie puede iniciar conexión hacia ella. | Laboratorio en un portátil, o cualquier caso en el que la virtual solo necesita salir (actualizaciones, navegar) y nadie necesita llegar a ella. |
| **Puente** (*bridged*) | Está en la misma red que el anfitrión, como si tuviera su propio cable. Recibe IP del DHCP de esa red, o una estática del mismo rango. El resto de equipos la ven como un equipo más. | Cuando la virtual tiene que ser un servidor de verdad: que otros entren por SSH, que se una al dominio, que sirva una web. |
| **Solo anfitrión** (*host-only*) | Está en una red privada entre ella y el anfitrión, sin salida al exterior. El anfitrión suele hacer de DHCP de esa red. Otras máquinas virtuales en la misma red solo-anfitrión se ven entre sí. | Aislar un laboratorio: varias máquinas que se hablan, y ninguna puede salir ni ser alcanzada desde la red real. |

Hay un cuarto, **red interna**, que es como solo-anfitrión pero sin el anfitrión: solo se ven las virtuales entre sí. Útil para un segmento que ni siquiera el anfitrión debe alcanzar.

La confusión de fondo es esperar que una máquina en NAT se comporte como un servidor. No puede: la traducción es de salida, igual que el NAT de casa. Para que alguien de fuera conecte hay que hacer un reenvío de puerto concreto (el equivalente al DNAT) o, más limpio, ponerla en modo puente.

---

## 2. Cómo se ve desde dentro

La máquina virtual no sabe en qué modo está. Solo ve una tarjeta de red y una configuración. El modo se adivina por la dirección que recibe.

| Si la virtual tiene | Está en |
|---------------------|---------|
| Una IP de un rango pequeño que no es el de tu red (a menudo `10.0.2.15` en VirtualBox, o `192.168.122.0/24` en la red `default` de KVM) y su puerta de enlace es una IP de ese mismo rango | NAT. |
| Una IP del mismo rango que el anfitrión, y puede hacer ping a otros equipos de la oficina | Puente. |
| Una IP de un rango que no existe en la oficina, puede hacer ping al anfitrión y no puede salir a Internet | Solo anfitrión. |

```bash
ip -4 addr
ip route
ping -c 2 1.1.1.1
```

### Qué estás viendo

```text
$ ip -4 addr show eth0
inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0

$ ip route
default via 10.0.2.2 dev eth0
```

`10.0.2.15` con puerta de enlace `10.0.2.2` es la firma del NAT de VirtualBox: el anfitrión está haciendo de router en `10.0.2.2` y traduciendo la salida. Desde esta máquina se llega a Internet y no se la alcanza desde la red local. Si necesitabas que un compañero conectara por SSH, este modo no sirve por mucho que abras el puerto en el cortafuegos de la virtual: el NAT no sabe a quién entregar la conexión entrante.

---

## 3. KVM y libvirt

En KVM la red la define una red virtual de libvirt, y cada máquina se conecta a una de ellas. La red `default` que viene creada es un NAT sobre `192.168.122.0/24`, con DHCP incluido. Por eso toda máquina nueva «tiene Internet» sin que hayas configurado nada, y por eso tampoco es alcanzable desde la LAN.

```bash
virsh net-list --all
virsh net-dumpxml default
ip -4 addr show virbr0
```

`virbr0` es el puente que libvirt crea en el anfitrión para esa red: la puerta de enlace que ven las virtuales. Si la red está `inactive`, las máquinas arrancan sin enlace.

Para poner una máquina en la red real se usa un puente del anfitrión (un `br0` que contiene la interfaz física) y se conecta la interfaz de la máquina a ese puente. A partir de ahí la máquina pide DHCP al router de la oficina como cualquier portátil. Es la opción correcta para un servidor virtual que da servicio.

---

## 4. Hyper-V

Hyper-V llama **conmutador virtual** a lo mismo, y los tipos coinciden: externo (puente, ligado a una interfaz física del anfitrión), interno (las virtuales y el anfitrión, sin salir) y privado (solo las virtuales).

El matiz de Hyper-V es que al crear un conmutador externo el anfitrión pasa a tener su propia IP sobre ese conmutador, y durante el cambio se puede perder la conexión un momento. Conviene hacerlo con consola. El conmutador por defecto que trae Hyper-V es de tipo NAT, así que una máquina nueva tiene salida y no entrada, igual que en los otros.

---

## 5. VirtualBox

En la configuración de red de cada máquina, el desplegable «Conectado a» tiene exactamente estas opciones: NAT, adaptador puente, adaptador solo-anfitrión, red interna y NAT network. La diferencia entre NAT y «red NAT» es que en la segunda varias máquinas comparten la misma red NAT y se ven entre sí; en el NAT simple, cada máquina está aislada de las demás.

El reenvío de puertos está en las opciones avanzadas del modo NAT: «puerto anfitrión 2222 → puerto invitado 22» permite entrar por SSH a `localhost:2222` del anfitrión. Sirve para un caso concreto; para un servicio de verdad, adaptador puente.

Las *guest additions* no cambian el modo de red, pero sin ellas el cortapega y las carpetas compartidas no funcionan (notas [guest-additions](../notas/guest-additions-virtualbox.md) y [carpetas-compartidas](../notas/carpetas-compartidas-virtualbox.md)).

---

## 6. Checklist

| Pregunta | Cómo saberlo |
|----------|--------------|
| ¿En qué modo está? | La IP de dentro comparada con la red del anfitrión, según la tabla de arriba. |
| ¿Necesito que otros lleguen a ella? | Entonces puente, o un reenvío de puerto si basta con uno. |
| ¿Necesito que no salga de mi laboratorio? | Solo anfitrión o red interna. |
| ¿El anfitrión tiene el puente o la red activos? | `virsh net-list`, conmutadores de Hyper-V, o las preferencias de red de VirtualBox. Una red `inactive` deja la máquina sin enlace aunque su configuración sea correcta. |
| ¿El cortafuegos de la virtual permite el acceso? | El modo puente la pone en la red, no abre sus puertos. `ss -tulpn` dentro. |

---

## 7. Error típico

**Situación.** Montas un Windows Server de laboratorio en VirtualBox para probar un dominio. Le pones un nombre, activas el rol de DNS y DHCP, y desde tu propio Windows anfitrión no eres capaz de unir ni un equipo de prueba: ni siquiera llegas a la IP del servidor. Dentro de la virtual, `ipconfig` muestra `10.0.2.15`.

**Por qué ocurre.** La máquina está en el modo NAT que VirtualBox pone por defecto. Su dirección `10.0.2.15` solo existe dentro de la red privada que el anfitrión inventa para ella, y la traducción que hace el anfitrión es únicamente de salida. Tu Windows anfitrión no tiene ruta hacia `10.0.2.15`, y el resto de la oficina tampoco. El servidor está perfectamente configurado y completamente aislado. Encima, si más adelante consiguieras llegar, tener un DHCP de pruebas en modo puente sobre la red de la oficina sería peligroso: empezaría a repartir direcciones a equipos reales.

**Cómo se ve.** Dentro, `10.0.2.15` con puerta de enlace `10.0.2.2`. Desde el anfitrión, `ping 10.0.2.15` no responde. En VirtualBox, la tarjeta de la máquina dice «Conectado a: NAT».

**Cómo se arregla.** Para un laboratorio de dominio, lo sano es una red solo-anfitrión (o una red interna con una segunda máquina que haga de cliente): las máquinas del dominio se ven entre ellas y con el anfitrión si hace falta, y el DHCP de prueba no se escapa a la red real. Se cambia el modo con la máquina apagada, se arranca, y se comprueba que ahora tiene una IP del rango de esa red y que el anfitrión le hace ping. El modo puente solo tendría sentido si quisieras que el servidor virtual fuera alcanzable desde la oficina, y en ese caso el DHCP de prueba se queda desactivado.

---

Relacionado: [direccionamiento](../../Redes/chuletas/direccionamiento.md) · [nat-enrutado](../../Redes/chuletas/nat-enrutado.md) · [dhcp-dns-windows-server](dhcp-dns-windows-server.md) · [red-linux-configuracion](red-linux-configuracion.md)

*Biblioteca — Sistemas Operativos · redes de máquinas virtuales*
