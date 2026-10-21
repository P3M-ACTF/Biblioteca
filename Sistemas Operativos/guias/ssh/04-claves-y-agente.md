# SSH · Claves de usuario y agente

[Índice](README.md) · [Conexión básica](02-conexion-basica.md) · [Referencia de este bloque](05-referencia-claves.md)

Este recorrido permite crear una identidad de laboratorio, autorizar su pública, demostrar qué clave se utiliza y retirarla sin perder el acceso de recuperación. Continúa la primera conexión; la fingerprint de host debe estar verificada previamente.

**Estado:** procedimiento contrastado con manuales y código de OpenSSH Portable 10.6p1, pendiente de ejecución. Los criterios de salida son resultados esperados, no capturas. El caso principal es cliente Linux/Bash → servidor Linux; se indican las diferencias para un cliente Windows/PowerShell. La administración de un servidor Windows, certificados, FIDO/PKCS#11 y KRL quedan para sus bloques.

## 1. Preparar el ejercicio

Usar una cuenta ordinaria de laboratorio y conservar una consola o sesión de recuperación. El servidor ya debe permitir un método de acceso y autenticación `publickey`; instalar una pública no habilita esa política.

Continuamos desde la carpeta y el `ssh-lab.conf` de la [práctica anterior](02-conexion-basica.md). Sus valores ficticios son `192.0.2.10`, `2222` y `alumno`; sustituirlos. El archivo `known_hosts_ssh_lab` debe contener una referencia ya comprobada. Las rutas relativas de este ejercicio se resuelven desde esa carpeta.

| Material | Dónde permanece | Para qué sirve |
| --- | --- | --- |
| `id_ed25519_lab` | Cliente, carpeta privada del usuario. | Privada de la identidad nueva; no se publica ni se copia al servidor. |
| `id_ed25519_lab.pub` | Cliente y pública autorizada en el servidor. | Identificar la clave y permitir su autenticación. |
| `ssh-claves.conf` | Cliente. | Aislar la prueba de una identidad concreta. |
| `authorized_keys` efectivo | Servidor, cuenta de laboratorio. | Autorizar públicas; conservar entradas y restricciones ajenas al ejercicio. |
| Registro de evidencia | Ubicación elegida para documentación. | Versiones, fingerprint pública, método, retorno y resultado, sin secretos. |

Comprobar las rutas de `ssh`, `ssh-keygen` y `ssh-add`. En Linux puede usarse `command -v`; en PowerShell, `Get-Command -CommandType Application` como en la primera práctica. No mezclar sin comprobar el cliente de Windows, el de Git for Windows y un agente de WSL: pueden comunicarse con agentes diferentes.

## 2. Comprobar que el nombre está libre

En Bash del cliente Linux:

```bash
test ! -e ./id_ed25519_lab && test ! -L ./id_ed25519_lab &&
test ! -e ./id_ed25519_lab.pub && test ! -L ./id_ed25519_lab.pub &&
test ! -e ./id_ed25519_lab-cert.pub && test ! -L ./id_ed25519_lab-cert.pub
```

**Qué estás viendo.** Código `0` indica que no existen esos nombres ni enlaces simbólicos en ellos; `1` indica que alguno está ocupado y hay que elegir otra ruta. Consultar `$?` inmediatamente. La comprobación no reserva los nombres frente a concurrencia: si después aparece una pregunta para sobrescribir, cancelar e investigar.

En PowerShell del cliente Windows:

```powershell
Test-Path -LiteralPath ./id_ed25519_lab
Test-Path -LiteralPath ./id_ed25519_lab.pub
Test-Path -LiteralPath ./id_ed25519_lab-cert.pub
```

**Qué estás viendo.** Las tres respuestas deberían ser `False`. Si alguna es `True`, elegir otro nombre antes de generar. Usar una carpeta nueva y propia, sin enlaces ni puntos de reanálisis preparados por terceros; `Test-Path` aislado no es una reserva segura frente a concurrencia o enlaces. Aquí `Test-Path` devuelve booleanos; no es el código de retorno nativo de SSH.

El tercer nombre evita asociar accidentalmente un certificado preexistente a la nueva prueba. Mantener la carpeta bajo control exclusivo del usuario y fuera del repositorio, carpetas compartidas y sincronización no autorizada.

## 3. Generar una clave con frase de paso

En el cliente Linux o PowerShell, dentro de la carpeta elegida:

```sh
ssh-keygen -t ed25519 -a 32 -C "lab-cliente-01" -f ./id_ed25519_lab
```

**Qué estás viendo.** `-t` selecciona Ed25519; `-a` fija 32 rondas del KDF del formato privado, que coincide con el default upstream de esta versión; `-C` añade un comentario y `-f` da el nombre de la privada. Se creará también el archivo `.pub`. Introducir una frase de paso propia mediante el prompt y repetirla; no escribirla en el comando ni en el registro del ejercicio.

El número de rondas influye en el coste de desbloquear o atacar una privada cifrada. No cambia el tamaño ni el algoritmo de la clave y no protege una privada guardada sin cifrado. No se propone 32 como política universal: el entorno debe valorar coste y protección.

Esperamos los mensajes de archivos guardados y una huella pública. Si el tipo no está disponible o la política lo prohíbe, registrar versión/error y elegir un algoritmo aprobado mediante su ficha; no desactivar la política para completar el ejemplo.

## 4. Revisar protección y correspondencia

### Cliente Linux

```bash
ls -l ./id_ed25519_lab ./id_ed25519_lab.pub
chmod 600 ./id_ed25519_lab
```

**Qué estás viendo.** `ls` muestra modo, propietario y archivos; la privada debe pertenecer al usuario y estar protegida frente a acceso no autorizado. `chmod` fija lectura/escritura solo para el titular en este archivo nuevo del laboratorio. No resuelve por sí mismo ACL adicionales, permisos de la carpeta ni un propietario erróneo. La pública no requiere ser secreta.

### Cliente Windows

```powershell
Get-Acl -LiteralPath ./id_ed25519_lab | Format-List Owner, AccessToString
```

**Qué estás viendo.** Se consultan propietario y entradas de ACL de la privada. Revisar accesos efectivos e herencia conforme a la política del equipo; `600` no es una ACL de Windows. Si hay permisos excesivos, corregirlos con el procedimiento del entorno antes de seguir. Esta guía no aplica una receta que retire permisos a ciegas.

### Identificar la pública y derivarla desde la privada

En ambos clientes:

```sh
ssh-keygen -l -E sha256 -f ./id_ed25519_lab.pub
ssh-keygen -y -f ./id_ed25519_lab
```

**Qué estás viendo.** El primer comando imprime tamaño, huella, comentario y tipo de la pública. El segundo solicita desbloquear la privada cuando corresponde y escribe la pública derivada por stdout; no muestra la privada. Comparar tipo y datos base64 con el archivo `.pub`. El comentario no es la identidad criptográfica.

No redirigir la derivación sobre la privada ni sobre una pública que queramos conservar. Tampoco intentar reconstruir una privada a partir de una pública: `-y` funciona en la dirección privada → pública.

## 5. Instalar únicamente la pública

La cuenta debe autorizar la pública en la fuente que realmente consulte el servidor. `~/.ssh/authorized_keys` es una ubicación habitual; `AuthorizedKeysFile`, condiciones `Match` u otras fuentes pueden cambiarla. Confirmarlo con el administrador si no se conoce. En un entorno gestionado, usar su mecanismo de provisión.

### Con ssh-copy-id en un cliente Linux que lo incluya

```sh
ssh-copy-id -n -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
ssh-copy-id -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** La primera orden calcula qué públicas instalaría y las muestra sin escribirlas en `authorized_keys`. **Puede conectar e intentar autenticaciones** para detectar claves existentes; no es una operación puramente local. Revisar la pública y el destino antes de ejecutar la segunda orden, que añade las pendientes mediante el acceso ya permitido.

`-i` selecciona explícitamente la pública. Sin él, el script puede seleccionar claves del agente o una pública predeterminada distinta. No utilizar `-f` para corregir un fallo sin entenderlo: omite la comprobación de presencia y puede duplicar entradas.

El script de referencia normalmente ejecuta comandos en el servidor. Su modo SFTP y rutas personalizadas tienen requisitos propios y no se necesitan en este recorrido. No atribuir su disponibilidad al cliente nativo Windows.

### Mediante consola del servidor, también válido para cliente Windows

Abrir la pública con un editor del cliente y copiar **solo su línea pública**. En la consola del servidor, como la cuenta de laboratorio, revisar primero:

```sh
id
ls -ld "$HOME" "$HOME/.ssh"
```

**Qué estás viendo.** `id` confirma qué cuenta está trabajando y `ls` permite revisar propietario/permisos del home y directorio SSH. Si `.ssh` no existe, su ausencia explica ese error de `ls`; no implica que falle el servicio.

Si falta el directorio, crearlo como esa cuenta:

```sh
mkdir -m 700 "$HOME/.ssh"
```

**Qué estás viendo.** Se crea únicamente el directorio ausente con acceso para su titular. No ejecutar la orden para intentar “reparar” un directorio existente ni usar `sudo` sobre una cuenta distinta.

Editar el archivo efectivo con el editor disponible, conservando su contenido. Añadir la pública completa en **una sola línea**, con salto de línea final, sin BOM ni ajuste que inserte saltos dentro de la base64. En una instalación de laboratorio que use `~/.ssh/authorized_keys`:

```sh
chmod 600 "$HOME/.ssh/authorized_keys"
ssh-keygen -l -E sha256 -f "$HOME/.ssh/authorized_keys"
```

**Qué estás viendo.** El modo protege el archivo de autorizaciones de esta cuenta. La lista de huellas permite localizar la pública añadida y compararla con la del cliente; puede mostrar también otras claves, que no debemos eliminar. No cambiar propietarios/permisos de un entorno gestionado sin revisar su diseño.

Ni `chmod` ni una huella listada demuestran que el servidor consulte ese archivo. En RHEL y otros entornos con SELinux, también puede intervenir el contexto de seguridad; investigar los registros antes de cambiar controles.

## 6. Entender authorized_keys

El esquema de una entrada es:

```text
[opciones] tipo-de-clave datos-base64 [comentario]
```

**Qué estás viendo.** Es una gramática, no una clave instalable. Una entrada ordinaria Ed25519 tiene tipo `ssh-ed25519`, su base64 y comentario opcional. Las opciones anteriores al tipo pueden restringir el uso. No pegar encabezados `BEGIN OPENSSH PRIVATE KEY` ni el bloque privado en ese archivo.

| Campo o decisión | Interpretación |
| --- | --- |
| Tipo + datos públicos | Identifican la clave; usar huella para comparar y material público para localizar duplicados. |
| Comentario | Etiqueta administrativa; cambiarla no crea otra identidad. |
| Opciones por clave | Pueden limitar origen, PTY, comandos o forwarding; el catálogo completo queda en el inventario. |
| Misma pública repetida | No equivale a otra clave; revisar todas las apariciones y sus restricciones. |
| Archivo de usuario frente a otras fuentes | Retirar una línea no elimina una autorización equivalente procedente de otro archivo, comando o CA. |

En esta práctica se añade una pública ordinaria a una cuenta de laboratorio. Las restricciones por clave se desarrollarán con sus pruebas de operación permitida/denegada; no se declaran cubiertas por enumerarlas aquí.

## 7. Demostrar el acceso con esa privada

Guardar `ssh-claves.conf` en la carpeta del cliente, sustituyendo los tres datos ficticios:

```sshconfig
Host ssh-lab-key
    HostName 192.0.2.10
    User alumno
    Port 2222
    UserKnownHostsFile ./known_hosts_ssh_lab
    StrictHostKeyChecking yes
    IdentityFile ./id_ed25519_lab
    IdentitiesOnly yes
    IdentityAgent none
    AddKeysToAgent no
    ForwardAgent no
    PreferredAuthentications publickey
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    ConnectTimeout 5
    ConnectionAttempts 1
```

**Qué estás viendo.** Se elige una identidad explícita, se desactiva el agente para esta invocación y solo se intenta autenticación pública. Se impide que un éxito por contraseña parezca una prueba de la nueva clave. `StrictHostKeyChecking yes` exige una referencia de host aplicable ya preparada; no repetir la primera aceptación a ciegas.

Este caso presupone que la política permite completar la autenticación con esa pública. Si exige un segundo método, registrar esa precondición y desarrollar el caso MFA por separado; no cambiar la política.

```sh
ssh -F ./ssh-claves.conf -G ssh-lab-key
ssh -v -T -F ./ssh-claves.conf ssh-lab-key hostname
```

**Qué estás viendo.** En `-G` comprobar destino, cuenta, identidad, `identityagent none` y métodos. Después, en el intento real, buscar la clave ofrecida y la confirmación final de autenticación por clave pública. `Server accepts key` por sí solo no demuestra que la firma y autenticación se hayan completado. `hostname` debe corresponder al servidor de laboratorio.

Guardar inmediatamente el retorno mediante `$?` en Bash o `$LASTEXITCODE` en PowerShell. Si falla, relacionar retorno y última fase; no registrar como éxito que `-G` termine correctamente.

## 8. Usar un agente de forma controlada

El agente permite solicitar operaciones con una identidad cargada. Quitar la frase de paso a la privada no es necesario para usarlo. Un proceso capaz de acceder al agente puede intentar utilizar sus identidades conforme a sus restricciones; no prestar su socket ni habilitar agent forwarding por rutina.

### Linux: agente dedicado al ejercicio

En Bash local:

```bash
(
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    agent_env=$(ssh-agent -s -t 15m) || exit 1
    eval "$agent_env"
    trap 'ssh-agent -k >/dev/null' EXIT
    ssh-add -t 10m ./id_ed25519_lab || exit 1
    ssh-add -l
    ssh-add -T ./id_ed25519_lab.pub
    ssh -v -T -F ./ssh-claves.conf -o IdentityAgent=SSH_AUTH_SOCK -o BatchMode=yes ssh-lab-key hostname
    ssh-add -d ./id_ed25519_lab.pub
    ssh-add -l
)
```

**Qué estás viendo.** Los paréntesis ejecutan el bloque en un subshell Bash: las variables del agente anterior de la terminal exterior no se sobrescriben. Se eliminan las referencias heredadas dentro del subshell, se comprueba que arranca otro agente y se registra su cierre mediante `trap` al salir. Se configura una vida máxima predeterminada de identidad de 15 minutos; `ssh-add` la sustituye por 10 para la identidad cargada. La frase se introduce en su prompt.

`ssh-add -l` lista huellas de **ese agente**. `-T` pide una firma y verificación locales: no prueba la autorización remota. La conexión sustituye `IdentityAgent none` por la referencia al socket del subshell y prohíbe preguntas con `BatchMode`. Confirmar en el diagnóstico que se usó el agente y que terminó la autenticación; el éxito aislado no describe todos los mecanismos internos.

`ssh-add -d` retira esa identidad. En un agente dedicado, la lista quedará vacía y puede devolver `1`: es el resultado esperado de esa consulta, no una revocación remota. El `trap` ejecuta `ssh-agent -k` al salir del subshell y termina únicamente el agente identificado por su `SSH_AGENT_PID`. Una terminación que impida ejecutar el trap, como SIGKILL, requiere comprobar y cerrar ese agente por separado; el límite de identidad no es un temporizador de apagado del proceso.

Evaluar solo la salida del ejecutable local de confianza. No ejecutar `eval` sobre texto descargado o suministrado por un servidor. El bloque es exclusivo de Bash/POSIX; no se copia en PowerShell.

### Windows: agente nativo ya disponible

En PowerShell local:

```powershell
Get-Service -Name ssh-agent
ssh-add -l
```

**Qué estás viendo.** La primera orden consulta el estado del servicio nativo; la segunda comprueba qué agente alcanza ese `ssh-add`. Un servicio iniciado y una lista vacía son situaciones diferentes. Si falta o está deshabilitado, registrar el paso como pendiente y seguir el procedimiento administrativo del entorno; esta práctica no cambia su inicio global.

Con el servicio operativo y el mismo conjunto de ejecutables nativos:

```powershell
ssh-add ./id_ed25519_lab
ssh-add -l
ssh-add -T ./id_ed25519_lab.pub
ssh-add -d ./id_ed25519_lab.pub
```

**Qué estás viendo.** Se carga, identifica, prueba y retira la identidad del agente accesible. Registrar cada retorno con `$LASTEXITCODE` inmediatamente después de la orden. Las funciones y restricciones admitidas deben comprobarse con el build; si `-T` no está soportado, registrar esa diferencia.

No trasladar automáticamente al servicio Windows las rutas de sockets, variables ni garantías temporales del agente POSIX. El almacenamiento y persistencia requieren su propia comprobación. La prueba remota sin agente del apartado anterior sigue siendo independiente de este ejercicio.

## 9. Cambiar la frase de paso

Antes de modificar la privada, disponer de una copia de recuperación protegida conforme a la política. Ejecutar en el cliente:

```sh
ssh-keygen -p -a 32 -f ./id_ed25519_lab
ssh-keygen -l -E sha256 -f ./id_ed25519_lab.pub
```

**Qué estás viendo.** `-p` solicita la frase anterior y dos veces la nueva; reescribe la privada. La pública debe conservar su huella: cambiar la protección del archivo no rota la identidad ni revoca copias anteriores.

Una identidad ya cargada en el agente puede seguir utilizable sin la nueva frase. Retirarla selectivamente, volver a cargar desde el archivo y comprobar el desbloqueo. Conservar la privada anterior cifrada con una frase comprometida también conserva ese riesgo; revisar sus copias conforme a la política.

`-N` y `-P` permiten proporcionar frases por argumento en ciertos modos, pero pueden exponerlas en historial, procesos o automatización. Por eso esta práctica usa prompts y no incluye secretos en argv.

## 10. Rotación y revocación

| Operación | Qué cambia | Qué no demuestra por sí sola |
| --- | --- | --- |
| Cambiar frase de paso | Protección de una copia de privada. | Que otras copias dejen de funcionar. |
| `ssh-add -d` | Identidad disponible en ese agente. | Que el servidor deje de autorizarla. |
| Retirar pública autorizada | Fuente concreta de autorización del servidor. | Que no exista otra fuente equivalente. |
| Generar otra clave y migrar | Identidad criptográfica. | Que la anterior esté retirada de todos los destinos. |
| Desconectar sesiones existentes | Accesos ya abiertos que se decida finalizar. | Que se haya revocado una clave para accesos nuevos. |

Para una rotación planificada:

1. Inventariar cuenta, destinos, huella anterior y todas las fuentes de autorización; conservar acceso de recuperación.
2. Generar otro par con **otro nombre libre** y frase de paso. No sobrescribir la privada anterior.
3. Añadir la pública nueva conservando restricciones y comprobarla con una configuración como `ssh-claves.conf` que seleccione únicamente esa identidad.
4. Preparar una segunda configuración, `ssh-clave-anterior.conf`, con el mismo destino y controles, cambiando la única `IdentityFile` a la ruta anterior. Comprobar ambas con `-G`; **no añadir otra IdentityFile mediante -o**, porque las identidades se acumulan.
5. Retirar todas las autorizaciones de la pública anterior en el alcance acordado, identificándola por material público/huella y conservando entradas ajenas. Verificar también archivos adicionales y fuentes administradas.
6. Abrir conexiones **nuevas** con la configuración nueva y con la anterior: la nueva debe autenticar y la anterior debe fallar en autenticación. Mantener `IdentityAgent none`, solo `publickey` y ausencia de certificados asociados para no aceptar un método alternativo como prueba.
7. Retirar la identidad anterior de los agentes pertinentes y gestionar las copias de privada según la política. Registrar dónde se aplicó la retirada y qué destinos faltan.

Ejemplo de los dos intentos, una vez preparadas y revisadas ambas configuraciones:

```sh
ssh -v -T -F ./ssh-claves.conf ssh-lab-key hostname
ssh -v -T -F ./ssh-clave-anterior.conf ssh-lab-key hostname
```

**Qué estás viendo.** Se comparan dos conexiones nuevas. Capturar el retorno de cada una inmediatamente, antes de lanzar la siguiente. Un fallo de DNS, confianza de host o red en la segunda no prueba revocación: debe llegar a autenticación y rechazar la identidad anterior.

En una sospecha de compromiso, coordinar la retirada urgente en todos los destinos y evaluar sesiones activas y acciones realizadas. No esperar una rotación rutinaria como si la privada siguiera siendo confiable. KRL, certificados y `RevokedKeys` requieren el bloque específico; crear una KRL sin conectarla a una política no tiene efecto.

## 11. Diagnóstico y evidencia

| Síntoma | Comprobación |
| --- | --- |
| Privada ignorada por permisos | Revisar propietario, modos/ACL y acceso a la ruta, sin desactivar la comprobación. |
| `invalid format` | Confirmar archivo, formato, codificación y si se copió la pública en lugar de la privada. |
| Agente no accesible | Distinguir ejecutable, sesión, socket/servicio y retorno `2` de ssh-add en upstream. |
| Agente sin identidades | Puede devolver `1`; no confundir una lista vacía con un agente ausente. |
| Firma local correcta y acceso denegado | Revisar cuenta, autorización de pública, algoritmo, MFA y logs del servidor. |
| La clave antigua todavía funciona | Buscar duplicados, fuentes adicionales, certificados, agentes y sesiones reutilizadas. |
| Cambio de frase sin prompt posterior | Comprobar agente o una privada diferente antes de concluir que el cambio no se aplicó. |

Registrar SO/build, shell, rutas/versiones de herramientas, huellas públicas, configuración reducida, método completado, stdout/stderr y retornos pertinentes. Los diagnósticos pueden contener metadatos: revisarlos antes de compartir.

Casos de aceptación pendientes:

- [ ] Par nuevo protegido, pública derivada coincidente y nombres anteriores conservados.
- [ ] Instalación de la pública correcta y repetición sin entradas duplicadas.
- [ ] Acceso con privada explícita, sin agente ni fallback a contraseña.
- [ ] Agente accesible, identidad cargada, firma local y retirada selectiva.
- [ ] Caducidad de identidad POSIX comprobada mediante consulta/firma tras el intervalo, separada del proceso del agente.
- [ ] Cambio de frase con huella invariable y nueva carga comprobada.
- [ ] Rotación con éxito de nueva y rechazo autenticado de anterior en conexiones nuevas.
- [ ] Diferencias de cliente Windows registradas, sin extrapolar comportamiento POSIX.

Al terminar, retirar solo las autorizaciones y recursos creados para este ejercicio según su registro. Conservar la confianza del host o configuración si se seguirá el curso. No borrar `~/.ssh`, vaciar agentes compartidos ni retirar el acceso de recuperación sin revisar qué sigue dependiendo de él.

## Fuentes y relación con el guion

- [ssh-keygen(1), Portable 10.6p1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1).
- [ssh-add(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1) y [ssh-agent(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1).
- [ssh-copy-id(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1) y [script](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id).
- [sshd(8): formato y permisos](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8) y [sshd_config(5): fuente de autorización](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5).
- [Microsoft: claves y agente Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement), consultado el 21 de octubre de 2026.

Desarrollo parcial de SSH-T04, SSH-C007, SSH-C012/C013, SSH-C016/C017/C018, SSH-C023/C026 y SSH-P01/P02/P09. La [referencia](05-referencia-claves.md) delimita opciones y modos; el catálogo restante y todas las pruebas funcionales permanecen abiertos.
