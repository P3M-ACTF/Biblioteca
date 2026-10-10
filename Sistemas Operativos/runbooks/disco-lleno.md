# Runbook: disco lleno

Úsalo cuando una aplicación falla con «no space left on device», cuando `df` muestra un sistema de ficheros por encima del 90 %, o cuando un servicio no arranca y el journal menciona espacio. El orden importa: primero se confirma **qué** está lleno, luego **quién** lo llena, y solo al final se borra algo. Borrar a ciegas en `/` es la forma más rápida de convertir un disco lleno en un sistema que no arranca.

## 1. Confirmar qué está lleno

**Por qué este paso.** «El disco está lleno» puede significar tres cosas distintas, y el remedio no es el mismo: el sistema de ficheros de datos no tiene bloques libres, se han agotado los **inodos** (hay sitio pero no se pueden crear ficheros), o el que está lleno es un sistema de ficheros distinto del que crees (`/var` separado de `/`). Medir antes de borrar evita limpiar `/tmp` cuando el problema está en `/home`.

```bash
df -hT
df -hi
findmnt
```

### Qué estás viendo

```text
$ df -hT
S.ficheros     Tipo  Tamaño Usados  Disp Uso% Montado en
/dev/sda2      ext4    30G    28G   400M  99% /
/dev/sda1      vfat   511M    6,1M  505M   2% /boot/efi
/dev/sdb1      ext4   100G    40G    55G  43% /srv

$ df -hi
S.ficheros     Inodos IUsados ILibres IUso% Montado en
/dev/sda2        1,9M   214mil   1,7M   12% /
```

`Uso%` del 99 % en `/` con 400 MB libres es el problema, y está en la raíz, no en `/srv`. El tipo `ext4` dice qué herramientas valen después. La tabla de inodos al 12 % descarta la otra causa: aquí faltan bloques, no inodos. Si `IUso%` estuviera al 100 % con espacio libre de sobra, borrar ficheros grandes no ayudaría: habría que borrar **cantidad** de ficheros (correo en cola, cachés de millones de piezas pequeñas, sesiones PHP).

`findmnt` confirma qué hay montado encima. Si `/var` es un sistema de ficheros aparte, limpiar `/home` no le quita ni un byte.

Anota el punto de montaje y el dispositivo antes de seguir. Chuletas: [fhs-montajes](../chuletas/fhs-montajes.md) y [disco-lvm](../chuletas/disco-lvm.md).

## 2. Encontrar quién ocupa el espacio

**Por qué este paso.** El espacio lo ocupa un directorio concreto, y casi siempre se adivina mal. `du` suma de verdad lo que hay en disco; se hace por niveles para no esperar diez minutos una suma recursiva completa.

```bash
sudo du -xh --max-depth=1 / 2>/dev/null | sort -h
sudo du -xh --max-depth=1 /var 2>/dev/null | sort -h
```

`-x` no cruza a otros sistemas de ficheros, así que no cuenta `/srv` dentro de `/`. `sort -h` ordena por tamaño de verdad (`1,2G` después de `800M`).

### Qué estás viendo

```text
$ sudo du -xh --max-depth=1 /var | sort -h
4,0K    /var/local
120M    /var/cache
1,1G    /var/lib
24G     /var/log
25G     /var
```

`/var/log` con 24 GB es la respuesta. Se baja un nivel más (`du -xh --max-depth=1 /var/log`) hasta llegar al fichero. Los sospechosos habituales: `/var/log` sin rotación, `/var/lib/docker` con imágenes viejas, homes con volcados de memoria, copias de seguridad locales que nadie depuró y `/tmp`.

## 3. Si son logs

**Por qué este paso.** Los logs se regeneran: borrar el fichero sin parar lo que escribe, o sin arreglar la rotación, lo devuelve al mismo tamaño en unos días. Primero se mira la rotación; el borrado es el alivio inmediato, no la solución.

```bash
sudo du -sh /var/log/* | sort -h
ls /etc/logrotate.d/
journalctl --disk-usage
```

### Qué estás viendo

```text
$ journalctl --disk-usage
Archived and active journals take up 18.0G in the file system.
```

18 GB de journal es un journal sin límite en un disco pequeño. Si la política de retención lo permite, se recorta con `journalctl --vacuum-size=500M` o `--vacuum-time=14d`, y se deja el límite escrito en `/etc/systemd/journald.conf` (`SystemMaxUse=`) para que no vuelva a crecer. Para un log de texto que creció porque su rotación está mal, se revisa el fichero en `/etc/logrotate.d/` antes de truncar: un `logrotate -d /etc/logrotate.d/miapp` muestra qué haría sin hacerlo.

Si un log crece sin parar, el problema es el servicio que escribe (un error en bucle). Vaciarlo sin mirar el contenido pierde la pista de por qué crecía. Chuleta: [logs-clasicos](../chuletas/logs-clasicos.md) y [systemd-journalctl](../chuletas/systemd-journalctl.md).

## 4. Si `du` y `df` no coinciden

**Por qué este paso.** Un proceso puede tener abierto un fichero que ya se borró. El nombre desaparece del directorio, `du` deja de contarlo, pero el espacio no se libera hasta que el proceso cierre el descriptor. El síntoma es exactamente este: borras un log de 10 GB, `du` baja 10 GB y `df` no se mueve.

```bash
sudo lsof +L1
```

### Qué estás viendo

```text
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NLINK NAME
java     2210 app    4w   REG  8,2   10737418240  0   /var/log/app.log (deleted)
```

`NLINK 0` y `(deleted)` dicen que el fichero ya no tiene nombre. `SIZE/OFF` de diez mil millones de bytes es el espacio retenido. El proceso es `java` con PID 2210. El espacio vuelve cuando ese proceso cierre el fichero: reiniciar o recargar el servicio, no matarlo a lo bruto si se puede evitar. Borrar más cosas mientras tanto no arregla esta causa.

## 5. Cachés que se pueden tirar

**Por qué este paso.** Algunas ocupaciones son reconstrucciones baratas: la caché de paquetes, las imágenes de contenedor que ya no usa ningún contenedor, las sesiones viejas. Se limpian con la herramienta del propio sistema, que sabe qué es seguro, en lugar de borrar directorios a mano.

La caché de paquetes se limpia con `apt clean` o `dnf clean all` (chuleta [paquetes](../chuletas/paquetes.md)). Las imágenes y volúmenes de Docker o Podman que nadie usa se listan antes de borrar (`docker system df` muestra cuánto hay) y se quitan con sus propios comandos de limpieza, nunca borrando `/var/lib/docker` entero: ahí están también los contenedores que sí se usan.

## 6. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| Hay espacio para operar | `df` por debajo del umbral que usa tu monitorización, con margen para el crecimiento de un día normal. Liberar 200 MB en un disco que crece 2 GB al día no es cerrar: es aplazar una hora. |
| La causa está escrita | Una frase: «journal sin límite», «volcado de la aplicación en /var/crash», «copias locales con retención infinita». Sin esa frase, el siguiente aviso será dentro de un mes por lo mismo. |
| La causa no se repite | El límite quedó configurado (journald, logrotate, retención de copias), no solo ejecutado una vez. |
| Si hace falta disco, está planificado | Ampliar un volumen lógico o un disco se hace con la chuleta delante y con copia previa, no en caliente mientras todo está al 100 % y con prisas. |

---

*Biblioteca — runbook · disco lleno*
