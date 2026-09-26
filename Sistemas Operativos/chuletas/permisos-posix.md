# Chuleta: permisos POSIX (Linux / Unix)

Referencia rápida de permisos de ficheros y directorios: modo `rwx`, notación octal y simbólica, bits especiales y ACLs POSIX.

---

## 1. Modelo básico: usuario, grupo, otros

Cada objeto tiene:

| Campo | Significado |
|-------|-------------|
| **uid** (propietario) | Usuario dueño |
| **gid** (grupo) | Grupo dueño |
| **modo** | Bits de permiso + bits especiales |

Tres tripletas `rwx`:

```
- rwx r-x r--
  │   │   └── otros (other, o)
  │   └────── grupo (group, g)
  └────────── usuario propietario (user, u)
```

El primer carácter es el **tipo**:

| Carácter | Tipo |
|----------|------|
| `-` | Fichero regular |
| `d` | Directorio |
| `l` | Enlace simbólico |
| `c` / `b` | Dispositivo carácter / bloque |
| `p` / `s` | FIFO / socket |
| `s` en bit x | setuid/setgid (ver §3) |
| `t` en bit x de otros | sticky (ver §3) |

---

## 2. Significado de r, w, x

### En ficheros

| Bit | Efecto |
|-----|--------|
| **r** | Leer contenido |
| **w** | Modificar / truncar contenido |
| **x** | Ejecutar (binario o script con shebang) |

### En directorios

| Bit | Efecto |
|-----|--------|
| **r** | Listar nombres de entradas (`ls`) |
| **w** | Crear / borrar / renombrar entradas **dentro** (hace falta también `x`) |
| **x** | Atravesar: `cd`, resolver rutas (`dir/fichero`) |

Sin `x` en un directorio no puedes usar nada de su interior aunque tengas `r`/`w` en los ficheros hijos.

---

## 3. Notación octal

Cada tripleta = un dígito 0–7:

| Octal | Binario | Simbólico |
|-------|---------|-----------|
| `0` | 000 | `---` |
| `1` | 001 | `--x` |
| `2` | 010 | `-w-` |
| `3` | 011 | `-wx` |
| `4` | 100 | `r--` |
| `5` | 101 | `r-x` |
| `6` | 110 | `rw-` |
| `7` | 111 | `rwx` |

Formato completo: `0special UGO` → p. ej. `0755`, `0644`, `4755`.

### Valores habituales

| Octal | Uso típico |
|-------|------------|
| `644` / `0644` | Fichero: dueño rw, resto r (`rw-r--r--`) |
| `755` / `0755` | Ejecutable o directorio público (`rwxr-xr-x`) |
| `700` | Solo dueño (`rwx------`) |
| `600` | Secretos / claves (`rw-------`) |
| `750` | Directorio de grupo (`rwxr-x---`) |
| `711` | Directorio “ciego”: entrar sin listar (`rwx--x--x`) |

```bash
chmod 644 archivo.txt
chmod 755 script.sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
```

---

## 4. Notación simbólica (`chmod`)

```
chmod [referencias][operador][permisos] archivo...
```

| Referencia | Quién |
|------------|-------|
| `u` | user (propietario) |
| `g` | group |
| `o` | other |
| `a` | all (`ugo`) |
| *(vacío)* | como `a`, respetando `umask` |

| Operador | Acción |
|----------|--------|
| `+` | Añadir |
| `-` | Quitar |
| `=` | Asignar exactamente (los no citados se quitan en esa referencia) |

| Permiso | Bit |
|---------|-----|
| `r` `w` `x` | lectura / escritura / ejecución |
| `s` | setuid o setgid (según `u`/`g`) |
| `t` | sticky (`o+t`) |
| `X` | `x` solo si ya es ejecutable o es directorio |

### Ejemplos

```bash
chmod u+x script.sh          # dueño: ejecutar
chmod go-w archivo           # quitar escritura a grupo y otros
chmod a=r,u+w fichero        # todos leen; dueño también escribe → rw-r--r--
chmod g+w,o-rwx dir/         # grupo escribe; otros nada
chmod -R u=rwX,go=rX proyecto/   # recursivo; X inteligente en dirs
```

---

## 5. Bits especiales: setuid, setgid, sticky

Cuarto dígito octal (miles) o letras `s`/`t`/`S`/`T` en el listado.

| Bit | Octal | Dónde se ve | Efecto en **fichero** | Efecto en **directorio** |
|-----|-------|-------------|------------------------|---------------------------|
| **setuid** | `4xxx` | `u` → `s` (o `S` si no hay `x`) | Proceso corre con UID del **propietario** del binario | (raro / no portable; ignora en muchos sistemas) |
| **setgid** | `2xxx` | `g` → `s`/`S` | Proceso corre con GID del **grupo** del binario | Entradas nuevas heredan el **grupo del directorio** |
| **sticky** | `1xxx` | `o` → `t`/`T` | (histórico; poco usado en ficheros) | Solo el dueño del fichero (o root) puede **borrar/renombrar** dentro |

### Ejemplos clásicos

```bash
# /usr/bin/passwd → setuid root (cambia contraseñas)
ls -l /usr/bin/passwd
# -rwsr-xr-x  …  (4755)

# /tmp → sticky bit
ls -ld /tmp
# drwxrwxrwt  …  (1777)

# Directorio de equipo: setgid para heredar grupo
chmod 2775 /srv/proyecto
chown root:developers /srv/proyecto
# → drwxrwsr-x
```

### Octal con especiales

| Valor | Significado |
|-------|-------------|
| `4755` | setuid + `rwxr-xr-x` |
| `2755` | setgid + `rwxr-xr-x` |
| `1777` | sticky + `rwxrwxrwx` (`/tmp`) |
| `3777` | setgid + sticky |

```bash
chmod u+s binario      # setuid
chmod g+s directorio   # setgid
chmod +t /tmp/compartido
chmod 2775 /var/shared
```

`S` / `T` mayúsculas = bit especial activo **sin** bit `x` en esa posición (configuración anómala o incompleta).

---

## 6. umask

Máscara que se **quita** a los permisos por defecto al crear ficheros/dirs.

| umask | Ficheros (base 666) | Directorios (base 777) |
|-------|---------------------|------------------------|
| `022` | `644` | `755` |
| `002` | `664` | `775` |
| `077` | `600` | `700` |

```bash
umask            # ver actual (octal)
umask 027        # fijar (sesión actual)
```

---

## 7. Propiedad: chown / chgrp

```bash
chown usuario archivo
chown usuario:grupo archivo
chown :grupo archivo          # solo grupo
chgrp grupo archivo
chown -R usuario:grupo dir/   # recursivo (cuidado)
```

Solo root (o CAP_CHOWN) puede cambiar el propietario en la mayoría de sistemas.

---

## 8. ACLs POSIX (`getfacl` / `setfacl`)

Las ACL amplían el modelo u/g/o con entradas por usuario o grupo concretos.

### Ver ACL

```bash
getfacl archivo
getfacl -R dir/          # recursivo
ls -l archivo            # una + al final del modo indica ACL extendida
# -rw-r-----+ …
```

### Entradas típicas

```
user::rwx          # dueño (equivale a u)
user:ana:r-x      # ACL named user
group::r-x        # grupo dueño
group:devs:rwx    # ACL named group
mask::rwx         # techo efectivo para named user/group y group::
other::r--
default:user::rwx # solo en directorios: ACL por defecto (herencia)
```

La **mask** limita el máximo efectivo de entradas `user:`, `group:` y `group::`. Tras `chmod` en un fichero con ACL, la mask suele recalcularse.

### setfacl — ejemplos

```bash
# Dar a ana lectura+ejecución
setfacl -m u:ana:rx archivo

# Dar al grupo devs rw en un directorio
setfacl -m g:devs:rwX dir/

# Quitar entrada concreta
setfacl -x u:ana archivo

# ACL por defecto (herencia para ficheros/dirs nuevos)
setfacl -d -m g:devs:rwX dir/
setfacl -d -m o::--- dir/

# Recursivo
setfacl -R -m u:ana:rX proyecto/

# Copiar ACL de uno a otro
getfacl origen | setfacl --set-file=- destino

# Eliminar todas las ACL extendidas
setfacl -b archivo
setfacl -R -b dir/
```

### Efectivo vs nominal

```bash
getfacl -e archivo   # muestra #effective: cuando mask recorta
```

---

## 9. Comandos de inspección rápida

```bash
ls -l archivo
ls -ld dir
stat archivo
stat -c '%a %A %U %G %n' archivo     # GNU: octal, simbólico, dueño, grupo
namei -l /ruta/profunda               # permisos de cada componente
id                                    # uid, gid, grupos
getfacl -p archivo                    # sin cabecera de ruta absoluta
```

Alias útil (ver [`../shell/`](../shell/)): `perms` → `stat -c '%a %A %n'`.

---

## 10. Checklist operativo

| Objetivo | Acción |
|----------|--------|
| Script ejecutable solo por ti | `chmod 700 script.sh` |
| Clave privada SSH | `chmod 600 ~/.ssh/id_*` ; `chmod 700 ~/.ssh` |
| Directorio de equipo con grupo común | `chown :devs dir && chmod 2775 dir` |
| Compartido tipo /tmp | `chmod 1777 dir` |
| Excepción para un usuario | `setfacl -m u:persona:rwX ruta` |
| Auditar | `getfacl -R .` / `find . -perm -4000` (setuid) |

### find útil

```bash
find / -perm -4000 -type f 2>/dev/null    # setuid
find / -perm -2000 -type f 2>/dev/null    # setgid
find / -perm -1000 -type d 2>/dev/null    # sticky
find . -perm -o+w -type f                 # escribibles por otros
```

---

## 11. Tabla resumen octal ↔ simbólico

| Octal | Simbólico | Notas |
|-------|-----------|-------|
| `644` | `rw-r--r--` | Fichero normal |
| `664` | `rw-rw-r--` | Colaborativo |
| `600` | `rw-------` | Privado |
| `755` | `rwxr-xr-x` | Binario / dir público |
| `750` | `rwxr-x---` | Grupo puede entrar |
| `700` | `rwx------` | Solo dueño |
| `4755` | `rwsr-xr-x` | setuid |
| `2755` | `rwxr-sr-x` | setgid |
| `1777` | `rwxrwxrwt` | sticky |

---

*Biblioteca — Sistemas Operativos · permisos POSIX*
