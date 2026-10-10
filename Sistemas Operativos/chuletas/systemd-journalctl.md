# Chuleta: systemd y journalctl

systemd es el primer proceso que arranca el kernel (PID 1) en casi todas las distribuciones actuales, y desde ahí levanta todo lo demás: servicios, montajes, temporizadores, sesiones. journalctl es el lector de su registro. Entre los dos cubren la mayor parte del trabajo diario de un administrador de Linux: saber qué está corriendo, arrancarlo o pararlo, y leer qué pasó cuando algo falló.

---

## 1. Unidades: qué gestiona systemd

systemd no gestiona «programas» sino **unidades**. Una unidad es un fichero de texto que describe algo que systemd tiene que mantener en un estado: un demonio que debe estar corriendo, un sistema de ficheros que debe estar montado, un temporizador que debe disparar algo a las tres de la mañana. El tipo de unidad lo indica la extensión del fichero, y cada tipo tiene sus propias opciones.

| Tipo | Extensión | Qué describe |
|------|-----------|--------------|
| Servicio | `.service` | Un proceso o demonio: cómo se arranca (`ExecStart=`), con qué usuario, qué hacer si muere (`Restart=`). Es el tipo que más vas a tocar. |
| Temporizador | `.timer` | Un calendario que activa otra unidad, normalmente un `.service` con el mismo nombre. Sustituye a cron dentro de systemd. |
| Socket | `.socket` | Un puerto o socket que systemd abre por adelantado; cuando llega la primera conexión, arranca el servicio asociado. Ahorra recursos en servicios que se usan poco. |
| Mount / Automount | `.mount` / `.automount` | Un punto de montaje. systemd genera estas unidades a partir de `/etc/fstab`, por eso un error en `fstab` aparece como una unidad fallida. |
| Target | `.target` | Un grupo de unidades que se activan juntas. `multi-user.target` es el equivalente al antiguo runlevel 3; `graphical.target`, al 5. |
| Path | `.path` | Vigila una ruta y dispara una unidad cuando el fichero aparece o cambia. |

### Dónde viven los ficheros de unidad

Hay tres sitios, y el orden importa: si el mismo nombre existe en varios, gana el más específico.

| Ámbito | Directorio | Quién escribe aquí |
|--------|------------|--------------------|
| Sistema, instalado por paquete | `/lib/systemd/system/` o `/usr/lib/systemd/system/` | El gestor de paquetes. No edites aquí: la siguiente actualización pisará el cambio. |
| Sistema, del administrador | `/etc/systemd/system/` | Tú. Tiene prioridad sobre `/lib`. Aquí van las unidades propias y los *drop-ins* que modifican unidades de paquete. |
| Usuario | `~/.config/systemd/user/` | Cada usuario, para servicios que corren con su sesión sin necesitar root. |

Un **drop-in** es un fichero parcial en `/etc/systemd/system/NOMBRE.service.d/*.conf` que añade o sobreescribe opciones sin copiar la unidad entera. Es la forma correcta de cambiar, por ejemplo, el usuario con el que corre un servicio de paquete: la unidad original sigue actualizándose y tu cambio se aplica encima.

---

## 2. systemctl: el día a día

`systemctl` es la herramienta para hablar con systemd. Casi todo lo que haces con un servicio pasa por aquí.

```bash
systemctl status ssh
systemctl start NOMBRE
systemctl stop NOMBRE
systemctl restart NOMBRE
systemctl reload NOMBRE
systemctl enable --now NOMBRE
systemctl disable --now NOMBRE
systemctl is-active NOMBRE
systemctl is-enabled NOMBRE
systemctl list-units --type=service --state=running
systemctl --failed
systemctl daemon-reload
systemctl cat NOMBRE
systemctl edit NOMBRE
systemctl show NOMBRE -p FragmentPath -p ActiveState
```

Hay dos conceptos que conviene separar desde el principio porque se confunden constantemente:

- **Arrancar** (`start`) y **parar** (`stop`) actúan ahora, sobre el proceso que está corriendo. No cambian nada para el próximo reinicio.
- **Habilitar** (`enable`) y **deshabilitar** (`disable`) actúan sobre el próximo arranque: crean o borran el enlace simbólico que hace que la unidad se active con su target. No tocan el proceso actual.

Por eso existe `--now`: `enable --now` habilita para el futuro y arranca ahora, en un solo paso. Un servicio puede estar `active` pero `disabled` (corre ahora, no volverá tras reiniciar) o `inactive` pero `enabled` (no corre ahora, arrancará en el próximo boot). Las dos situaciones son legítimas, pero hay que saber en cuál estás.

`reload` pide al servicio que relea su configuración sin cortar las conexiones, si el servicio lo soporta (nginx, sshd, muchos demonios). `restart` lo mata y lo arranca de nuevo. Para un servidor web en producción la diferencia es que `reload` no deja caer peticiones.

`daemon-reload` es distinto a todo lo anterior: no toca ningún servicio, sino que hace que systemd vuelva a leer los ficheros de unidad del disco. Hay que ejecutarlo cada vez que editas o creas una unidad; si no, systemd sigue trabajando con la versión que tenía en memoria y los cambios parecen no aplicarse.

### Qué estás viendo en `systemctl status`

```text
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-10-10 09:12:04 UTC; 2h 3min ago
       Docs: man:nginx(8)
    Process: 812 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 815 (nginx)
      Tasks: 3 (limit: 4558)
     Memory: 8.2M
        CPU: 1.204s
     CGroup: /system.slice/nginx.service
             ├─815 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─816 "nginx: worker process"
             └─817 "nginx: worker process"
```

- La línea `Loaded` dice de qué fichero viene la unidad y si está `enabled` o `disabled`. Si pone `masked`, alguien la ha bloqueado a propósito y no arrancará aunque se lo pidas.
- `Active` tiene dos partes: el estado general (`active`, `inactive`, `failed`, `activating`) y el subestado entre paréntesis (`running`, `exited`, `dead`, `auto-restart`). `active (exited)` es normal en unidades que ejecutan algo y terminan, como un script de arranque; en un demonio significa que el proceso principal se fue y systemd no lo considera un error.
- `Main PID` es el proceso que systemd vigila. Si ese PID muere, la unidad pasa a `failed` o se reinicia según `Restart=`.
- `CGroup` lista todos los procesos que pertenecen a la unidad. Si matas uno de los hijos, systemd lo sabe. Es también lo que permite que `systemctl stop` acabe con todo el árbol, no solo con el padre.
- Debajo de esto, `status` muestra las últimas líneas del journal de la unidad. Para un servicio caído, esas diez líneas suelen ser la respuesta.

### Ámbito de usuario

Cada usuario tiene su propia instancia de systemd para su sesión. Los servicios que viven ahí corren con sus permisos, sin root, y por defecto mueren cuando el usuario cierra la última sesión.

```bash
systemctl --user status NOMBRE
systemctl --user enable --now NOMBRE
loginctl enable-linger USUARIO
```

`enable-linger` hace que la instancia de ese usuario arranque con la máquina y sobreviva al cierre de sesión. Es lo que necesitas para que un servicio de usuario corra en un servidor donde nadie inicia sesión interactiva.

---

## 3. Timers frente a cron

Un timer es la forma de systemd de hacer lo que hace cron: ejecutar algo a una hora o cada cierto tiempo. La diferencia no está en el calendario sino en todo lo que hay alrededor. Un timer activa una unidad, y esa unidad tiene todo lo que tiene cualquier servicio: su propio registro en el journal, su usuario, sus dependencias, su límite de recursos. Una tarea de cron es una línea que lanza un comando con un entorno mínimo y cuya salida, si la hay, acaba en el correo local que nadie lee.

| | systemd timer | cron |
|--|---------------|------|
| Qué ejecuta | Una unidad `.service`, con todas sus opciones (usuario, entorno, dependencias). | Una línea de comando con un entorno mínimo (`PATH` corto, sin variables de sesión). |
| Dónde queda el registro | En el journal, filtrable con `journalctl -u NOMBRE`. | En el correo local del usuario, o en ningún sitio si se redirige a `/dev/null`. |
| Si la máquina estaba apagada | Con `Persistent=true`, ejecuta la tarea perdida al arrancar. | No, salvo que uses anacron. |
| Evitar solapamientos | Automático: si el servicio aún corre, el timer no lanza otra instancia. | Hay que gestionarlo con `flock` en el propio comando. |
| Ver qué hay programado | `systemctl list-timers` muestra última y próxima ejecución. | `crontab -l` por usuario, más `/etc/cron.d/`, `/etc/cron.daily/`… |
| Portabilidad | Solo sistemas con systemd. | Cualquier Unix. |

```bash
systemctl list-timers --all
systemctl status NOMBRE.timer
systemctl start NOMBRE.timer
systemctl start NOMBRE.service
```

La última línea es un truco útil: puedes ejecutar la tarea a mano, ahora, arrancando el `.service` directamente. Sirve para probarla sin esperar al calendario y ver su salida en el journal.

### Qué estás viendo en `list-timers`

```text
NEXT                        LEFT       LAST                        PASSED    UNIT                     ACTIVATES
Sun 2026-10-11 03:15:00 UTC 12h left   Sat 2026-10-10 03:15:01 UTC 11h ago   backup-diario.timer      backup-diario.service
Sun 2026-10-11 00:00:00 UTC 8h left    Sat 2026-10-10 00:00:03 UTC 15h ago   logrotate.timer          logrotate.service
```

`NEXT` y `LEFT` dicen cuándo se dispara; `LAST` y `PASSED`, cuándo lo hizo por última vez. Si `LAST` dice `n/a`, el timer nunca ha corrido, lo que suele significar que está habilitado pero el servicio asociado falla o que acabas de crearlo. La columna `ACTIVATES` confirma qué unidad lanza; si está vacía, el timer no encuentra su servicio.

### Sintaxis del calendario

```text
OnCalendar=*-*-* 03:15:00
OnCalendar=Mon..Fri 09:00
OnCalendar=weekly
OnBootSec=5min
OnUnitActiveSec=1h
```

`OnCalendar=` es el equivalente a la línea de cron: año-mes-día hora:minuto:segundo, con `*` como comodín. `OnBootSec=` cuenta desde el arranque; `OnUnitActiveSec=` cuenta desde la última vez que el servicio terminó, lo que da «cada hora» de verdad aunque la tarea tarde. Puedes comprobar cómo interpreta systemd una expresión con `systemd-analyze calendar "Mon..Fri 09:00"`, que devuelve las próximas ejecuciones.

Cuándo usar cada uno: timer para cualquier tarea que quieras ver en el journal, que dependa de otro servicio o que no deba solaparse; cron para tareas simples que ya existen y funcionan, o cuando el mismo fichero tiene que servir en sistemas sin systemd. La chuleta [cron-timers](cron-timers.md) desarrolla las dos sintaxis y el Programador de tareas de Windows.

---

## 4. journalctl: leer el registro

El journal guarda todo lo que escriben los servicios en su salida estándar y de error, lo que llega por syslog y los mensajes del kernel, en un formato binario indexado. Esa indexación es lo que permite filtrar por unidad, por tiempo o por prioridad sin recorrer ficheros a mano.

```bash
journalctl
journalctl -b
journalctl -b -1
journalctl -u ssh
journalctl -u nginx -u php-fpm
journalctl -f
journalctl -xe
journalctl --since "1 hour ago"
journalctl --since "2026-09-01" --until "2026-09-02 12:00"
journalctl -p err..alert
journalctl -p 3 -xb
journalctl _PID=1234
journalctl _UID=1000
journalctl -k
journalctl --disk-usage
journalctl --vacuum-size=500M
journalctl --vacuum-time=14d
```

Los filtros se combinan: `journalctl -u nginx -b -p warning --since "30 min ago"` da los avisos y errores de nginx en este arranque durante la última media hora, que es exactamente lo que quieres cuando te avisan de que «la web va mal».

Algunas opciones que conviene entender bien:

- `-b` limita al arranque actual. `-b -1` es el anterior, `-b -2` el de antes, y así. Cuando una máquina se ha reiniciado sola, `journalctl -b -1 -e` muestra qué fue lo último que escribió antes de caer. Esto solo funciona si el journal es persistente; por defecto en Debian lo es, en otras distribuciones hay que activarlo (nota [journal-persistente](../notas/journal-persistente.md)).
- `-x` añade, debajo de algunos mensajes, un texto explicativo del catálogo de systemd. `-e` salta al final. `-xe` es la combinación habitual tras un fallo.
- `-p` filtra por prioridad. Acepta un nombre, un número o un rango. `-p 3` muestra prioridad 3 y más graves (0 a 3); `-p err..alert` equivale a 1..3.
- Los campos con guion bajo (`_PID`, `_UID`, `_SYSTEMD_UNIT`) son metadatos que añade el journal, no el programa, así que son fiables aunque el servicio mienta en su mensaje.
- `--vacuum-size` y `--vacuum-time` borran los ficheros archivados del journal más antiguos hasta cumplir el límite. No tocan el fichero activo. Para limitar el crecimiento de forma permanente, el sitio es `SystemMaxUse=` en `/etc/systemd/journald.conf`.

### Qué estás viendo

```text
oct 10 09:12:03 web01 systemd[1]: Starting A high performance web server and a reverse proxy server...
oct 10 09:12:04 web01 nginx[812]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
oct 10 09:12:04 web01 systemd[1]: Started A high performance web server and a reverse proxy server.
oct 10 11:40:51 web01 nginx[816]: 2026/10/10 11:40:51 [error] 816#816: *44 connect() failed (111: Connection refused) while connecting to upstream
```

Cada línea lleva fecha y hora, nombre de la máquina, quién la escribió (con PID entre corchetes) y el mensaje. Las líneas de `systemd[1]` cuentan lo que systemd hace con la unidad: `Starting`, `Started`, `Stopped`, `Failed`. Las demás son lo que el propio servicio escribe. En el ejemplo, nginx arrancó bien a las 9:12 y dos horas después no consigue conectar con su backend: el problema no es nginx sino lo que hay detrás.

### Formatos de salida

```bash
journalctl -u ssh -o short-iso
journalctl -u ssh -o json-pretty
journalctl -u ssh -n 50 --no-pager
```

`short-iso` pone las fechas en formato ISO con zona horaria, lo que ayuda a correlacionar con otras máquinas. `json-pretty` muestra todos los campos de cada entrada, incluidos los ocultos; útil para ver qué metadatos hay disponibles para filtrar. `--no-pager` evita que la salida pase por `less`, necesario cuando rediriges a un fichero o lo pegas en un informe.

---

## 5. Prioridades syslog

La prioridad la asigna quien escribe el mensaje, no el journal, así que su fiabilidad depende del servicio. Aun así, es el filtro más rápido para separar ruido de problema.

| Nº | Nombre | Qué suele significar |
|----|--------|----------------------|
| 0 | emerg | El sistema no puede seguir; suele venir del kernel. |
| 1 | alert | Hace falta actuar ya: disco de sistema corrupto, hardware fallando. |
| 2 | crit | Fallo grave de un componente, pero el sistema sigue. |
| 3 | err | Algo falló: un servicio no arranca, una conexión se rechaza. Es el nivel que miras primero. |
| 4 | warning | Algo no es como debería pero funciona: configuración obsoleta, certificado cerca de caducar. |
| 5 | notice | Normal, pero digno de mención: inicio de sesión, cambio de configuración. |
| 6 | info | Funcionamiento normal. |
| 7 | debug | Detalle para depuración; no debería estar activo en producción. |

---

## 6. Checklist operativo

| Objetivo | Comando o acción |
|----------|------------------|
| Ver qué ha fallado | `systemctl --failed` y después `journalctl -xe` para el detalle. |
| Logs de un servicio en este arranque | `journalctl -u NOMBRE -b --no-pager` |
| Qué pasó antes del último reinicio | `journalctl -b -1 -e` (requiere journal persistente). |
| Cambiar una unidad de paquete sin romper actualizaciones | `systemctl edit NOMBRE` crea un drop-in en `/etc`. |
| Después de editar una unidad | `systemctl daemon-reload` y luego `restart`. |
| Ver tareas programadas | `systemctl list-timers --all` |
| Probar una tarea programada ahora | `systemctl start NOMBRE.service` (el servicio, no el timer). |
| Recortar el journal | `--vacuum-size=` o `--vacuum-time=`; de forma permanente, `SystemMaxUse=` en `journald.conf`. |

---

## 7. Error típico

**Situación.** Editas `/lib/systemd/system/miapp.service` para cambiar `ExecStart=`, ejecutas `systemctl restart miapp` y el servicio sigue arrancando con el comando antiguo. Repites el restart. Nada.

**Por qué ocurre.** systemd carga los ficheros de unidad en memoria al arrancar y cada vez que se lo pides. Editar el fichero en disco no cambia lo que systemd tiene cargado; `restart` reinicia el proceso con la definición que systemd ya conocía. Además, has editado el fichero del paquete, así que la próxima actualización de `miapp` te devolverá al punto de partida.

**Cómo se ve.** `systemctl cat miapp` muestra tu cambio (lee del disco), pero `systemctl show miapp -p ExecStart` muestra el comando antiguo (lee de memoria). El journal no dice nada raro porque, desde el punto de vista de systemd, todo va bien. A veces `systemctl status` avisa con `Warning: The unit file, source configuration file or drop-ins of miapp.service changed on disk. Run 'systemctl daemon-reload' to reload units.`, pero no siempre, y es fácil no leerlo.

**Cómo se arregla.** Primero, `systemctl daemon-reload` y luego `systemctl restart miapp`. Segundo, deshaz el cambio en `/lib` y hazlo bien: `systemctl edit miapp` abre un editor sobre un drop-in nuevo en `/etc/systemd/system/miapp.service.d/override.conf`. Para sustituir `ExecStart=` en un drop-in hay que vaciarlo primero y luego definirlo:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/miapp --config /etc/miapp/nuevo.conf
```

Sin la línea vacía, systemd añade un segundo `ExecStart=` en lugar de reemplazar el primero, y en un servicio de tipo `simple` eso es un error. Al guardar, `systemctl edit` hace el `daemon-reload` por ti.

---

Relacionado: [cron-timers](cron-timers.md) · [procesos-senales](procesos-senales.md) · [logs-clasicos](logs-clasicos.md) · nota [journal-persistente](../notas/journal-persistente.md) · runbook [servicio-no-arranca](../runbooks/servicio-no-arranca.md) · plantilla [unit-systemd.ejemplo](../plantillas/unit-systemd.ejemplo)

*Biblioteca — Sistemas Operativos · systemd / journalctl*
