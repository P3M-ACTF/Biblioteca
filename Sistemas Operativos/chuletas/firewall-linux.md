# Chuleta: cortafuegos en Linux

En Linux el cortafuegos es una sola cosa, netfilter, dentro del kernel. Lo que cambia de una distribución a otra es la herramienta con la que se le dan las reglas: firewalld, nftables, ufw o el viejo iptables. Buena parte de la confusión viene de pensar que son cuatro cortafuegos distintos cuando son cuatro formas de hablar con el mismo. Esta chuleta explica qué hace cada capa, cómo saber cuál está mandando en una máquina y cómo encaja el cortafuegos del host con el de la red.

---

## 1. Dos planos: perímetro y host

En una empresa el tráfico se filtra en dos sitios distintos, y conviene tener claro qué se decide en cada uno.

El **perímetro** es un equipo dedicado (un cortafuegos físico o virtual, un NGFW, o en la nube un *security group*) que está entre la red y el exterior, o entre segmentos de la red. Filtra antes de que el paquete llegue al servidor. Lo gestiona normalmente el equipo de redes o de seguridad, con su propio ciclo de cambios, y suele tener reglas por red de origen, por servicio y por zona.

El cortafuegos del **host** corre dentro del propio servidor Linux. Es la última línea: si el perímetro deja pasar algo que no debería, o si el ataque viene de dentro de la misma red, es lo único que queda. Lo gestiona el administrador de sistemas y se configura con las herramientas de esta chuleta.

| Plano | Ejemplos | Qué decide |
|-------|----------|------------|
| Perímetro | Cortafuegos dedicado, NGFW, security group, NACL | Qué redes pueden llegar a qué servidores y puertos. Filtra antes de que el paquete entre en la máquina. |
| Host | netfilter a través de firewalld, nftables o ufw | Qué acepta esta máquina concreta, venga de donde venga. Filtra cuando el paquete ya ha llegado a la tarjeta de red. |

Los dos planos coexisten, y lo normal es que las reglas sean redundantes a propósito: el security group abre el 443 solo desde Internet y el host también acepta solo el 443. Si el perímetro cierra un puerto, el host nunca verá el tráfico; si el perímetro lo abre y el host lo rechaza, tampoco entra. Un servidor con el cortafuegos del host desactivado «porque ya hay un firewall delante» funciona hasta el día en que otro servidor del mismo segmento se ve comprometido.

---

## 2. netfilter y sus frontales

El kernel tiene un subsistema, **netfilter**, con puntos de enganche en el camino de cada paquete: cuando entra, cuando sale, cuando se reenvía. Las reglas que se cuelgan de esos puntos deciden si el paquete se acepta, se descarta o se modifica (ahí vive también el NAT). El administrador no habla con netfilter directamente; usa un frontal que traduce lo que quiere a reglas del kernel.

```text
Lo que quiere el admin → frontal (firewalld, ufw, nft, iptables) → netfilter (kernel)
```

| Frontal | Dónde se encuentra | Qué es realmente |
|---------|-------------------|------------------|
| **firewalld** | RHEL, Rocky, Alma, Fedora, y disponible en otras | Un demonio que organiza las reglas en **zonas** (`public`, `internal`, `trusted`…) y las aplica sin cortar conexiones. Por debajo, en versiones actuales, escribe reglas nftables. Es el estándar en entornos Red Hat y lo que esperan encontrar sus herramientas de gestión. |
| **nftables** | Debian, Ubuntu, cualquier kernel moderno | La sintaxis actual del propio kernel, a través del comando `nft`. Reglas organizadas en tablas y cadenas que escribes tú en un fichero. Es lo que hay debajo de firewalld y de ufw; usarlo directamente da el control completo a cambio de aprender la sintaxis. |
| **ufw** | Ubuntu, por defecto; VPS de un solo servicio | «Uncomplicated Firewall»: una capa fina pensada para un host con pocas reglas. `ufw allow 22` y poco más. Genera reglas iptables o nftables según la versión. Cómodo mientras las necesidades sean sencillas; incómodo cuando necesitas NAT, varias interfaces o reglas por zona. |
| **iptables** | Scripts antiguos, documentación de hace diez años | La interfaz anterior a nftables. En distribuciones actuales el comando `iptables` suele ser `iptables-nft`: acepta la sintaxis vieja pero escribe reglas nftables. Sigue funcionando, pero mezclarlo con reglas nft escritas a mano acaba en dos conjuntos de reglas que no se ven entre sí. |

La idea importante: **un solo frontal por máquina**. firewalld, ufw y un fichero nftables propio son tres administradores distintos del mismo recurso; si dos de ellos están activos, cada uno escribe sus reglas sin saber del otro, y el resultado depende del orden en que arrancaron. Elige uno, documéntalo y desactiva los demás.

En la práctica, en una empresa la elección la marca la distribución: firewalld en el mundo Red Hat porque viene integrado y lo esperan sus herramientas; nftables directo o ufw en Debian y Ubuntu según la complejidad. Lo que no se hace es instalar ufw en un RHEL que ya tiene firewalld.

La plantilla [nftables-base.nft](../plantillas/nftables-base.nft) es un ejemplo del camino nftables directo, no una recomendación de usarlo sobre los demás.

---

## 3. Saber cuál está activo

Antes de tocar una regla en una máquina que no conoces, averigua quién manda. Cada frontal tiene su forma de preguntarlo.

```bash
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all

sudo ufw status verbose

sudo nft list ruleset

sudo iptables -L -n -v
sudo iptables -V
```

### Qué estás viendo

`firewall-cmd --state` responde `running` o `not running`. Si dice `running`, firewalld gestiona el cortafuegos y todo cambio debe hacerse con `firewall-cmd`; si editas nftables por debajo, firewalld lo sobreescribirá en su próxima recarga.

```text
$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: ens192
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 443/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

La zona `public` está activa en la interfaz `ens192`. Acepta los servicios `ssh` y `cockpit` (nombres predefinidos que firewalld traduce a puertos) y además el puerto `443/tcp`. Todo lo demás se rechaza. `masquerade: no` dice que esta máquina no hace NAT de salida.

```text
$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
443/tcp                    ALLOW IN    Anywhere
```

La línea `Default` es la política: se niega lo que entra, se permite lo que sale, no se reenvía. Las reglas se leen como frases: el 22 solo desde la red `10.0.0.0/8`, el 443 desde cualquier sitio.

`nft list ruleset` vuelca todas las reglas que hay en el kernel, las haya puesto quien las haya puesto. Si ves tablas con nombres como `firewalld` o cadenas `ufw-*`, hay un frontal detrás. Si solo hay una tabla con el nombre que le diste tú, estás en el camino nftables directo.

`iptables -V` dice `(nf_tables)` o `(legacy)`. Lo primero significa que iptables es una capa sobre nftables y sus reglas aparecerán también en `nft list ruleset`; lo segundo, que hay dos subsistemas separados y las reglas de uno son invisibles para el otro.

| Señal | Interpretación |
|-------|----------------|
| `firewall-cmd --state` dice `running` | firewalld manda. Usa `firewall-cmd` para todo y no edites nftables a mano. |
| `ufw status` dice `active` | ufw manda. No añadas reglas iptables sueltas: ufw las ignorará o las pisará. |
| Solo `nft list ruleset` tiene reglas, sin tablas de firewalld ni cadenas ufw | Camino nftables directo. Las reglas están en un fichero, normalmente `/etc/nftables.conf`. |
| Dos frontales responden que están activos | Conflicto. Decide cuál se queda, desactiva el otro (`systemctl disable --now`) y limpia sus reglas. |

---

## 4. Política base de un host

Independientemente del frontal, la política de un servidor es casi siempre la misma, y conviene tenerla en la cabeza como lista de frases antes de traducirla a reglas:

1. **Lo que entra se descarta por defecto.** La cadena de entrada tiene política `drop`. Todo lo que se acepte tiene que estar en una regla explícita.
2. **Se aceptan las respuestas a conexiones que inició esta máquina.** La regla `ct state established,related accept` (o su equivalente) va la primera; sin ella, el servidor puede hacer una petición pero no recibir la respuesta.
3. **Se acepta el loopback.** Muchos servicios hablan consigo mismos por `127.0.0.1`; bloquearlo rompe cosas de formas difíciles de diagnosticar.
4. **Se acepta la administración, acotada.** SSH solo desde las redes de administración o el bastión, nunca desde cualquier origen si se puede evitar.
5. **Se aceptan los servicios del rol.** Un servidor web abre 80 y 443; un servidor de base de datos abre su puerto solo desde los servidores de aplicación. Nada más.
6. **La salida se permite,** salvo que haya razón para restringirla. Restringir la salida es una medida de bastionado valiosa pero exige saber qué necesita hablar la máquina (actualizaciones, DNS, NTP, su propio backend).

La diferencia entre `drop` y `reject`: `drop` descarta el paquete en silencio y el cliente espera hasta agotar su tiempo; `reject` devuelve un error inmediato. Para la entrada desde Internet, `drop` da menos información a quien escanea; dentro de la red, `reject` hace que los fallos sean inmediatos y fáciles de diagnosticar.

Tras cualquier cambio en el cortafuegos de una máquina remota, comprueba que sigues pudiendo entrar **desde otra sesión** antes de cerrar la que tienes abierta. firewalld tiene `--timeout` para reglas de prueba que se revierten solas; con nftables, el truco es cargar la regla y programar un `nft flush ruleset` con `at` o un timer que puedas cancelar si todo ha ido bien.

---

## 5. Cómo se traduce lo mismo en cada frontal

La política «SSH desde la red de administración, HTTPS desde cualquiera, nada más» en los tres frontales habituales. No hace falta memorizar las tres; sí reconocerlas cuando las veas.

**firewalld**

```bash
sudo firewall-cmd --permanent --zone=public --remove-service=ssh
sudo firewall-cmd --permanent --new-zone=admin
sudo firewall-cmd --permanent --zone=admin --add-source=10.10.0.0/24
sudo firewall-cmd --permanent --zone=admin --add-service=ssh
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

firewalld piensa en zonas: la red de administración se asigna a una zona `admin` que acepta SSH, y la zona `public` (la interfaz) acepta HTTPS. `--permanent` escribe en disco pero no aplica; `--reload` aplica lo permanente. Sin `--permanent` el cambio es inmediato pero se pierde al reiniciar; es útil para probar.

**ufw**

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 10.10.0.0/24 to any port 22 proto tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

Las reglas se leen como se escriben. `ufw enable` activa el cortafuegos y lo habilita para el arranque.

**nftables**

```nft
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept
        iif lo accept
        ip saddr 10.10.0.0/24 tcp dport 22 accept
        tcp dport 443 accept
    }
}
```

Esto va en `/etc/nftables.conf` y se carga con `nft -f` o con el servicio `nftables`. Las reglas se evalúan en orden; la primera que coincide decide. Observa que `established,related` va antes que todo lo demás.

---

## 6. Relación con el perímetro

Cuando algo no llega a un servidor, la pregunta es en qué plano se está cortando. La tabla ayuda a repartir la búsqueda.

| Lo que configura el perímetro | Lo que configura el host |
|-------------------------------|--------------------------|
| El puerto 22 solo es alcanzable desde el bastión. | SSH acepta solo desde la IP del bastión; aunque el perímetro fallara, el host no abre a más. |
| El 443 es público. | nginx escucha en 443 y el cortafuegos del host lo acepta. |
| Todo lo demás se niega. | Política `drop` en la entrada. |
| El servidor de base de datos no es alcanzable desde Internet. | El puerto de la base de datos acepta solo desde las IP de los servidores de aplicación. |

Para saber dónde se corta: desde una máquina de la misma red del servidor, `nc -zv servidor 443` o `Test-NetConnection servidor -Port 443`. Si desde dentro funciona y desde fuera no, es el perímetro. Si desde dentro tampoco, es el host (o el servicio no está escuchando: `ss -tlnp` lo confirma). La chuleta [diagnostico](../../Redes/chuletas/diagnostico.md) desarrolla la secuencia.

---

## 7. Checklist

| Objetivo | Comando o acción |
|----------|------------------|
| Saber qué frontal manda | `firewall-cmd --state`, `ufw status`, `nft list ruleset`. Uno, no varios. |
| Ver la política efectiva | `firewall-cmd --list-all`, `ufw status verbose` o `nft list ruleset`. |
| Qué escucha realmente la máquina | `ss -tulpn`; una regla que acepta un puerto donde nadie escucha no sirve de nada. |
| SSH acotado | Origen limitado a la red de administración; `fail2ban` o equivalente si la política de la organización lo pide. |
| Antes de cerrar la sesión tras un cambio | Entrar desde otra sesión. Con firewalld, `--timeout=300` para la prueba. |
| Que sobreviva al reinicio | firewalld: `--permanent` y `--reload`. ufw: `ufw enable`. nftables: fichero en `/etc/nftables.conf` y `systemctl enable nftables`. |

---

## 8. Error típico

**Situación.** Un servidor Ubuntu lleva años con ufw. Un compañero añade una regla con `iptables -A INPUT -p tcp --dport 8080 -j ACCEPT` siguiendo un tutorial, porque «es más rápido». Funciona. Tres semanas después el servidor se reinicia por una actualización del kernel y el puerto 8080 deja de responder. Nadie recuerda la regla.

**Por qué ocurre.** ufw tiene sus propias cadenas (`ufw-before-input`, `ufw-user-input`…) y es lo único que persiste entre reinicios porque ufw guarda su configuración en `/etc/ufw/`. Una regla añadida con `iptables` directamente vive solo en la memoria del kernel: no la conoce ufw, no está en ningún fichero y desaparece al reiniciar. Mientras la máquina estuvo encendida, las dos convivieron por casualidad en el orden correcto.

**Cómo se ve.** `ufw status` no muestra el 8080 porque nunca lo supo. `iptables -L -n` sí lo mostraba antes del reinicio y ya no. El servicio en 8080 escucha (`ss -tlnp` lo confirma) pero `nc -zv servidor 8080` desde fuera se queda esperando: política `deny` de ufw.

**Cómo se arregla.** Añadir la regla donde toca, con el frontal que gestiona la máquina: `sudo ufw allow 8080/tcp`. Comprobar con `ufw status verbose` que aparece, y con `nc` desde otra máquina que responde. Y la lección de fondo: cuando una máquina tiene un frontal, todas las reglas pasan por él; si el frontal no sabe hacer lo que necesitas, se cambia de frontal, no se le puentea.

---

Relacionado: plantilla [nftables-base.nft](../plantillas/nftables-base.nft) · [nat-enrutado](../../Redes/chuletas/nat-enrutado.md) · [diagnostico](../../Redes/chuletas/diagnostico.md) · [bastionado-linux](../../Ciberseguridad/chuletas/bastionado-linux.md) · [windows-firewall-acceso](windows-firewall-acceso.md) · runbook [maquina-nueva](../runbooks/maquina-nueva.md)

*Biblioteca — Sistemas Operativos · firewall Linux*
