# Nota: Guest Additions en una VM Linux (VirtualBox)

Sin Guest Additions la resolución no sigue a la ventana, el portapapeles no se comparte y las [carpetas compartidas](carpetas-compartidas-virtualbox.md) no montan. El módulo se compila contra el kernel que está en marcha: las cabeceras tienen que ser las de `uname -r`.

Entorno: invitado Debian/Ubuntu o Fedora/RHEL sobre VirtualBox. Prueba el instalador de la ISO del anfitrión, que coincide con la versión de VirtualBox que abre la VM.

> [!NOTE]
> Si el invitado ya tiene `virtualbox-guest-dkms`, `virtualbox-guest-utils` o `virtualbox-guest-x11` de la distro, quítalos antes. Esos paquetes se construyen para el VirtualBox de la distro y chocan con el instalador de la ISO.

## 1. Compilador, DKMS y cabeceras

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r)
```

Fedora/RHEL (en RHEL, `dkms` suele estar en EPEL):

```bash
sudo dnf install gcc make perl elfutils-libelf-devel dkms kernel-headers kernel-devel
sudo dnf install "kernel-devel-uname-r == $(uname -r)"
```

Comprueba que el árbol de cabeceras de ese kernel existe.

Debian/Ubuntu:

```bash
uname -r
ls /usr/src/linux-headers-$(uname -r)
```

Fedora/RHEL:

```bash
uname -r
ls /usr/src/kernels/$(uname -r)
```

Si el paquete de cabeceras no existe para ese kernel, actualiza (`apt full-upgrade` o `dnf upgrade`), reinicia con el kernel nuevo e instala las cabeceras de ese `uname -r`.

## 2. Instalar desde la ISO

En la ventana de la VM: **Dispositivos → Insertar imagen de CD de las Guest Additions**.

```bash
sudo mkdir -p /mnt/cdrom
sudo mount /dev/sr0 /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
sudo reboot
```

Si `/dev/sr0` no aparece, prueba `/dev/cdrom`. El instalador registra los módulos en DKMS para que se recompilen al cambiar de kernel.

## 3. Comprobar

```bash
lsmod | grep -E 'vboxguest|vboxsf|vboxvideo'
systemctl status vboxadd-service || systemctl status vboxadd
```

`vboxguest` cargado y el servicio activo. Al redimensionar la ventana, el escritorio debería seguirla.

## Si falla

| Síntoma | Qué revisar |
|---------|-------------|
| `Kernel headers not found` | El paquete de cabeceras no coincide con `uname -r` (paso 1) |
| El módulo no carga y la VM tiene Secure Boot | En la config de la VM, Sistema → placa base, desactiva Secure Boot y vuelve a ejecutar el instalador. En un laboratorio es lo práctico; firmar el módulo es el camino si Secure Boot tiene que seguir activo |
| Tras un `upgrade` del kernel la pantalla se queda pequeña | Arranca el kernel nuevo y, si DKMS no recompiló, vuelve a lanzar `VBoxLinuxAdditions.run` |
| `lsmod` vacío y el `.run` acabó con error | Lee el final de `/var/log/vboxadd-setup.log` |

Siguiente paso habitual: [carpetas compartidas](carpetas-compartidas-virtualbox.md).

---

*Biblioteca — Sistemas Operativos · Guest Additions*
