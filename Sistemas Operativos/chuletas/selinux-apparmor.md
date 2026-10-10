# Chuleta: SELinux y AppArmor

Los permisos POSIX dicen qué puede hacer un usuario. SELinux y AppArmor dicen qué puede hacer un **programa**, aunque corra como root. Son dos implementaciones de la misma idea, el control de acceso obligatorio, y la mitad del trabajo con ellos consiste en leer bien un mensaje de denegación y entender qué está protegiendo. Esta chuleta explica qué hacen, cómo saber en qué modo están y cómo interpretar lo que registran. No explica cómo desactivarlos: eso casi nunca es la solución.

---

## 1. La idea: qué añade el MAC

Con permisos POSIX, si un proceso corre como `www-data` puede leer todo lo que `www-data` pueda leer. Si alguien consigue que el servidor web ejecute algo que no debería, ese algo tiene todos los permisos de `www-data`: leer `/etc/passwd`, conectar a cualquier puerto, escribir en `/tmp`. Los permisos clásicos son **discrecionales**: el dueño de un fichero decide quién accede, y root accede a todo.

El control de acceso **obligatorio** (MAC, Mandatory Access Control) añade una segunda pregunta que se hace después de la primera: aunque el usuario tenga permiso, ¿este programa concreto tiene permiso para esta operación concreta sobre este recurso concreto? La respuesta la da una política escrita por la distribución, no por el dueño del fichero. Así, el servidor web puede leer `/var/www` porque la política lo dice, pero no puede leer el directorio home de nadie aunque los permisos POSIX lo permitieran, y da igual que corra como root.

El efecto práctico es que una denegación de SELinux o AppArmor casi siempre significa una de dos cosas: o algo está intentando hacer lo que no debe (y la política está haciendo su trabajo), o has movido un fichero o cambiado una configuración y la política no sabe que el nuevo sitio es legítimo. Ninguna de las dos se arregla desactivando el sistema.

| Sistema | Distribuciones | Cómo decide |
|---------|----------------|-------------|
| **SELinux** | RHEL, Rocky, Alma, CentOS Stream, Fedora | Por **etiquetas**: cada fichero, proceso y puerto lleva un contexto de seguridad, y la política dice qué contextos pueden interactuar. Es más granular y más difícil de leer. |
| **AppArmor** | Ubuntu, Debian (en algunos paquetes), SLES, openSUSE | Por **perfiles**: cada programa confinado tiene un fichero que lista las rutas que puede tocar y qué puede hacer con ellas. Es más legible y menos exhaustivo. |

---

## 2. SELinux: modos y contextos

SELinux tiene un modo global que determina si la política se aplica o solo se registra.

| Modo | Efecto |
|------|--------|
| **enforcing** | La política se aplica: lo que no está permitido se niega y se registra. Es el estado esperado en producción. |
| **permissive** | La política se evalúa y las denegaciones se registran, pero no se aplican. Sirve para diagnosticar: ves qué fallaría sin que falle. |
| **disabled** | SELinux no carga. Los ficheros dejan de etiquetarse; volver a `enforcing` después exige reetiquetar todo el sistema de ficheros, que tarda y a veces rompe cosas. Por eso no es un «apagar un rato». |

```bash
getenforce
sestatus
cat /etc/selinux/config
```

### Qué estás viendo

```text
$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

`Current mode` es lo que está pasando ahora; `Mode from config file` es lo que habrá tras reiniciar. Si no coinciden, alguien cambió el modo en caliente con `setenforce` y el próximo arranque lo revertirá. `Loaded policy name: targeted` es la política habitual: confina los servicios de red conocidos y deja a los usuarios normales sin confinar.

### Contextos

Todo en SELinux lleva una etiqueta con cuatro partes: usuario SELinux, rol, tipo y nivel. En la práctica, con la política `targeted`, lo que importa es el **tipo** (la tercera parte, la que acaba en `_t`).

```bash
ls -Z /var/www/html
ps -eZ | grep -E 'httpd|nginx'
id -Z
```

```text
$ ls -Z /var/www/html
unconfined_u:object_r:httpd_sys_content_t:s0 index.html
unconfined_u:object_r:user_home_t:s0 subido.html

$ ps -eZ | grep httpd
system_u:system_r:httpd_t:s0  1203 ?  00:00:00 httpd
```

El proceso `httpd` corre con el tipo `httpd_t`. La política dice que `httpd_t` puede leer ficheros de tipo `httpd_sys_content_t`. El primer fichero lo tiene; el segundo tiene `user_home_t` porque alguien lo copió desde su home con `mv` (que conserva la etiqueta) en lugar de `cp` (que asigna la del directorio destino). Ese segundo fichero dará un 403 aunque sus permisos POSIX sean `644`.

---

## 3. SELinux: leer una denegación

Las denegaciones se llaman AVC (Access Vector Cache) y van al registro de auditoría. Hay tres sitios donde buscarlas, según lo que tenga instalada la máquina.

```bash
sudo ausearch -m avc -ts recent
sudo journalctl -t setroubleshoot --since "1 hour ago"
sudo grep 'avc:.*denied' /var/log/audit/audit.log | tail
```

### Qué estás viendo

```text
type=AVC msg=audit(1728556803.412:289): avc:  denied  { read } for  pid=1203 comm="httpd" name="subido.html" dev="dm-0" ino=1835 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0
```

Se lee de izquierda a derecha como una frase:

- `denied { read }`: la operación denegada fue leer.
- `comm="httpd"` con `pid=1203`: quién lo intentó.
- `name="subido.html"`: sobre qué.
- `scontext=...httpd_t`: el contexto del proceso que pide (*source*).
- `tcontext=...user_home_t`: el contexto del recurso al que accede (*target*).
- `tclass=file`: el tipo de objeto; podría ser `dir`, `tcp_socket`, `unix_stream_socket`.
- `permissive=0`: se aplicó de verdad. Con `permissive=1` solo se registró.

La frase completa: «httpd intentó leer el fichero subido.html, pero httpd_t no tiene permiso para leer ficheros con etiqueta user_home_t». La solución no es dar permiso a httpd para leer homes, sino poner al fichero la etiqueta que le corresponde por estar en `/var/www/html`.

Si `setroubleshoot` está instalado, el journal lleva además una traducción al lenguaje humano con sugerencias. `sealert -a /var/log/audit/audit.log` hace lo mismo bajo demanda, y `audit2why` explica por qué la política niega. Son herramientas de interpretación; `audit2allow`, que genera módulos de política, hay que usarlo con cuidado porque permite exactamente lo que se denegó sin preguntar si debía denegarse.

### Arreglar la etiqueta

```bash
sudo restorecon -Rv /var/www/html
sudo semanage fcontext -a -t httpd_sys_content_t '/srv/web(/.*)?'
sudo restorecon -Rv /srv/web
sudo semanage port -a -t http_port_t -p tcp 8081
getsebool -a | grep httpd
sudo setsebool -P httpd_can_network_connect on
```

`restorecon` aplica a cada fichero la etiqueta que la política dice que le toca según su ruta. Es la primera cosa que probar cuando una denegación afecta a ficheros que han sido movidos. Si el contenido vive en una ruta que la política no conoce (`/srv/web` en lugar de `/var/www`), `semanage fcontext` enseña a la política la nueva ruta y después `restorecon` la aplica. `semanage port` hace lo mismo para puertos no estándar. Los **booleanos** (`getsebool`, `setsebool -P`) son interruptores predefinidos para casos frecuentes: que el servidor web pueda conectar a la red, que pueda servir homes, que pueda enviar correo. Antes de escribir política propia, mira si hay un booleano.

---

## 4. AppArmor: perfiles y modos

AppArmor no etiqueta ficheros. Confina programas: cada programa confinado tiene un perfil en `/etc/apparmor.d/` que dice qué rutas puede leer, escribir o ejecutar, y qué capacidades tiene. Un programa sin perfil está **sin confinar** y se comporta como si AppArmor no existiera.

| Estado del perfil | Efecto |
|-------------------|--------|
| **enforce** | Lo que el perfil no permite se niega y se registra. |
| **complain** | Las violaciones se registran pero se permiten. Equivalente al `permissive` de SELinux, pero por perfil, no global. |
| **unconfined** | El programa no tiene perfil cargado. |

```bash
sudo aa-status
sudo aa-enabled
ls /etc/apparmor.d/
```

### Qué estás viendo

```text
$ sudo aa-status
apparmor module is loaded.
38 profiles are loaded.
36 profiles are in enforce mode.
   /usr/bin/man
   /usr/sbin/mysqld
   /usr/sbin/tcpdump
   ...
2 profiles are in complain mode.
   /usr/sbin/dnsmasq
   /usr/sbin/dnsmasq//libvirt_leaseshelper
5 processes have profiles defined.
5 processes are in enforce mode.
   /usr/sbin/mysqld (1187)
   ...
0 processes are unconfined but have a profile defined.
```

La parte importante es la última: procesos que **tienen** perfil pero corren sin confinar. Si ese número no es cero, hay un programa que debería estar protegido y no lo está, normalmente porque se arrancó antes de que AppArmor cargara el perfil o porque alguien hizo `aa-disable`.

Los nombres de perfil son rutas de ejecutable. `//libvirt_leaseshelper` es un subperfil: la parte del perfil que aplica cuando dnsmasq ejecuta ese programa auxiliar.

---

## 5. AppArmor: leer una denegación

AppArmor registra en el log del kernel, así que se lee con `dmesg` o con `journalctl -k`. Según la distribución, también acaba en `/var/log/syslog` o en `/var/log/kern.log`.

```bash
sudo journalctl -k --since "1 hour ago" | grep -i apparmor
sudo dmesg | grep -i apparmor | tail
sudo grep 'apparmor="DENIED"' /var/log/syslog | tail
```

### Qué estás viendo

```text
audit: type=1400 audit(1728557120.841:412): apparmor="DENIED" operation="open" profile="/usr/sbin/mysqld" name="/srv/mysql-data/ibdata1" pid=1187 comm="mysqld" requested_mask="rw" denied_mask="rw" fsuid=112 ouid=112
```

- `apparmor="DENIED"`: se negó. Con `ALLOWED` sería un perfil en modo `complain`.
- `operation="open"`: qué intentó hacer. Otros valores habituales: `exec`, `mknod`, `connect`, `capable`.
- `profile="/usr/sbin/mysqld"`: qué perfil lo negó.
- `name="/srv/mysql-data/ibdata1"`: sobre qué ruta.
- `requested_mask="rw"` y `denied_mask="rw"`: pidió leer y escribir; se le negó leer y escribir.
- `fsuid=112 ouid=112`: el proceso corre como UID 112 y el fichero pertenece al UID 112. Es decir, los permisos POSIX habrían dejado pasar; fue AppArmor.

La frase: «mysqld quiso abrir en lectura y escritura un fichero en /srv/mysql-data, pero su perfil solo le permite el directorio de datos estándar». Alguien movió el directorio de datos de MySQL a `/srv` y actualizó `my.cnf`, pero no el perfil de AppArmor.

### Arreglar el perfil

```bash
sudo nano /etc/apparmor.d/local/usr.sbin.mysqld
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
sudo aa-complain /usr/sbin/mysqld
sudo aa-enforce /usr/sbin/mysqld
```

Los perfiles de paquete se extienden desde `/etc/apparmor.d/local/`, que el perfil principal incluye al final; así tus cambios sobreviven a las actualizaciones. Para el caso del ejemplo, el fichero local llevaría una línea `/srv/mysql-data/ rw,` y otra `/srv/mysql-data/** rwk,`. `apparmor_parser -r` recarga el perfil sin reiniciar el servicio. `aa-complain` pasa un perfil a modo registro mientras investigas y `aa-enforce` lo devuelve a aplicación; úsalo por perfil, nunca desactives AppArmor entero para probar.

---

## 6. Qué hacer ante una denegación

| Paso | Qué hacer | Por qué |
|------|-----------|---------|
| 1 | Confirma el modo: `getenforce` o `aa-status`. | Si el sistema ya está en permissive o complain, la denegación que ves no es la causa del fallo; busca en otro sitio. |
| 2 | Localiza el mensaje y extrae proceso, operación y recurso. | Sin esos tres datos no puedes saber si es legítimo. |
| 3 | Pregúntate qué cambió: ¿se movió un directorio, se cambió un puerto, se instaló una versión nueva? | Casi todas las denegaciones en producción vienen de un cambio reciente, no de la política. |
| 4 | Arregla donde está el error: etiqueta con `restorecon` o `semanage`; perfil en `local/`; booleano si existe. | Es la solución que mantiene la protección. |
| 5 | Si no hay forma legítima, usa `audit2allow` o un perfil nuevo, con el permiso mínimo y revisado. | Permitir exactamente lo que se denegó sin leerlo es lo mismo que desactivar el sistema para ese programa. |
| Nunca | `chmod 777`, `setenforce 0` permanente, `aa-teardown`, `SELINUX=disabled`. | Resuelven el síntoma destruyendo la protección de toda la máquina. |

---

## 7. Checklist

| Objetivo | SELinux | AppArmor |
|----------|---------|----------|
| ¿Está activo y en qué modo? | `getenforce`, `sestatus` | `aa-status` |
| Ver denegaciones recientes | `ausearch -m avc -ts recent` | `journalctl -k | grep apparmor` |
| Ver contexto o perfil de algo | `ls -Z`, `ps -eZ` | Perfil por ruta en `aa-status`; fichero en `/etc/apparmor.d/` |
| Arreglar ficheros movidos | `restorecon -Rv RUTA` | Añadir la ruta en `/etc/apparmor.d/local/PERFIL` |
| Ruta o puerto nuevo permanente | `semanage fcontext`, `semanage port` | Mismo fichero `local/` y `apparmor_parser -r` |
| Diagnosticar sin romper | `setenforce 0` temporal, volver a 1 | `aa-complain PERFIL`, luego `aa-enforce` |

---

## 8. Error típico

**Situación.** En un Rocky Linux, el sitio web devuelve 403 en todos los ficheros que subió el desarrollador esta tarde. Los que ya estaban funcionan. Los permisos son idénticos: `-rw-r--r-- root root`. El `error_log` de Apache dice `Permission denied` sin más.

**Por qué ocurre.** El desarrollador copió los ficheros con `scp` a su home y después los movió a `/var/www/html` con `mv`. En SELinux, `mv` conserva la etiqueta del fichero original (`user_home_t`), mientras que `cp` habría asignado la del directorio destino (`httpd_sys_content_t`). Apache corre como `httpd_t` y la política no le deja leer `user_home_t`: para SELinux, Apache está intentando leer un fichero del home de un usuario, que es exactamente lo que se supone que no debe poder hacer.

**Cómo se ve.** `ls -Z /var/www/html` muestra dos etiquetas distintas en la misma carpeta. `ausearch -m avc -ts recent` tiene una línea por fichero con `scontext=...httpd_t`, `tcontext=...user_home_t`, `denied { read }`. Si pruebas `setenforce 0` un momento, los ficheros se sirven; eso confirma que es SELinux, pero no es la solución.

**Cómo se arregla.** `restorecon -Rv /var/www/html` reetiqueta todo según la política por defecto; la salida lista cada fichero que cambia de `user_home_t` a `httpd_sys_content_t`. Los 403 desaparecen al instante, sin reiniciar nada. Y para que no vuelva a pasar: copiar con `cp` o, si hay que usar `mv`, hacer `restorecon` después; mejor aún, que el despliegue lo haga una herramienta que escriba directamente en el destino.

---

Relacionado: [permisos-posix](permisos-posix.md) · [logs-clasicos](logs-clasicos.md) · [systemd-journalctl](systemd-journalctl.md) · [bastionado-linux](../../Ciberseguridad/chuletas/bastionado-linux.md) · [auditoria-eventos](../../Ciberseguridad/chuletas/auditoria-eventos.md) · runbook [servicio-no-arranca](../runbooks/servicio-no-arranca.md)

*Biblioteca — Sistemas Operativos · SELinux / AppArmor*
