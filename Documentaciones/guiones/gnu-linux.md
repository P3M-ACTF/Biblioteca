# Guion de contenidos · GNU/Linux: consulta y administración

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Base común GNU/Linux y variantes Debian/Ubuntu, Arch/Manjaro, RHEL/Fedora y derivadas. Delimitar versión, instalación mínima/desktop/server, kernel, shell, init, paquetes y herramientas opcionales. GNU/Linux no tiene un catálogo universal cerrado: inventariar comandos por paquete y funciones del sistema elegido. No asumir que Debian usa siempre systemd-networkd, que Ubuntu usa siempre Netplan ni que Manjaro comparte exactamente repositorios/ciclo con Arch. Verificar quién gestiona cada interfaz antes de cambiarla.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### LIN-T01 · Distribución, instalación y arranque

- [ ] Kernel, GNU userland, distribución, paquetes, shell e init; límites de portabilidad POSIX/GNU/BSD/BusyBox.
- [ ] Instalación física/VM/cloud, particionado, UEFI/BIOS, Secure Boot, initramfs y bootloader.
- [ ] Ciclo de vida, release fija/rolling, repositorios, firmas y versiones de Debian/Ubuntu/Arch/RHEL.
- [ ] Desktop/server/minimal; herramientas opcionales y diferencias de instalación.

### LIN-T02 · Shell y automatización

- [ ] Terminal, TTY, sesiones, login/non-login, interactiva/no interactiva y shell por usuario.
- [ ] Bash/sh/zsh, ayuda, built-ins, aliases, funciones, PATH, variables, expansión y quoting.
- [ ] stdin/stdout/stderr, pipelines, redirecciones, exit status, señales, jobs y sustitución de comandos.
- [ ] Scripts, argumentos, getopts, tests, arrays, bucles, funciones, errores, traps, logs e idempotencia.

### LIN-T03 · Filesystem y datos

- [ ] Jerarquía FHS, rutas, inodos, enlaces duros/simbólicos, dispositivos, /proc y /sys.
- [ ] Consulta, creación, copia, búsqueda, filtrado, ordenación, comparación, compresión y checksums.
- [ ] Texto, locales, Unicode, bytes/caracteres, archivos vacíos, nombres con espacios/saltos/guiones.
- [ ] Filesystem, mounts, atributos, tiempos, cuotas y metadatos.

### LIN-T04 · Usuarios, grupos y privilegios

- [ ] UID/GID, identidades locales/NSS/directorio, grupos primario/suplementarios y sesiones.
- [ ] Crear, consultar, modificar, bloquear y retirar cuentas/grupos; perfiles/home y shells.
- [ ] Contraseñas, expiración, shadow, PAM, sudo/su y derechos de servicio.
- [ ] Capabilities, setuid/setgid, umask, sticky bit y mínimo privilegio.

### LIN-T05 · Permisos, ACL y control obligatorio

- [ ] Permisos POSIX y recorrido de directorios; owner/grupo y permisos efectivos.
- [ ] ACL access/default, named users/groups, máscara, herencia y efecto de chmod.
- [ ] SELinux, AppArmor, contextos/perfiles, denegaciones y ajustes persistentes.
- [ ] Copiar/restaurar permisos, ACL, xattrs, owners y enlaces; comparación con NTFS.

### LIN-T06 · Procesos, memoria y servicios

- [ ] PID/PPID, usuario, sesión, estado, señales, prioridades, nice y cgroups.
- [ ] Consultar/filtrar/iniciar/esperar/terminar procesos; jobs, background, nohup y supervisión.
- [ ] systemd: unidades, dependencias, targets, drop-ins, usuario/sistema, logs y recursos.
- [ ] Servicios, cuentas dedicadas, sandboxing, sockets, timers y diferencias con cron/anacron.
- [ ] CPU/RAM/I/O/disco/red, errores, logs, core dumps y diagnóstico.

### LIN-T07 · Software, kernel y hardware

- [ ] apt/dpkg, pacman y dnf/rpm: búsqueda, consulta, instalación, verificación y retirada.
- [ ] Dependencias, versiones, holds/pinning, repositorios, firmas, caché y actualizaciones.
- [ ] Compilación/build como bloque separado; DKMS, módulos del kernel, firmware y dispositivos.
- [ ] Flatpak/Snap/AppImage/AUR como canales opcionales y sus modelos de confianza.

### LIN-T08 · Red y acceso remoto

- [ ] Interfaces, IP/prefijo, rutas, vecinos, DHCP, DNS, hostname y resolución NSS.
- [ ] iproute2 y consultas; configuración persistente con NetworkManager/networkd/ifupdown/Netplan según gestor real.
- [ ] Firewall nftables, ufw/firewalld e iptables legacy/compatibilidad; IPv4/IPv6 y persistencia.
- [ ] Puertos, listeners, sockets, proceso/servicio, pruebas, captura y diagnóstico.
- [ ] SSH, DNS/DHCP, HTTP/TLS, NFS/SMB y servicios de red como bloques identificados.

### LIN-T09 · Almacenamiento, backup y recuperación

- [ ] Discos, particiones GPT/MBR, filesystem, LVM, RAID, swap y cifrado LUKS.
- [ ] Montajes persistentes, UUID, fstab, cuotas, xattrs, snapshots y reparación offline.
- [ ] Copias coherentes, rsync/tar/restic/borg según herramientas elegidas; restauración probada.
- [ ] Arranque fallido, rescue/chroot, disco lleno, inode agotado, permisos y pérdida de red.

### LIN-T10 · Virtualización, seguridad y operación

- [ ] KVM/libvirt, contenedores Docker/Podman y namespaces/cgroups: catálogos opcionales por producto.
- [ ] Actualizaciones, hardening, logs, auditoría, secretos, certificados, hora y acceso remoto.
- [ ] Inventario, monitorización, capacidad, automatización, documentación y respuesta a fallos.
- [ ] Reconciliar cada paquete/binario/builtin/directiva del entorno; no presentar un listado básico como exhaustivo.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="lin-c001"></a>LIN-C001 | Ayuda y catálogo | `man`, `info`, `apropos`, `whatis`, `help`, `type`, `command -v`, `which` si instalado, `comando --help` | Secciones 1/5/8, built-ins frente a binarios y versión del paquete. |
| <a id="lin-c002"></a>LIN-C002 | Identidad del sistema | `uname -a/-r/-m`, `/etc/os-release`, `hostnamectl`, `lsb_release` si disponible, `getconf` | Kernel frente a distribución, arquitectura y usuarios del entorno. |
| <a id="lin-c003"></a>LIN-C003 | Shell y sesión | `bash`, `sh`, `zsh` según instalación; login/interactiva, `source`, `.`, `exec`, `exit`, `logout`, `tty`, `stty`, `reset`, `clear` | Recargar perfil frente a sustituir shell; no asumir que sh es Bash. |
| <a id="lin-c004"></a>LIN-C004 | Variables y expansión | `export`, `unset`, `env`, `printenv`, `set`, `declare`, `readonly`, `local`; quoting, glob, brace y parameter expansion | Entorno heredado, scope y expansión antes de ejecutar el comando. |
| <a id="lin-c005"></a>LIN-C005 | Entrada, salida y control | `printf`, `echo`, `read`, `test`, `[`, `[[`, `true`, `false`, `:`, `&&`, `&#124;&#124;`, redirecciones y pipelines | Portabilidad, códigos de salida, stderr y pipefail según shell. |
| <a id="lin-c006"></a>LIN-C006 | Scripts y parámetros | `getopts`, `shift`, `case`, bucles, funciones, arrays, `trap`, `return`, `eval` si se justifica | Validación, quoting, señales, salida parcial y riesgo de evaluación de texto. |
| <a id="lin-c007"></a>LIN-C007 | Rutas y listado | `pwd`, `cd`, `ls`, `tree`, `realpath`, `readlink`, `basename`, `dirname` | `-a`, `-l`, `-h`, `-d`, `-R`, `-L`, `-P`, `-f` solo donde proceda; ruta física/lógica y enlaces. |
| <a id="lin-c008"></a>LIN-C008 | Metadatos y tipos | `stat`, `file`, `du`, `df`, `findmnt`, `mountpoint`, `lsattr`, `getfattr` | Bloques/inodos, uso aparente/asignado, filesystem y atributos. |
| <a id="lin-c009"></a>LIN-C009 | Crear/copiar/mover/retirar | `touch`, `mkdir`, `rmdir`, `cp`, `mv`, `rm`, `install`, `ln`, `unlink`, `truncate` | `-p`, `-r/-R`, `-a`, `-i`, `-n`, `-f`, `-s`, `--preserve`, `--` según herramienta; enlaces, recursión y sobrescritura. |
| <a id="lin-c010"></a>LIN-C010 | Leer contenido | `cat`, `tac`, `less`, `more`, `head`, `tail`, `nl`, `wc`, `od`, `hexdump`, `xxd` según paquete | `-n`, `-c`, `-f`, `-F`, `-b`; bytes/líneas, follow y binario frente a texto. |
| <a id="lin-c011"></a>LIN-C011 | Buscar archivos | `find`, `locate`/`plocate`, `updatedb` si instalado | find `-name`, `-iname`, `-type`, `-user`, `-group`, `-perm`, `-size`, `-mtime`, `-mmin`, `-maxdepth`, `-xdev`, `-exec`, `-print0`, `-delete`; precedencia y seguridad de nombres. |
| <a id="lin-c012"></a>LIN-C012 | Buscar texto | `grep`, `rg` si instalado | `-i`, `-n`, `-v`, `-r`, `-l`, `-E`, `-F`, `-w`, `-A/-B/-C`, `--null` donde exista; status match/no-match/error. |
| <a id="lin-c013"></a>LIN-C013 | Procesar texto | `sed`, `awk`, `cut`, `paste`, `tr`, `sort`, `uniq`, `join`, `comm`, `split`, `csplit`, `fmt`, `fold`, `column` | Inventario individual de flags/programas; delimitadores, locale, orden y streams. |
| <a id="lin-c014"></a>LIN-C014 | Comparar, codificar y ejecutar lotes | `diff`, `cmp`, `patch`, `iconv`, `base64`, `xargs`, `tee`, `yes`, `seq` | diff `-u/-r`; xargs `-0`, `-n`, `-P`, `-I`; límites, códigos y entradas no confiables. |
| <a id="lin-c015"></a>LIN-C015 | Editar y revisar | `vi`/`vim`, `nano`, `ed` según instalación | Modos, navegación, búsqueda/sustitución, guardado/salida, permisos y recovery; inventario por editor elegido. |
| <a id="lin-c016"></a>LIN-C016 | Archivos y compresión | `tar`, `gzip`, `gunzip`, `bzip2`, `xz`, `zstd`, `zip`, `unzip`, `ar`, `cpio` según paquetes | Crear/listar/extraer, compresión, permisos/owners/ACL/xattrs, rutas peligrosas y sobrescritura. |
| <a id="lin-c017"></a>LIN-C017 | Hashes y firmas | `sha256sum`, `sha512sum`, `b2sum`, `cksum`, `gpg`, `openssl dgst` | Verificación frente a autenticidad; algoritmos, firma, clave confiable y códigos de retorno. |
| <a id="lin-c018"></a>LIN-C018 | Identidad y sesiones | `id`, `whoami`, `groups`, `who`, `w`, `users`, `last`, `lastlog` o alternativa del paquete | UID/GID, grupos de proceso frente a base de cuentas y registros de sesión. |
| <a id="lin-c019"></a>LIN-C019 | NSS y cuentas | `getent passwd/group/shadow`, `getent hosts`, `nsswitch.conf`, `pwck`, `grpck`, `vipw`, `vigr` | Fuente local/directorio, validación y privilegios; no volcar hashes en documentación. |
| <a id="lin-c020"></a>LIN-C020 | Usuarios | `useradd`, `usermod`, `userdel`, `adduser`, `deluser` según distribución | `-m`, `-d`, `-s`, `-u`, `-g`, `-G`, `-a`, `-L`, `-U`, `-e`, `-r` según comando; home, grupos, bloqueo y retirada. |
| <a id="lin-c021"></a>LIN-C021 | Grupos | `groupadd`, `groupmod`, `groupdel`, `gpasswd`, `groupmems`, `newgrp`, `sg` según paquete | GID, nombre, añadir/retirar miembro, cambio de grupo de sesión y permisos. |
| <a id="lin-c022"></a>LIN-C022 | Contraseña y expiración | `passwd`, `chage`, políticas PAM y lockout del entorno | `-S`, `-l`, `-u`, `-d`, `-e`; chage `-l`, `-M`, `-m`, `-W`, `-I`, `-E` según orden; password lock no bloquea todos los métodos de acceso. |
| <a id="lin-c023"></a>LIN-C023 | Otra identidad y delegación | `su`, `sudo`, `sudoedit`, `visudo`, `runuser`, `setpriv` | `su -`, `sudo -u/-g/-i/-s/-l/-k/-v`, validación `visudo -c`; entorno, identidad y privilegios efectivos. |
| <a id="lin-c024"></a>LIN-C024 | `sudoers` | Usuarios/hosts/runas/comandos, aliases, Defaults, includes, tags y reglas por archivo | Precedencia, argumentos, rutas y delegación mínima; evitar permisos más amplios de lo necesario. |
| <a id="lin-c025"></a>LIN-C025 | Permisos POSIX | `chmod`, `chown`, `chgrp`, `umask`, `namei` | Simbólico/octal, `-R`, `-h`, `--reference`, `--preserve-root` donde existan; recorrido de directorios y symlinks. |
| <a id="lin-c026"></a>LIN-C026 | Permisos especiales y atributos | setuid/setgid/sticky; `chattr`, `lsattr`, xattrs y atributos soportados por filesystem | Archivo frente a directorio, inmutabilidad, herencia de grupo y efecto de copiar. |
| <a id="lin-c027"></a>LIN-C027 | `getfacl` | `-p`, `-R`, `-c`, `-e`, `-s`, access/default y opciones de la versión | Owner, group, named entries, mask y comentario effective. |
| <a id="lin-c028"></a>LIN-C028 | `setfacl` | `-m`, `-x`, `-b`, `-k`, `-R`, `-d`, `-n`, `--mask`, `--restore`, `--test` | Access/default, máscara, interacción con chmod y restauración completa. |
| <a id="lin-c029"></a>LIN-C029 | Capabilities | `getcap`, `setcap`, `capsh`, `getpcaps` si incluidos | Conjuntos permitted/effective/inheritable/ambient/bounding y herencia de exec. |
| <a id="lin-c030"></a>LIN-C030 | SELinux consulta | `getenforce`, `sestatus`, `ls -Z`, `ps -Z`, `getsebool`, `ausearch` | Modo, dominio/tipo, booleanos y AVC frente a permisos POSIX. |
| <a id="lin-c031"></a>LIN-C031 | SELinux administración | `semanage`, `restorecon`, `setsebool`, `chcon`, `semodule` | fcontext/port, persistencia, política/booleanos; chcon frente a restorecon; no desactivar el control para resolver denegaciones. |
| <a id="lin-c032"></a>LIN-C032 | AppArmor | `aa-status`, `aa-enforce`, `aa-complain`, `aa-logprof`, perfiles y logs según paquete | Perfil, modo, denegación y cambio mínimo justificado. |
| <a id="lin-c033"></a>LIN-C033 | Consulta de procesos | `ps`, `pgrep`, `pstree`, `/proc`, `pidof` | ps `-ef`, `aux`, `-o`, `-p`, `--forest`; pgrep `-a`, `-f`, `-u`, `-x`; no mezclar sintaxis BSD/UNIX sin explicación. |
| <a id="lin-c034"></a>LIN-C034 | Monitorización de procesos | `top`, `htop`, `atop`, `pidstat`, `lsof`, `fuser` según paquetes | Intervalo, usuario, hilos, CPU acumulada/instantánea, memoria y ficheros/sockets abiertos. |
| <a id="lin-c035"></a>LIN-C035 | Señales y prioridad | `kill`, `pkill`, `killall`, `nice`, `renice`, `ionice`, `timeout`, `time`, `watch` | Señal numérica/nombre, selección exacta, TERM frente a KILL, proceso/zombie y consecuencias. |
| <a id="lin-c036"></a>LIN-C036 | Jobs y ejecución | `jobs`, `bg`, `fg`, `wait`, `nohup`, `disown`, `setsid`, `screen`, `tmux` según shell/paquetes | Sesión, terminal, HUP, persistencia y diferencia con servicio supervisado. |
| <a id="lin-c037"></a>LIN-C037 | CPU, RAM e I/O | `free`, `uptime`, `vmstat`, `iostat`, `mpstat`, `sar`, `dstat` o alternativa elegida, `iotop`, `swapon --show` | Disponible frente a libre, carga, wait, presión y unidades. |
| <a id="lin-c038"></a>LIN-C038 | Límites y cgroups | `ulimit`, `prlimit`, `/proc/*/limits`, cgroup v1/v2, `systemd-cgls`, `systemd-cgtop` | Soft/hard, herencia, memoria/CPU/PID y límites de servicio. |
| <a id="lin-c039"></a>LIN-C039 | `systemctl` consulta | `status`, `show`, `cat`, `list-units`, `list-unit-files`, `list-dependencies`, `is-active`, `is-enabled`, `--failed`, `--user` | Activo frente a habilitado, unidad cargada, origen y estado de salida. |
| <a id="lin-c040"></a>LIN-C040 | `systemctl` modificación | `start`, `stop`, `restart`, `reload`, `reload-or-restart`, `enable`, `disable`, `mask`, `unmask`, `daemon-reload`, `reset-failed`, `edit`, `revert`, `--now` | Configuración frente a estado; persistencia, drop-ins y reversión. |
| <a id="lin-c041"></a>LIN-C041 | Unidades systemd | `Unit`, `Service`, `Install`; `Description`, `After`, `Before`, `Wants`, `Requires`, `Type`, `ExecStart`, `ExecStop`, `User`, `Group`, `WorkingDirectory`, `Environment`, `EnvironmentFile`, `Restart`, `WantedBy` | Orden frente a dependencia, quoting y prefijos; inventariar todas las directivas de los tipos incluidos. |
| <a id="lin-c042"></a>LIN-C042 | systemd seguridad y recursos | `NoNewPrivileges`, `ProtectSystem`, `ProtectHome`, `PrivateTmp`, `CapabilityBoundingSet`, `ReadWritePaths`, `MemoryMax`, `CPUQuota` y catálogo | Cuenta dedicada, restricciones, compatibilidad y fallo por sandbox. |
| <a id="lin-c043"></a>LIN-C043 | Sockets y timers systemd | Tipos `.socket`, `.timer`, `ListenStream`, `OnCalendar`, `OnBootSec`, `OnUnitActiveSec`, `Persistent`, `RandomizedDelaySec` | Activación, calendario, tareas perdidas, zonas horarias y dependencias. |
| <a id="lin-c044"></a>LIN-C044 | `journalctl`, logs y core | `-u`, `-b`, `-p`, `--since`, `--until`, `-f`, `-n`, `-o`, `--disk-usage`, `--vacuum-*`; `dmesg`, `coredumpctl` | Boots, prioridades, campos, retención y operaciones que eliminan evidencia. |
| <a id="lin-c045"></a>LIN-C045 | Cron, at y rotación | `crontab -l/-e/-r/-u`, `/etc/cron*`, `at`, `atq`, `atrm`, `anacron`, `logrotate` | Entorno mínimo, PATH, usuario, shell, horario, DST y logs; dry run/force según herramienta. |
| <a id="lin-c046"></a>LIN-C046 | Hora y locales | `date`, `timedatectl`, `localectl`, `locale`, `localedef`, `chronyc`, `hwclock` | Zona, NTP, reloj hardware, sincronización, formato y locales instalados. |
| <a id="lin-c047"></a>LIN-C047 | Debian/Ubuntu paquetes | `apt`, `apt-get`, `apt-cache`, `dpkg`, `dpkg-query`, `dpkg-deb`, `dpkg-reconfigure` | update/upgrade/full-upgrade/install/remove/purge/autoremove/search/show/policy; archivos, dependencias, estado y scripts. |
| <a id="lin-c048"></a>LIN-C048 | Debian/Ubuntu repositorios | sources.list/.sources, Signed-By/keyrings, `apt-mark`, apt preferences/pinning | Prioridad, hold, origen, firma y estabilidad de apt-get para scripts; métodos obsoletos separados. |
| <a id="lin-c049"></a>LIN-C049 | Arch/Manjaro paquetes | `pacman`, `pacman-key`, `makepkg`, herramientas AUR opcionales | `-S`, `-Ss`, `-Si`, `-Syu`, `-R`, `-Rns`, `-Q`, `-Qi`, `-Ql`, `-Qo`, `-Qk`, `-U`, `-F`; inventariar subopciones por modo y evitar partial upgrades. |
| <a id="lin-c050"></a>LIN-C050 | RHEL/Fedora paquetes | `dnf`, variante/versionado, `rpm`, `subscription-manager` solo donde aplique | search/info/list/install/upgrade/remove/repolist/history/provides/download; rpm query/verify/files; repositorios y suscripción. |
| <a id="lin-c051"></a>LIN-C051 | Canales y build opcionales | `flatpak`, `snap`, AppImage, AUR/PKGBUILD, `make`, `cmake`, `gcc`, `pkg-config` según alcance | Versionado, confianza, aislamiento y catálogo separado por producto; no tratar AUR como repositorio oficial. |
| <a id="lin-c052"></a>LIN-C052 | Hardware y kernel | `lscpu`, `lsmem`, `lsblk`, `lspci`, `lsusb`, `lsmod`, `modinfo`, `modprobe`, `insmod`, `rmmod`, `udevadm`, `dmidecode` | Hardware/driver, parámetros, reglas, firmas y disponibilidad por privilegio. |
| <a id="lin-c053"></a>LIN-C053 | Arranque y initramfs | `bootctl`, herramientas GRUB, `update-initramfs`, `dracut`, `mkinitcpio`, `efibootmgr` según distribución | Inventario por gestor; consulta antes de cambiar EFI/bootloader y recuperación. |
| <a id="lin-c054"></a>LIN-C054 | Red iproute2 consulta | `ip link`, `ip address`, `ip route`, `ip rule`, `ip neigh`, `ip -6`, `ip -br`, `ip -s`, `ip -j` | Link/MTU/estado, prefijo, scope, next hop, métrica, tabla y vecinos. |
| <a id="lin-c055"></a>LIN-C055 | Red iproute2 modificación | `ip link set`, `ip address add/del/flush`, `ip route add/replace/del`, `ip rule add/del`, namespaces | Cambios temporales, namespace, rutas y recuperación de conectividad. |
| <a id="lin-c056"></a>LIN-C056 | Puertos y sockets | `ss`, `lsof`, `fuser`; `ss -lntup`, `-a`, `-s`, `-o`, filtros | Listener frente a conexión, IPv4/IPv6, PID/usuario y wildcard frente a loopback. |
| <a id="lin-c057"></a>LIN-C057 | NetworkManager | `nmcli`, `nmtui`; general/device/connection/networking/radio y propiedades por objeto | Estado, perfiles activos, IP/DNS persistentes, autoconnect y cambio remoto seguro. |
| <a id="lin-c058"></a>LIN-C058 | systemd-networkd y resolved | `networkctl`, `resolvectl`, `.network`, `.netdev`, `.link`, resolved.conf | Gestión real de interfaz, Match/Network/Address/Route/DHCP y DNS dividido; inventariar directivas por versión. |
| <a id="lin-c059"></a>LIN-C059 | Netplan | `get`, `set`, `generate`, `try`, `apply`, `status` según versión; YAML, renderer, routes, nameservers, dhcp4/6 | Generador frente a backend, permisos, sintaxis, rollback temporal y archivos generados. |
| <a id="lin-c060"></a>LIN-C060 | ifupdown y gestores alternativos | `ifup`, `ifdown`, `ifquery`, `/etc/network/interfaces`, dhcpcd y otros solo si instalados | Stanzas/options, hooks y conflictos entre gestores; no editar configuración de uno inactivo. |
| <a id="lin-c061"></a>LIN-C061 | Resolución DNS/NSS | `getent`, `dig`, `host`, `nslookup`, `resolvectl`, `/etc/hosts`, `resolv.conf`, `nsswitch.conf` | Nombre corto/FQDN, búsqueda, tipo de registro, TTL, servidor y caché. |
| <a id="lin-c062"></a>LIN-C062 | Pruebas de red | `ping`, `tracepath`, `traceroute`, `mtr`, `nc`/`ncat`, `curl`, `wget`, `openssl s_client`, `iperf3` según paquetes | Opciones por implementación; ICMP/TCP/UDP, DNS/TLS/HTTP y pruebas de carga autorizadas. |
| <a id="lin-c063"></a>LIN-C063 | Captura | `tcpdump`, `tshark`, `dumpcap`, Wireshark si incluido | Interfaz, BPF/display filter, snaplen, captura/lectura, rotación y datos sensibles. |
| <a id="lin-c064"></a>LIN-C064 | `nft` | `list ruleset`, add/delete/flush por objeto, `-a`, `-n`, `-j`, `-c`, `-f`; families/tables/chains/sets/maps/rules | Hook, prioridad, policy, state, counters, persistencia y validación antes de aplicar. |
| <a id="lin-c065"></a>LIN-C065 | `ufw`, `firewall-cmd` | Ufw status/allow/deny/delete/default/route; firewalld zones/services/ports/rich rules/runtime/permanent | Frontend y backend reales, perfiles y persistencia; no administrar reglas con herramientas competidoras sin control. |
| <a id="lin-c066"></a>LIN-C066 | `iptables`, `ip6tables` | `-L`, `-S`, `-A`, `-I`, `-D`, `-F`, `-P`, `-t`, matches/targets, save/restore | Legacy frente a nft backend, conntrack, IPv6, NAT y persistencia. |
| <a id="lin-c067"></a>LIN-C067 | SSH y servicios de red | Todas las unidades de [SSH](ssh.md); DNS/DHCP/NFS/SMB/web si se incluyen | Inventario por daemon y configuración, clientes, puertos, permisos y logs. |
| <a id="lin-c068"></a>LIN-C068 | Discos consulta | `lsblk`, `blkid`, `fdisk -l`, `parted -l`, `findmnt`, `ls -l /dev/disk/by-*`, `smartctl`/`nvme` si instalados | Dispositivo correcto, UUID, filesystem, montaje, salud y particiones. |
| <a id="lin-c069"></a>LIN-C069 | Particionado y filesystem | `fdisk`, `sfdisk`, `parted`, `gdisk`, `mkfs.*`, `wipefs`, `fsck.*`, `tune2fs`, `resize2fs`, herramientas XFS/Btrfs | Flags por herramienta/filesystem, online/offline y destrucción de metadatos; solo disco virtual de laboratorio. |
| <a id="lin-c070"></a>LIN-C070 | Montaje y persistencia | `mount`, `umount`, `findmnt`, `lsblk`, `fstab`, unidades .mount/.automount | Tipo, UUID, bind, ro/rw, noexec/nosuid/nodev, _netdev, nofail, fsck order y dependencias. |
| <a id="lin-c071"></a>LIN-C071 | LVM y RAID | `pvs/vgs/lvs`, `pvcreate/vgcreate/lvcreate`, extend/reduce/remove, snapshots; `mdadm` | PV/VG/LV, tamaño/filesystem, array, degradación, reconstrucción y compatibilidad de reducción. |
| <a id="lin-c072"></a>LIN-C072 | Swap y cuotas | `swapon`, `swapoff`, `mkswap`, `fallocate`, `dd`, `quota`, `repquota`, `quotacheck`, `edquota`, `setquota` | Tamaño, prioridad, sparse files, límites soft/hard y soporte del filesystem. |
| <a id="lin-c073"></a>LIN-C073 | Cifrado | `cryptsetup`, LUKS header/keyslots, `crypttab`, `lsblk`, `dmsetup` según alcance | Abrir/cerrar, formatos, keyslot y backup de cabecera; no guardar claves en documentación. |
| <a id="lin-c074"></a>LIN-C074 | `rsync` | `-a`, `-v`, `-h`, `-z`, `-P`, `-n`, `-e`, `-A`, `-X`, `-H`, `--numeric-ids`, `--delete`, `--exclude`, `--include`, `--partial`, `--link-dest` | Barra final, ACL/xattrs, enlace duro, SSH, dry-run y borrado de destino. |
| <a id="lin-c075"></a>LIN-C075 | Backups y restauración | `tar`, `cp -a`, `dd`, snapshots; restic/borg solo si elegidos | Consistencia, copia lógica SQL, metadatos, retención, cifrado, restauración y comprobación de integridad. |
| <a id="lin-c076"></a>LIN-C076 | Auditoría y logging | `auditctl`, `ausearch`, `aureport`, auditd, rsyslog/journald, logrotate | Reglas, claves, syscall/path, persistencia, volumen de eventos y evidencia. |
| <a id="lin-c077"></a>LIN-C077 | Certificados y secretos | `openssl`, `gpg`, almacén CA y herramientas por distribución; gestores de secretos opcionales | Llaves, CSR, SAN, cadena, expiración, permisos y rotación sin exponer material privado. |
| <a id="lin-c078"></a>LIN-C078 | Virtualización | `virsh`, `virt-install`, `virt-manager`, `qemu-img` y herramientas del hypervisor si se incluyen | Inventario de comandos/flags por versión; discos, redes, snapshots y acceso al host. |
| <a id="lin-c079"></a>LIN-C079 | Contenedores | Docker/Compose, Podman, namespaces/cgroups; `unshare`, `nsenter` si incluidos | Rootless frente a rootful, redes, volúmenes, permisos y catálogos separados. |
| <a id="lin-c080"></a>LIN-C080 | Recuperación y apagado | `systemctl rescue/emergency/reboot/poweroff`, `shutdown`, `reboot`, `chroot`, medios de rescate | Sesiones, trabajos pendientes, montaje de recuperación y rollback. |
| <a id="lin-c081"></a>LIN-C081 | Catálogo completo del entorno | Coreutils, util-linux, procps-ng, iproute2, shadow-utils, shell, systemd y todos los paquetes declarados | Una ficha por ejecutable/subcomando/opción/argumento/directiva; registrar lo ausente o fuera de alcance con motivo. |

## Casos integradores que deben desarrollarse

- [ ] **LIN-P01.** Identificar distribución/kernel/shell/init y paquetes reales; contrastar la misma operación en Debian, Ubuntu, Arch y RHEL.
- [ ] **LIN-P02.** Crear usuarios/grupos y un árbol de departamentos con setgid/sticky/umask; comprobar permisos con sesiones reales.
- [ ] **LIN-P03.** Aplicar ACL access/default, modificar la máscara y mostrar el permiso efectivo; guardar/restaurar ACL y xattrs.
- [ ] **LIN-P04.** Consultar procesos, relacionar listener con PID/unidad, cambiar prioridad y demostrar TERM frente a KILL.
- [ ] **LIN-P05.** Crear un servicio con cuenta dedicada, drop-in y límites; detenerlo, diagnosticar fallo y retirar la unidad.
- [ ] **LIN-P06.** Programar el mismo trabajo con cron y systemd timer; interpretar entorno, logs y ejecución perdida.
- [ ] **LIN-P07.** Detectar el gestor real de red antes de configurar IP/DNS; probar cambio temporal, persistencia y recuperación.
- [ ] **LIN-P08.** Construir reglas de firewall en VM con consola y verificar accesos permitidos/denegados en IPv4 e IPv6.
- [ ] **LIN-P09.** Añadir disco virtual, particionar/montar, gestionar LVM y recuperar un fstab erróneo desde rescate.
- [ ] **LIN-P10.** Diagnosticar disco lleno por bytes, por inodos y por archivo abierto borrado; conservar evidencia.
- [ ] **LIN-P11.** Sincronizar con rsync preservando metadatos, revisar --dry-run y restaurar una copia en un destino limpio.
- [ ] **LIN-P12.** Resolver una denegación SELinux/AppArmor con ajuste mínimo y persistente sin desactivar el control.
- [ ] **LIN-P13.** Reconciliar catálogos por paquete y versión, desglosar todas sus opciones y documentar diferencias sin extrapolar entre distribuciones.

## Captura de catálogo para el cierre

Ejecutar consultas en cada entorno elegido y guardar las versiones junto a la ayuda de sus paquetes. Estos bloques son alternativas por familia, no una receta que instale herramientas:

```sh
cat /etc/os-release
uname -r
command -v bash systemctl nmcli networkctl netplan ifquery
```

```sh
# Debian/Ubuntu: paquetes realmente instalados
dpkg-query -W -f='${binary:Package}	${Version}
'
```

```sh
# Arch/Manjaro: inventario y archivos de un paquete
pacman -Q
pacman -Ql coreutils
```

```sh
# RHEL/Fedora y derivadas
rpm -qa --qf '%{NAME}	%{VERSION}-%{RELEASE}
'
```

En Bash, `help` inventaría los built-ins y `compgen -c` ayuda a descubrir nombres resolubles; este último también puede incluir aliases, funciones y duplicados. No sustituye el listado de archivos del paquete ni los índices de manuales. Recoger `--help` y la página man de **cada** herramienta del alcance; comparar opciones sin confundir variantes GNU con BusyBox/BSD. Las consultas de catálogo no prueban los procedimientos de administración.

## Materiales derivados y relaciones

Los materiales nuevos siguen pendientes. Registrar sus enlaces reales y los IDs cubiertos en la ficha de cada unidad; una mención en este guion no acredita que un recurso existente cubra todas sus variantes.

| Formato | Contenido que debe extraerse | Estado |
| --- | --- | --- |
| Guía divulgativa | Modelo mental, conceptos y decisiones de uso. | Pendiente |
| Guía técnica | Sintaxis completa por versión, configuración y laboratorios. | Pendiente |
| Cheatsheet Markdown | Consultas y operaciones con interpretación de salida. | Pendiente |
| Cheatsheet visual | Relaciones, flujos y decisiones; enlazar al detalle técnico. | Pendiente |
| Referencia | Fichas de todas las opciones, argumentos y casos inventariados. | Pendiente |

### Recursos existentes o guiones relacionados

- [Chuletas de Sistemas Operativos](../../Sistemas%20Operativos/chuletas/README.md).
- [Runbooks](../../Sistemas%20Operativos/runbooks/README.md) y [plantillas existentes](../../Sistemas%20Operativos/plantillas/README.md).
- [SSH](ssh.md), [Windows](windows.md), [Compose](comun-compose.md), [LAMP](lampp.md) y [LEMP](lempp.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [GNU manuals](https://www.gnu.org/manual/manual.html)
- [Linux man-pages project](https://www.kernel.org/doc/man-pages/)
- [systemd manual index](https://www.freedesktop.org/software/systemd/man/latest/)
- [Debian documentation](https://www.debian.org/doc/)
- [Ubuntu Server documentation](https://documentation.ubuntu.com/server/)
- [Arch package manual pages](https://man.archlinux.org/)
- [RHEL documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10)
- [Netplan documentation](https://netplan.readthedocs.io/)
- [NetworkManager documentation](https://networkmanager.dev/docs/)
- [Bash manual](https://www.gnu.org/software/bash/manual/)
