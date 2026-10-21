# SSH · Primera conexión y diagnóstico básico

[Índice](README.md) · [Fundamentos](01-fundamentos.md) · [Referencia de opciones](03-referencia-conexion.md)

El objetivo es conectar con una cuenta autorizada, verificar a qué servidor llegamos y ejecutar un comando sencillo. Cada bloque indica **dónde ejecutarlo, para qué sirve y qué debemos observar**.

**Estado de la práctica:** procedimiento contrastado documentalmente con OpenSSH Portable 10.6p1; pendiente de ejecución en un laboratorio identificado. Las salidas son esquemas o criterios de observación, no capturas de una prueba realizada.

## 1. Entorno y datos que debemos conocer

Usaremos un cliente Linux con shell POSIX/Bash o Windows con PowerShell, y un **servidor Linux** ya preparado para recibir SSH. Los comandos remotos `hostname`, `id` y `exit` de esta práctica corresponden a ese servidor; no se atribuyen a un servidor Windows.

| Requisito | Comprobación previa |
| --- | --- |
| Cliente OpenSSH disponible | Localizar `ssh` y obtener su versión. |
| Servidor y puerto accesibles | Conocer la IP/hostname y el puerto realmente configurado. |
| Cuenta autorizada | Disponer de un método de autenticación que el servidor ya permita: contraseña, clave u otro método. |
| Referencia de confianza | Obtener la fingerprint del servidor mediante consola u otro canal independiente. |
| Acceso de recuperación | Conservar la consola de la VM o un acceso administrativo conocido. |

Los ejemplos utilizan **`192.0.2.10`, puerto `2222` y usuario `alumno`**, todos ficticios. Sustituirlos por los datos reales antes de ejecutar conexiones. Esta práctica no instala `sshd`, no cambia su puerto y no habilita autenticación por contraseña.

Crear o elegir una carpeta de trabajo propia y permanecer en ella. Allí guardaremos `ssh-lab.conf`, `known_hosts_ssh_lab` y, si hace falta, salidas de diagnóstico. Son archivos del laboratorio; no deben confundirse con los archivos habituales del usuario.

## 2. Identificar el cliente utilizado

### En un cliente Linux

Ejecutar en la terminal local:

```sh
command -v ssh
ssh -V
```

**Qué estás viendo.** `command -v` identifica el comando que resolverá el shell. `ssh -V` muestra la versión del cliente y termina. El mensaje de versión puede ir por stderr; eso no implica un fallo. Si no se encuentra el comando, falta el cliente o su ruta no está en PATH: resolverlo con el gestor de paquetes del sistema antes de seguir.

### En un cliente Windows

Ejecutar en PowerShell local:

```powershell
Get-Command ssh -CommandType Application | Select-Object Source
ssh -V
```

**Qué estás viendo.** `Source` muestra el ejecutable utilizado. Esto ayuda a distinguir Windows OpenSSH de otra copia incluida con Git, Cygwin u otra herramienta. `ssh -V` identifica esa copia del cliente. No deducir de esta salida la versión del servidor ni asumir que coincide con la referencia 10.6p1 de la documentación.

## 3. Obtener la huella esperada desde el servidor

Ejecutar **en la consola del servidor Linux**, mediante un acceso que ya consideremos fiable:

```sh
ssh-keygen -l -E sha256 -f /etc/ssh/ssh_host_ed25519_key.pub
```

**Qué estás viendo.** Se inspecciona una **clave pública de host**, no la privada del usuario. La salida contiene tamaño, fingerprint, comentario y tipo. Si ese archivo no existe, identificar una clave de host realmente configurada; no generarla ni sustituirla solo para poder seguir el ejemplo.

Esquema de salida:

```text
256 SHA256:<HUELLA_ESPERADA> <comentario-del-host> (ED25519)
```

**Qué estás viendo.** La parte que compararemos es la fingerprint `SHA256:…`, junto con el tipo de clave. El comentario ayuda a reconocer el archivo, pero no constituye la prueba de identidad. Un servidor con varias claves puede negociar otro tipo: comparar entonces la huella de esa clave mediante el mismo canal independiente.

Anotar la huella de referencia y su procedencia. Una huella obtenida únicamente preguntando al mismo destino por una red aún no confiable no añade una verificación independiente.

## 4. Crear una configuración propia del laboratorio

Guardar el siguiente contenido en `ssh-lab.conf`, sustituyendo IP, usuario y puerto:

```sshconfig
Host ssh-lab
    HostName 192.0.2.10
    User alumno
    Port 2222
    UserKnownHostsFile ./known_hosts_ssh_lab
    StrictHostKeyChecking ask
    ConnectTimeout 5
    ConnectionAttempts 1
```

**Qué estás viendo.**

- `Host ssh-lab` selecciona este bloque cuando usamos ese alias. No crea un registro DNS.
- `HostName`, `User` y `Port` fijan el destino y la cuenta.
- `UserKnownHostsFile` guarda la confianza del usuario para el laboratorio en un archivo separado. No desactiva otras fuentes de confianza, como la base global del sistema.
- `StrictHostKeyChecking ask` mantiene la comprobación de host y puede pedir confirmación de una clave desconocida.
- `ConnectTimeout` limita la conexión TCP y la negociación inicial; no limita la duración de un comando remoto.
- `ConnectionAttempts` controla los intentos de establecimiento.

La ruta relativa `./known_hosts_ssh_lab` se interpreta respecto del directorio de trabajo del cliente. No hay que suponer que sea relativa al archivo indicado con `-F`. Para utilizar la configuración desde otras carpetas, sustituirla por una ruta absoluta propia del entorno.

Los ejemplos de esta guía seleccionan siempre el archivo con `-F`. En la referencia upstream, proporcionar `-F` sustituye la configuración personal y hace que se omita la configuración global del cliente. **No modifica los archivos normales ni elimina la base global de claves de host.**

## 5. Revisar la configuración antes de conectar

Ejecutar en el cliente, dentro de la carpeta de trabajo:

```sh
ssh -F ./ssh-lab.conf -G ssh-lab
```

**Qué estás viendo.** `-G` imprime la configuración resultante y termina sin abrir una sesión SSH. Buscar, al menos:

```text
hostname 192.0.2.10
user alumno
port 2222
connectionattempts 1
connecttimeout 5
stricthostkeychecking ask
userknownhostsfile ./known_hosts_ssh_lab
```

**Qué estás viendo.** Este fragmento muestra los campos que buscamos, no una salida completa ni una comparación byte a byte. El orden, representación y otros defaults pueden variar. Hay que confirmar que dirección, cuenta, puerto y archivo de confianza son los previstos. `-G` no demuestra que el servidor escuche ni que la cuenta pueda autenticarse.

En configuraciones generales, la evaluación puede activar `Match exec` o resolución relacionada con canonicalización. El archivo reducido de esta práctica no contiene esos mecanismos. Para inspeccionar defaults sin leer archivos de configuración puede utilizarse `ssh -F none -G alumno@192.0.2.10` en la referencia upstream.

## 6. Realizar la primera conexión

Ejecutar en el cliente:

```sh
ssh -F ./ssh-lab.conf ssh-lab
```

**Qué estás viendo.** Si la clave ya es confiable por alguna fuente aplicable, puede no aparecer una pregunta. Si es desconocida y el cliente necesita confirmación, comparar tipo y fingerprint con la referencia obtenida en el servidor. Confirmar solo tras una coincidencia explicada.

Después se ejecutarán los métodos de autenticación permitidos. Leer la petición: puede corresponder a la contraseña de la cuenta, a la frase de paso de una clave privada o a otro factor. No introducir una credencial de una identidad distinta para probar al azar.

Una conexión correcta debería permitir la sesión autorizada. En la shell **remota**:

```sh
hostname
id
exit
```

**Qué estás viendo.** `hostname` identifica el nombre configurado en ese sistema y `id` muestra UID, GID y grupos de la cuenta remota. Son comprobaciones útiles después de entrar, pero un hostname autodeclarado no sustituye la verificación de la clave de host. `exit` cierra la shell y devuelve el control al cliente.

Anotar la cuenta remota observada y comprobar que no hemos entrado por error con una identidad administrativa.

## 7. Ejecutar un comando sin sesión interactiva

Ejecutar en el cliente:

```sh
ssh -T -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Se solicita ejecutar `hostname` en el servidor sin asignar PTY. Al terminar el proceso remoto, finaliza esa sesión de comando. Se espera un nombre de host por stdout. Una shell restringida o un comando forzado pueden producir otro resultado: revisar la política antes de atribuirlo a un problema de transporte.

### Capturar stdout, stderr y resultado desde Bash

```sh
ssh -T -F ./ssh-lab.conf ssh-lab hostname > salida.txt 2> error.txt
ssh_rc=$?
printf 'Código SSH: %s\n' "$ssh_rc"
```

**Qué estás viendo.** `salida.txt` recibe stdout y `error.txt` stderr. La variable se guarda inmediatamente, antes de que otro comando reemplace `$?`. Código cero indica terminación satisfactoria según el proceso ejecutado; no demuestra por sí solo que el contenido de la salida sea el esperado.

### Capturar el mismo resultado desde PowerShell

```powershell
ssh -T -F ./ssh-lab.conf ssh-lab hostname > salida.txt 2> error.txt
$sshRc = $LASTEXITCODE
"Codigo SSH: $sshRc"
```

**Qué estás viendo.** Para el ejecutable nativo `ssh` se conserva `$LASTEXITCODE`, no se interpreta `$?` como si fuera el entero de retorno de Bash. La codificación de los archivos producidos por redirección depende de la versión de PowerShell; no asumir que los bytes sean iguales a los de Bash.

### Probar un retorno remoto intencional

```sh
ssh -T -F ./ssh-lab.conf ssh-lab "exit 7"
```

**Qué estás viendo.** En el servidor Linux de la práctica se solicita salir con código `7`. Leer inmediatamente `$?` en Bash o `$LASTEXITCODE` en PowerShell. Si la sesión alcanza esa shell sin restricciones que sustituyan el comando, esperamos `7`. Es un fallo intencional del comando, útil para distinguirlo de una conexión que no llega a ejecutarlo.

Un retorno `255` suele indicar un error del cliente/conexión, pero el comando remoto también podría devolver `255`. Examinar stderr y el diagnóstico antes de decidir su origen.

## 8. Probar una identidad ya desplegada

Este paso utiliza una clave privada de laboratorio **que ya exista y cuya pública esté autorizada en esa cuenta**. No sustituir `-i` por una ruta de privada del servidor.

```sh
ssh -F ./ssh-lab.conf -i ./id_ed25519_lab -o IdentitiesOnly=yes ssh-lab hostname
```

**Qué estás viendo.** `-i` selecciona la identidad indicada. `IdentitiesOnly=yes` limita las identidades ofrecidas a las configuradas; no desactiva el agente ni significa «sin frase de paso». Si el archivo está cifrado puede pedirla. Las demás identidades explícitas que aparezcan en la configuración seguirían siendo candidatas.

Si aún no hay una clave desplegada, registrar el paso como pendiente. La instalación y gestión completa de claves pertenece al siguiente bloque; la [nota existente de primer uso](../../notas/ssh-claves-primer-uso.md) ofrece una introducción.

## 9. Comprobar el comportamiento sin interacción

Después de verificar la confianza del host, probar:

```sh
ssh -F ./ssh-lab.conf -o BatchMode=yes ssh-lab hostname
```

**Qué estás viendo.** El cliente no debe detenerse solicitando contraseña o confirmación de host. Puede autenticarse con un método disponible sin interacción, por ejemplo una identidad ya utilizable. Si la cuenta solo permite una contraseña que hay que escribir, el intento debe fallar; eso no implica que las credenciales sean incorrectas.

`BatchMode` no autoriza un host desconocido ni convierte cualquier autenticación en autenticación por clave. Registrar por separado el resultado del transporte, la confianza y el método de usuario.

## 10. Obtener diagnóstico de un fallo

Volver al cliente y reproducir una sola conexión con diagnóstico:

```sh
ssh -v -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Buscar el orden de las fases: destino/puerto, conexión, negociación, comprobación de host, identidad ofrecida, autenticación y comando. No confundir una pública ofrecida o aceptada para consulta con una autenticación completada.

Si hace falta más detalle:

```sh
ssh -vvv -E ./ssh-debug.log -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** `-vvv` aumenta el nivel hasta el máximo documentado y `-E` añade diagnóstico a `ssh-debug.log`. El archivo es acumulativo: puede contener intentos anteriores. No asumir que contiene un único intento ni que esté libre de nombres, direcciones, rutas o comandos sensibles. `-E` no es una captura íntegra de toda la sesión ni sustituye stdout/stderr del proceso remoto.

## 11. Interpretar los fallos por su fase

| Mensaje o síntoma | Hipótesis inicial | Comprobación útil |
| --- | --- | --- |
| No se encuentra `ssh` | Falta el cliente o no se resuelve su ruta. | Revisar ubicación del ejecutable y PATH. |
| `Could not resolve hostname` | No se resuelve el nombre o no se aplicó el alias esperado. | Revisar `-F`, `HostName` y resolución del cliente. |
| `Connection refused` | El destino respondió rechazando la conexión; puede faltar escucha o existir un rechazo activo. | Comprobar dirección, puerto, servicio y firewall. |
| `Connection timed out` | No se completó a tiempo alguna fase de establecimiento. | Revisar ruta, filtrado, respuesta y negociación; el mensaje exacto aporta contexto. |
| `Host key verification failed` | No se puede establecer confianza conforme a la política. | Revisar huella, archivo aplicable, permisos y posibilidad de interacción. |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | La clave no coincide con la referencia conocida. | Identificar la causa por otro canal antes de modificar confianza. |
| `Permission denied (…)` al autenticar | Los métodos completados no satisfacen la política para esa cuenta. | Revisar usuario, identidad, firma, segundo factor y logs del servidor. |
| `Permission denied` al leer un archivo remoto | La cuenta ya puede estar autenticada, pero carece de autorización sobre el recurso. | Comprobar permisos del recurso y cuenta efectiva. |
| `Too many authentication failures` | Se agotaron intentos; a veces se ofrecieron demasiadas identidades. | Ver qué claves se ofrecen y delimitar las configuradas. |

Estos textos son patrones orientativos; no acreditan una causa única. Si está disponible la consola del servidor, contrastar el mismo intento en sus registros y conservar hora, usuario y origen necesarios para correlacionarlo.

## 12. Evidencia y cierre de la práctica

| Caso | Qué registrar | Estado inicial |
| --- | --- | --- |
| Cliente | SO/shell, ruta del binario y versión. | Pendiente |
| Destino | Cuenta, dirección, puerto y configuración efectiva. | Pendiente |
| Host | Tipo de clave, comparación de fingerprint y procedencia de la referencia. | Pendiente |
| Sesión | Identidad remota observada y salida limpia. | Pendiente |
| Comando | stdout, stderr y retorno, incluido `exit 7`. | Pendiente |
| Identidad opcional | Clave utilizada, sin privada/passphrase, y método completado. | Pendiente |
| Lote | Resultado con BatchMode y explicación de éxito/fallo. | Pendiente |
| Diagnóstico | Última fase completada y causa confirmada o hipótesis pendiente. | Pendiente |

Conservar la configuración y los archivos de confianza del laboratorio si se repetirán los casos. Para retirarlos, cerrar las sesiones, confirmar la carpeta de trabajo y eliminar **solo los archivos de ese ejercicio** mediante el gestor de archivos. No borrar `~/.ssh` ni las bases de confianza normales.

La práctica no cambia la configuración del servidor. Si durante un laboratorio posterior se modifica `sshd`, habrá que documentar validación, acceso alternativo y reversión antes de aplicar el cambio.

## Fuentes y relación con el inventario

- [ssh(1), referencia Portable 10.6p1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1).
- [ssh_config(5), referencia Portable 10.6p1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5).
- [ssh-keygen(1), inspección de fingerprints](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1).
- [Referencia detallada de este bloque](03-referencia-conexion.md).
- [Cobertura y estado](README.md#cobertura-y-estado): conexión, quoting, confianza, identidad, sesión y diagnóstico; ningún caso se marca ejecutado por estar descrito aquí.
