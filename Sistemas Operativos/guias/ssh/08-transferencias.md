# SSH · Transferencias con SFTP y SCP

[Índice](README.md) · [Referencia de transferencias](09-referencia-transferencias.md) · [rsync sobre SSH](10-rsync-sobre-ssh.md)

El objetivo es copiar archivos en ambas direcciones, comprobar su contenido y reanudar únicamente cuando el parcial corresponde al mismo origen. Incluye ejecución por lotes y distingue contenido, metadatos y permisos.

**Estado:** documentado con OpenSSH Portable 10.6p1; todos los ensayos pendientes. Las salidas se describen como criterios, no como capturas. El recorrido usa cliente Linux/Bash y servidor Linux con cuenta ordinaria, shell y subsistema SFTP operativos. Un servidor SFTP confinado puede presentar otra raíz o impedir los comandos SSH usados para preparar/comprobar; requiere adaptar el laboratorio.

## 1. Elegir herramienta y preparar acceso

| Herramienta | Qué utiliza | Cuándo resulta útil |
| --- | --- | --- |
| `sftp` | Protocolo SFTP sobre SSH; intérprete interactivo o lote. | Navegar, subir/descargar y reanudar archivos concretos. |
| `scp` actual de referencia | SFTP por defecto; `-O` solicita el protocolo SCP heredado. | Copias indicadas desde una orden del shell. |
| `rsync` sobre SSH | Protocolo rsync entre ejecutables locales/remotos, transportado por SSH. | Actualizar árboles y reutilizar datos existentes; ver su práctica separada. |

SFTP no es FTP con TLS. Autenticarse por SSH tampoco garantiza que el servidor autorice el subsistema, la ruta o su escritura.

Continuar desde `ssh-claves.conf` y el alias `ssh-lab-key` del [bloque de claves](04-claves-y-agente.md). Revisar destino, cuenta, puerto real, pública autorizada y host verificado. Los datos `192.0.2.10`, `2222` y `alumno` de ejemplos anteriores son ficticios; no cambiar el servidor para hacerlos coincidir.

Ese archivo selecciona una privada explícita, `IdentityAgent none`, `IdentitiesOnly yes` y el método público. Puede pedir su frase de paso en modo interactivo. Los lotes necesitarán una identidad utilizable sin interacción, como un agente dedicado; no quitar el cifrado de la privada para resolverlo.

Registrar rutas/versiones de `ssh`, `sftp` y `scp`. `sftp version` dentro de su intérprete muestra versión del protocolo, no sustituye el registro del paquete/build. No asumir que `sftp -V` existe por analogía con `ssh -V`.

## 2. Crear datos propios de laboratorio

Permanecer en la misma carpeta del cliente que contiene la configuración y privada. El nombre `xfer-lab-20261022` debe estar libre; si existe, elegir otro y cambiar **todas** las rutas de la guía.

```bash
mkdir -m 700 ./xfer-lab-20261022 &&
mkdir ./xfer-lab-20261022/origen ./xfer-lab-20261022/recibidos &&
mkdir ./xfer-lab-20261022/origen/sub &&
printf 'Contenido estable para la prueba de transferencia.\n' > "./xfer-lab-20261022/origen/nota con espacios.txt" &&
printf 'Informe de laboratorio.\n' > ./xfer-lab-20261022/origen/sub/informe.txt
```

**Qué estás viendo.** `mkdir` sin `-p` evita reutilizar silenciosamente la raíz de un ejercicio anterior. `&&` detiene la cadena si falla un paso. Son datos de texto propios, sin secretos ni enlaces; mantenerlos sin cambios durante las comprobaciones.

Crear la raíz remota desde la cuenta de laboratorio:

```bash
ssh -T -F ./ssh-claves.conf ssh-lab-key 'mkdir -m 700 "$HOME/xfer-lab-20261022" && mkdir "$HOME/xfer-lab-20261022/scp" "$HOME/xfer-lab-20261022/sftp" "$HOME/xfer-lab-20261022/rsync"'
```

**Qué estás viendo.** Se crean directorios nuevos bajo el home remoto, no bajo el cliente. Las comillas simples del shell local conservan `$HOME` para que lo interprete la shell remota. Si ya existe la raíz o falla la creación, detenerse y elegir otra; no borrar contenido para continuar.

La práctica presupone que el directorio inicial SFTP corresponde a ese home. Confirmarlo con `pwd` antes de usar rutas relativas. Un chroot, un comando forzado o una política distinta pueden invalidar esa suposición.

## 3. Copiar y recuperar con scp

En Bash local:

```bash
scp -p -F ./ssh-claves.conf "./xfer-lab-20261022/origen/nota con espacios.txt" ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** Se sube un archivo local a un directorio remoto existente. El shell recibe la ruta con espacios como un argumento. `-p` solicita preservar tiempos y modo; **no** selecciona puerto, que se toma de configuración o `-P`. No acredita conservación de propietario, ACL o atributos extendidos.

Después:

```bash
scp -F ./ssh-claves.conf "ssh-lab-key:xfer-lab-20261022/scp/nota con espacios.txt" ./xfer-lab-20261022/recibidos/scp-nota.txt
```

**Qué estás viendo.** Se descarga el archivo remoto con un nombre local nuevo. Un destino existente puede ser sobrescrito; scp no ofrece un dry-run general ni una reanudación equivalente a reget. Leer el retorno inmediatamente mediante `$?` antes de otra orden.

Para el subdirectorio:

```bash
scp -r -F ./ssh-claves.conf ./xfer-lab-20261022/origen/sub ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** El directorio remoto `scp` ya existe, por lo que esperamos `scp/sub/informe.txt`. Confirmar la forma del árbol; no trasladar automáticamente a scp las reglas de barra final de rsync. `scp -r` sigue enlaces simbólicos al recorrer el origen: comprobar qué contienen árboles reales antes de copiarlos.

La interfaz `scp` de la referencia usa SFTP por defecto. No añadir `-O` para “hacerla más segura” ni para omitir un error sin diagnóstico: activa un protocolo distinto que utiliza la shell remota y cambia el tratamiento de nombres/comodines.

## 4. Transferir desde el intérprete SFTP

Abrir desde el cliente:

```sh
sftp -F ./ssh-claves.conf ssh-lab-key
```

**Qué estás viendo.** La autenticación SSH precede a la apertura del subsistema. Una conexión SSH correcta con rechazo del subsistema requiere revisar configuración/política del servidor, no volver a instalar públicas sin evidencia.

En el prompt `sftp>`, ejecutar estas órdenes **sin copiar el prompt**:

```text
pwd
lpwd
lcd ./xfer-lab-20261022/origen
cd xfer-lab-20261022/sftp
put "nota con espacios.txt"
get "nota con espacios.txt" "../recibidos/sftp-nota.txt"
put -R sub sub
ls -ln
bye
```

**Qué estás viendo.**

- `pwd` y `cd` se refieren al servidor; `lpwd` y `lcd` al cliente.
- `put` lee la ruta local y escribe la remota; `get` realiza el recorrido inverso.
- El destino de `get` es relativo al directorio local cambiado con `lcd`.
- `put -R` copia el subdirectorio; SFTP no sigue enlaces simbólicos en el recorrido recursivo.
- `ls -ln` muestra el listado remoto largo y datos numéricos de usuario/grupo; no demuestra por sí solo acceso de escritura.
- `bye` cierra el intérprete. Un error interactivo anterior puede no quedar representado como fallo global al terminar: revisar el resultado de cada orden y verificar los archivos.

Aquí las comillas pertenecen al parser SFTP; no son las comillas de un comando de shell remoto. Los patrones `*?[` tienen su propia expansión y deben tratarse con cuidado. La práctica utiliza nombres constantes sin caracteres glob; no concatenar entradas no confiables para formar un lote.

## 5. Comprobar integridad y metadatos

Comparar los archivos recuperados con el origen:

```bash
sha256sum "./xfer-lab-20261022/origen/nota con espacios.txt" ./xfer-lab-20261022/recibidos/scp-nota.txt ./xfer-lab-20261022/recibidos/sftp-nota.txt
```

**Qué estás viendo.** El primer campo es el resumen del contenido y el resto identifica el archivo. Los tres resúmenes deben coincidir. Los nombres distintos son deliberados. Tamaño coincidente o una barra al 100 % no sustituyen esta comparación.

Para contrastar también la copia remota, ejecutar por separado y registrar el retorno de cada orden:

```bash
sha256sum "./xfer-lab-20261022/origen/nota con espacios.txt"
ssh -T -F ./ssh-claves.conf ssh-lab-key 'sha256sum "$HOME/xfer-lab-20261022/scp/nota con espacios.txt" "$HOME/xfer-lab-20261022/sftp/nota con espacios.txt"'
```

**Qué estás viendo.** Comparar los resúmenes, no las líneas completas: los prefijos de ruta difieren. La comprobación remota necesita shell/herramienta disponible y confianza en ambos extremos; no es una prueba independiente frente a un servidor comprometido.

Comprobar también `sub/informe.txt` en ambos destinos si se quiere aceptar la copia del árbol. Para metadatos, consultar modos, propietario y tiempos con las herramientas del sistema: un hash no mide ACL, permisos, enlaces ni marcas temporales. Leer un archivo para calcular su hash puede afectar a atime según el montaje.

En un cliente Windows nativo puede usarse `Get-FileHash -Algorithm SHA256` para archivos locales. Las herramientas, rutas y conservación de permisos/tiempos requieren ensayo propio; los comandos Bash y la creación de prefijos del siguiente apartado no se atribuyen a PowerShell.

## 6. Reanudar sobre un prefijo conocido

SFTP reanuda a partir del tamaño del parcial; **no demuestra que ese prefijo coincida**. No utilizar `-a` o reget/reput sobre una copia completa distinta, un origen modificado ni un parcial de procedencia desconocida.

Para un caso reproducible sin cortar la red, preparar dos prefijos locales de ocho bytes del origen estable. Las rutas nuevas deben seguir libres:

```bash
test ! -e ./xfer-lab-20261022/recibidos/reanudada.txt &&
test ! -e ./xfer-lab-20261022/recibidos/prefijo.txt &&
head -c 8 "./xfer-lab-20261022/origen/nota con espacios.txt" > ./xfer-lab-20261022/recibidos/reanudada.txt &&
head -c 8 "./xfer-lab-20261022/origen/nota con espacios.txt" > ./xfer-lab-20261022/recibidos/prefijo.txt
```

**Qué estás viendo.** Se fabrican parciales **conocidos** dentro de la carpeta propia recién creada. No son evidencia de una interrupción real. Si las rutas están ocupadas, detenerse; no truncar archivos anteriores. No permitir modificaciones concurrentes ni enlaces introducidos por terceros en esa carpeta.

Abrir otra sesión SFTP y ejecutar:

```text
lcd ./xfer-lab-20261022
cd xfer-lab-20261022/sftp
reget "nota con espacios.txt" "recibidos/reanudada.txt"
put "recibidos/prefijo.txt" "subida-reanudada.txt"
reput "origen/nota con espacios.txt" "subida-reanudada.txt"
bye
```

**Qué estás viendo.** `reget` continúa la descarga local conocida. El `put` posterior instala otro prefijo conocido con un nombre remoto nuevo y `reput` continúa esa subida. Ambos equivalen a las variantes `get -a` y `put -a`. Mantener origen y nombres entre pasos; no reanudar el archivo equivocado porque su tamaño parezca razonable.

Comprobar después:

```bash
sha256sum "./xfer-lab-20261022/origen/nota con espacios.txt" ./xfer-lab-20261022/recibidos/reanudada.txt
ssh -T -F ./ssh-claves.conf ssh-lab-key 'sha256sum "$HOME/xfer-lab-20261022/sftp/subida-reanudada.txt"'
```

**Qué estás viendo.** Los resúmenes deben coincidir con el origen. El ensayo de interrupción real requiere además un archivo suficientemente grande, control del proceso concreto y registro del estado del parcial; no desconectar una interfaz ni reiniciar sshd para simularlo.

Como caso negativo pendiente, usar otra copia desechable con un prefijo distinto y demostrar que la reanudación puede dejar contenido incorrecto. No utilizar la pública/privada ni archivos ajenos como datos de esa prueba.

## 7. Ejecutar un lote con autenticación preparada

Guardar `xfer-lab-20261022/transfer.sftp` con este contenido:

```text
lcd ./xfer-lab-20261022/origen
cd xfer-lab-20261022/sftp
put "nota con espacios.txt" "lote-nota.txt"
get "lote-nota.txt" "../recibidos/lote-nota.txt"
bye
```

**Qué estás viendo.** El archivo contiene órdenes SFTP, no órdenes Bash. Revisarlo antes de ejecutarlo: algunas órdenes del intérprete pueden modificar o borrar datos. Este lote utiliza únicamente nombres del ejercicio.

`sftp -b` activa modo no interactivo de autenticación en esta referencia. El `IdentityAgent none` del archivo original debe sustituirse deliberadamente si se utiliza un agente. En Bash local, usar uno dedicado:

```bash
(
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    agent_env=$(ssh-agent -s -t 15m) || exit 1
    eval "$agent_env"
    trap 'ssh-agent -k >/dev/null' EXIT
    ssh-add -t 10m ./id_ed25519_lab || exit 1
    sftp -F ./ssh-claves.conf -o IdentityAgent=SSH_AUTH_SOCK -b ./xfer-lab-20261022/transfer.sftp ssh-lab-key
    transfer_rc=$?
    printf 'Retorno del lote: %s\n' "$transfer_rc"
    exit "$transfer_rc"
)
```

**Qué estás viendo.** Se conserva el agente de la terminal exterior y se carga la identidad mediante su prompt local. La conexión del lote usa el socket de ese subshell. El trap cierra ese agente al salir, salvo una terminación que impida ejecutar el trap. Evaluar solo la salida del ejecutable local de confianza; ver el [bloque del agente](04-claves-y-agente.md#8-usar-un-agente-de-forma-controlada).

Se espera retorno cero y hash de `lote-nota.txt` coincidente con el origen. Si no hay una identidad utilizable sin interacción, registrar el paso pendiente o el fallo de autenticación; no desactivar host checking ni introducir la frase en el lote.

Preparar después un **segundo lote desechable** cuyo primer get pida un nombre remoto inexistente y cuyo siguiente put escriba `no-debe-subirse.txt` en la raíz del ejercicio. Repetir la invocación con ese archivo: debe detenerse en el error con retorno no cero y sin crear la segunda salida. Comprobar esa ausencia en una sesión nueva. Anteponer `-` a una orden suprime su parada por error y cambia esa garantía; `@` solo suprime eco de la orden, no la convierte en secreta.

## 8. Comparar recursión, límites y nombres

| Caso | Qué debe distinguirse |
| --- | --- |
| Enlace simbólico dentro del árbol | scp -r lo sigue; SFTP recursivo no lo sigue; rsync -a lo conserva como enlace. |
| Espacios | Shell local, parser SFTP y protocolo heredado no tienen las mismas reglas de quoting. |
| Nombre local con `:` | En scp puede parecer una especificación remota; usar ruta explícita como `./nombre:parte`. |
| Varios orígenes | El destino debe poder recibir un conjunto; verificar que sea un directorio y no un nombre de archivo. |
| Destino existente | Puede sobrescribirse o cambiar metadatos; ninguna copia supone una transacción con rollback. |
| `scp/sftp -l` | La unidad documentada es Kbit/s; el parser usa escala de 1024. No confundir con KiB/s ni con `rsync --bwlimit`. |
| SCP heredado `-O` | Requiere soporte y ejecución de shell remota; no se ensaya como sustitución automática. |

La comparación de enlaces debe usar únicamente enlaces de prueba que apunten a datos propios del laboratorio, sin ciclos. Registrar qué entradas se copiaron y con qué tipo; un hash del archivo referido no demuestra conservación del enlace.

## 9. Diagnóstico, reversión y aceptación

| Síntoma | Comprobación |
| --- | --- |
| SSH autentica, SFTP falla | Disponibilidad/autorización del subsistema, comando forzado y raíz presentada. |
| `Permission denied` durante put/get | Cuenta efectiva, ruta, permisos/ACL, cuotas y política de lectura/escritura. |
| Archivo no encontrado | Directorio local/remoto, comillas, expansión de glob y namespace del servidor. |
| Reanudación termina, hash difiere | Origen o parcial distintos; retirar esa copia del uso y repetir desde una copia limpia. |
| Lote termina antes de lo previsto | Primera orden que falla, sus rutas y retorno; comprobar efectos anteriores ya realizados. |
| Retorno cero al salir del intérprete | Revisar cada orden interactiva; no inferir que todas fueron correctas. |
| Copia sin progreso visible | TTY, modo silencioso/batch y salida redirigida; el silencio no determina el resultado. |

No hay rollback general: un fallo puede dejar archivos completos, parciales o metadatos cambiados. El ejercicio separa destinos para poder identificar sus efectos. Al terminar, cerrar sesiones, revisar raíces y retirar únicamente datos/copias de ese ejercicio mediante el procedimiento del sistema; no borrar home, claves o directorios remotos calculados sin comprobar su ubicación.

- [ ] Versiones, identidad, host, puerto y raíz SFTP registrados.
- [ ] Copia/subida/descarga con espacios y árbol confirmadas por ubicación y contenido.
- [ ] Metadatos comprobados por separado del hash.
- [ ] Reget/reput sobre prefijo conocido e inmutable producen contenido correcto.
- [ ] Parcial incoherente detectado como fallo de integridad en datos desechables.
- [ ] Lote correcto y lote fallido con parada/efectos anteriores comprobados.
- [ ] Diferencias de recursión/enlaces y unidades de límite registradas.
- [ ] Recursos creados y retirada final identificados; ninguna prueba se marca ejecutada por estar escrita.

## Fuentes y cobertura

- [scp(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1) y [sftp(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1), Portable 10.6p1.
- [scp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c), [sftp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c) y [sftp-client.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-client.c): contraste de parser, retorno y copia.
- [Referencia desarrollada](09-referencia-transferencias.md): 11 opciones, nueve órdenes y flags de ls.
- [rsync sobre SSH](10-rsync-sobre-ssh.md): herramienta externa y alcance introductorio.

Consulta: 22 de octubre de 2026. Desarrollo parcial de SSH-T06, SSH-C027/C028/C029 y SSH-P04; SFTP-only, transferencias remoto-remoto y todas las opciones restantes siguen pendientes.
