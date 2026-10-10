# Chuleta: usuarios, grupos y sudo

En Linux cada proceso corre con la identidad de un usuario y de uno o varios grupos, y los permisos de los ficheros se comprueban contra esa identidad. Crear cuentas, meterlas en grupos y decidir quién puede ejecutar qué como root es el trabajo de administración más frecuente, y el que más daño hace cuando se hace a lo grande. Esta chuleta explica cómo están organizadas las cuentas locales, cómo inspeccionarlas y cómo dar privilegios con sudo de forma acotada.

---

## 1. Qué es una cuenta

Una cuenta local no es más que una línea en tres ficheros. El kernel no conoce nombres: solo números. El nombre `ana` existe para las personas; el proceso corre con un UID.

| Concepto | Qué significa |
|----------|----------------|
| **UID** | Número que identifica al usuario. El kernel compara UIDs, no nombres. UID 0 es root, siempre. |
| **GID** | Número del grupo. Cada usuario tiene un grupo primario y puede pertenecer a varios suplementarios. |
| **Usuario de sistema** | Cuenta con UID bajo (normalmente por debajo de 1000) y sin shell de login. La usan los demonios: `www-data`, `nobody`, `sshd`. Nadie inicia sesión con ellas. |
| **Grupo primario** | El que aparece en `/etc/passwd`. Los ficheros que crea el usuario pertenecen a este grupo por defecto. |
| **Grupos suplementarios** | El resto de grupos a los que pertenece. Es donde se meten los permisos extra: `sudo`, `docker`, `vboxsf`. |
| **sudo** | Programa que ejecuta un comando con otra identidad, casi siempre root, si una regla lo permite, y lo deja registrado. |

| Fichero | Qué guarda | Quién puede leerlo |
|---------|------------|--------------------|
| `/etc/passwd` | Nombre, UID, GID primario, home y shell. La contraseña no está aquí desde hace décadas. | Todo el mundo. Por eso no lleva secretos. |
| `/etc/shadow` | El hash de la contraseña, la caducidad y si la cuenta está bloqueada. | Solo root. |
| `/etc/group` | Nombre de cada grupo, su GID y la lista de miembros suplementarios. | Todo el mundo. |
| `/etc/sudoers` y `/etc/sudoers.d/*` | Las reglas de quién puede ejecutar qué como quién. | Solo root, y con permisos `0440`. |

`/etc/passwd` tiene siete campos separados por dos puntos: nombre, `x` (el hash está en shadow), UID, GID, comentario (nombre real), directorio home y shell. Un shell de `/usr/sbin/nologin` o `/bin/false` impide iniciar sesión: la cuenta existe para que un servicio corra con ella, no para que alguien entre.

---

## 2. Crear y modificar cuentas

```bash
sudo useradd -m -s /bin/bash ana
sudo passwd ana

sudo usermod -aG sudo ana
sudo usermod -s /bin/zsh ana
sudo usermod -L ana
sudo usermod -U ana
sudo usermod -d /home/nueva -m ana

sudo userdel -r ana
```

`useradd -m` crea el directorio home copiando el esqueleto de `/etc/skel`; sin `-m` el usuario no tiene home y muchas cosas fallan de formas raras. `-s` fija el shell. `-G` pone los grupos suplementarios **en el momento de crear** la cuenta; para una cuenta que ya existe se usa `usermod`.

La opción que más problemas causa es `-G` de `usermod` sin la `a`. `usermod -G docker ana` **sustituye** la lista de grupos suplementarios por `docker`: ana deja de estar en `sudo`, en `vboxsf` y en lo que fuera. `usermod -aG docker ana` **añade** (`a` de append). Casi siempre quieres `-aG`.

`-L` bloquea la cuenta poniendo `!` delante del hash en shadow: la contraseña deja de valer, pero la cuenta, el home y los procesos siguen. `-U` quita el bloqueo. `userdel -r` borra la cuenta y el home; sin `-r` el home queda huérfano, con ficheros cuyo UID ya no corresponde a nadie.

### Grupos

```bash
sudo groupadd desarrolladores
sudo gpasswd -a ana desarrolladores
sudo gpasswd -d ana desarrolladores
sudo groupdel desarrolladores
```

El grupo que da privilegios de administración no se llama igual en todas partes: en Debian y Ubuntu es `sudo`; en RHEL, Rocky y Fedora es `wheel`. Meter a alguien en el grupo equivocado no da error y no hace nada.

Un detalle que sorprende: **los grupos se leen al iniciar sesión**. Si añades a ana al grupo `docker` mientras tiene una sesión abierta, `id` dentro de esa sesión seguirá sin mostrar `docker` hasta que cierre y vuelva a entrar (o haga `newgrp`, que abre un shell nuevo). Los servicios que corren como ella tampoco ven el grupo nuevo hasta que se reinician.

### Qué estás viendo en `id`

```text
$ id ana
uid=1001(ana) gid=1001(ana) grupos=1001(ana),27(sudo),1002(desarrolladores)
```

`uid` y el primer `gid` son la identidad principal. `grupos` lista todos, primario incluido. Si acabas de añadirla a un grupo y aquí no aparece, estás mirando una sesión antigua: entra de nuevo.

```bash
id
id -u
id -Gn
getent passwd ana
getent group sudo
getent passwd
who
w
last -n 20
```

`getent` no lee el fichero directamente: pregunta al sistema de resolución de nombres, que puede ser ficheros locales, LDAP o un dominio. Por eso `getent passwd ana` encuentra a ana tanto si es local como si viene de otro sitio, y `grep ana /etc/passwd` solo si es local. Cuando algo «no existe» según grep pero sí inicia sesión, es que no es una cuenta local.

`who` y `w` muestran quién tiene sesión ahora; `last` el historial de inicios de sesión, que es lo primero que miras cuando una cuenta se ha usado a una hora rara.

---

## 3. sudo: dar privilegios sin dar la cuenta de root

Compartir la contraseña de root es mala idea por dos razones: no sabes quién la usó, y no puedes quitársela a uno sin cambiársela a todos. sudo resuelve las dos. Cada persona tiene su cuenta y su contraseña; una regla dice qué puede ejecutar; y cada uso queda en el journal (`journalctl _COMM=sudo` o `/var/log/auth.log`).

**No edites `/etc/sudoers` con un editor normal.** Un error de sintaxis deja a todo el mundo sin sudo, root incluido si no tienes la contraseña, y la máquina queda sin forma de administrar. `visudo` comprueba la sintaxis antes de guardar y rechaza el fichero si está mal.

Las reglas propias van en ficheros separados dentro de `/etc/sudoers.d/`, uno por persona o por equipo. Así cada cambio es un fichero que se puede leer, comparar y borrar sin tocar el resto.

```bash
sudo visudo -f /etc/sudoers.d/ana
sudo visudo -c
```

El fichero tiene que quedar con propietario root y permisos `0440`. `visudo` lo hace; si lo copias a mano y dejas permisos laxos, sudo ignora el fichero con un aviso y la regla no existe.

### Cómo se lee una regla

```text
usuario  HOST = (usuario_destino:grupo_destino) etiquetas: comandos
```

| Ejemplo | Qué permite |
|---------|-------------|
| `ana ALL=(ALL:ALL) ALL` | ana puede ejecutar cualquier comando como cualquier usuario, en cualquier máquina, poniendo su contraseña. Es el privilegio completo. |
| `%sudo ALL=(ALL:ALL) ALL` | Lo mismo, pero para todo el grupo `sudo`. El `%` indica grupo. Es la línea que trae Debian. |
| `%wheel ALL=(ALL:ALL) ALL` | Igual, para el grupo `wheel` de RHEL. |
| `ana ALL=(root) NOPASSWD: /bin/systemctl restart nginx` | ana puede reiniciar nginx como root **sin contraseña**, y solo eso. La ruta tiene que ser absoluta y exacta. |
| `Cmnd_Alias WEB = /bin/systemctl start nginx, /bin/systemctl stop nginx, /bin/systemctl reload nginx` seguido de `ana ALL=(root) WEB` | Un alias para no repetir la lista. ana puede arrancar, parar y recargar nginx, nada más. |

`NOPASSWD` se usa para tareas que lanza un script o un timer, donde no hay nadie para escribir la contraseña. Acotado a comandos concretos es razonable; `NOPASSWD: ALL` es entregar root sin dejar rastro de intención, y no debería existir fuera de una máquina de laboratorio que se va a destruir.

Un matiz que se olvida: sudo compara el comando **tal como se escribe**, pero el usuario puede poner argumentos. `NOPASSWD: /bin/systemctl restart nginx` permite `restart nginx` y también, según la versión y la regla, no impide por sí mismo variantes si no fijas los argumentos. Cuando el comando es peligroso, lo más seguro es un script propio en `/usr/local/sbin/` que haga exactamente una cosa, y permitir solo ese script.

### Comprobar qué puede hacer alguien

```bash
sudo -l
sudo -U ana -l
sudo -k
```

### Qué estás viendo en `sudo -l`

```text
$ sudo -U ana -l
Matching Defaults entries for ana on web01:
    env_reset, mail_badpass, secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

User ana may run the following commands on web01:
    (ALL : ALL) ALL
    (root) NOPASSWD: /bin/systemctl restart nginx
```

La primera línea dice qué opciones por defecto se aplican: `env_reset` limpia las variables de entorno antes de ejecutar, para que nadie cuele un `PATH` o un `LD_PRELOAD` malicioso; `secure_path` fija el `PATH` con el que corre el comando, ignorando el del usuario. Debajo, la lista de reglas que casan con ana, por usuario y por grupo. Si esperabas una regla y no sale, el fichero de `sudoers.d` tiene permisos mal, no se llama como crees (sudo ignora ficheros con `~` o con punto) o tiene un error que `visudo -c` te dirá.

`sudo -k` olvida la contraseña cacheada. Por defecto sudo no vuelve a pedirla durante unos minutos (15 habitualmente); al dejar una sesión compartida conviene invalidarla.

---

## 4. Buenas prácticas

| Práctica | Por qué |
|----------|---------|
| Un fichero por persona o equipo en `sudoers.d` | Se revisa, se revierte y se borra sin tocar las demás reglas. |
| Privilegios por grupo, no por usuario | Das de baja a alguien quitándolo del grupo, sin cazar reglas sueltas. |
| Comandos concretos, nunca `NOPASSWD: ALL` | Cada regla debería responder a «para hacer esta tarea». |
| Cuentas de servicio con `/usr/sbin/nologin` | Existen para que un proceso tenga identidad, no para que alguien entre. |
| Revisar altas | `last` y `journalctl _COMM=sudo` después de crear cuentas privilegiadas. |

---

## 5. Checklist

| Objetivo | Acción |
|----------|--------|
| Crear una cuenta de persona | `useradd -m -s /bin/bash`, `passwd`, y el grupo que le toque. |
| Ver quién es alguien | `id USUARIO` y `getent passwd USUARIO`. |
| Dar administración general | `usermod -aG sudo` (Debian/Ubuntu) o `wheel` (RHEL). Hace falta nueva sesión. |
| Dar un permiso concreto | Fichero en `/etc/sudoers.d/` creado con `visudo -f`, con la ruta absoluta del comando. |
| Comprobar | `visudo -c` para la sintaxis, `sudo -U USUARIO -l` para el resultado. |
| Quitar privilegios | `gpasswd -d` o borrar el fichero de `sudoers.d`. `userdel -r` solo si se va la cuenta entera. |

---

## 6. Error típico

**Situación.** Añades a ana al grupo `docker` porque lo necesita para el despliegue. Ella ejecuta `docker ps` y recibe `permission denied` al socket `/var/run/docker.sock`. Compruebas el grupo: `grep docker /etc/group` la incluye. Le dices que pruebe otra vez. Sigue igual.

**Por qué ocurre.** La lista de grupos de un proceso se fija cuando empieza la sesión, y se hereda. La sesión SSH que ana tiene abierta empezó antes del cambio, así que su shell sigue con los grupos antiguos. `/etc/group` ya está bien; el proceso no se ha enterado. Lo mismo pasa con sudo: si la regla depende del grupo, la sesión vieja no la ve.

**Cómo se ve.** Dentro de su sesión, `id` no muestra `docker`, aunque `getent group docker` sí la lista. `ls -l /var/run/docker.sock` muestra `srw-rw---- root docker`: el permiso está bien, pero ella no está en el grupo **para ese proceso**. Si abres tú una sesión nueva como ana, funciona a la primera.

**Cómo se arregla.** ana cierra la sesión y entra de nuevo. No hace falta reiniciar nada, ni tocar permisos del socket, ni poner el socket a `666` (que es el «arreglo» que aparece en foros y deja el control de docker, es decir root, abierto a cualquiera). Si es un servicio y no una persona, se reinicia el servicio, porque un proceso no tiene «nueva sesión»: hay que relanzarlo.

---

Relacionado: [permisos-posix](permisos-posix.md) · [ssh-admin](ssh-admin.md) · [systemd-journalctl](systemd-journalctl.md) · [windows-usuarios-grupos](windows-usuarios-grupos.md) · plantilla [sudoers.d-ejemplo](../plantillas/sudoers.d-ejemplo) · guía [Qué pasa cuando ejecutas sudo](https://github.com/P3M-ACTF/Biblioteca/wiki/Que-pasa-cuando-ejecutas-sudo)

*Biblioteca — Sistemas Operativos · usuarios / grupos / sudo*
