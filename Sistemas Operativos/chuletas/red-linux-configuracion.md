# Chuleta: configurar la red en Linux

Diagnosticar la red dice qué está mal; esta chuleta dice cómo dejar la configuración escrita para que sobreviva a un reinicio. En Linux conviven tres formas de hacerlo, y el error habitual es editar el fichero de la que no se está usando: el cambio se ve perfecto, se reinicia, y la máquina vuelve a salir por DHCP.

---

## 1. Saber quién gestiona la red

Antes de escribir nada, averigua qué servicio manda. Igual que con el cortafuegos, solo puede mandar uno.

| Qué encuentras | Quién manda | Dónde se configura |
|-----------------|-------------|--------------------|
| `NetworkManager` activo | NetworkManager. Es lo normal en servidores RHEL, en Fedora y en escritorios. | `nmcli` o los ficheros de `/etc/NetworkManager/system-connections/`. |
| `systemd-networkd` activo, a menudo con netplan | netplan en Ubuntu Server genera la configuración y se la entrega a networkd. | `/etc/netplan/*.yaml`. |
| Ninguno de los dos, y existe `/etc/network/interfaces` | ifupdown, el sistema clásico de Debian. | `/etc/network/interfaces` y ficheros en `interfaces.d/`. |

```bash
systemctl is-active NetworkManager systemd-networkd
networkctl status
ls /etc/netplan/ 2>/dev/null
```

`networkctl` dice, interfaz por interfaz, quién la controla. Si pone `unmanaged`, networkd no la toca y la gestiona otro. Configurar por dos sitios a la vez produce el síntoma de «a veces coge una IP y a veces otra».

---

## 2. NetworkManager con nmcli

`nmcli` modifica la conexión, que es la configuración persistente, y puede aplicarla al momento. Una conexión tiene nombre propio, que no siempre coincide con el de la interfaz.

```bash
nmcli connection show
nmcli device status
sudo nmcli connection modify "ens192" \
  ipv4.method manual \
  ipv4.addresses 192.168.10.20/24 \
  ipv4.gateway 192.168.10.1 \
  ipv4.dns "10.0.0.1,10.0.0.2" \
  ipv4.dns-search "empresa.local"
sudo nmcli connection up "ens192"
```

`ipv4.method manual` desactiva el DHCP para esa conexión: si lo dejas en `auto`, tu dirección estática y la del DHCP conviven o se pisan. `connection up` aplica ya; sin ese paso la configuración queda guardada para el próximo arranque y la sesión actual sigue como estaba.

### Qué estás viendo

```text
$ nmcli device status
DEVICE  TYPE      STATE      CONNECTION
ens192  ethernet  connected  ens192
lo      loopback  connected  (lo)

$ ip -4 addr show ens192
inet 192.168.10.20/24 brd 192.168.10.255 scope global ens192
```

`STATE connected` con el nombre de la conexión dice que la interfaz está gobernada por esa conexión y no por un ajuste manual suelto. La dirección mostrada por `ip addr` tiene que coincidir con la que acabas de fijar; si sigue saliendo la antigua, la conexión no se llegó a levantar o levantaste otra distinta de la que está activa.

---

## 3. netplan en Ubuntu

netplan no configura la red él mismo: lee un YAML y genera la configuración para networkd (en servidores) o para NetworkManager (en escritorios). El fichero vive en `/etc/netplan/` y se aplica con `netplan apply`.

```yaml
network:
  version: 2
  ethernets:
    ens192:
      addresses:
        - 192.168.10.20/24
      routes:
        - to: default
          via: 192.168.10.1
      nameservers:
        addresses: [10.0.0.1, 10.0.0.2]
        search: [empresa.local]
```

La indentación es significativa: un espacio de más y el fichero entero se ignora. `netplan try` aplica y espera confirmación; si te quedas sin conexión y no confirmas, revierte solo. Es la opción sensata cuando trabajas en remoto. `netplan apply` aplica sin red de seguridad.

Ojo con el DHCP que trae el fichero de fábrica: si convive con `addresses` sin desactivarlo (`dhcp4: false`), la interfaz puede acabar con dos direcciones.

---

## 4. ifupdown

En Debian sin NetworkManager, la configuración sigue estando en `/etc/network/interfaces`.

```text
auto ens192
iface ens192 inet static
    address 192.168.10.20/24
    gateway 192.168.10.1
    dns-nameservers 10.0.0.1 10.0.0.2
    dns-search empresa.local
```

Se aplica con `ifdown ens192 && ifup ens192`, que sí corta la conexión un instante. `auto` hace que suba sola al arrancar; sin esa línea, la configuración existe pero nadie la activa.

Las líneas `dns-nameservers` solo llegan a `/etc/resolv.conf` si está instalado el paquete `resolvconf` o equivalente. Si no lo está, la dirección funciona y los nombres no, y el fallo parece del DNS cuando es de la configuración.

---

## 5. Rutas añadidas

Una ruta que no sea la de defecto se añade en el mismo sitio que el resto, para que persista. Una ruta metida con `ip route add` a mano dura hasta el próximo reinicio y es la causa clásica de «después del parche del kernel no se llega a la otra sede».

```bash
sudo nmcli connection modify "ens192" +ipv4.routes "10.8.0.0/24 192.168.10.254"
```

En netplan va dentro de `routes:`, igual que la ruta por defecto. En ifupdown, una línea `up ip route add 10.8.0.0/24 via 192.168.10.254`.

La comprobación es `ip route get 10.8.0.5`: tiene que salir por la puerta de enlace que pusiste y no por la de defecto.

---

## 6. Checklist

| Pregunta | Cómo comprobarla |
|----------|------------------|
| ¿Quién gestiona esta interfaz? | `networkctl status` y `systemctl is-active` de NetworkManager y networkd. |
| ¿La dirección sobrevivirá al reinicio? | Está en la conexión, en el YAML o en `interfaces`, no solo en `ip addr`. |
| ¿El DNS es el interno? | `resolvectl status` muestra los servidores que pusiste, no los del DHCP antiguo. |
| ¿La puerta de enlace está en tu red? | Cae dentro del bloque de tu dirección. Si no, la ruta no puede funcionar. |
| ¿Puedo volver atrás si me corto? | `netplan try`, o una sesión de consola abierta, o una regla que revierta sola. |

---

## 7. Error típico

**Situación.** En un Ubuntu Server cambias la IP editando `/etc/network/interfaces`, como hacías en Debian. Reinicias para que coja la configuración nueva y la máquina no vuelve a aparecer en la red. Por la consola del hipervisor ves que tiene la IP de siempre, la del DHCP.

**Por qué ocurre.** Esa instalación usa netplan y systemd-networkd, que es lo que Ubuntu Server trae desde hace años. `/etc/network/interfaces` existe, a veces con un comentario diciendo que no se usa, y nadie lo lee. Tu cambio es correcto y es irrelevante. Mientras tanto el YAML de `/etc/netplan/` sigue diciendo DHCP, y es lo que se aplicó al arrancar.

**Cómo se ve.** `systemctl is-active systemd-networkd` dice `active`. `ls /etc/netplan/` muestra un fichero YAML con `dhcp4: true`. `ip addr` muestra la IP del DHCP y no la que escribiste. `networkctl status ens192` dice que la configura networkd.

**Cómo se arregla.** Escribir la configuración en el YAML, con `dhcp4: false` para que no convivan, y aplicarla con `netplan try` desde la consola que ya tienes abierta. Cuando `ip addr` muestre la dirección nueva y un ping a la puerta de enlace responda, confirmas. Y dejas `/etc/network/interfaces` como estaba: dos sitios de configuración es el problema que acabas de sufrir.

---

Relacionado: [direccionamiento](../../Redes/chuletas/direccionamiento.md) · [diagnostico](../../Redes/chuletas/diagnostico.md) · [dns](../../Redes/chuletas/dns.md) · [nat-enrutado](../../Redes/chuletas/nat-enrutado.md)

*Biblioteca — Sistemas Operativos · configuración de red en Linux*
