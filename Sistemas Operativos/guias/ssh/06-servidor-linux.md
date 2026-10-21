# SSH · Servidor Linux: instalación y cambio controlado

[Índice](README.md) · [Claves y agente](04-claves-y-agente.md) · [Referencia de servidor](07-referencia-servidor.md)

El objetivo es preparar un servidor de laboratorio, identificar qué proceso escucha y aplicar una política comprobable con recuperación. Una configuración que pasa `sshd -t` todavía puede bloquear una cuenta o no corresponder a la que usa el servicio.

**Estado:** procedimiento documentado, pendiente de ejecución. La referencia de opciones es OpenSSH Portable 10.6p1; los paquetes Linux tienen versiones, defaults y unidades propios. No se presentan salidas como resultados observados. El recorrido principal utiliza Linux con systemd; las diferencias de paquete se indican para Ubuntu/Debian, Arch y RHEL. Servidor Windows, contenedores, cambio de puerto, límites avanzados y MFA completo quedan para otros bloques.

## 1. Preparar acceso y alcance

Trabajar en una VM o equipo de laboratorio con consola accesible. Mantener una sesión de recuperación y probar su capacidad administrativa antes de editar. La sesión abierta ayuda a recuperar, pero no garantiza sobrevivir a cualquier reinicio o cambio de cuenta.

| Dato | Precondición |
| --- | --- |
| Exposición | Red de laboratorio y filtrado conocido antes de instalar: algunos paquetes arrancan el servicio durante la instalación. |
| Cuenta | Usuario ordinario autorizado y elevación administrativa comprobada; no depender del acceso remoto directo de root. |
| Clave | Nueva conexión por clave pública ya probada conforme al bloque anterior, con host verificado. |
| Recuperación | Consola o canal independiente operativo; copia de la configuración y procedimiento para restaurarla. |
| Cambios concurrentes | Sin otra persona o automatización modificando configuración, includes o unidades durante el ejercicio. |
| Política | Perfil simple de clave pública; no aplicarlo sobre una política que exija MFA ni sobre flujos que necesiten forwarding. |

Se documentan los comandos; no se ejecutan contra un servidor del usuario. Sustituir los datos ficticios: servidor `192.0.2.10`, cliente observado por el servidor `192.0.2.20` y cuenta `alumno`.

La instalación nueva normalmente usa TCP `22`. Las prácticas anteriores utilizaron `2222` como ejemplo: **comprobar la escucha y ajustar el cliente**, sin cambiar el puerto del servidor para hacer coincidir una guía. En NAT, el puerto/dirección vistos por cliente y servidor pueden ser diferentes.

## 2. Instalar el paquete del entorno

Identificar primero la distribución y los paquetes ya presentes. Instalar solo en el laboratorio previsto, desde sus repositorios configurados; revisar la transacción del gestor.

| Familia | Instalación del servidor | Consulta de paquete | Unidad habitual, que hay que comprobar |
| --- | --- | --- | --- |
| Ubuntu/Debian | `sudo apt install openssh-server` | `dpkg-query -W openssh-server` | `ssh.service` y posible `ssh.socket`. |
| Arch | `sudo pacman -S openssh` | `pacman -Q openssh` | `sshd.service`. |
| RHEL | `sudo dnf install openssh-server` | `rpm -q openssh-server` | `sshd.service`. |

**Qué estás viendo.** Son alternativas por distribución, no órdenes consecutivas. El paquete Arch reúne cliente y servidor; las otras filas identifican el paquete servidor. La consulta registra el paquete instalado, no prueba que escuche. En Arch partir de un sistema con repositorios/base de paquetes coherentes y seguir su procedimiento de mantenimiento; no introducir una sincronización parcial para resolver una instalación.

Identificar el ejecutable y su versión:

```sh
command -v sshd
```

**Qué estás viendo.** La ruta puede ser `/usr/sbin/sshd` en Ubuntu/Debian/RHEL o `/usr/bin/sshd` en Arch. Si no aparece, revisar PATH y los archivos del paquete; no concluir que falta el servidor solo porque el usuario no tenga sbin en PATH.

Después de comprobar la ruta absoluta, fijarla para los ejemplos siguientes:

```sh
ssh_server_bin=/usr/sbin/sshd
sudo "$ssh_server_bin" -V
```

**Qué estás viendo.** Cambiar la asignación si el ejecutable está en otro lugar. `-V` muestra la versión de ese servidor y sale; en upstream escribe en stderr con retorno cero. No confundirla con `ssh -V`, que identifica el cliente. Si el build no admite `-V`, registrar la diferencia y usar los metadatos del paquete.

## 3. Identificar servicio, socket y escucha

```sh
systemctl list-unit-files 'ssh*.service' 'ssh*.socket' --no-pager
systemctl list-sockets --all 'ssh*.socket' --no-pager
sudo ss -ltnp
```

**Qué estás viendo.** La primera consulta muestra unidades instaladas y habilitación; la segunda, sockets gestionados por systemd. `ss` muestra sockets TCP en escucha, dirección local, puerto y proceso cuando se dispone de permiso. Una escucha en `127.0.0.1`, una IP concreta, `0.0.0.0` o `[::]` no implica la misma exposición. Una escucha IPv6 no prueba por sí sola que IPv4 esté operativo.

Elegir la unidad real. Para Ubuntu/Debian con `ssh.service`, por ejemplo:

```sh
ssh_unit=ssh.service
systemctl cat "$ssh_unit"
systemctl show "$ssh_unit" -p LoadState -p ActiveState -p CanReload -p ExecStart -p ExecReload -p EnvironmentFiles
```

**Qué estás viendo.** En Arch/RHEL suele corresponder `ssh_unit=sshd.service`, tras comprobarlo. Revisar archivo efectivo, argumentos `-f/-o` y archivos de entorno usados por la unidad. No publicar configuraciones o entorno completos si contienen información sensible.

Una unidad socket activa puede mantener la escucha aunque el servicio esté inactivo. Tampoco `enabled` significa `active`. Si falta escucha y se ha elegido la ruta de servicio tradicional, con red/filtrado preparados:

```sh
sudo "$ssh_server_bin" -t &&
sudo systemctl start "$ssh_unit"
```

**Qué estás viendo.** Ejecutar el arranque solo si la validación previa termina correctamente. `start` inicia ahora; no habilita automáticamente el arranque futuro. No arrancar a la vez un servicio tradicional y otro daemon que compitan por el mismo puerto. Con activación por socket, utilizar el procedimiento de su paquete en lugar de forzar ese modelo.

Este ejercicio cambia política de autenticación, **no las unidades ni Port/ListenAddress**. Una modificación de puerto en un sistema con generadores o socket activation puede requerir actualizar unidades y reiniciar el socket, además de validar sshd. Ese cambio necesita su propio plan y no se realiza aquí.

## 4. Verificar red, cuenta e identidad de host

Antes de endurecer:

1. Confirmar dirección/puerto en escucha y ruta desde el cliente.
2. Revisar firewall local, reglas del proveedor, NAT y filtrado de red; permitir solo los orígenes necesarios mediante la herramienta ya utilizada por el entorno.
3. Obtener la huella de una clave pública de host por consola y contrastarla con el cliente, como en [conexión básica](02-conexion-basica.md).
4. Confirmar cuenta, fuentes de públicas autorizadas y acceso por una identidad explícita, como en [claves](04-claves-y-agente.md).
5. Abrir una conexión nueva y verificar `id` y la elevación autorizada que se necesite para recuperar.

No se incluye una orden universal para abrir el firewall: UFW, firewalld, nftables y controles del proveedor tienen estado/alcance diferentes. No desactivarlos como diagnóstico rutinario. Tampoco regenerar claves de host existentes para eliminar un error de carga.

Las claves de host y las claves de usuario cumplen funciones distintas. Sus privadas no se copian al repositorio ni al registro de este ejercicio.

## 5. Registrar la política efectiva inicial

Desde la consola administrativa del servidor:

```sh
sudo "$ssh_server_bin" -t -f /etc/ssh/sshd_config
sudo "$ssh_server_bin" -T -f /etc/ssh/sshd_config -C user=alumno,addr=192.0.2.20,host=cliente.example,laddr=192.0.2.10,lport=22
```

**Qué estás viendo.** `-t` comprueba configuración y coherencia de claves; normalmente no imprime nada en éxito. Leer su retorno antes de continuar. `-T` añade salida de configuración efectiva; `-C` simula datos de una conexión para aplicar `Match`. `host` es el nombre resuelto del **cliente**, no el nombre del servidor. Sustituir IP/puerto por los vistos realmente por sshd.

Repetir `-T -C` para cada cuenta/origen afectado, incluida recuperación. No limitarse a la salida sin contexto si hay reglas `Match`. Las comprobaciones de grupos pueden requerir consultas de cuentas del sistema; no suponer que son independientes del servicio de identidades.

Comprobar, al menos, `permitrootlogin`, `pubkeyauthentication`, `passwordauthentication`, `kbdinteractiveauthentication`, `authenticationmethods`, `usepam`, listas Allow/Deny, `authorizedkeysfile`, `strictmodes` y `disableforwarding`.

Si la unidad añade opciones, otro `-f` o una política administrada, reproducir esos argumentos al evaluar o detener este recorrido hasta conocer la configuración utilizada. La salida de un archivo que el servicio no carga no valida el servicio real.

## 6. Preparar copia y candidato

Este procedimiento presupone que `/etc/ssh/sshd_config` es un archivo regular y no un enlace. Comprobarlo antes:

```sh
sudo test -f /etc/ssh/sshd_config &&
sudo test ! -L /etc/ssh/sshd_config
```

**Qué estás viendo.** Ambas órdenes deben devolver cero. Si es un enlace o el archivo activo es otro, adaptar copia, candidato y restauración al diseño real; no editar un enlace de candidato que termine apuntando al archivo activo.

Elegir un directorio administrativo nuevo; el siguiente nombre es un ejemplo que no debe reutilizarse:

```sh
sudo mkdir -m 700 /root/ssh-lab-20261021-01 &&
sudo cp -a /etc/ssh/sshd_config /root/ssh-lab-20261021-01/sshd_config.original &&
sudo cp -a /etc/ssh/sshd_config /root/ssh-lab-20261021-01/sshd_config.candidato
```

**Qué estás viendo.** Si `mkdir` falla porque existe, elegir otro nombre y corregir todas las rutas; no seguir escribiendo sobre una copia previa. `&&` evita continuar la cadena si falla un paso; comprobar el retorno de toda la cadena y no seguir con pasos posteriores si no es cero. El directorio restringe el acceso a los archivos de trabajo. Se copia configuración, **no el directorio completo con privadas de host**.

Inventariar los archivos incluidos y confirmar que no cambian durante el ejercicio. Aquí se modificará únicamente el archivo principal; sus `Include` seguirán leyendo las rutas activas. Por tanto, el candidato no es un snapshot autónomo de todos los includes. Si hace falta cambiar uno, ampliar antes el registro de copias y restauración; no aplicar solo la restauración del principal.

## 7. Construir una política limitada de laboratorio

Editar únicamente el candidato con el editor administrativo disponible:

```sh
sudoedit /root/ssh-lab-20261021-01/sshd_config.candidato
```

**Qué estás viendo.** El daemon sigue utilizando el archivo original. No basta con pegar opciones al final: podrían quedar dentro de `Match` o encontrar una asignación previa que tenga prioridad.

Para este laboratorio simple de acceso por clave, situar las siguientes líneas en contexto **global antes del primer Include/Match**, conservando el resto del archivo:

```sshconfig
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
AuthenticationMethods publickey
StrictModes yes
DisableForwarding yes
LogLevel INFO
```

**Qué estás viendo.** Se impide entrada directa de root y se exige el método público ya probado. Se desactivan los métodos password y keyboard-interactive; cambiar solo el primero no elimina necesariamente contraseñas solicitadas mediante el segundo. `StrictModes` mantiene comprobaciones de archivos. `DisableForwarding` bloquea las funciones de forwarding de OpenSSH, no toda posibilidad de retransmitir tráfico desde una shell.

Este perfil **no es una política universal**. No debe sustituir MFA por una clave simple ni aplicarse a una cuenta que necesita bastión, túneles o agent forwarding autorizado. Se conserva la integración PAM del paquete: `UsePAM yes` puede seguir ejecutando controles de cuenta/sesión aunque no se permitan los métodos de contraseña.

Los valores escalares globales suelen conservar la primera asignación; `Match` puede establecer valores para conexiones concretas. Las listas Allow/Deny tienen reglas acumulativas. No deducir que `99-lab.conf` gana por su nombre ni que estas ocho líneas cubren todas las identidades y recursos. La [referencia](07-referencia-servidor.md) detalla cada regla.

## 8. Validar candidato y practicar un fallo sin aplicarlo

```sh
sudo "$ssh_server_bin" -t -f /root/ssh-lab-20261021-01/sshd_config.candidato
sudo "$ssh_server_bin" -T -f /root/ssh-lab-20261021-01/sshd_config.candidato -C user=alumno,addr=192.0.2.20,host=cliente.example,laddr=192.0.2.10,lport=22
```

**Qué estás viendo.** Exigir retorno cero y los valores esperados para cada contexto del apartado 5. Una clave de host ilegible, algoritmo no disponible o directorio de ejecución no preparado puede hacer fallar el test: investigar el mensaje y preparación del paquete, sin desactivar controles ni regenerar identidades a ciegas.

Como caso negativo, crear otra copia del candidato con nombre `sshd_config.invalido` dentro del directorio protegido y añadir con el editor una directiva ficticia `DirectivaInexistenteLab yes`. Ejecutar solo:

```sh
sudo "$ssh_server_bin" -t -f /root/ssh-lab-20261021-01/sshd_config.invalido
```

**Qué estás viendo.** Se espera error de configuración y retorno no cero. Ese archivo **no se instala ni se utiliza para arrancar un daemon**. Documentar que un error detiene el flujo antes de recargar.

## 9. Instalar y recargar

Continuar únicamente con el servicio activo, `CanReload=yes`, configuración/argumentos identificados y candidato válido para todos los contextos. Si el modelo no admite esta ruta, utilizar el procedimiento específico de la unidad; no sustituir automáticamente `reload` por `restart`.

Antes de instalar, verificar que el principal sigue coincidiendo con su copia:

```sh
sudo cmp -s /etc/ssh/sshd_config /root/ssh-lab-20261021-01/sshd_config.original
```

**Qué estás viendo.** Cero indica coincidencia. Si hay diferencia o error de lectura, detenerse y reconciliar los cambios concurrentes, también en includes. La comparación no los bloquea: la ausencia de cambios concurrentes sigue siendo una precondición.

Instalar el candidato revisado:

```sh
sudo cp -a /root/ssh-lab-20261021-01/sshd_config.candidato /etc/ssh/sshd_config &&
sudo "$ssh_server_bin" -t -f /etc/ssh/sshd_config
```

**Qué estás viendo.** Se modifica el archivo activo en disco. Comprobar copia y validación inmediatamente; ante cualquier fallo, restaurar por consola antes de recargar. Este recorrido no pretende una actualización concurrente/atómica gestionada. En entornos con SELinux también deben conservarse los contextos apropiados; un fallo de acceso requiere revisar etiquetas/registros.

Después, solo tras validación correcta:

```sh
sudo systemctl reload "$ssh_unit"
systemctl status "$ssh_unit" --no-pager
sudo ss -ltnp
```

**Qué estás viendo.** `reload` solicita releer la configuración del servicio; `daemon-reload` relee definiciones de unidades systemd y tiene otro propósito. Confirmar el retorno de recarga, estado y escucha. Una sesión abierta o un estado activo no demuestran que nuevas conexiones satisfagan la política.

No habilitar arranque persistente, cambiar sockets ni reiniciar el sistema como parte de esta prueba. Si se requiere persistencia, verificar aparte la unidad adecuada y el acceso tras un reinicio planificado desde consola.

## 10. Probar comportamiento real

Abrir conexiones nuevas desde el cliente con el `ssh-lab.conf` ajustado a la escucha real y el material del bloque anterior. Para impedir reutilizar una conexión existente, desactivar multiplexación en estas pruebas:

```sh
ssh -v -T -F ./ssh-lab.conf -S none -o ControlMaster=no -o IdentityAgent=none -o IdentitiesOnly=yes -i ./id_ed25519_lab -o PreferredAuthentications=publickey ssh-lab id
```

**Qué estás viendo.** Debe autenticar por la identidad prevista y devolver la cuenta/grupos remotos. Verificar el método completado, salida y retorno. `-S none` impide usar un socket de control existente. No basta con escribir otra orden ssh si pudiera reutilizar una sesión autenticada antes del cambio.

Probar que el servidor no ofrece el método password:

```sh
ssh -v -F ./ssh-lab.conf -S none -o ControlMaster=no -o PubkeyAuthentication=no -o PreferredAuthentications=password -o NumberOfPasswordPrompts=1 ssh-lab
```

**Qué estás viendo.** Se espera que no pueda autenticar por ese método y no aparezca una solicitud de contraseña. Si se pide una, cancelar y revisar la política efectiva. No introducir credenciales para completar una prueba que debería denegarse. No usar `BatchMode=yes` como prueba de retirada del método: podría suprimir la interacción del cliente aunque el servidor lo admitiese.

Repetir la comprobación con `PreferredAuthentications=keyboard-interactive` y revisar también los contextos de root y cuentas/orígenes afectados. Un rechazo de root usando una clave nunca autorizada para root no prueba por sí solo `PermitRootLogin no`: correlacionar política efectiva y registro.

| Caso | Criterio que debe observarse |
| --- | --- |
| Cuenta permitida y clave prevista | Autenticación pública y comando correctos en conexión nueva. |
| Password/keyboard-interactive | El método retirado no permite completar autenticación ni solicita ese secreto. |
| Cuenta/origen excluido por política existente | Rechazo en la fase y regla esperadas; no inferirlo de un fallo de red. |
| Forwarding de OpenSSH | `disableforwarding yes` para el contexto; ensayo de canales se amplía en el bloque de túneles. |
| Archivo inválido | Validación falla antes de instalar/recargar. |
| Recuperación | Restauración verificable por consola y nueva conexión posterior. |

## 11. Consultar logs y localizar la fase

```sh
sudo journalctl -u "$ssh_unit" --since "10 minutes ago" --no-pager
```

**Qué estás viendo.** Correlacionar hora, origen, cuenta, método y motivo. Según la unidad y el paquete, algunos procesos de sesión pueden registrarse de otra manera: revisar su identificación y el sistema de logs configurado si no aparece el intento. `/var/log/auth.log` o `/var/log/secure` no existen necesariamente en todos los sistemas.

| Síntoma | Próxima comprobación |
| --- | --- |
| No hay escucha | Estado de servicio/socket, conflicto de puerto, configuración y preparación del paquete. |
| Timeout/rechazo | Dirección/puerto, familia IP, ruta, firewall y escucha; todavía no es un fallo de clave. |
| Verificación de host fallida | Referencia y huella por canal independiente; no borrar known_hosts para ocultarlo. |
| `Permission denied` | Cuenta, fuentes de públicas, modos/ACL, política de algoritmos, PAM y Match. |
| `-t` correcto y nadie entra | Política efectiva por contexto, listas de acceso y métodos realmente habilitados. |
| Configuración efectiva correcta y comportamiento distinto | Unidad/argumentos/instancia evaluada, recarga, socket y conexión reutilizada. |

Mantener `LogLevel INFO` para el recorrido. Una elevación temporal a VERBOSE/DEBUG requiere objetivo, alcance, duración y revisión de metadatos; no publicar logs completos sin revisarlos.

## 12. Restaurar desde consola

Si el cambio falla o se quiere volver a la política inicial, mantener la consola y restaurar el archivo de **esta misma ejecución**:

```sh
sudo cp -a /root/ssh-lab-20261021-01/sshd_config.original /etc/ssh/sshd_config &&
sudo "$ssh_server_bin" -t -f /etc/ssh/sshd_config
```

**Qué estás viendo.** Confirmar copia y validación antes de la siguiente acción. Si también se modificaron includes, unidades, cuentas o firewall, este archivo no basta: restaurar esos cambios según el registro; el recorrido propuesto no los cambia.

Si el servicio sigue activo y admite recarga:

```sh
sudo systemctl reload "$ssh_unit"
```

**Qué estás viendo.** Se devuelve la política validada al servicio. Si está detenido/fallido, revisar la causa y utilizar desde consola el arranque de la unidad correcta una vez reparada; no repetir recargas sobre una unidad inactiva.

Repetir consultas de configuración y una conexión nueva por el acceso de recuperación, además de comprobar escucha. Conservar la evidencia y el respaldo mientras sean necesarios. Su retirada posterior afecta únicamente a los archivos identificados del ejercicio.

## 13. Registro de aceptación

- [ ] Distribución, paquete, versión, binario y modelo de activación registrados.
- [ ] Escucha y filtrado comprobados antes de nuevas exposiciones.
- [ ] Cuenta ordinaria por clave y recuperación administrativa probadas.
- [ ] Principal/includes/argumentos de unidad inventariados y sin cambios concurrentes.
- [ ] Candidato validado por sintaxis y todos los contextos afectados.
- [ ] Archivo inválido rechazado antes de aplicar.
- [ ] Política aplicada y conexiones nuevas positivas/negativas contrastadas con logs.
- [ ] Restauración ensayada por consola; persistencia tras reinicio registrada aparte si se requiere.

Todos los casos permanecen **pendientes de ejecución**. Los comandos de paquete, systemd, ss y journalctl se utilizan con alcance limitado; sus catálogos completos pertenecen al guion GNU/Linux.

## Fuentes y cobertura

- [sshd(8)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8) y [sshd_config(5)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5): referencia Portable 10.6p1.
- [Ubuntu: servidor OpenSSH](https://ubuntu.com/server/docs/how-to/security/openssh-server/) y [activación por socket](https://discourse.ubuntu.com/t/sshd-now-uses-socket-based-activation-ubuntu-22-10-and-later/30189).
- [Debian trixie: configuración del paquete](https://manpages.debian.org/trixie/openssh-server/sshd_config.5.en.html).
- [Arch: archivos del paquete openssh](https://archlinux.org/packages/core/x86_64/openssh/files/).
- [RHEL 9: acceso mediante OpenSSH](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/assembly_using-secure-communications-between-two-systems-with-openssh_configuring-basic-system-settings).
- [systemctl: manual oficial](https://www.freedesktop.org/software/systemd/man/latest/systemctl.html).

Fuentes de distribución consultadas el 21 de octubre de 2026. Sus páginas pueden actualizarse; registrar el paquete realmente probado. Desarrollo parcial de SSH-T02/T05/T08 y SSH-C020/C021/C022/C023/C024/C025, junto con SSH-P09; no acredita cobertura completa por distribución ni bastionado terminado.
