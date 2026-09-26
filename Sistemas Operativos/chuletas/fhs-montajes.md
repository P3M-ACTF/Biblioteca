# Chuleta: FHS, montajes y espacio en disco

Referencia rápida de la jerarquía FHS, montajes (`mount`/`findmnt`) y consulta de espacio (`df`/`du`/`lsblk`).

---

## 1. FHS — directorios clave

| Ruta | Contenido típico |
|------|------------------|
| `/` | Raíz del sistema de ficheros |
| `/bin`, `/sbin` | Binarios esenciales (a menudo enlazados a `/usr`) |
| `/usr` | Programas y datos de solo lectura de usuario |
| `/usr/local` | Software instalado localmente (admin) |
| `/etc` | Configuración del sistema |
| `/var` | Datos variables: logs, spools, cachés |
| `/var/log` | Registros |
| `/tmp` | Temporal (suele limpiarse; sticky bit) |
| `/home` | Homes de usuarios |
| `/root` | Home de root |
| `/opt` | Paquetes opcionales / de terceros |
| `/srv` | Datos de servicios (www, ftp…) |
| `/proc`, `/sys` | Pseudo-FS: kernel y dispositivos |
| `/dev` | Nodos de dispositivo |
| `/boot` | Kernel, initramfs, bootloader |
| `/mnt`, `/media` | Montajes temporales / medios extraíbles |
| `/run` | Datos de runtime (PID files, sockets) |

Regla mental: **config en `/etc`**, **logs en `/var/log`**, **datos de servicio en `/srv` o `/var`**, **software local en `/usr/local` o `/opt`**.

---

## 2. Ver discos y particiones: lsblk

```bash
lsblk
lsblk -f                 # FS, UUID, labels
lsblk -o NAME,SIZE,FSTYPE,UUID,MOUNTPOINTS
```

| Campo | Significado |
|-------|-------------|
| NAME | Dispositivo (`sda`, `nvme0n1p2`…) |
| FSTYPE | Tipo de sistema de ficheros |
| UUID | Identificador estable (preferible en fstab) |
| MOUNTPOINTS | Dónde está montado |

---

## 3. Montajes: findmnt, mount, fstab

```bash
findmnt                  # árbol de montajes (preferido)
findmnt /home
findmnt -t ext4,xfs,btrfs
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS

mount                    # listado clásico
mount /dev/sdb1 /mnt/data
mount -a                 # montar todo lo de fstab
umount /mnt/data
umount -l /mnt/data      # lazy unmount
```

`/etc/fstab` (columnas):

```
UUID=…  /home  ext4  defaults  0  2
```

| Campo | Rol |
|-------|-----|
| dispositivo | UUID= / LABEL= / ruta |
| punto de montaje | path absoluto |
| tipo | ext4, xfs, vfat… |
| opciones | `defaults`, `noatime`, `nofail`… |
| dump | suele `0` |
| pass | orden fsck (`1` raíz, `2` resto, `0` no) |

```bash
findmnt --verify         # comprobar fstab (si está disponible)
blkid                    # UUID de dispositivos
```

---

## 4. Espacio: df y du

```bash
df -h                    # por sistema de ficheros (legible)
df -hT                   # con tipo
df -h /var

du -sh /var/log/*        # tamaño de cada entrada
du -h --max-depth=1 /var | sort -h
du -sh *                 # cwd
```

| Herramienta | Pregunta que responde |
|-------------|----------------------|
| `df` | ¿Cuánto queda en cada **montaje**? |
| `du` | ¿Qué **directorios/ficheros** ocupan? |
| `lsblk` | ¿Qué **dispositivos** hay y dónde montan? |

Si `df` y `du` no cuadran: ficheros borrados aún abiertos por un proceso → `lsof +L1` o reiniciar el servicio que los tiene abiertos.

---

## 5. Opciones de montaje frecuentes

| Opción | Efecto |
|--------|--------|
| `defaults` | rw, suid, dev, exec, auto, nouser, async |
| `noatime` | menos escrituras de atime |
| `nofail` | no abortar el boot si falla el montaje |
| `ro` | solo lectura |
| `nosuid` / `noexec` | endurecer montajes de datos |
| `bind` | remontar un path en otro (`mount --bind`) |

---

## 6. Checklist

| Objetivo | Comando |
|----------|---------|
| Ver qué hay montado | `findmnt` |
| Ver discos | `lsblk -f` |
| Espacio libre | `df -hT` |
| Quién ocupa | `du -h --max-depth=1 … \| sort -h` |
| UUID para fstab | `blkid` / `lsblk -f` |

---

*Biblioteca — Sistemas Operativos · FHS / montajes*
