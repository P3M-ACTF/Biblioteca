# Chuleta: paquetes (apt y dnf)

Comandos de consulta, búsqueda, instalación y actualización en Debian/Ubuntu (`apt`) y RHEL/Fedora (`dnf`).

---

## 1. Equivalencias rápidas

| Acción | **apt** (Debian/Ubuntu) | **dnf** (RHEL/Fedora) |
|--------|-------------------------|------------------------|
| Actualizar índices | `apt update` | `dnf check-update`* |
| Actualizar paquetes | `apt upgrade` | `dnf upgrade` |
| Instalar | `apt install pkg` | `dnf install pkg` |
| Quitar | `apt remove pkg` | `dnf remove pkg` |
| Buscar | `apt search texto` | `dnf search texto` |
| Info | `apt show pkg` | `dnf info pkg` |
| ¿Instalado? | `apt list --installed` | `dnf list installed` |
| Qué archivo | `dpkg -S /ruta` / `apt-file` | `dnf provides /ruta` |
| Limpiar caché | `apt clean` | `dnf clean all` |

\*En dnf, `check-update` consulta; `makecache` refresca metadatos explícitamente.

---

## 2. apt — día a día

```bash
sudo apt update
sudo apt upgrade
sudo apt full-upgrade          # permite cambios de dependencias más amplios
sudo apt install nginx
sudo apt install pacquete=1.2.3
sudo apt remove nginx
sudo apt purge nginx           # quita también configs en /etc (paquete)
sudo apt autoremove            # deps huérfanas

apt search nginx
apt show nginx
apt list --installed | grep nginx
apt policy nginx               # candidate / instalada / orígenes

dpkg -l 'nginx*'
dpkg -L nginx                  # ficheros del paquete
dpkg -S $(which nginx)         # qué paquete posee un binario
```

Historial aproximado: `/var/log/apt/history.log`.

---

## 3. dnf — día a día

```bash
sudo dnf upgrade
sudo dnf install nginx
sudo dnf remove nginx
sudo dnf autoremove

dnf search nginx
dnf info nginx
dnf list installed 'nginx*'
dnf list available nginx
dnf provides /usr/sbin/nginx
dnf repoquery -l nginx         # ficheros (si plugin/repoquery)
dnf history
dnf history info N
```

Módulos (AppStream, cuando aplique):

```bash
dnf module list
dnf module info nombre
```

---

## 4. Consultas útiles

| Pregunta | apt/dpkg | dnf |
|----------|----------|-----|
| ¿Hay actualización? | `apt list --upgradable` | `dnf check-update` |
| Dependencias | `apt depends pkg` | `dnf repoquery --requires pkg` |
| Quién depende de X | `apt rdepends pkg` | `dnf repoquery --whatrequires pkg` |
| Repos habilitados | `apt-cache policy` / ficheros en `sources.list*` | `dnf repolist` |

---

## 5. Buenas prácticas

| Práctica | Motivo |
|----------|--------|
| `update` antes de instalar (apt) | índices frescos |
| Leer qué se va a quitar/instalar | evitar sorpresas en upgrade |
| Preferir paquetes oficiales | suministro y firmas de la distro |
| No mezclar a ciegas PPAs/repos de terceros | conflictos y confianza |
| Anotar cambios en hosts críticos | reproducibilidad |

---

## 6. Checklist

| Objetivo | apt | dnf |
|----------|-----|-----|
| Parchear | `update` + `upgrade` | `upgrade` |
| Instalar | `install` | `install` |
| Buscar | `search` | `search` |
| Detalle | `show` | `info` |
| Limpiar | `autoremove` / `clean` | `autoremove` / `clean all` |

---

*Biblioteca — Sistemas Operativos · paquetes*
