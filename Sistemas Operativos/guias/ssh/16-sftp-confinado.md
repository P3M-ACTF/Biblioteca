# SSH · Cuenta SFTP confinada y restricciones de operación

[Índice](README.md) · [Referencia](17-referencia-sftp-confinado.md) · [Servidor Linux](06-servidor-linux.md)

El objetivo es crear una cuenta de laboratorio que transfiera archivos mediante SFTP dentro de una raíz propia, sin ejecutar una shell/comando remoto ni abrir canales de forwarding. Después se comparan permisos de filesystem, modo de solo lectura y filtros de solicitudes SFTP.

**Referencia documental:** OpenSSH Portable 10.6p1, consulta del 26 de octubre de 2026. **Todas las pruebas de servidor y confinamiento están pendientes de laboratorio Linux.** La inspección local del perfil cliente se registra al final y no acredita chroot, autorización ni permisos efectivos.

## 1. Preparación y límites

Usar B, un servidor Linux de laboratorio con consola y acceso administrativo ya verificado, y C como cliente. Los datos ficticios son B `192.0.2.10:2222` y la cuenta nueva `sftp_lab`. Sustituir IP/puerto por los reales; no modificar la escucha para adaptarse a la guía.

Trabajar sobre un candidato conforme al [bloque de servidor](06-servidor-linux.md), conservando configuración original, recuperación y sesiones identificadas. Esta práctica presupone autenticación de laboratorio por una pública ordinaria; si B exige MFA o usa gestión central de cuentas, preparar un entorno adecuado o adaptar la política deliberadamente, sin relajar esos controles.

El confinamiento de esta cuenta debe aplicarse **en todos sus orígenes de conexión**. Usar Match User sftp_lab; añadir Address a ese Match sin otra regla de confinamiento podría dejar la cuenta fuera de la jaula al conectar desde otro origen.

| Ruta de B | Propietario/modo previstos | Ruta vista por SFTP |
| --- | --- | --- |
| /srv/sftp-lab/sftp_lab | root:root, 0755 y ancestros seguros. | / |
| /srv/sftp-lab/sftp_lab/datos | sftp_lab:sftp_lab, 0700. | /datos |
| /etc/ssh/authorized_keys-sftp-lab/sftp_lab | root:root, 0644; directorio 0755. | Se consulta antes del chroot, fuera del área de subida. |
| /srv/sftp-lab/fuera.txt | root:root, 0644, solo dato de prueba. | Queda fuera de la raíz del usuario. |

Chroot cambia la raíz de resolución de rutas del proceso; no equivale a una máquina virtual ni controla por sí solo forwarding, comandos, credenciales, cuotas o accesos locales de la cuenta. No montar dentro datos del host que no se pretendan exponer.

## 2. Crear la cuenta sin crear un home en el host

Comprobar que cuenta, grupo y rutas de laboratorio no existen:

```sh
getent passwd sftp_lab
getent group sftp_lab
ls -ld /srv /srv/sftp-lab /etc/ssh/authorized_keys-sftp-lab
```

**Qué estás viendo.** getent no debe encontrar sftp_lab; las dos rutas nuevas deben estar libres. Un error no encontrado es esperado para ellas, no para /srv. Si existen, detenerse y elegir/revisar un entorno propio; no reutilizar material desconocido. / y /srv deben pertenecer a root y carecer de escritura para grupo/otros.

En una consola administrativa de B:

```sh
sudo useradd -U -M -d /datos -s /bin/sh sftp_lab
id sftp_lab
getent passwd sftp_lab
sudo passwd -S sftp_lab
```

**Qué estás viendo.** -U crea su grupo propio; -M evita crear /datos en el filesystem del host; -d guarda /datos como home que existirá dentro de la jaula. La shell /bin/sh debe existir y ser válida para la política de B; no se copiará dentro porque se utilizará internal-sftp.

Revisar UID/GID, grupos y estado de contraseña sin mostrar hashes. Mantener la cuenta sin credenciales utilizables hasta activar su política. El estado bloqueado y su interacción con claves depende de PAM/sshd; no deducir aceptación solo de passwd -S. La restricción SSH vendrá de ForceCommand, no del nombre de la shell. Esta guía no habilita otros servicios de acceso para la cuenta.

## 3. Crear raíz y área de datos

Solo con los destinos nuevos ya comprobados:

```sh
sudo install -d -o root -g root -m 0755 /srv/sftp-lab /srv/sftp-lab/sftp_lab
sudo install -d -o sftp_lab -g sftp_lab -m 0700 /srv/sftp-lab/sftp_lab/datos
namei -l /srv/sftp-lab/sftp_lab/datos
```

**Qué estás viendo.** Todos los componentes hasta sftp_lab, incluidos / y /srv, son directorios de root sin escritura para grupo/otros. Solo datos pertenece al usuario. No hacer chown -R del árbol al usuario: daría control de la propia raíz y sshd rechazaría el chroot.

Si el entorno utiliza ACL, revisar las de cada componente con la herramienta disponible, por ejemplo:

```sh
getfacl -p / /srv /srv/sftp-lab /srv/sftp-lab/sftp_lab /srv/sftp-lab/sftp_lab/datos
```

**Qué estás viendo.** Buscar entradas nombradas/default que concedan escritura a terceros o alteren herencia. Si getfacl no está disponible, registrar que esa revisión falta; no declarar seguros los permisos solo por ver 0755. Revisar también SELinux/AppArmor y mounts cuando apliquen; no desactivarlos ante un rechazo.

Preparar un marcador inocuo fuera de la jaula y un enlace de prueba hacia él, desde una carpeta administrativa nueva:

```sh
printf 'marcador-fuera-jaula\n' > ./fuera-lab.txt
sudo install -o root -g root -m 0644 ./fuera-lab.txt /srv/sftp-lab/fuera.txt
sudo ln -s /srv/sftp-lab/fuera.txt /srv/sftp-lab/sftp_lab/datos/enlace-fuera
```

**Qué estás viendo.** El target absoluto existe en B pero se resolverá desde / del chroot para la sesión SFTP. El enlace no debe permitir leer el marcador exterior. No usar archivos reales sensibles como sonda. Estos nombres también deben estar libres antes de crearlos.

## 4. Pública fuera de la zona escribible

En C, generar una identidad protegida y dedicada mediante el [procedimiento de claves](04-claves-y-agente.md), con nombre id_sftp_lab. La privada permanece en C. Transferir a la consola administrativa de B solo id_sftp_lab.pub y verificar su huella por el canal previsto.

En B, desde su carpeta de recepción:

```sh
ssh-keygen -l -E sha256 -f ./id_sftp_lab.pub
sudo install -d -o root -g root -m 0755 /etc/ssh/authorized_keys-sftp-lab
sudo install -o root -g root -m 0644 ./id_sftp_lab.pub /etc/ssh/authorized_keys-sftp-lab/sftp_lab
```

**Qué estás viendo.** Es una pública legible y administrada por root, no una privada. La cuenta debe poder leer el archivo durante la autorización y no modificarlo. La ruta absoluta evita depender de ~/.ssh dentro de la jaula y separa autorización de los datos que puede subir el usuario. Mantener StrictModes.

## 5. Integrar la política candidata

Comprobar que B ya tiene un Subsystem llamado sftp. Conservar su definición actual si existe: ForceCommand proporcionará el servidor interno y sus argumentos para esta cuenta. No esperar que los argumentos del Subsystem global se hereden sobre otro ForceCommand.

Si el servidor de laboratorio no tiene ninguno, añadir globalmente una única definición antes de Match:

```sshconfig
Subsystem sftp internal-sftp
```

**Qué estás viendo.** Habilita el nombre de subsistema, no crea chroot ni restringe por sí solo la cuenta. En 10.6p1 Subsystem admite contexto Match según su parser; versiones anteriores pueden diferir. La práctica conserva una definición global compatible y no duplica un nombre ya existente.

Añadir/reconciliar en el candidato:

```sshconfig
Match User sftp_lab
    ChrootDirectory /srv/sftp-lab/%u
    ForceCommand internal-sftp -d /datos -u 0077 -e -l VERBOSE
    AuthorizedKeysFile /etc/ssh/authorized_keys-sftp-lab/%u
    PubkeyAuthentication yes
    AuthenticationMethods publickey
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    DisableForwarding yes
    PermitTTY no
    PermitUserRC no
```

**Qué estás viendo.** ChrootDirectory fija la raíz; -d el directorio inicial **dentro** de ella; -u limita permisos iniciales. ForceCommand limita shell/comando/subsistema, mientras DisableForwarding bloquea canales que no dependen de abrir una sesión. PermitTTY y PermitUserRC explicitan la restricción de PTY y rc.

-e dirige el log de internal-sftp a stderr y -l VERBOSE registra transacciones. Se elige para observar el laboratorio sin añadir un socket /dev/log dentro. Ese log no queda automáticamente en el journal administrativo: se recogerá también en C. Para auditoría central, diseñar la ruta syslog conforme al paquete, sin desactivar controles ni improvisar sockets.

Reconciliar Match anteriores, AllowUsers/AllowGroups, políticas de claves y autenticación. Si hay una lista de acceso, añadir solo la cuenta prevista al candidato conservando las entradas existentes; no borrar la lista para hacer pasar el ensayo. No sustituir una política MFA por este perfil.

## 6. Validar, activar y habilitar la cuenta

Con binario, candidato y datos reales del bloque de servidor:

```sh
sudo "$ssh_server_bin" -t -f /ruta/real/al/candidato
sudo "$ssh_server_bin" -T -f /ruta/real/al/candidato -C user=sftp_lab,addr=192.0.2.20,host=cliente.example,laddr=192.0.2.10,lport=2222
```

**Qué estás viendo.** Confirmar chrootdirectory, forcecommand y todos sus argumentos, authorizedkeysfile, authenticationmethods, disableforwarding, permittty y permituserrc. Repetir para sftp_lab desde otro origen: debe seguir confinado. Repetir para el administrador ajeno: debe mantener su política anterior.

-t/-T no ejecutan la sesión con su UID, no realizan el chroot ni comprueban toda la interacción de filesystem/ACL/PAM. Validar/recargar por el procedimiento recuperable y comprobar que el archivo activo es el candidato esperado.

Solo después de activar y verificar la política SSH de la cuenta, completar su activación según las reglas del laboratorio. Cuando se precise una contraseña válida en la base de cuentas:

```sh
sudo passwd sftp_lab
sudo passwd -S sftp_lab
```

**Qué estás viendo.** Introducir la contraseña interactivamente; no publicarla ni pasarla como argumento. Esto no habilita password authentication por SSH en el Match preparado. No usar passwd -d para resolver una cuenta bloqueada ni desactivar PAM. Si su política de cuenta sigue impidiendo el acceso, investigar esa fase y dejar el ensayo pendiente.

Comprobar una nueva conexión administrativa antes de seguir. Los cambios de configuración se prueban con transportes nuevos, sin multiplexación ni reutilización de una sesión SFTP ya abierta.

## 7. Perfil cliente y operaciones permitidas

En C preparar carpeta de trabajo nueva, prueba.txt con texto ficticio y la identidad id_sftp_lab. La confianza de host se obtiene por el [procedimiento de primera conexión](02-conexion-basica.md), conservándola en known_hosts_sftp_lab. No aceptar huellas desconocidas para resolver un fallo de SFTP.

Guardar ssh-sftp-lab.conf:

```sshconfig
Host sftp-jaula
    HostName 192.0.2.10
    Port 2222
    User sftp_lab
    IdentityFile ./id_sftp_lab
    IdentitiesOnly yes
    IdentityAgent none
    ForwardAgent no
    UserKnownHostsFile ./known_hosts_sftp_lab
    StrictHostKeyChecking yes
    PreferredAuthentications publickey
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    RequestTTY no
    ControlMaster no
    ControlPath none
    ConnectTimeout 5
    ConnectionAttempts 1
```

**Qué estás viendo.** Sustituir datos y mantener el cwd de C para las rutas relativas. Se selecciona una identidad dedicada y no se delega agente. El estado de host checking es independiente del confinamiento y de la autorización del usuario.

```sh
ssh -F ./ssh-sftp-lab.conf -G sftp-jaula
sftp -F ./ssh-sftp-lab.conf sftp-jaula
```

**Qué estás viendo.** -G solo imprime configuración. sftp debe autenticar y arrancar en /datos. Un rechazo de autenticación es distinto de un cierre tras autenticarse por permisos de ChrootDirectory.

En el intérprete SFTP, con nombres nuevos:

```text
pwd
ls -la
put ./prueba.txt /datos/prueba.txt
get /datos/prueba.txt ./descarga.txt
mkdir /datos/carpeta-lab
rename /datos/prueba.txt /datos/renombrada.txt
ls -l /datos
```

**Qué estás viendo.** Deben funcionar navegación, subida/descarga y cambio de nombre en datos para el perfil inicial. Comparar hashes de prueba.txt y descarga.txt como en [transferencias](08-transferencias.md). Los permisos de creación deben corresponder a modo solicitado menos umask/ACL; no prometer 0600 para todo fichero si el cliente preserva o cambia atributos.

En B, revisar solo los archivos de la sonda:

```sh
ls -ld /srv/sftp-lab/sftp_lab /srv/sftp-lab/sftp_lab/datos
ls -l /srv/sftp-lab/sftp_lab/datos
```

**Qué estás viendo.** La raíz sigue administrada por root y el archivo lo crea el UID de la cuenta. -u 0077 influye en nuevas creaciones, no es una prohibición de chmod ni revoca permisos de archivos previos.

## 8. Operaciones que deben fallar

En SFTP:

```text
put ./prueba.txt /no-escribible.txt
cd /datos
cd ../../..
pwd
get /srv/sftp-lab/fuera.txt ./fuera-directo.txt
get /datos/enlace-fuera ./fuera-enlace.txt
```

**Qué estás viendo.** La subida en / debe ser denegada por permisos. cd .. puede **tener éxito sin escapar**: al alcanzar la raíz se mantiene en / del chroot. Los dos get no deben entregar el marcador exterior. Registrar el resultado y comprobar en B que el marcador real no cambió; un simple cd .. exitoso no demuestra escape.

Cerrar SFTP y probar por separado desde C:

```sh
ssh -T -F ./ssh-sftp-lab.conf sftp-jaula id
ssh -tt -F ./ssh-sftp-lab.conf sftp-jaula
```

**Qué estás viendo.** La autenticación puede ser válida, pero el comando/shell no deben ejecutarse. Se espera rechazo de servicio no SFTP y/o de PTY según fase. No considerar una sesión autenticada como fallo del confinamiento sin comprobar qué operación llegó a realizar.

Para forwarding, usar otro transporte nuevo:

```sh
ssh -N -F ./ssh-sftp-lab.conf -o ExitOnForwardFailure=yes -R 127.0.0.1:19010:127.0.0.1:18080 sftp-jaula
```

**Qué estás viendo.** B debe rechazar la solicitud de escucha remota. No hace falta un servicio en C:18080 para comprobar este rechazo inicial. Si inesperadamente se acepta, cerrar ese proceso identificado y registrar fallo; no dejar el listener activo. ForceCommand por sí solo no cubre este caso con -N.

Las órdenes locales del cliente SFTP, como lcd, lls o !comando, se ejecutan en C. Que funcionen no significa que B permita una shell ni que se haya salido de su chroot.

## 9. Comparar solo lectura y filtros

Modificar únicamente ForceCommand en un candidato nuevo, validarlo, recargar y abrir una conexión SFTP nueva en cada variante.

| Variante | ForceCommand alternativo | Ensayo esperado |
| --- | --- | --- |
| Solo lectura | internal-sftp -R -d /datos -u 0077 -e -l VERBOSE | get/ls permitidos; put, rm, mkdir y cambios de atributos rechazados aunque datos sea escribible por el UID. |
| Denegar solicitudes concretas | internal-sftp -d /datos -u 0077 -P remove,rmdir,rename,posix-rename -e -l VERBOSE | rm/rmdir y las dos formas de rename denegadas; la escritura de un archivo puede seguir permitida. |
| Lista permitida acotada | internal-sftp -R -d /datos -p open,close,read,lstat,fstat,opendir,readdir,realpath,stat,readlink,limits,expand-path -e -l VERBOSE | Probar cliente real y sus solicitudes implícitas; toda solicitud no enumerada debe rechazarse. |

**Qué estás viendo.** Los nombres de filtros son solicitudes de protocolo: rm del cliente usa remove; rename puede utilizar una extensión llamada posix-rename. No son nombres de binarios ni patrones de rutas. La [referencia](17-referencia-sftp-confinado.md) recorre las 29 solicitudes de esta versión.

La variante de denegación **no garantiza inmutabilidad ni append-only**. Probar una copia propia del mismo nombre con contenido distinto: open/write aún pueden truncar o sobrescribir aunque remove/rename estén denegados. No usar datos que se quieran conservar para demostrarlo.

Cuando el paquete incluya un ejecutable externo sftp-server, localizar su ruta real mediante sus archivos de paquete y consultar desde consola:

```sh
"$sftp_server_bin" -Q requests
```

**Qué estás viendo.** sftp_server_bin representa esa ruta confirmada, no el texto internal-sftp ni una ruta supuesta universal. La consulta enumera nombres del binario interrogado. Si no está instalado, conservar la limitación; no instalar otro servidor para presentar esa lista como prueba del integrado.

Si se combinan -P y -p, la denegación se evalúa primero. Un error tipográfico no debe suponerse rechazado al arrancar: la implementación compara nombres exactos al tramitar peticiones. Registrar cliente/versión, solicitud que falla y efecto sobre la operación completa; no ampliar la lista a ciegas ante cada error.

## 10. Evidencia, cierre y restauración

Separar log de autenticación/sshd en B de stderr de internal-sftp en C. Repetir una sesión de laboratorio con captura propia:

```sh
sftp -vv -F ./ssh-sftp-lab.conf sftp-jaula 2> ./sftp-lab.stderr
```

**Qué estás viendo.** El archivo contiene diagnóstico y transacciones del ejercicio, no una prueba automática de todos los controles. Correlacionar usuario, transporte, perfil activo, operación y resultado; logs pueden contener nombres/rutas aunque los datos sean ficticios.

Antes de retirar ForceCommand o el chroot, dejar la cuenta nueva sin acceso y cerrar sus sesiones identificadas. Con el nombre .retirada libre, retirar su pública del archivo que consulta esta política:

```sh
sudo mv /etc/ssh/authorized_keys-sftp-lab/sftp_lab /etc/ssh/authorized_keys-sftp-lab/sftp_lab.retirada
```

**Qué estás viendo.** La pública se conserva fuera de la ruta exacta de autorización. Comprobar que una conexión nueva con esa identidad falla; si existe otra vía autorizada, resolverla antes de seguir. Esto no desconecta transportes ya autenticados.

Comprobar que no quedan procesos de la cuenta:

```sh
ps -u sftp_lab -o pid,ppid,args
```

**Qué estás viendo.** Identificar procesos propios del ejercicio y cerrarlos desde sus clientes; no ejecutar un kill general por coincidencia de nombre. Una contraseña bloqueada por sí sola no garantiza revocar una pública ni cerrar una sesión existente.

Cuando ya no queden sesiones/procesos y se confirme que es la cuenta creada en este ejercicio:

```sh
sudo userdel sftp_lab
getent passwd sftp_lab
```

**Qué estás viendo.** No usar -r: el home registrado es /datos y no corresponde al árbol del host creado para la jaula. Si userdel rechaza por actividad, detener la retirada y resolver esa actividad, sin forzarla. La consulta debe confirmar que la cuenta ya no existe.

Restaurar el candidato/configuración anterior conforme al bloque de servidor y comprobar conexión administrativa nueva. Archivar o retirar solo las públicas, grupo vacío y archivos de laboratorio identificados. Conservar datos huérfanos requiere revisar propietario/retención antes de reutilizar el UID. No cambiar permisos ni borrar /srv, /datos u otras rutas ajenas.

- [ ] Cuenta nueva, grupo, rutas y recuperación identificados sin reutilizar recursos ajenos.
- [ ] Raíz/ancestros seguros y datos separados; ACL y controles adicionales revisados.
- [ ] Pública validada y fuera del área de escritura de la cuenta.
- [ ] Candidato efectivo confina a la cuenta desde todos sus orígenes y preserva al administrador.
- [ ] SFTP permite transferencias propias en datos y conserva contenido esperado.
- [ ] Escritura en raíz y lectura del marcador exterior/enlace denegadas.
- [ ] Shell, comando remoto, PTY y forwarding rechazados en su fase.
- [ ] Solo lectura y filtros probados con conexiones nuevas y solicitudes implícitas registradas.
- [ ] Logs/retornos permiten distinguir autenticación, inicio de sesión, filesystem y protocolo.
- [ ] Cuenta retirada antes de quitar confinamiento; restauración y nueva conexión administrativa comprobadas.

Estos diez criterios permanecen abiertos hasta el laboratorio completo.

## Estado de verificación y fuentes

Se inspecciona localmente el perfil cliente con Windows OpenSSH 9.5p2 mediante ssh -G, sin conexión: esta lectura no prueba configuración servidor ni SFTP. El entorno actual no dispone de un sshd Linux utilizable; los ensayos de servidor, permisos/chroot, filtros y restauración quedan pendientes. La comprobación con bash -n tampoco está acreditada en este entorno.

- [Referencia de SFTP confinado](17-referencia-sftp-confinado.md): 15 fichas y las 29 solicitudes inventariadas.
- [sshd_config(5)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5), [sftp-server(8)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8) y [session.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/session.c): Portable 10.6p1.
- [useradd(8)](https://manpages.debian.org/trixie/passwd/useradd.8.en.html), [passwd(1)](https://manpages.debian.org/trixie/passwd/passwd.1.en.html), [userdel(8)](https://manpages.debian.org/trixie/passwd/userdel.8.en.html) e [install(1)](https://manpages.debian.org/trixie/coreutils/install.1.en.html): auxiliares Linux; revisar paquete/política del entorno real.

Desarrollo parcial de SSH-T05/T06, SSH-C024/C028/C029/C030 y SSH-P07. No cierra autenticación por plataforma, catálogo completo de restricciones por clave, aislamiento del sistema ni compatibilidad de todos los clientes.
