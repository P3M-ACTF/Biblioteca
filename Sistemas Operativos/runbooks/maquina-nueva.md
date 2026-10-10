# Runbook: máquina nueva (Linux)

Úsalo al recibir un Linux recién instalado, antes de poner nada en producción. El orden está elegido para no quedarte fuera: primero consigues un acceso de administración que no dependa de la contraseña de root, y solo después cierras las puertas que sobran. Cada paso dice qué decisión estás tomando, no solo qué comando toca. El detalle de cada comando está en la chuleta enlazada.

No sustituye al estándar de tu organización. Si hay una imagen corporativa, una política de cuentas o un directorio central, eso gana.

## 1. Anotar qué es esta máquina

**Por qué este paso.** Dentro de un mes nadie recuerda para qué se pidió. El inventario mínimo evita que una máquina quede con la IP que le asignó DHCP el día de la instalación y con acceso de root por contraseña «provisional» para siempre.

| Dato | Por qué hace falta |
|------|--------------------|
| Nombre, IP con su máscara, puerta de enlace y DNS | Sin esto no hay acceso remoto ni resolución de nombres internos. Se configura de forma persistente, no solo en la sesión (chuleta [red-linux-configuracion](../chuletas/red-linux-configuracion.md)). |
| Rol | Qué va a hacer decide qué puertos se abren. Una máquina «por si acaso» acaba con todos abiertos. |
| Quién la administra y cómo se entra si SSH falla | Consola del hipervisor, IPMI, cuenta de emergencia. Decidido ahora, no durante la caída. |

## 2. Cuenta de administración con nombre

**Por qué este paso.** Trabajar como root directamente no deja rastro de quién hizo cada cambio: todo aparece como `root`. Una cuenta personal con sudo deja en el journal quién ejecutó qué, y se puede revocar sin cambiar la contraseña que todos comparten.

1. Crea la cuenta con home y shell: `useradd -m -s /bin/bash` y `passwd`.
2. Métela en el grupo de administración: `sudo` en Debian y Ubuntu, `wheel` en RHEL y derivados. Recuerda que el grupo se aplica en el próximo inicio de sesión, no en el actual.
3. Comprueba con `sudo -l` desde esa cuenta que puede elevar, antes de seguir.

La contraseña de root se guarda en el canal de emergencia y no se usa en el día a día. Chuleta: [usuarios-grupos-sudo](../chuletas/usuarios-grupos-sudo.md). Plantilla: [sudoers.d-ejemplo](../plantillas/sudoers.d-ejemplo).

### Qué estás viendo

```text
$ sudo -l
User ana may run the following commands on web01:
    (ALL : ALL) ALL
```

La cuenta puede elevar. Si `sudo -l` pide contraseña y la rechaza, o dice que el usuario no está en el fichero sudoers, el grupo no se aplicó (sesión antigua) o es el grupo equivocado para esta distribución. No sigas al paso de cerrar el acceso por contraseña hasta que esto funcione.

## 3. SSH por clave

**Por qué este paso.** La contraseña viaja y se puede adivinar; la clave pública no. Pero el orden es estricto: si desactivas el acceso por contraseña antes de haber comprobado que la clave funciona, la próxima conexión no podrá entrar y dependerás de la consola.

1. Genera una clave Ed25519 en tu equipo y copia la pública a `~/.ssh/authorized_keys` de la cuenta de administración (nota [ssh-claves-primer-uso](../notas/ssh-claves-primer-uso.md)).
2. **Desde otra ventana**, entra usando la clave. No cierres la sesión original todavía.
3. Endurece `sshd_config`: `PasswordAuthentication no` cuando la clave ya funcionó, `PermitRootLogin no`, y `AllowUsers` o `AllowGroups` si quieres limitar quién puede entrar.
4. Comprueba la sintaxis con `sshd -t` y recarga con `systemctl reload ssh`. Recargar no corta la sesión abierta; reiniciar tampoco debería, pero recargar basta.

Chuleta: [ssh-admin](../chuletas/ssh-admin.md). Plantilla: [sshd_config.ejemplo](../plantillas/sshd_config.ejemplo).

### Qué estás viendo

```text
$ ssh -v ana@servidor
...
debug1: Offering public key: ED25519 SHA256:abCd...
debug1: Server accepts key: ED25519 SHA256:abCd...
debug1: Authentication succeeded (publickey).
```

`Authentication succeeded (publickey)` es la comprobación. Si el servidor no ofrece `publickey` entre sus métodos, la configuración no se ha recargado o has editado un fichero que sshd no lee. `sshd -T` muestra la configuración efectiva, que es la que manda cuando hay varios ficheros en `sshd_config.d`.

## 4. Actualizar

**Por qué este paso.** Una instalación recién hecha puede llevar meses de parches atrasados si la imagen es antigua. Se actualiza antes de abrir servicios, no después de que lleve una semana en producción.

Actualiza el índice e instala los parches (chuleta [paquetes](../chuletas/paquetes.md)) y comprueba si hace falta reiniciar: un kernel nuevo no entra en uso hasta el reinicio, y `reboot` es mejor ahora que con el servicio ya montado. Decide cómo se van a aplicar los siguientes: a mano con cadencia fija, o de forma automática para los de seguridad. Cualquiera de las dos vale; no decidir es lo que deja la máquina sin parches.

## 5. Cortafuegos

**Por qué este paso.** El rol de la máquina dice qué puertos necesitan estar abiertos, y todo lo demás sobra. Hacerlo ahora, con la lista corta, es más fácil que recortarla dentro de seis meses cuando nadie se acuerda de qué se abrió y para qué.

1. Identifica qué frontal usa la distribución (firewalld, ufw o nftables) y usa solo ese.
2. Política de entrada restrictiva: solo los puertos del rol, y SSH limitado a la red de administración cuando sea posible.
3. Comprueba desde fuera que entra lo que debe y no entra lo demás, y anota las excepciones con su motivo.

Chuleta: [firewall-linux](../chuletas/firewall-linux.md). Plantilla: [nftables-base.nft](../plantillas/nftables-base.nft). Contexto: [bastionado-linux](../../Ciberseguridad/chuletas/bastionado-linux.md).

### Qué estás viendo

```text
$ ss -tulpn
Netid  State   Local Address:Port  Process
tcp    LISTEN  0.0.0.0:22          users:(("sshd",pid=900,fd=3))
tcp    LISTEN  127.0.0.1:5432      users:(("postgres",pid=1100,fd=5))
```

`sshd` en todas las interfaces es lo esperado si el cortafuegos limita el origen. `postgres` escuchando solo en `127.0.0.1` es lo correcto para una base de datos que solo usa la aplicación local: aunque el cortafuegos fallara, no habría nada escuchando fuera. Cualquier línea `LISTEN` en `0.0.0.0` con un puerto que no sea del rol es algo que sobra.

## 6. Lo mínimo para poder operarla

**Por qué este paso.** Una máquina sin hora sincronizada genera registros que no se pueden correlacionar y certificados que parecen caducados. Una máquina sin copias se pierde entera el día del fallo.

| Elemento | Qué comprobar |
|----------|----------------|
| Hora | `timedatectl` muestra `System clock synchronized: yes` y la zona horaria correcta. Nota: [hora-ntp-chrony](../notas/hora-ntp-chrony.md). |
| Registros | Sabes dónde mirar: `journalctl` y `/var/log`. Si el journal no es persistente, lo será en el próximo reinicio. |
| Copias | Decidido qué se copia, con qué frecuencia y dónde. Aunque la decisión sea «esta máquina no lleva datos y se reinstala», que esté escrita. Chuleta: [copias-seguridad](../../Ciberseguridad/chuletas/copias-seguridad.md). |

## 7. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| Entras por clave desde otra máquina | Lo probaste en una sesión nueva, no en la que usaste para configurarlo. La sesión original se cierra la última. |
| Solo escucha lo previsto | `ss -tulpn` coincide con el rol, y el cortafuegos rechaza el resto. Lo comprobaste desde fuera, no solo mirando la configuración. |
| No quedan credenciales de cortesía | La contraseña inicial del proveedor, la clave que venía en la imagen y cualquier cuenta `temp` están cambiadas o eliminadas. Son la puerta que todo el mundo olvida. |
| Alguien más podría operarla | El inventario del paso 1 está en el sitio donde el equipo guarda esas cosas, no en tu cabeza. |

---

*Biblioteca — runbook · máquina nueva*
