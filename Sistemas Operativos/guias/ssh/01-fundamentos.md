# SSH · Fundamentos para entender una conexión

[Índice de la guía](README.md) · [Siguiente: conexión básica](02-conexion-basica.md)

Secure Shell (SSH) permite utilizar servicios remotos a través de un canal que protege la comunicación. Su uso más conocido es abrir una terminal en otro equipo, pero una misma conexión también puede transportar comandos, transferencias o canales reenviados.

Para administrarlo con criterio conviene responder cuatro preguntas: **a qué equipo llegamos, cómo comprobamos su identidad, con qué cuenta entramos y qué puede hacer esa cuenta**. El cifrado de la conexión no resuelve por sí solo las otras tres.

## 1. SSH, OpenSSH y sus herramientas

**SSH** es una familia de protocolos. **OpenSSH** es una implementación que incluye varios programas. La versión del cliente, la del servidor y la versión del protocolo son datos diferentes.

| Elemento | Función |
| --- | --- |
| `ssh` | El cliente inicia una conexión y solicita una sesión, comando o subsistema. |
| `sshd` | El servidor escucha, participa en la autenticación y atiende las solicitudes autorizadas. |
| `ssh-keygen` | Genera e inspecciona claves, fingerprints y certificados; también dispone de otros modos. |
| `ssh-agent` | Ofrece operaciones con identidades cargadas para autenticarse sin volver a desbloquear cada clave en cada conexión. |
| `ssh-add` | Carga, consulta o retira identidades de un agente. |
| `sftp` y `scp` | Transfieren archivos utilizando SSH; su interfaz y el protocolo de transferencia deben distinguirse. |

Cuando una pantalla muestra `OpenSSH_10.6p1` se refiere al producto. Un banner de protocolo `SSH-2.0-…` identifica la familia de protocolo utilizada. Instalar una versión nueva del cliente no actualiza el servidor ni garantiza que ambos admitan las mismas funciones.

Esta guía toma como referencia documental **OpenSSH Portable 10.6p1**. El paquete de una distribución y Windows OpenSSH pueden incorporar otras versiones o cambios. La referencia de [opciones del bloque](03-referencia-conexion.md) identifica sus límites.

## 2. Cliente, servidor y cuenta remota

El equipo desde el que escribimos `ssh` actúa como **cliente**. El destino necesita un servicio SSH disponible. Tener el cliente instalado no convierte a ese equipo en servidor.

Una conexión ordinaria utiliza TCP y el puerto de destino convencional es **22**. El administrador puede configurar otro. Hay que conocer la dirección, el puerto y una cuenta permitida; el puerto, por sí solo, no identifica la cuenta ni sus permisos.

| Dato | Ejemplo ficticio | Qué identifica |
| --- | --- | --- |
| Dirección | `192.0.2.10` | El destino IP del ejemplo; habrá que sustituirlo por el de la VM. |
| Puerto | `2222` | El puerto en el que se espera encontrar el servicio de ese laboratorio. |
| Usuario | `alumno` | La cuenta solicitada en el servidor. |
| Alias cliente | `ssh-lab` | Una etiqueta local de configuración; puede apuntar a una IP sin existir en DNS. |

Las direcciones `192.0.2.0/24` y los nombres bajo `.example` se usan aquí para documentación. No son datos de una máquina preparada para conectarse.

La cuenta local y la remota pueden tener nombres distintos. Entrar como `alumno` no concede automáticamente administración: las operaciones quedan sujetas a los permisos y políticas del servidor. La elevación con `sudo`, si está permitida, es una decisión posterior y separada.

## 3. Qué protege el canal

En una conexión habitual, **Key Exchange (KEX) — intercambio de claves** permite acordar el material que protegerá la sesión. Después se utiliza cifrado simétrico para transportar los datos con eficiencia. La integridad de los mensajes se protege mediante el mecanismo negociado: cifrado autenticado o las combinaciones que admita esa conexión.

La clave de usuario no cifra cada tecla escrita en la terminal. Su función habitual en autenticación con clave pública es permitir demostrar posesión de una identidad mediante firmas.

Las familias criptográficas resuelven problemas distintos:

| Familia | Pregunta que resuelve |
| --- | --- |
| Intercambio de claves | ¿Cómo acordamos el material de protección de esta conexión? |
| Identidad/firma del servidor | ¿Puede el servidor demostrar que posee la clave de host presentada? |
| Cifrado e integridad | ¿Cómo protegemos los datos que circulan por el canal? |
| Autenticación del usuario | ¿Qué prueba acepta el servidor para esta cuenta? |

Una clave de tipo RSA y un algoritmo de firma que use RSA tampoco son conceptos equivalentes. La compatibilidad depende de los algoritmos y políticas concretos, no solo del nombre del archivo de clave.

SSH protege el tránsito. Si el cliente está comprometido, el servidor autorizado registra información o la cuenta tiene permisos excesivos, el cifrado no impide esos problemas. También pueden seguir siendo observables datos de tráfico, como direcciones, volumen o tiempos.

## 4. Dos comprobaciones de identidad diferentes

En una conexión normal primero necesitamos comprobar la identidad del **servidor**. Después el servidor decide si acepta la autenticación del **usuario**. Cada parte mantiene material y reglas distintos.

| Identidad | Quién posee la privada | Qué conserva la otra parte |
| --- | --- | --- |
| Host o servidor | El servicio SSH del servidor. | El cliente conserva claves de host confiables en `known_hosts` o confía en una CA mediante la política configurada. |
| Usuario | El usuario o su dispositivo/proveedor de claves. | El servidor autoriza públicas o certificados para la cuenta, por ejemplo mediante `authorized_keys`. |

`known_hosts` responde a «¿qué servidor es este?». `authorized_keys` participa en «¿qué claves pueden autenticarse como esta cuenta?». Copiar una clave de usuario al servidor no verifica su identidad de host.

Un servidor puede tener varias claves de host y seleccionar una según los algoritmos negociados. Al comparar fingerprints hay que comparar **la misma clave y el mismo tipo**.

## 5. Fingerprint, primera conexión y confianza

Un **fingerprint — huella digital** es un resumen de una clave pública. Facilita comparar una clave larga con una referencia, pero no certifica por sí mismo de dónde salió esa referencia.

En una primera conexión puede aparecer un aviso con el tipo de clave, su huella y una pregunta de confirmación. La parte importante es obtener una huella esperada mediante un canal independiente: la consola de la VM, un inventario administrado o un canal autenticado distinto.

Si obtenemos una clave usando `ssh-keyscan` sobre la misma red y la aceptamos sin ninguna comprobación adicional, hemos recogido una clave, pero no hemos establecido de forma independiente a quién pertenece.

**Trust On First Use (TOFU) — confianza en el primer uso** consiste en recordar una clave aceptada y detectar cambios posteriores. Su seguridad depende de cómo se realice esa primera aceptación.

| Situación | Qué significa | Actuación |
| --- | --- | --- |
| Host desconocido | No hay una referencia aplicable que permita confiar en esa clave. | Obtener y comparar su huella antes de aceptarla. |
| Clave conocida y coincidente | Coincide con una referencia que ya se considera confiable. | Continuar con la autenticación del usuario según la política. |
| Clave cambiada | La referencia y la clave presentada ya no coinciden. | Investigar: puede ser una reinstalación, otro equipo en esa IP o un intento de suplantación. |

No debemos borrar una entrada de `known_hosts` para hacer desaparecer un aviso sin explicar antes por qué cambió. La [práctica de conexión](02-conexion-basica.md) mantiene una base de confianza propia del laboratorio y evita tocar la habitual.

## 6. Clave pública, privada y frase de paso

En autenticación con clave pública, el cliente demuestra que puede usar una privada asociada a una pública autorizada. La privada no se envía al servidor como parte de ese procedimiento.

| Elemento | Tratamiento |
| --- | --- |
| Clave pública | Puede distribuirse para autorizarla. Su publicación puede revelar comentarios o asociaciones de identidad, por lo que tampoco conviene difundir metadatos innecesarios. |
| Clave privada | Debe protegerse frente a lectura/copia y uso no autorizado. Quien puede utilizarla puede intentar autenticarse como su titular. |
| `Passphrase` — frase de paso | Protege la privada almacenada cuando se usa cifrado del archivo. No es la contraseña de la cuenta remota. |
| Agente | Permite solicitar operaciones con identidades cargadas; su socket y su acceso también deben protegerse. |

Una contraseña de cuenta, una frase de paso de clave y un PIN de un autenticador son solicitudes diferentes. Conviene leer qué programa pregunta y qué identidad intenta utilizar.

El servidor puede exigir varios factores o métodos consecutivos. Tener una pública autorizada no garantiza, por sí solo, una sesión: pueden faltar la firma, otro factor o una autorización posterior.

## 7. Autenticarse y estar autorizado

La **autenticación** prueba una identidad conforme a los métodos configurados. La **autorización** determina qué acceso y operaciones se permiten después o durante la solicitud.

Ejemplos:

- Una firma válida puede corresponder a una cuenta deshabilitada o no permitida por la política del servidor.
- Una conexión autenticada puede tener un comando forzado en lugar de una shell.
- Una cuenta puede estar limitada a SFTP o tener prohibido solicitar un pseudoterminal.
- Poder entrar en una shell no implica poder leer cualquier archivo ni utilizar `sudo`.

Por eso un fallo de permisos al ejecutar un comando no se arregla necesariamente cambiando la clave SSH.

## 8. Shell, comando y pseudoterminal

Al ejecutar una conexión sin comando solemos solicitar una shell interactiva. Si añadimos un comando, SSH solicita su ejecución en el servidor y devuelve su resultado cuando termina.

Un **pseudoterminal (PTY)** proporciona el comportamiento de terminal que necesitan ciertos programas interactivos. Influye en el eco, las señales, el tratamiento de caracteres y la separación de salida/error.

| Solicitud | Uso habitual |
| --- | --- |
| Shell interactiva | Administrar manualmente desde una terminal. |
| Comando sin PTY | Automatizar y tratar stdout, stderr y código de retorno. |
| Comando con PTY | Utilizar un programa que realmente necesita terminal. |
| Subsistema | Solicitar un servicio como SFTP, según lo permitido. |

La referencia desarrolla `-T` y `-t`. Añadir un PTY sin necesidad puede alterar la salida de un script; quitarlo puede impedir el funcionamiento de una aplicación interactiva.

## 9. Leer una conexión por fases

Conviene localizar la última fase que llegó a completarse antes de cambiar ajustes.

| Fase | Evidencia orientativa | Qué revisar si falla |
| --- | --- | --- |
| Selección de destino | Configuración efectiva, dirección y puerto. | Alias, usuario, archivos de configuración y opciones CLI. |
| Resolución y TCP | Dirección intentada y conexión establecida. | DNS, familia IP, ruta, escucha y firewall. |
| Negociación y host | Algoritmos compatibles y clave de host verificada. | Política criptográfica, huella y base de confianza. |
| Usuario | Método y autenticación completados. | Cuenta, identidad, firma, segundo factor y política del servidor. |
| Sesión o comando | Shell abierta, comando ejecutado y retorno. | PTY, restricciones, permisos y disponibilidad del programa remoto. |

La redacción exacta de los logs varía por versión. Un mensaje `Offering public key` describe un intento. `Server accepts key` indica que el servidor considera aceptable esa pública en la fase de consulta; todavía no acredita por sí solo que toda la autenticación haya terminado.

## 10. Comprobación de comprensión

Antes del laboratorio deberíamos poder explicar:

1. Qué comprueba `known_hosts` y qué autoriza `authorized_keys`.
2. Por qué una conexión cifrada a un servidor suplantado sigue siendo un problema.
3. Por qué la privada del usuario no tiene que copiarse al servidor.
4. Qué diferencia hay entre contraseña de cuenta y frase de paso.
5. Por qué SSH puede autenticar correctamente y después denegar una operación.
6. Cuándo utilizar una shell y cuándo un comando sin PTY.
7. Qué fase investigar ante timeout, aviso de host o `Permission denied`.

## Fuentes y cobertura

Los conceptos se apoyan en la arquitectura de SSH y en los manuales upstream; la selección de algoritmos y las políticas concretas se consultan en la versión instalada.

- [RFC 4251: arquitectura SSH](https://www.rfc-editor.org/rfc/rfc4251).
- [RFC 4252: autenticación de usuario](https://www.rfc-editor.org/rfc/rfc4252).
- [RFC 4253: transporte SSH](https://www.rfc-editor.org/rfc/rfc4253).
- [ssh(1), referencia Portable 10.6p1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1).
- [sshd(8), claves autorizadas y autenticación](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8).
- [OpenSSH para Windows](https://learn.microsoft.com/en-us/windows-server/administration/OpenSSH/openssh-overview).

Cobertura conceptual: [SSH-T01](../../../Documentaciones/guiones/ssh.md#ssh-t01--protocolo-y-modelo-de-confianza), con introducciones parciales a SSH-T03 y SSH-T04. La [matriz de cobertura](README.md#cobertura-y-estado) distingue documentación y pruebas.

[Siguiente: conexión básica](02-conexion-basica.md)
