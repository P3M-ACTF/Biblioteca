# Chuleta: compartir carpetas con Samba y NFS

Compartir una carpeta es dejar que otra máquina la use como si fuera suya, y el lío está en que hay **dos** sistemas de permisos que tienen que decir que sí a la vez: el del protocolo (Samba o NFS) y el del sistema de ficheros de debajo (POSIX o NTFS). Cuando uno permite y el otro niega, el resultado es un «acceso denegado» que parece no tener sentido. Esta chuleta explica los dos protocolos, cuándo se usa cada uno y cómo se leen los permisos.

---

## 1. Cuál usar

| Protocolo | Se usa entre | Cómo identifica al usuario |
|-----------|--------------|----------------------------|
| **Samba** (SMB) | Windows y Linux, o Linux y Linux cuando hay Windows de por medio. Es el protocolo nativo de Windows. | Usuario y contraseña, o la cuenta del dominio si el servidor está unido a él. |
| **NFS** | Linux con Linux, sobre todo servidores. | Por la IP del cliente y, con NFSv4 y configuración, por la identidad del usuario. No pide contraseña en su forma habitual: la confianza está en la red. |

Samba es la respuesta cuando algún cliente es Windows. NFS es más simple y más rápido entre servidores Linux de la misma red de confianza. Exponer NFS a una red donde cualquiera puede ponerse la IP que quiera es regalar los datos, porque el control es la propia IP.

---

## 2. Samba

Samba presenta carpetas de Linux como recursos de red de Windows. Tiene dos capas de permiso independientes.

La primera está en el recurso, dentro de `smb.conf`: `read only`, `valid users`, `write list`. Decide quién puede conectar y si puede escribir.

La segunda está en el sistema de ficheros: los permisos POSIX de la carpeta, aplicados con la identidad a la que Samba traduce al usuario. Un usuario puede tener permiso de escritura en el recurso y que el kernel le niegue la escritura porque los ficheros son de otro usuario. Las dos cosas se comprueban.

```text
[facturas]
    path = /srv/facturas
    read only = no
    valid users = @contabilidad
    create mask = 0660
    directory mask = 2770
```

Este recurso solo deja entrar a los miembros del grupo `contabilidad`, les permite escribir, y los ficheros nuevos se crean legibles y escribibles por el grupo (`0660`) de modo que el compañero pueda abrirlos. El `2770` del directorio incluye el bit setgid para que lo creado dentro herede el grupo de la carpeta y no el grupo personal de quien lo crea. Sin ese bit, el primer usuario que crea un fichero deja al resto del grupo sin poder modificarlo.

Los usuarios de Samba necesitan existir para Samba. En un servidor unido al dominio se usan las cuentas del dominio. En un servidor suelto, `smbpasswd -a ana` crea la contraseña de Samba para una cuenta Linux que ya existe: son dos contraseñas distintas, y cambiar una no cambia la otra.

```bash
testparm
sudo smbstatus
ls -ld /srv/facturas
```

### Qué estás viendo

`testparm` lee la configuración y dice si tiene errores de sintaxis, y muestra cómo queda cada recurso con los valores por defecto ya aplicados. Un recurso que no aparece ahí no existe para Samba, aunque tú lo veas en el fichero: puede estar fuera de sección o con un nombre mal escrito.

```text
$ sudo smbstatus
Service      pid  User  Group         Machine
facturas    2210  ana   contabilidad  10.1.10.40
```

ana, desde `10.1.10.40`, tiene abierto el recurso `facturas`. Si ella dice que no puede conectar y aquí no aparece, no ha llegado a autenticarse: usuario, contraseña de Samba o `valid users`. Si aparece y aun así no puede crear ficheros, ya pasó la primera capa y el problema es el permiso POSIX de la carpeta.

Desde el cliente Windows se llega con `\\servidor\facturas`. Desde Linux, `smbclient //servidor/facturas -U ana` es la prueba más limpia, porque no depende del montaje.

---

## 3. NFS

NFS exporta un directorio a una lista de clientes. La configuración está en `/etc/exports` y no se aplica al guardar: hay que recargarla.

```text
/srv/datos  10.1.20.0/24(rw,sync,root_squash,no_subtree_check)
```

Esta línea exporta `/srv/datos` a toda la subred `10.1.20.0/24`, con permiso de escritura. `sync` confirma las escrituras antes de responder, que es lo seguro. `root_squash` convierte a root del cliente en un usuario sin privilegios en el servidor: sin eso, quien tenga root en cualquier máquina de esa subred tendría root sobre los datos exportados. Se deja puesto salvo que haya una razón muy concreta.

```bash
sudo exportfs -rv
sudo exportfs -v
```

`-r` recarga `/etc/exports` y `-v` enseña qué quedó exportado. Es la comprobación de que la línea que escribiste es la que está activa.

En el cliente se monta con `mount -t nfs servidor:/srv/datos /mnt/datos`, y de forma permanente en `/etc/fstab`. La identidad del usuario viaja por su UID numérico en NFSv3: el usuario 1001 del cliente es el usuario 1001 del servidor, aunque se llamen distinto. Por eso en NFS los UID se coordinan (mismo número, mismo nombre, en todos los equipos) o se usa NFSv4 con su mapeo de identidades. No coordinarlos produce ficheros que «son de otro usuario» sin que nadie entienda por qué.

### Qué estás viendo

```text
$ sudo exportfs -v
/srv/datos  10.1.20.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

`rw` y `root_squash` confirman lo que pediste; el resto son valores por defecto que `exportfs` hace explícitos. Si el cliente que intentas montar no está en `10.1.20.0/24`, el servidor lo rechazará aunque el resto sea correcto, y el mensaje del cliente (`access denied`) no dice que sea por la IP.

---

## 4. Las dos capas, juntas

Cuando algo se niega, decide primero cuál de las dos capas habla.

| Prueba | Si funciona | Si falla |
|--------|-------------|----------|
| En el servidor, como el usuario dueño, leer el fichero | El sistema de ficheros está bien para ese usuario. | El problema es POSIX, antes de hablar del protocolo. |
| `smbclient` o `mount` desde el cliente | El protocolo deja pasar. | Autenticación, `valid users`, IP no incluida en la exportación, o cortafuegos (445 para SMB, 2049 para NFS). |
| Conectar sí, escribir no | Pasó la primera capa. | Permiso de escritura del recurso, o permiso POSIX del directorio para la identidad traducida. |

El cortafuegos entra en la lista porque un recurso impecable detrás de un puerto cerrado se ve desde el cliente exactamente igual que un recurso inexistente.

---

## 5. Checklist

| Pregunta | Samba | NFS |
|----------|-------|-----|
| ¿La configuración es válida? | `testparm` | `exportfs -v` |
| ¿Quién está conectado ahora? | `smbstatus` | `ss -tn` al puerto 2049, o el log del servidor |
| ¿El permiso del sistema de ficheros cuadra? | `ls -ld` de la carpeta, con el usuario al que Samba traduce | UID del cliente igual al UID del servidor |
| ¿El cortafuegos deja pasar? | 445/tcp | 2049/tcp y, en NFSv3, los puertos auxiliares |
| ¿root del cliente está neutralizado? | El recurso no fuerza `admin users` | `root_squash` presente |

---

## 6. Error típico

**Situación.** Compartes `/srv/proyectos` por Samba para el grupo `proyectos`. ana entra, crea un fichero y trabaja. Su compañero berto entra, ve el fichero y no puede modificarlo: «acceso denegado». Los dos están en el grupo, lo compruebas en `smbstatus`, y los dos conectan al recurso sin problema.

**Por qué ocurre.** El recurso permite escribir, así que la primera capa está bien: por eso los dos entran. Pero la carpeta no tiene el bit setgid y la máscara de creación deja los ficheros con el grupo personal de ana (`ana:ana`) y permiso `0644`. berto está en el grupo `proyectos`, pero el fichero no pertenece a ese grupo: pertenece al grupo `ana`, donde berto no está. El permiso que le queda es el de «otros», que es solo lectura. Samba está aplicando fielmente lo que el sistema de ficheros dice.

**Cómo se ve.** `ls -l` dentro de la carpeta muestra `-rw-r--r-- ana ana` en lo que crea ana y `-rw-r--r-- berto berto` en lo que crea berto. `ls -ld /srv/proyectos` muestra el grupo `proyectos` en la carpeta pero sin la `s` en el bit de grupo. `smbstatus` confirma que ambos están conectados, lo que descarta autenticación y `valid users`.

**Cómo se arregla.** En la carpeta, `chgrp proyectos` y `chmod 2770`, para que lo nuevo herede el grupo. En `smb.conf`, `create mask = 0660`, `directory mask = 2770` y `force group = proyectos`, que hace que toda escritura se haga con ese grupo aunque el usuario tenga otro como primario. Se recarga Samba y se corrigen los ficheros que ya existían con un `chgrp -R`. A partir de ahí, lo que crea cualquiera del grupo lo puede modificar el resto del grupo, que era la intención desde el principio.

---

Relacionado: [permisos-posix](permisos-posix.md) · [usuarios-grupos-sudo](usuarios-grupos-sudo.md) · [permisos-ntfs](permisos-ntfs.md) · [firewall-linux](firewall-linux.md)

*Biblioteca — Sistemas Operativos · Samba y NFS*
