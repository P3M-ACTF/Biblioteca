# Chuleta: discos, particiones y LVM

Vista de dispositivos (`lsblk`), nociones de particionado y capas LVM (PV → VG → LV). Referencia de lectura; **sin recetas destructivas paso a paso**.

---

## 1. Capas mentales

```
Disco (sdX / nvme…) → particiones → [opcional LVM] → sistema de ficheros → montaje
```

| Capa | Herramientas de consulta |
|------|--------------------------|
| Dispositivo | `lsblk`, `ls -l /dev/disk/by-*` |
| Particiones | `lsblk`, `parted -l` (solo lectura) |
| LVM | `pvs`, `vgs`, `lvs` |
| FS / UUID | `lsblk -f`, `blkid`, `findmnt` |

---

## 2. lsblk — primer vistazo

```bash
lsblk
lsblk -f
lsblk -o NAME,SIZE,TYPE,FSTYPE,UUID,MOUNTPOINTS
```

| TYPE | Significado |
|------|-------------|
| `disk` | Disco completo |
| `part` | Partición |
| `lvm` | Volumen lógico |
| `rom` / `loop` | Óptico / loopback |

Identificadores estables: `/dev/disk/by-uuid/`, `by-label/`, `by-id/` (preferibles a `sdX` que puede cambiar).

---

## 3. Particiones (nivel chuleta)

| Concepto | Notas |
|----------|-------|
| **GPT** | Tabla moderna; habitual hoy |
| **MBR** | Legado; límite de 4 primarias clásicas |
| EFI vs BIOS | `/boot/efi` (ESP) en arranque UEFI |
| Tipos | Linux filesystem, Linux LVM, EFI System, swap… |

Consulta (sin modificar):

```bash
sudo parted -l
sudo fdisk -l                 # listar; evitar modos interactivos de escritura
cat /proc/partitions
```

Cualquier operación de **escritura** de tabla (crear/borrar particiones) es sensible: puede destruir datos. En producción, snapshots/backups y ventana de mantenimiento.

---

## 4. LVM — piezas

| Objeto | Nombre | Rol |
|--------|--------|-----|
| **PV** | Physical Volume | Disco o partición aportada a LVM |
| **VG** | Volume Group | Pool que agrupa PVs |
| **LV** | Logical Volume | “Disco virtual” sobre el VG; aquí formateas/montas |

```bash
sudo pvs          # physical volumes
sudo vgs          # volume groups
sudo lvs          # logical volumes
sudo pvdisplay
sudo vgdisplay
sudo lvdisplay
```

Flujo conceptual (solo vocabulario):

1. Marcar dispositivo como PV.
2. Crear o extender un VG con ese PV.
3. Crear LV con tamaño dentro del VG libre.
4. Crear FS en el LV y montarlo (fstab por UUID).

Extender un LV/FS y reducir son operaciones distintas (reducir es más delicado). Documenta el procedimiento de tu distro antes de tocar producción.

---

## 5. Relación con montajes y espacio

```bash
findmnt
df -hT
sudo lvs -o name,vg_name,lv_size,data_percent
```

| Síntoma | Mirar |
|---------|-------|
| Disco lleno | `df`, `du`; ¿VG sin espacio libre (`vgs`)? |
| LV no montado | `lsblk`, fstab, `findmnt --verify` |
| Disco nuevo no usado | ¿partición? ¿PV? ¿añadido al VG? |

---

## 6. Swap (breve)

```bash
swapon --show
free -h
cat /proc/swaps
```

Swap puede ser partición, fichero o LV. No es backup ni “RAM extra” mágica: es desbordamiento a disco.

---

## 7. Checklist seguro

| Objetivo | Acción de **consulta** |
|----------|------------------------|
| ¿Qué hay? | `lsblk -f` |
| ¿Hay LVM? | `pvs && vgs && lvs` |
| ¿Qué está montado? | `findmnt` / `df -hT` |
| UUID para fstab | `blkid` / `lsblk -f` |
| Cambios de tamaño/partición | plan + backup; no improvisar en caliente |

---

*Biblioteca — Sistemas Operativos · disco / LVM*
