# SSH · Referencia de conexión básica

[Índice](README.md) · [Fundamentos](01-fundamentos.md) · [Práctica](02-conexion-basica.md)

Esta referencia desarrolla **16 opciones de `ssh` y seis directivas de cliente** relacionadas con el primer bloque. Cada unidad conserva un enlace al inventario que la originó. Las demás opciones siguen en su [catálogo versionado](../../../Documentaciones/guiones/ssh/cli.md).

## Alcance y evidencia

| Campo | Referencia |
| --- | --- |
| Producto | OpenSSH Portable 10.6p1. |
| Fuente fijada | Commit `a8c72b842423f0774f542d3c2197247c3dd28d74` del repositorio upstream. |
| Plataforma | Semántica upstream; paths y permisos Unix donde se indica. Linux y Windows deben comprobarse con el ejecutable utilizado. |
| Privilegios | Cliente de usuario ordinario; necesita acceso a sus archivos y al destino. Ninguna de estas opciones concede administración remota. |
| Estado | Documentado mediante manuales y lectura de código; ejemplos y casos pendientes de prueba funcional. |
| Entorno de ejemplos | El descrito en la práctica; datos ficticios que deben sustituirse. |
| Persistencia | Las opciones valen para la invocación. Archivos de confianza, logs y otros efectos que se produzcan pueden persistir. |

**Los valores predeterminados de las fichas son upstream.** Una configuración efectiva puede cambiarlos antes de conectar. No atribuir automáticamente esos defaults a cualquier paquete Linux o Windows OpenSSH.

## Sintaxis, destinos y argumentos remotos

```text
ssh [opciones] [usuario@]host [comando [argumentos...]]
ssh [opciones] ssh://[usuario@]hostname[:puerto] [comando [argumentos...]]
```

En URI, un literal IPv6 se delimita con corchetes: `ssh://alumno@[2001:db8::10]:2222`. Sin usuario explícito se utiliza el que resulte de configuración/default. Mantener las opciones antes del destino facilita interpretar la orden.

```sh
ssh -F ./ssh-lab.conf -- ssh-lab hostname
```

**Qué estás viendo.** `--` termina las opciones del cliente. El alias sigue siendo el destino y `hostname` el comando remoto. No convierte los argumentos remotos en una estructura independiente del shell.

El shell local interpreta primero sus comillas y expansiones. Después, este cliente concatena el comando y los argumentos para enviarlos; el servidor los ejecuta conforme a su shell/política. Las comillas locales no garantizan que las fronteras de un argv arbitrario lleguen intactas al proceso remoto. En esta primera práctica se usan comandos constantes; no concatenar entradas no confiables para construir comandos.

En ejecución ordinaria, SSH devuelve el retorno del comando remoto o `255` ante un error SSH. Hay salidas locales específicas, como versión `0` o error de apertura del log `1`, y un comando remoto también puede devolver `255`. Por tanto, siempre relacionar retorno, stderr y fase completada.

## Reglas comunes para los casos

Cada lista de casos es una **comprobación pendiente**, no un resultado observado. Registrar versión, configuración, acción, stdout/stderr, código y criterio de éxito. Las comprobaciones con `-G` inspeccionan configuración; no sustituyen conexiones y pruebas del servidor.

La mayoría de los argumentos requeridos ausentes o valores rechazados producen error local de uso/configuración. El texto exacto y algunos códigos dependen del punto de fallo. No intentar corregir un error local desactivando controles del servidor.


<a id="ssh-r-opt-6c"></a>

## -l · usuario remoto

Unidad: [SSH-I-SSH-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6c). Fuente: [ssh(1):410](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L410).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Nombre de cuenta, obligatorio para esta opción. |
| Predeterminado | User efectivo; si no se ha fijado, nombre del usuario local. |
| Repetición y precedencia | La primera asignación aplicable de usuario prevalece en el parser 10.6p1. No combinar formas contradictorias. |
| Relación con configuración | User |
| Alcance y efectos | Selecciona la cuenta solicitada; no la crea ni concede privilegios. |

Usar una cuenta distinta de la local es normal. Un usuario indicado antes mediante -l o -o User puede impedir que otro -l o el usuario del destino lo reemplace. Poner todas las opciones antes del destino y elegir una sola forma evita depender de ese orden. El cliente también valida nombres introducidos por CLI; esa validación y los nombres admitidos por el servidor son controles distintos.

```sh
ssh -F ./ssh-lab.conf -l alumno ssh-lab hostname
```

**Qué estás viendo.** Comprobar user con -G e identidad remota con id. Un fallo de cuenta puede verse como autenticación denegada sin revelar si el usuario existe.

Casos que deben comprobarse:

- [ ] Nombre válido y usuario no autorizado: correlacionar con el servidor sin deducir existencia solo del error.
- [ ] -l sin argumento: error de uso; un argumento vacío/no válido no es una cuenta automática.
- [ ] Dos -l y -l frente a usuario@host: comprobar la primera asignación en esta referencia.
- [ ] Cuenta con restricciones: distinguir autenticación, shell y permisos del comando.

<a id="ssh-r-opt-70"></a>

## -p · puerto del servidor

Unidad: [SSH-I-SSH-OPT-70](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-70). Fuente: [ssh(1):526](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L526).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Puerto TCP; usar un número decimal 1…65535. El parser también consulta nombres de servicio TCP del sistema. |
| Predeterminado | Port efectivo; normalmente 22 si no se configura otro. |
| Repetición y precedencia | La primera asignación efectiva de puerto se conserva; no funciona como un selector en el que siempre gana el último -p. |
| Relación con configuración | Port |
| Alcance y efectos | Elige el destino TCP. No cambia la escucha ni el firewall del servidor. |

El rango numérico lo valida el cliente. Además, la función a2port permite resolver un nombre mediante la base de servicios TCP del host, por lo que esa variante depende del sistema. Para documentos y automatización conviene indicar el número conocido. El puerto de una URI se usa si no se había fijado otro.

```sh
ssh -F ./ssh-lab.conf -p 2222 ssh-lab hostname
```

**Qué estás viendo.** -G debe mostrar el puerto elegido; -v indica la dirección y puerto realmente intentados. Una configuración válida no demuestra que haya escucha.

Casos que deben comprobarse:

- [ ] 1 y 65535: límites numéricos del cliente; no asumir que haya servicio.
- [ ] 0, 65536 o nombre no resoluble como servicio: error local, sin autenticación.
- [ ] Puerto válido pero cerrado: investigar rechazo/timeout, servicio y firewall.
- [ ] Dos -p, -o Port y puerto de URI: comprobar precedencia antes de conectar.

<a id="ssh-r-opt-34"></a>

## -4 · usar IPv4

Unidad: [SSH-I-SSH-OPT-34](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-34). Fuente: [ssh(1):109](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L109).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | AddressFamily efectivo; any en upstream sin otra selección. |
| Repetición y precedencia | Repetir -4 es idempotente; al mezclar -4/-6, esta implementación conserva la última selección de esas flags. |
| Relación con configuración | AddressFamily inet |
| Alcance y efectos | Restringe la familia de direcciones utilizada para la conexión. |

No convierte una dirección IPv6 en IPv4 ni crea un registro A. Con un nombre de doble pila permite aislar problemas de familia, pero no demuestra que la otra familia funcione. Los bastiones y proxies añaden sus propias conexiones; sus decisiones no se deducen solo de esta flag.

```sh
ssh -4 -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Buscar addressfamily inet en -G y la dirección IPv4 intentada en -v. La resolución puede fallar si no hay dirección compatible.

Casos que deben comprobarse:

- [ ] Nombre con A y AAAA: seleccionar únicamente direcciones de la familia indicada.
- [ ] Destino sin IPv4: distinguir fallo de resolución/selección de un fallo de autenticación.
- [ ] Ruta IPv4 inexistente o filtrada: diagnosticar la red de esa familia.
- [ ] Mezcla -4/-6: verificar la selección efectiva, sin asumir fallback entre ambas.

<a id="ssh-r-opt-36"></a>

## -6 · usar IPv6

Unidad: [SSH-I-SSH-OPT-36](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-36). Fuente: [ssh(1):114](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L114).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | AddressFamily efectivo; any en upstream sin otra selección. |
| Repetición y precedencia | Repetir -6 es idempotente; con -4/-6 gana la última de esas selecciones en esta implementación. |
| Relación con configuración | AddressFamily inet6 |
| Alcance y efectos | Restringe la familia a IPv6. |

Necesita dirección, ruta y servicio accesibles por IPv6. Una conexión IPv4 previa no verifica esa disponibilidad. En una URI se usan corchetes para delimitar un literal IPv6 y su puerto; las direcciones de enlace local pueden necesitar identificar una interfaz según el sistema.

```sh
ssh -6 -p 2222 alumno@2001:db8::10 hostname
```

**Qué estás viendo.** El ejemplo usa una dirección de documentación que debe sustituirse. Buscar addressfamily inet6 y el literal IPv6 intentado; no confundir corchetes de URI con parte de la dirección.

Casos que deben comprobarse:

- [ ] Destino AAAA/IPv6 válido y ausencia de IPv6: resultados de transporte diferentes.
- [ ] Firewall IPv4 correcto pero IPv6 bloqueado: verificar la familia afectada.
- [ ] Literal IPv6 con puerto mediante URI: comprobar delimitadores y -p.
- [ ] Link-local con scope: documentar interfaz y soporte de la plataforma antes de usarlo.

<a id="ssh-r-opt-56"></a>

## -V · mostrar la versión

Unidad: [SSH-I-SSH-OPT-56](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-56). Fuente: [ssh(1):691](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L691).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento ni necesita destino. |
| Predeterminado | Sin esta opción se procesa la invocación normal. |
| Repetición y precedencia | La primera -V alcanzada termina el programa; no abre una sesión. |
| Relación con configuración | Sin directiva equivalente. |
| Alcance y efectos | Muestra la versión del cliente y sale con código 0 en el código upstream. |

La salida se escribe en stderr. Informa sobre el ejecutable invocado, no sobre el servidor ni sobre una conexión negociada. Esta salida temprana también significa que no se debe esperar que -E capture la versión como si fuera un log de sesión.

```sh
ssh -V
```

**Qué estás viendo.** Identificar la versión de OpenSSH y componentes que muestre el build. En PowerShell, comprobar que la ruta corresponde al cliente esperado.

Casos que deben comprobarse:

- [ ] Cliente en distintas rutas: distinguir qué copia está ejecutándose.
- [ ] Red no disponible: la consulta de versión no necesita conexión.
- [ ] stderr con código cero: no interpretar el canal de salida como prueba de fallo.
- [ ] -E combinado con -V: no confiar en que la versión se guarde en ese archivo.

<a id="ssh-r-opt-76"></a>

## -v · aumentar el diagnóstico

Unidad: [SSH-I-SSH-OPT-76](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-76). Fuente: [ssh(1):694](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L694).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | LogLevel efectivo; INFO en upstream sin otra selección. |
| Repetición y precedencia | Una -v activa DEBUG1; -vv y -vvv aumentan hasta DEBUG3. La mezcla con -q depende del estado y orden del parser. |
| Relación con configuración | LogLevel DEBUG1/DEBUG2/DEBUG3 |
| Alcance y efectos | Aumenta los mensajes del cliente; no cambia por sí sola la autenticación ni los permisos. |

El diagnóstico se emite por stderr salvo redirección de logging. Resulta útil localizar la última fase completada. Los mensajes pueden revelar nombres, IP, rutas, públicas o comandos; revisar su contenido antes de compartirlo.

```sh
ssh -vvv -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Distinguir selección de destino, conexión, clave de host, método de usuario y ejecución. Offering public key y Server accepts key no equivalen a autenticación completa.

Casos que deben comprobarse:

- [ ] -v/-vv/-vvv: registrar nivel y detalle sin cambiar la operación solicitada.
- [ ] Un cuarto -v sin flags contradictorias: el nivel no supera DEBUG3.
- [ ] -v junto a -q: comprobar la interacción del apéndice, no presuponer última opción gana.
- [ ] Error de transporte frente a retorno remoto: correlacionar fase, stderr y código.

<a id="ssh-r-opt-71"></a>

## -q · reducir mensajes del cliente

Unidad: [SSH-I-SSH-OPT-71](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-71). Fuente: [ssh(1):570](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L570).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | LogLevel efectivo; normalmente INFO. |
| Repetición y precedencia | Repetir -q mantiene QUIET; mezclar con -v altera el estado según el orden. |
| Relación con configuración | LogLevel QUIET |
| Alcance y efectos | Suprime la mayoría de advertencias y diagnóstico del cliente. No elimina la salida del comando remoto. |

Es útil cuando un procedimiento ya está controlado. No usar silencio como criterio de éxito: un comando puede seguir fallando, un parser puede escribir un error directo y stderr remoto puede contener datos propios.

```sh
ssh -q -T -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Se sigue esperando hostname en stdout. Leer el retorno y, si falta información, reproducir sin -q y con -v.

Casos que deben comprobarse:

- [ ] Conexión correcta: stdout remoto sigue presente.
- [ ] Comando remoto con stderr o retorno no cero: -q no lo convierte en éxito.
- [ ] Argumento/uso inválido: puede seguir habiendo un mensaje directo del cliente.
- [ ] Combinación con -v: validar el orden y evitar mezclarla en diagnóstico normal.

<a id="ssh-r-opt-46"></a>

## -F · elegir el archivo de configuración

Unidad: [SSH-I-SSH-OPT-46](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-46). Fuente: [ssh(1):236](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L236).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria o el valor especial none. |
| Predeterminado | Configuración personal ~/.ssh/config y configuración global del cliente según plataforma. |
| Repetición y precedencia | En este parser, una nueva -F sustituye la selección anterior; no acumula archivos. |
| Relación con configuración | Sin directiva equivalente; Include tiene otra función. |
| Alcance y efectos | Selecciona la configuración personal alternativa y omite la configuración global del cliente; none evita leer archivos de configuración. |

No desactiva por sí misma known_hosts, algoritmos ni políticas de confianza. Las rutas relativas usadas en el archivo tampoco se vuelven automáticamente relativas a su carpeta. En Windows, comprobar el ejecutable y sus convenciones antes de extrapolar rutas Unix.

```sh
ssh -F ./ssh-lab.conf -G ssh-lab
```

**Qué estás viendo.** Se espera la configuración resultante de ese archivo y las opciones CLI. Si no se puede leer un archivo indicado explícitamente, investigar la ruta y sus permisos.

Casos que deben comprobarse:

- [ ] Archivo existente, ruta relativa y ruta con espacios entre comillas.
- [ ] Archivo explícito inexistente/inaccesible: fallo local antes de conectar.
- [ ] -F none: defaults sin archivos, manteniendo otras fuentes de confianza que siguen configuradas por default.
- [ ] Dos -F: se elige el último archivo, no una fusión automática.

<a id="ssh-r-opt-47"></a>

## -G · imprimir la configuración efectiva

Unidad: [SSH-I-SSH-OPT-47](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-47). Fuente: [ssh(1):276](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L276).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; necesita un destino para evaluar la selección. |
| Predeterminado | Sin -G se continúa hacia la conexión. |
| Repetición y precedencia | Repetición idempotente: activa el modo de inspección. |
| Relación con configuración | Sin directiva equivalente. |
| Alcance y efectos | Imprime configuración y termina sin abrir una sesión SSH. La evaluación puede realizar otras acciones configuradas. |

Sirve para investigar Host, Match, Include y precedencia. No comprueba la escucha, la contraseña, la clave aceptada por el servidor ni la validez de sus restricciones. Match exec puede ejecutar un comando local y la canonicalización puede requerir resolución; -G no debe tratarse como un evaluador sin efectos de cualquier archivo ajeno.

```sh
ssh -F none -G -p 2222 -l alumno 192.0.2.10
```

**Qué estás viendo.** Buscar hostname, user, port, addressfamily y las directivas del bloque. La forma de imprimir defaults puede variar entre builds.

Casos que deben comprobarse:

- [ ] Configuración reducida propia: observar campos sin abrir sesión.
- [ ] Error de sintaxis: tratar el fallo del parser antes de investigar red.
- [ ] Servidor apagado: -G puede seguir funcionando porque no verifica la conexión.
- [ ] Archivo con Match exec/canonicalización: revisar efectos y procedencia antes de evaluarlo.

<a id="ssh-r-opt-6f"></a>

## -o · pasar una directiva en la línea de comandos

Unidad: [SSH-I-SSH-OPT-6F](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6f). Fuente: [ssh(1):508](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L508).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Una asignación de configuración, por ejemplo Keyword=value o una línea Keyword valor correctamente citada. |
| Predeterminado | El valor que resulte de los archivos y defaults de la directiva concreta. |
| Repetición y precedencia | Admite varias -o. La combinación depende de la directiva: algunas conservan el primer valor y otras acumulan. |
| Relación con configuración | La directiva indicada. |
| Alcance y efectos | Configura opciones del cliente para esta invocación; puede cambiar archivos, confianza o ejecución local según la clave elegida. |

El nombre de directiva es insensible a mayúsculas, pero sus valores no deben normalizarse sin consultar su gramática. Un argumento con espacios debe llegar como una sola asignación al ejecutable. -o no permite pasar cualquier opción interna de sshd: utiliza el catálogo cliente.

```sh
ssh -F ./ssh-lab.conf -o ConnectTimeout=5 -o ConnectionAttempts=1 ssh-lab hostname
```

**Qué estás viendo.** Verificar con -G cómo quedaron ambas directivas. Para valores complejos con espacios/quotes, preferir un archivo de configuración propio y comprobarlo.

Casos que deben comprobarse:

- [ ] Keyword=value y Keyword valor citado; argumento ausente y nombre desconocido.
- [ ] Valor válido/inválido según cada directiva y parser del build.
- [ ] Dos -o escalares frente a opciones acumulativas como IdentityFile: reglas diferentes.
- [ ] Asignación antes/después de una flag relacionada: comprobar precedencia; ver apéndice.

<a id="ssh-r-opt-69"></a>

## -i · seleccionar un archivo de identidad

Unidad: [SSH-I-SSH-OPT-69](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-69). Fuente: [ssh(1):296](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L296).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria a identidad privada; también puede ser una pública cuya privada correspondiente esté en el agente. |
| Predeterminado | Si no hay identidades explícitas, upstream incorpora sus rutas predeterminadas: id_rsa, id_ecdsa, id_ecdsa_sk, id_ed25519, id_ed25519_sk e id_mldsa44_ed25519 bajo ~/.ssh/. |
| Repetición y precedencia | Puede repetirse y coexistir con IdentityFile; el límite upstream es 100 entradas de identidad, con comprobación de duplicados. |
| Relación con configuración | IdentityFile |
| Alcance y efectos | Añade una identidad candidata; su uso puede requerir lectura, frase de paso, agente o dispositivo. |

No instala la pública en el servidor ni garantiza que sea la única identidad ofrecida. Si no se han fijado certificados con CertificateFile, se intenta localizar el certificado asociado añadiendo -cert.pub al nombre de identidad. El orden final también depende del agente y los certificados.

```sh
ssh -F ./ssh-lab.conf -i ./id_ed25519_lab -o IdentitiesOnly=yes ssh-lab hostname
```

**Qué estás viendo.** Buscar qué archivo se cargó, qué clave se ofrece y si la autenticación termina. Una ruta inexistente puede emitir warning y dejar que continúen otros métodos/identidades; no supone necesariamente un aborto inmediato.

Casos que deben comprobarse:

- [ ] Archivo correcto cifrado/sin cifrar; frase de paso ausente o incorrecta.
- [ ] Ruta inexistente/inaccesible, privada con permisos rechazados y pública utilizada con agente.
- [ ] Varias -i/IdentityFile, pública autorizada distinta y límite de entradas.
- [ ] Certificado asociado, identidades extra de agente y restricción con IdentitiesOnly.

<a id="ssh-r-opt-54"></a>

## -T · no asignar pseudoterminal

Unidad: [SSH-I-SSH-OPT-54](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-54). Fuente: [ssh(1):677](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L677).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | RequestTTY efectivo; auto en upstream sin otra selección. |
| Repetición y precedencia | Cada -T establece NO. La mezcla con -t depende del orden y estado. |
| Relación con configuración | RequestTTY no |
| Alcance y efectos | Solicita sesión/comando sin PTY; no desconecta stdin ni prohíbe una shell por sí misma. |

Es la elección habitual para tratar stdout, stderr y datos desde scripts. El servidor puede imponer restricciones o sustituir el comando. El programa remoto puede fallar si necesita un terminal, incluso con autenticación correcta.

```sh
ssh -T -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Comprobar el resultado del comando y la ausencia de comportamiento interactivo de terminal. No usar la mera ausencia de prompt como prueba de que la cuenta no abrió una shell.

Casos que deben comprobarse:

- [ ] Comando no interactivo: stdout/stderr y retorno conservados según el proceso.
- [ ] Programa que necesita terminal: diagnosticar el requisito, no cambiar claves.
- [ ] -T con entrada redirigida: stdin sigue siendo un canal disponible salvo -n u otra política.
- [ ] -T/-t en órdenes diferentes: comprobar RequestTTY efectivo.

<a id="ssh-r-opt-74"></a>

## -t · solicitar pseudoterminal

Unidad: [SSH-I-SSH-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-74). Fuente: [ssh(1):680](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L680).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | RequestTTY efectivo; auto en upstream. |
| Repetición y precedencia | -t solicita PTY; -tt lo fuerza aun sin TTY local. En el código 10.6p1, más repeticiones alternan YES/FORCE: no generalizar la regla a una cantidad arbitraria. |
| Relación con configuración | RequestTTY yes; -tt corresponde a force en el caso simple. |
| Alcance y efectos | Pide al servidor un PTY; no fuerza al servidor a autorizarlo. |

Utilizarlo para una aplicación que lo necesite. Un PTY puede cambiar eco, señales, finales de línea y el tratamiento de stdout/stderr. En automatización de datos conviene justificarlo y no añadir -tt por rutina.

```sh
ssh -t -F ./ssh-lab.conf ssh-lab "tty"
```

**Qué estás viendo.** En el servidor Linux del ejemplo, tty debería informar de un terminal si se concedió. Si el servidor deniega PTY, registrar el mensaje y la política.

Casos que deben comprobarse:

- [ ] -t con TTY local y sin TTY local: comparar la solicitud.
- [ ] -tt sin TTY local: solicitud forzada, sujeta a autorización del servidor.
- [ ] PTY prohibido por cuenta/clave/política: distinguirlo de fallo de autenticación.
- [ ] Repetición adicional y mezcla -T/-t: observar el estado del parser en la referencia fijada.

<a id="ssh-r-opt-6e"></a>

## -n · no leer la entrada estándar

Unidad: [SSH-I-SSH-OPT-6E](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6e). Fuente: [ssh(1):454](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L454).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | StdinNull efectivo; no en upstream. |
| Repetición y precedencia | Repetición idempotente: impide lectura de stdin. |
| Relación con configuración | StdinNull yes |
| Alcance y efectos | Evita que el cliente lea stdin para enviarlo a la sesión; no silencia stdout/stderr ni elimina toda interacción de autenticación. |

Puede evitar que ssh consuma la entrada de un bucle o pipeline local. No utilizarlo si el comando remoto necesita recibir datos de stdin. Tampoco equivale a BatchMode: la petición de contraseña/frase puede utilizar otros mecanismos de interacción.

```sh
ssh -n -T -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** hostname no necesita stdin, por lo que puede ejecutarse normalmente. Un comando como cat, usado sin argumentos en el servidor, verá fin de entrada en lugar de recibir el stream esperado.

Casos que deben comprobarse:

- [ ] Comando que no lee stdin frente a uno que lo necesita.
- [ ] Uso desde pipeline/bucle: comprobar que el cliente no consume datos ajenos.
- [ ] -n con autenticación interactiva: no asumir que se ha desactivado la pregunta.
- [ ] Comando remoto con retorno no cero: -n no modifica su criterio de éxito.

<a id="ssh-r-opt-45"></a>

## -E · añadir el diagnóstico a un archivo

Unidad: [SSH-I-SSH-OPT-45](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-45). Fuente: [ssh(1):218](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L218).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria a un archivo de log. |
| Predeterminado | El logging ordinario del cliente va a stderr. |
| Repetición y precedencia | La última ruta -E seleccionada es la utilizada; el archivo se abre en modo append. |
| Relación con configuración | Sin directiva cliente equivalente de archivo. |
| Alcance y efectos | Crea o abre un log local y añade mensajes del cliente. No es una copia integral de la sesión. |

El usuario necesita permiso sobre archivo/directorio. En Portable Unix se solicita modo 0600 al crear el archivo; no se restablecen automáticamente los permisos de uno existente. El código de esta versión termina con 1 si no logra abrirlo. -E no se combina con -y y no captura automáticamente stderr del comando remoto.

```sh
ssh -vvv -E ./ssh-debug.log -F ./ssh-lab.conf ssh-lab hostname
```

**Qué estás viendo.** Revisar el archivo por fecha/orden de intentos: append conserva entradas previas. Diferenciar diagnóstico cliente de stdout/stderr de la aplicación remota.

Casos que deben comprobarse:

- [ ] Archivo nuevo y existente: confirmar append, contenido y permisos.
- [ ] Directorio inexistente o archivo sin acceso: error local de apertura.
- [ ] Dos -E, combinación incompatible con -y y salida temprana con -V.
- [ ] Logs con rutas/IP/identidades: revisar antes de conservar o compartir evidencia.

<a id="ssh-r-opt-65"></a>

## -e · elegir el carácter de escape

Unidad: [SSH-I-SSH-OPT-65](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-65). Fuente: [ssh(1):223](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L223).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Un carácter de un byte, notación de control ^X admitida por el parser o none. |
| Predeterminado | EscapeChar efectivo; ~ en upstream. |
| Repetición y precedencia | En este parser, la última asignación de -e determina el carácter. |
| Relación con configuración | EscapeChar |
| Alcance y efectos | Controla escapes reconocidos al inicio de línea en sesiones con PTY; no procesa el quoting del comando. |

Con el carácter predeterminado, ~. desconecta y ~~ envía una tilde literal al inicio de línea. none desactiva los escapes del cliente. Un carácter Unicode multibyte no equivale necesariamente a un byte aceptado por esta opción.

```sh
ssh -e none -F ./ssh-lab.conf ssh-lab
```

**Qué estás viendo.** En una sesión con PTY, las secuencias del carácter habitual dejan de actuar como escapes del cliente. Para salir de forma normal, usar exit en la shell remota.

Casos que deben comprobarse:

- [ ] Carácter predeterminado/alternativo y secuencia al inicio frente a mitad de línea.
- [ ] Carácter seguido de sí mismo para enviarlo literalmente; desconexión con punto.
- [ ] ^X, none y argumento de longitud inválida: comprobación del parser.
- [ ] Sin PTY: no atribuirle el mismo comportamiento interactivo que a una sesión con terminal.

## Directivas utilizadas mediante -o o archivo

Estas seis fichas complementan las opciones anteriores. No abarcan todo ssh_config: cada directiva restante conserva su estado en el inventario. Los alias true/false proceden del parser fijado; para ejemplos mantenibles se utiliza yes/no.


<a id="ssh-r-cfg-batchmode"></a>

### BatchMode

Unidad: [SSH-I-CLIENT-BATCHMODE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-batchmode). Fuente: [ssh_config(5):363](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L363).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes/no; el parser también acepta true/false. |
| Predeterminado upstream | no. |
| Repetición y selección | Valor escalar; se conserva la primera asignación efectiva. |
| Alcance y efectos | Desactiva interacción, como peticiones de contraseña y confirmación de host, para la conexión. |

No selecciona por sí misma el método publickey y no autoriza claves de host. Una identidad utilizable sin interacción puede funcionar; una privada cifrada que todavía necesita intervención puede impedir la autenticación. Las políticas y proveedores externos también requieren contraste en el entorno.

```sh
ssh -F ./ssh-lab.conf -o BatchMode=yes ssh-lab hostname
```

**Qué estás viendo.** Comprobar que no se espera una respuesta interactiva y localizar la fase que permite continuar o provoca el fallo.

Casos que deben comprobarse:

- [ ] Host desconocido que necesita confirmación frente a host ya confiable.
- [ ] Clave/agente utilizable frente a contraseña que hay que escribir.
- [ ] Valor inválido y cambio mediante archivo/CLI; registrar valor efectivo.
- [ ] Éxito sin interacción no demuestra ausencia de segundo factor en la política general.

<a id="ssh-r-cfg-connecttimeout"></a>

### ConnectTimeout

Unidad: [SSH-I-CLIENT-CONNECTTIMEOUT](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-connecttimeout). Fuente: [ssh_config(5):694](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L694).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Tiempo no negativo en segundos; el parser 10.6p1 admite unidades s/m/h/d/w, sus mayúsculas y composición, además de none. Ver límites del parser más abajo. |
| Predeterminado upstream | Sin timeout explícito de esta opción; se utiliza el comportamiento TCP del sistema. |
| Repetición y selección | Escalar; none usa el valor centinela de no especificado y puede permitir una asignación posterior. |
| Alcance y efectos | Limita establecimiento TCP y handshake/intercambio de claves inicial. No limita la ejecución completa del comando ni la sesión. |

El parser convierte el tiempo a segundos enteros mediante convtime y rechaza valores fuera de su rango entero. En esta versión acepta fracciones en la parte de segundos y las convierte a entero: no tratar un valor fraccionario como temporizador de precisión. Cero no impone el timeout positivo de la práctica. El total real también depende de direcciones, intentos y fase; utilizar valores pequeños y deliberados como 5 segundos para el laboratorio.

```sh
ssh -F ./ssh-lab.conf -o ConnectTimeout=5 ssh-lab hostname
```

**Qué estás viendo.** Correlacionar el tiempo y mensaje con la fase. Un comando que dura más de cinco segundos después de conectar no tiene por qué terminar por esta opción.

Casos que deben comprobarse:

- [ ] 5, 5s y una composición admitida: inspeccionar conversión con -G.
- [ ] none y 0: distinguir ausencia de límite positivo de un timeout inmediato.
- [ ] Negativo, unidad no admitida, argumento ausente y conversión fuera del rango entero: error local.
- [ ] Destino con varias direcciones/intentos y comando lento tras autenticar: no asumir un deadline global.

<a id="ssh-r-cfg-connectionattempts"></a>

### ConnectionAttempts

Unidad: [SSH-I-CLIENT-CONNECTIONATTEMPTS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-connectionattempts). Fuente: [ssh_config(5):689](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L689).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Entero no negativo admitido por el parser, hasta INT_MAX del build. Para realizar conexiones usar al menos 1. |
| Predeterminado upstream | 1. |
| Repetición y selección | Escalar; primera asignación efectiva. |
| Alcance y efectos | Controla rondas de intento de conexión. Puede haber varias direcciones candidatas por host. |

El cliente espera un segundo entre rondas adicionales. Ese intervalo no incluye el tiempo consumido en cada conexión: tres intentos no equivalen a tres segundos totales. El código acepta cero, pero entonces no entra en el bucle de conexión; no usarlo para probar disponibilidad.

```sh
ssh -F ./ssh-lab.conf -o ConnectionAttempts=2 -o ConnectTimeout=5 ssh-lab hostname
```

**Qué estás viendo.** Con -v, buscar las direcciones intentadas y posibles reintentos. Si el primer intento funciona, no se fuerza una segunda conexión.

Casos que deben comprobarse:

- [ ] 1 frente a 2 con destino que rechaza o no responde.
- [ ] Host con varias direcciones: distinguir direcciones y rondas.
- [ ] 0 aceptado por parser y sin intento TCP según código; confirmar funcionalmente solo en laboratorio.
- [ ] Número negativo, texto no numérico, ausencia y overflow entero: error de configuración.

<a id="ssh-r-cfg-stricthostkeychecking"></a>

### StrictHostKeyChecking

Unidad: [SSH-I-CLIENT-STRICTHOSTKEYCHECKING](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-stricthostkeychecking). Fuente: [ssh_config(5):2037](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L2037).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes, ask, accept-new, no/off; el parser también admite true como yes y false como no. |
| Predeterminado upstream | ask. |
| Repetición y selección | Escalar; primera asignación efectiva. |
| Alcance y efectos | Determina cómo actuar frente a hosts nuevos y claves cambiadas. Puede producir confirmación, rechazo o escritura de confianza. |

yes exige confianza ya establecida por una fuente aplicable; ask puede solicitar aceptar una clave nueva; accept-new incorpora nuevas claves sin preguntar pero rechaza las cambiadas. no/off permite más situaciones, incluidas ciertas claves cambiadas sujetas a restricciones. Ese último comportamiento reduce la protección y no se utiliza como solución de la práctica. La escritura puede fallar aunque se haya aceptado continuar; revisar mensajes y el archivo.

```sh
ssh -F ./ssh-lab.conf -o StrictHostKeyChecking=yes ssh-lab hostname
```

**Qué estás viendo.** Con una referencia válida ya preparada se espera continuar. Con un host realmente desconocido, yes debe impedir la aceptación automática; no confundirlo con un error de contraseña.

Casos que deben comprobarse:

- [ ] Matriz de cada valor frente a host conocido, desconocido y clave cambiada, en entorno aislado.
- [ ] ask con y sin interacción; combinación con BatchMode.
- [ ] accept-new no verifica por canal independiente la primera clave ni acepta una clave cambiada.
- [ ] Archivo no escribible y fuentes globales/CA: comprobar qué referencia intervino.

<a id="ssh-r-cfg-identitiesonly"></a>

### IdentitiesOnly

Unidad: [SSH-I-CLIENT-IDENTITIESONLY](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-identitiesonly). Fuente: [ssh_config(5):1147](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1147).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes/no; true/false también aceptados por el parser. |
| Predeterminado upstream | no. |
| Repetición y selección | Escalar; primera asignación efectiva. |
| Alcance y efectos | Limita las identidades de autenticación a las configuradas por archivos/opciones, incluidas las predeterminadas cuando corresponda. |

No significa «no usar agente». El agente puede realizar la operación con una privada correspondiente a una pública seleccionada. También puede haber varias identidades y certificados explícitos. El objetivo es evitar ofrecer indiscriminadamente todas las identidades de agentes/proveedores, no sustituir las restricciones del servidor.

```sh
ssh -F ./ssh-lab.conf -i ./id_ed25519_lab -o IdentitiesOnly=yes ssh-lab hostname
```

**Qué estás viendo.** Con -v, relacionar las identidades configuradas con las ofrecidas y con la que completa la autenticación. La lista no se deduce únicamente de una -i.

Casos que deben comprobarse:

- [ ] Agente con varias identidades, con y sin la restricción.
- [ ] Pública seleccionada y privada correspondiente en agente.
- [ ] Varias IdentityFile/-i y certificados: todas las candidatas configuradas relevantes.
- [ ] Clave configurada no autorizada: no esperar que el servidor la acepte por esta opción.

<a id="ssh-r-cfg-userknownhostsfile"></a>

### UserKnownHostsFile

Unidad: [SSH-I-CLIENT-USERKNOWNHOSTSFILE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-userknownhostsfile). Fuente: [ssh_config(5):2210](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L2210).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Una o varias rutas separadas por espacios; none debe aparecer solo. Upstream admite como máximo 32 archivos de esta lista. |
| Predeterminado upstream | ~/.ssh/known_hosts y ~/.ssh/known_hosts2. |
| Repetición y selección | La primera lista efectiva se conserva; colocar varias rutas en esa lista, no asumir acumulación al repetir la directiva. |
| Alcance y efectos | Selecciona la base de confianza del usuario. Puede leerla y añadir información según la política; no elimina GlobalKnownHostsFile ni otras fuentes. |

Admite tilde, los tokens y las variables permitidos por el manual. none omite los archivos de usuario, pero no desactiva por sí solo toda comprobación de host. Una ruta relativa se refiere al directorio de trabajo. Para nombres con espacios usar quoting de configuración y verificarlo; la transmisión de comillas en argumentos nativos de PowerShell también depende de su versión.

```sh
ssh -F ./ssh-lab.conf -o UserKnownHostsFile=./known_hosts_ssh_lab ssh-lab hostname
```

**Qué estás viendo.** Revisar la ruta efectiva y qué referencia se lee o modifica. Un puerto no convencional se representa normalmente en la base con un identificador [host]:puerto.

Casos que deben comprobarse:

- [ ] Archivo nuevo/existente, directorio ausente y permisos de lectura/escritura.
- [ ] Varias rutas en una lista, repetición de directiva y límite de archivos.
- [ ] none solo frente a none mezclado con rutas: la mezcla se rechaza.
- [ ] Fuente global/CA que ya autoriza el host: no atribuir toda confianza al archivo local.

## Apéndice: reglas de precedencia que no debemos generalizar

La primera asignación efectiva es una regla frecuente en configuración, pero hay opciones que acumulan y flags que asignan directamente un estado. Las siguientes conclusiones proceden de la lectura de **ssh.c/readconf.c de 10.6p1**. Son predicciones de esa implementación, pendientes de ensayo con el binario del entorno.

Para inspeccionarlas sin leer archivos ajenos, utilizar `-F none -G` y un destino literal de documentación. No hay una conexión de sesión. Estas pruebas de configuración no verifican conectividad ni autenticación.

| Argumentos después de `ssh -F none -G` y antes de `alumno@192.0.2.10` | Campo esperado según el código | Explicación |
| --- | --- | --- |
| `-p 2222 -p 2200` | `port 2222` | La segunda -p encuentra el puerto ya asignado. |
| `-l uno -l dos` | `user uno` | La primera -l fija la cuenta antes de analizar el usuario del destino. |
| `-4 -6` | `addressfamily inet6` | Estas flags asignan la familia directamente. |
| `-6 -4` | `addressfamily inet` | La última de esas asignaciones decide. |
| `-T -t` | `requesttty yes` | -t cambia el estado NO a YES. |
| `-t -T` | `requesttty no` | -T establece NO. |
| `-t -t` | `requesttty force` | La segunda -t cambia YES a FORCE. |
| `-t -t -t` | `requesttty yes` | En este código, una -t aplicada a FORCE vuelve a YES. |
| `-v -q` | `loglevel QUIET` | -q asigna el nivel silencioso. |
| `-q -v` | `loglevel DEBUG1` | La primera -v inicializa su contador y selecciona DEBUG1. |
| `-v -q -v` | `loglevel FATAL` | El contador de -v ya estaba iniciado y el siguiente incremento parte del nivel fijado por -q. |

La representación textual de los niveles puede cambiar. El objetivo es confirmar el estado semántico, no exigir mayúsculas exactas. Para uso ordinario, elegir **-v o -q**, utilizar **-t o -tt** deliberadamente y evitar asignaciones contradictorias de usuario/puerto.

Ejemplo de inspección del puerto:

```sh
ssh -F none -G -p 2222 -p 2200 alumno@192.0.2.10
```

**Qué estás viendo.** Se espera conservar `2222` en la implementación fijada. Todavía no hemos contactado con ese puerto. Una futura versión o un fork debe comprobarse de nuevo antes de atribuirle esa regla.

## Errores de interpretación que conviene evitar

| Interpretación | Comprobación correcta |
| --- | --- |
| «No hay salida, así que funcionó». | Revisar código, stderr y resultado esperado del comando. |
| «-G demuestra que puedo entrar». | Solo muestra selección/configuración; aún faltan red, host, usuario y sesión. |
| «-i obliga a usar exclusivamente ese archivo». | Examinar todas las identidades configuradas, certificados y agente; delimitar con IdentitiesOnly cuando corresponda. |
| «-n desactiva todas las preguntas». | Controla stdin; BatchMode aborda interacción de autenticación/host. |
| «-T no permite ejecutar una shell». | Evita PTY; la política de sesión es otra decisión. |
| «Cambiar -p cambia el servidor». | Solo cambia el puerto al que intenta conectar el cliente. |
| «Borrar known_hosts corrige el aviso». | Investigar primero la identidad y el cambio de la referencia. |
| «Server accepts key ya es autenticación completa». | La firma y otras condiciones pueden estar pendientes; localizar la confirmación de autenticación completada. |

## Fuentes de contraste

- [ssh(1)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1): sintaxis y semántica pública.
- [ssh_config(5)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5): directivas, defaults y expansión.
- [ssh.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.c): opciones, orden y modo de inspección.
- [readconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.c): tipos, alias y primera asignación.
- [misc.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/misc.c): conversión de puertos, enteros y tiempos.
- [readconf.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.h) y [ssh.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.h): límites de entradas y estados de PTY.
- [sshconnect.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshconnect.c): rondas de conexión y direcciones.
- [sshconnect2.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshconnect2.c): diferencia entre pública aceptada para consulta y firma/autenticación.
- [log.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/log.c): apertura append del log y error local.

Las fichas están **documentadas para la referencia indicada**; la [matriz de cobertura](README.md#cobertura-y-estado) mantiene las pruebas como pendientes. Registrar diferencias del binario real antes de convertir una predicción de código en un resultado observado.
