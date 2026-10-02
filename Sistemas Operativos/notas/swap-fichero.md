# Nota: swap en un fichero

Añadir swap sin reparticionar. Sirve cuando `free -h` muestra la swap a cero o se queda corta. Mira antes qué hay:

```bash
swapon --show
free -h
```

Entorno: Linux con el fichero en un sistema de ficheros que admita swap (ext4 es el caso directo). El ejemplo usa 2 GiB; elige el tamaño según la RAM. Para hibernar, el swap tiene que cubrir la RAM.

## Crear y activar

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

`chmod 600` antes de `swapon`: el kernel rechaza un swap legible por otros usuarios.

Si `swapon` dice que el fichero tiene agujeros, `fallocate` dejó un sparse. Sustitúyelo por una copia real:

```bash
sudo swapoff /swapfile 2>/dev/null || true
sudo rm -f /swapfile
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## fstab

```fstab
/swapfile  none  swap  sw  0  0
```

```bash
sudo swapon --show
free -h
```

## btrfs

En btrfs el fichero no puede tener copy-on-write ni compresión. Créalo así, en un subvolumen que no entre en las instantáneas:

```bash
sudo truncate -s 0 /swapfile
sudo chattr +C /swapfile
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

`chattr +C` va con el fichero todavía vacío.

## Quitarla

```bash
sudo swapoff /swapfile
sudo rm /swapfile
```

Borra también la línea de `/etc/fstab`.

Montajes y espacio, en la chuleta [FHS y montajes](../chuletas/fhs-montajes.md).

---

*Biblioteca — Sistemas Operativos · swap en fichero*
