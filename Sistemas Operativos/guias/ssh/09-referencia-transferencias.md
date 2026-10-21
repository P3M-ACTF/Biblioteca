# SSH · Referencia de SFTP y SCP

[Índice](README.md) · [Laboratorio de transferencias](08-transferencias.md) · [rsync sobre SSH](10-rsync-sobre-ssh.md)

Esta entrega desarrolla **20 fichas: 11 opciones CLI y nueve órdenes SFTP**. La ficha ls añade una tabla de sus nueve flags, con enlaces a sus unidades inventariadas. No se declara completo el catálogo de scp/sftp ni el de rsync.

## Referencia y alcance

| Campo | Valor |
| --- | --- |
| Producto | OpenSSH Portable 10.6p1, commit a8c72b842423f0774f542d3c2197247c3dd28d74. |
| Consulta | 22 de octubre de 2026. |
| Entorno | Referencia upstream; ejemplos Linux/Bash → servidor Linux con subsistema SFTP. Windows, ACL y servidores confinados requieren contraste propio. |
| Privilegios | Cuenta ordinaria con acceso local/remoto a archivos y subsistema. Autenticación válida no concede permiso sobre cualquier ruta. |
| Estado | Documentado por manuales/código; todos los casos funcionales pendientes. |
| Unidades padre | SSH-C027/C028/C029 y SSH-P04. Rsync sigue siendo una herramienta externa de SSH-C033/GNU/Linux. |
| Persistencia | Consultas/listados no copian datos; put/get/scp pueden crear, sobrescribir, cambiar atributos o dejar parciales. No hay rollback general. |

Los ejemplos se apoyan en `ssh-claves.conf` y las raíces nuevas del laboratorio. Son alternativas o pasos identificados; no ejecutar todos sobre rutas reales ajenas al ejercicio.

## Formas de invocación y rutas

```text
scp [opciones] origen ... destino
sftp [opciones] [usuario@]host[:ruta]
sftp [opciones] sftp://[usuario@]host[:puerto][/ruta]
```

**Qué estás viendo.** Scp exige al menos origen y destino; varios orígenes necesitan destino directorio. Un extremo remoto usa `[usuario@]host:ruta` o URI `scp://…`; un nombre local con dos puntos se hace explícito mediante ruta relativa/absoluta para evitar interpretarlo como host.

SFTP sin ruta, o con una ruta directorio, abre su intérprete; un destino que identifica archivo puede provocar descarga automática. Una barra final puede forzar interpretación de directorio en esa sintaxis. Para IPv6 usar delimitadores de la forma correspondiente, por ejemplo corchetes en URI. Las transferencias remoto-remoto, saltos y todas las variantes URI quedan fuera del recorrido principal.

El shell local interpreta primero comillas y expansiones. Dentro del intérprete, el parser SFTP resuelve sus propias comillas y glob. Con SCP heredado interviene además la shell remota. Citar espacios no convierte cualquier cadena con comodines en un nombre literal seguro; no construir órdenes desde entradas no confiables.

## Casos, retornos y recuperación comunes

Registrar cliente/servidor, protocolo real, identidad, pwd/lpwd, origen/destino, permisos, datos estables y estado previo. Guardar stdout/stderr y código inmediatamente, sin sustituirlo por el de una orden posterior. En Bash se usa `$?`; en PowerShell, `$LASTEXITCODE` para ejecutables nativos.

Scp documenta cero para éxito y mayor que cero para error. SFTP batch usa el resultado del flujo del lote en esta implementación; un error interactivo anterior puede no hacer que salir con bye termine con fallo. No aplicar a estas herramientas la tabla de retornos de ssh o rsync. Ningún cero sustituye la comparación de contenido o el resultado de cada orden.

| Efecto | Comprobación y recuperación |
| --- | --- |
| Copia nueva | Hash y ubicación correctos; retirar solo los archivos del ejercicio al cerrar. |
| Sobrescritura/metadatos | Recuperación desde copia previa; un fallo puede haber cambiado ya parte del destino. |
| Reanudación | Confirmar prefijo/origen y hash final; descartar como resultado aceptable una copia inconsistente. |
| Lote | Revisar órdenes ya ejecutadas antes del fallo. No hay reversión automática del lote. |
| Consulta | Interpretar el namespace y permisos; una lista no prueba capacidad de transferencia. |

La preservación de modo/tiempos no equivale a conservar propietario, ACL, xattrs, todos los enlaces o durabilidad frente a cualquier caída. Los archivos de práctica son propios, sin secretos ni enlaces a otros datos.

## scp

<a id="ssh-x-scp-50"></a>

### scp -P

Unidad: [SSH-I-SCP-OPT-50](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-50). Fuente: [scp.1:267](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L267).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Puerto obligatorio; parser 1…65535, también nombres de servicio TCP resueltos por a2port. |
| Predeterminado | Port efectivo de SSH; 22 sin otra selección. |
| Repetición y selección | La última -P asigna el puerto en este parser. URI y opciones SSH pueden intervenir: evitar selecciones contradictorias. |
| Efecto y límites | Selecciona destino; no cambia escucha ni firewall. Se escribe con mayúscula. |

```sh
scp -P 2222 -F ./ssh-claves.conf "./xfer-lab-20261022/origen/nota con espacios.txt" ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** Comprobar puerto real del laboratorio, no copiar el ficticio por rutina. No confundir con -p de metadatos ni con ssh -p.

Casos pendientes:

- [ ] Puerto correcto frente a cerrado/filtrado: diagnosticar transporte antes de claves.
- [ ] 0, 65536, nombre no resoluble o argumento ausente: error; repeticiones/URI requieren comprobar destino final.

<a id="ssh-x-scp-70"></a>

### scp -p

Unidad: [SSH-I-SCP-OPT-70](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-70). Fuente: [scp.1:274](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L274).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Sin argumento. |
| Predeterminado | No solicita el conjunto de preservación de -p. |
| Repetición y selección | Indicador idempotente. |
| Efecto y límites | Solicita preservar mtime, atime y bits de modo del origen. No es conservación completa de propietario, ACL, xattrs ni de todos los atributos del sistema; depende de permisos y receptor. |

```sh
scp -p -F ./ssh-claves.conf "./xfer-lab-20261022/origen/nota con espacios.txt" ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** Comprobar metadatos por separado de contenido. Leer para hacer hashes puede afectar a atime según montaje.

Casos pendientes:

- [ ] Archivo nuevo y existente: observar modo/tiempos, además del hash.
- [ ] Permiso insuficiente, FS receptor diferente y atributos no soportados: registrar diferencias/error sin prometer copia íntegra de metadatos.

<a id="ssh-x-scp-72"></a>

### scp -r

Unidad: [SSH-I-SCP-OPT-72](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-72). Fuente: [scp.1:292](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L292).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Sin argumento. |
| Predeterminado | No copia directorios recursivamente. |
| Repetición y selección | Indicador idempotente; no añade destinos por repetirlo. |
| Efecto y límites | Copia árboles y sigue enlaces simbólicos encontrados en el recorrido. Revisar origen para no copiar datos ajenos o entrar en ciclos; no equivale a la política de enlaces SFTP/rsync. |

```sh
scp -r -F ./ssh-claves.conf ./xfer-lab-20261022/origen/sub ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** Con directorio destino existente, verificar la aparición de sub/informe.txt. No trasladar reglas de barra final de rsync.

Casos pendientes:

- [ ] Árbol propio con destino existente/ausente: verificar nombres y ubicación resultante.
- [ ] Enlace a datos propios y archivo no legible: registrar qué se sigue/copia y cualquier resultado parcial.

<a id="ssh-x-scp-4f"></a>

### scp -O

Unidad: [SSH-I-SCP-OPT-4F](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-4f). Fuente: [scp.1:146](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L146).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Sin argumento. |
| Predeterminado | SFTP en este cliente de referencia. |
| Repetición y selección | Repetir -O mantiene modo SCP heredado. |
| Efecto y límites | Selecciona el protocolo SCP clásico, que utiliza shell remota. Quoting, expansión de comodines y compatibilidad cambian. No mejora el cifrado ni omite necesidad de autenticar/verificar host. |

```sh
scp -O -F ./ssh-claves.conf ./xfer-lab-20261022/origen/sub/informe.txt ssh-lab-key:xfer-lab-20261022/scp/informe-legacy.txt
```

**Qué estás viendo.** Solo alternativa de laboratorio si el servidor admite ese modo; no forma parte de la secuencia principal. No resolver rechazos añadiendo -T ni desactivando confianza.

Casos pendientes:

- [ ] SFTP disponible y legacy permitido: comparar protocolo y nombres en copia propia.
- [ ] Servidor SFTP-only o shell restringida: registrar rechazo; nombres/comodines requieren otro análisis de quoting.

<a id="ssh-x-scp-46"></a>

### scp -F

Unidad: [SSH-I-SCP-OPT-46](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-46). Fuente: [scp.1:120](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L120).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria de configuración personal alternativa para SSH; none es valor especial de ssh. |
| Predeterminado | Configuración habitual del cliente SSH. |
| Repetición y selección | Se transmite a ssh; varias -F siguen la selección de su parser, última ruta en la referencia. |
| Efecto y límites | Permite usar alias, identidad y confianza del ejercicio. Sustituye configuración personal y omite global cliente conforme a ssh; no elimina known_hosts global ni otras fuentes de confianza. |

```sh
scp -F ./ssh-claves.conf "./xfer-lab-20261022/origen/nota con espacios.txt" ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** Verificar alias con ssh -F archivo -G; esa inspección no prueba permisos de transferencia.

Casos pendientes:

- [ ] Alias definido y ruta con espacios citada: seleccionar el archivo correcto.
- [ ] Archivo explícito inexistente/ilegible o argumento ausente: fallo de selección, distinto de archivo remoto inexistente.

<a id="ssh-x-scp-6c"></a>

### scp -l

Unidad: [SSH-I-SCP-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-scp-opt-6c). Fuente: [scp.1:144](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L144).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Entero obligatorio en Kbit/s documentados; parser 1…104857600, multiplicado por 1024 bits/s. |
| Predeterminado | Sin limitador explícito de esta opción. |
| Repetición y selección | La última -l asigna el límite. |
| Efecto y límites | Limita el ritmo de datos del cliente, no reserva ancho de banda ni mide bytes de archivo por segundo. No trasladar unidades a rsync --bwlimit. |

```sh
scp -l 1024 -F ./ssh-claves.conf "./xfer-lab-20261022/origen/nota con espacios.txt" ssh-lab-key:xfer-lab-20261022/scp/
```

**Qué estás viendo.** 1024 se escala a 1048576 bits/s en la implementación; una copia pequeña no permite medir bien el límite. No es un timeout.

Casos pendientes:

- [ ] Archivo propio grande con/sin límite: medir duración/datos sin exigir igualdad con el límite teórico.
- [ ] 0, negativo, texto, exceso de rango o ausencia: rechazo; no usar extremos del parser como política operativa.

## sftp

<a id="ssh-x-sftp-50"></a>

### sftp -P

Unidad: [SSH-I-SFTP-OPT-50](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-opt-50). Fuente: [sftp.1:328](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L328).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Puerto obligatorio; validado por a2port, 1…65535 o servicio TCP resoluble. |
| Predeterminado | Port efectivo del cliente, normalmente 22 sin otra selección. |
| Repetición y selección | Última -P en el parser; un puerto URI puede reasignarlo y las directivas SSH también influyen. |
| Efecto y límites | Selecciona puerto de conexión. La -p minúscula del cliente SFTP tiene otra función de metadatos; no intercambiarlas. |

```sh
sftp -P 2222 -F ./ssh-claves.conf ssh-lab-key
```

**Qué estás viendo.** Sustituir puerto por escucha real; una autenticación correcta no acredita que se abra el subsistema.

Casos pendientes:

- [ ] Puerto correcto con subsistema disponible frente a puerto sin escucha.
- [ ] Valores inválidos y mezcla con URI/-o Port: verificar selección sin suponer una regla universal de precedencia.

<a id="ssh-x-sftp-46"></a>

### sftp -F

Unidad: [SSH-I-SFTP-OPT-46](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-opt-46). Fuente: [sftp.1:178](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L178).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria de configuración de ssh; puede utilizar none según el cliente. |
| Predeterminado | Configuración habitual de SSH. |
| Repetición y selección | Se transmite a ssh y mantiene su regla de -F; no acumula archivos de configuración al repetirla. |
| Efecto y límites | Selecciona identidad/alias/política de host para el transporte. El archivo no contiene órdenes put/get ni define la raíz SFTP del servidor. |

```sh
sftp -F ./ssh-claves.conf ssh-lab-key
```

**Qué estás viendo.** Revisar destino efectivo e identidad; dentro del intérprete comprobar pwd/lpwd.

Casos pendientes:

- [ ] Alias, configuración y archivo de confianza propios del laboratorio.
- [ ] Ruta ilegible/ausente, alias no definido y ruta local relativa: separar fallo de configuración de la raíz remota.

<a id="ssh-x-sftp-62"></a>

### sftp -b

Unidad: [SSH-I-SFTP-OPT-62](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-opt-62). Fuente: [sftp.1:125](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L125).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Archivo de órdenes obligatorio; - indica stdin. |
| Predeterminado | Lectura interactiva de órdenes desde stdin cuando no se elige batch. |
| Repetición y selección | Una sola -b; el parser 10.6p1 rechaza una segunda. |
| Efecto y límites | Lee órdenes SFTP, activa BatchMode SSH y reduce progreso/interacción. Fallos de operaciones documentadas como get/put/ls/cd/lcd/mkdir detienen el lote, salvo prefijo -; @ elimina eco, no vuelve secreto su contenido. |

```sh
sftp -F ./ssh-claves.conf -o IdentityAgent=SSH_AUTH_SOCK -b ./xfer-lab-20261022/transfer.sftp ssh-lab-key
```

**Qué estás viendo.** Requiere el agente/identidad ya preparados como en la práctica. Un fallo puede dejar efectos anteriores: no hay rollback del lote.

Casos pendientes:

- [ ] Lote válido con identidad utilizable y confianza preparada: retorno cero y contenidos esperados.
- [ ] Primer get inexistente impide un put posterior; repetir con -get cambia esa garantía. Sin autenticación no interactiva falla antes del lote.

<a id="ssh-x-sftp-61"></a>

### sftp -a

Unidad: [SSH-I-SFTP-OPT-61](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-opt-61). Fuente: [sftp.1:113](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L113).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Sin argumento. |
| Predeterminado | Sin petición global de reanudación. |
| Repetición y selección | Indicador global idempotente. |
| Efecto y límites | Intenta continuar copias existentes, incluidas completas. Presupone prefijos coincidentes; un origen o parcial distinto puede producir corrupción. Para control por archivo preferir get -a/put -a o reget/reput. |

```sh
sftp -a -F ./ssh-claves.conf ssh-lab-key
```

**Qué estás viendo.** Es una alternativa de la ficha, no la invocación principal. No usar en una sesión con archivos existentes de procedencia desconocida.

Casos pendientes:

- [ ] Parcial conocido del mismo origen frente a copia limpia: comprobar resultado completo.
- [ ] Parcial de igual tamaño inicial pero contenido distinto, o archivo completo distinto: demostrar detección mediante hash, no confiar en retorno.

<a id="ssh-x-sftp-6c"></a>

### sftp -l

Unidad: [SSH-I-SFTP-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-opt-6c). Fuente: [sftp.1:206](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L206).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Entero obligatorio en Kbit/s; parser 1…104857600, escala interna por 1024 bits/s. |
| Predeterminado | Sin limitador explícito de esta opción. |
| Repetición y selección | Última -l seleccionada. |
| Efecto y límites | Limita ancho de banda del cliente para transferencias; no cambia cuotas ni limita duración de sesión. No equivale al límite de rsync expresado con otras unidades. |

```sh
sftp -l 1024 -F ./ssh-claves.conf ssh-lab-key
```

**Qué estás viendo.** Medir con un archivo propio grande y comprobar progreso/tiempo; la autenticación y latencia también consumen tiempo.

Casos pendientes:

- [ ] Transferencia grande con límite y sin límite: comparar sin interpretar estadísticas como integridad.
- [ ] 0, negativo, texto y overflow del rango: error local antes de completar transferencia.

## Órdenes del intérprete SFTP

Escribirlas en el prompt SFTP o en un archivo de lote, no como ejecutables independientes del shell. Su repetición ejecuta otra operación con el estado actual de directorios/archivos; no garantiza idempotencia ni deshace una operación anterior.

<a id="ssh-x-cmd-get"></a>

### get

Unidad: [SSH-I-SFTP-CMD-GET](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-get). Fuente: [sftp.1:492](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L492).

```text
get [-afpR] remote-path [local-path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Origen remoto obligatorio, glob permitido; destino local opcional, mismo nombre si se omite. Con varias coincidencias y destino explícito, este debe ser directorio. |
| Predeterminado | Sin flags no se solicita reanudación, fsync, preservación ampliada ni recursión, salvo opciones globales heredadas de la invocación. |
| Efecto y límites | Descarga. -a reanuda sobre prefijo confiable; -f solicita fsync local; -p conserva modo/tiempos; -R recorre directorios sin seguir symlinks. No preserva por sí solo propietario/ACL/xattrs. Puede sobrescribir o dejar parcial. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
get "nota con espacios.txt" "../recibidos/sftp-nota.txt"
```

**Qué estás viendo.** remote-path se resuelve desde pwd; local-path desde lpwd. Progreso/retorno no sustituyen hash.

Casos pendientes:

- [ ] Un archivo, destino omitido/renombrado y glob múltiple con destino directorio.
- [ ] Archivo/directorio ilegible, destino ocupado y prefijo incoherente con -a: comprobar efectos parciales y hash.

<a id="ssh-x-cmd-put"></a>

### put

Unidad: [SSH-I-SFTP-CMD-PUT](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-put). Fuente: [sftp.1:651](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L651).

```text
put [-afpR] local-path [remote-path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Origen local obligatorio, glob permitido; destino remoto opcional, mismo nombre si se omite. Varias coincidencias exigen directorio remoto si se da destino. |
| Predeterminado | Flags no solicitados salvo los globales del cliente. |
| Efecto y límites | Subida. -a intenta reanudar; -f pide fsync remoto, que requiere extensión fsync@openssh.com; -p solicita modo/tiempos; -R recursión sin seguir symlinks. Permisos/servidor pueden impedir atributos; no proporciona rollback. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
put "nota con espacios.txt" "copia-nota.txt"
```

**Qué estás viendo.** Comprobar pwd/lpwd, autorización de escritura y hash del receptor. Solicitar fsync no demuestra durabilidad de todas las capas ante cualquier fallo.

Casos pendientes:

- [ ] Subida individual, renombrada y árbol con -R: verificar ubicación y contenido.
- [ ] Destino no escribible/cuota, varias coincidencias sobre un archivo y prefijo distinto con -a: fallo/resultado parcial.

<a id="ssh-x-cmd-reget"></a>

### reget

Unidad: [SSH-I-SFTP-CMD-REGET](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-reget). Fuente: [sftp.1:710](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L710).

```text
reget [-fpR] remote-path [local-path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Mismos orígenes/destinos que get; -f/-p/-R tienen sus efectos de descarga. |
| Predeterminado | La reanudación está implícita: equivalente a get -a. |
| Efecto y límites | Continúa una descarga a partir del parcial local. No verifica que sus bytes previos coincidan. Repetirlo sobre una copia distinta no la repara automáticamente. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
reget "nota con espacios.txt" "recibidos/reanudada.txt"
```

**Qué estás viendo.** Este ejemplo usa el pwd/lpwd del apartado de reanudación. Comparar hash final con origen estable.

Casos pendientes:

- [ ] Prefijo local conocido y destino nuevo sin parcial: registrar comportamiento y archivo completo.
- [ ] Origen modificado, parcial mayor o prefijo no coincidente: error o posible contenido incorrecto; comprobar y no aceptar silenciosamente.

<a id="ssh-x-cmd-reput"></a>

### reput

Unidad: [SSH-I-SFTP-CMD-REPUT](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-reput). Fuente: [sftp.1:722](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L722).

```text
reput [-fpR] local-path [remote-path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Mismas rutas que put; -f/-p/-R corresponden a subida. |
| Predeterminado | Equivalente a put -a: reanudación implícita. |
| Efecto y límites | Continúa sobre la copia parcial remota. Exige confirmar identidad del origen y prefijo existente; no equivale al algoritmo delta de rsync. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
reput "origen/nota con espacios.txt" "subida-reanudada.txt"
```

**Qué estás viendo.** Usar solo tras instalar el prefijo conocido descrito en la práctica. Verificar contenido remoto después, no solo tamaño.

Casos pendientes:

- [ ] Prefijo remoto conocido y origen inmutable: resultado con hash coincidente.
- [ ] Origen distinto, remoto completo diferente, permisos/cuota o tamaño incompatible: revisar error y contenido antes de continuar.

<a id="ssh-x-cmd-ls"></a>

### ls

Unidad: [SSH-I-SFTP-CMD-LS](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-ls). Fuente: [sftp.1:592](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L592).

```text
ls [-1afhlnrSt] [path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Ruta remota opcional con glob; sin ella lista el directorio remoto actual. |
| Predeterminado | Orden léxico; flags de listado no activados por defecto. |
| Efecto y límites | Consulta entradas y, con formato largo, atributos. Las nueve flags se desglosan debajo. No es ls local ni garantiza exactitud de dueño/grupo en todos los servidores; no demuestra acceso de escritura. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
ls -ln
```

**Qué estás viendo.** Leer tipo, modo, enlaces/campos disponibles, dueño/grupo numéricos, tamaño y tiempo. No comparar texto de formato largo como si fuera hash.

Casos pendientes:

- [ ] Directorio actual, ruta concreta y glob múltiple: confirmar que los nombres proceden del servidor.
- [ ] Ruta inexistente/no accesible y criterios de ordenación combinados: registrar parser/salida; elegir un criterio para comparaciones reproducibles.

Flags públicas de ls; cada fila enlaza con su ID del inventario. Las combinaciones y casos siguen pendientes de ensayo:

| Flag / unidad | Efecto | Criterio de comprobación |
| --- | --- | --- |
| [-1](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-31) | Una columna; no implica formato largo. | Comparar con el listado multicolumna, sin usarlo como API de nombres arbitrarios. |
| [-a](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-61) | Incluye nombres que empiezan por punto. | Confirmar archivos ocultos propios del ejercicio, no suponer que todos los servidores exponen las mismas entradas. |
| [-f](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-66) | No ordena; orden normal sin este flag es léxico. | El orden recibido puede variar; no compararlo como si fuera un orden estable. |
| [-h](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-68) | En formato largo utiliza unidades binarias legibles; K=1024, M=1048576. | No interpretar los tamaños abreviados como bytes exactos; comparar con formato numérico. |
| [-l](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-6c) | Formato largo con atributos como modo, propietario, grupo, tamaño y tiempo. | Interpretar campos según lo que devuelve el servidor; no prueba escritura ni integridad. |
| [-n](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-6e) | Formato largo con identificación numérica de usuario y grupo. | Distinguir números de la traducción de nombres; no trasladar UID/GID a ACL Windows. |
| [-r](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-72) | Invierte el orden de la clasificación seleccionada. | Comparar entradas con/sin el flag y un único criterio de ordenación. |
| [-S](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-53) | Ordena por tamaño. | Usar archivos de tamaños distintos y comprobar inversión si se añade -r. |
| [-t](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-ls-2d-74) | Ordena por última modificación. | Usar tiempos conocidos; zonas/formato de presentación no equivalen a contenido. |

Todas las flags de ls anteriores se escriben sin argumento. Cada orden ls comienza con sus flags de formato y orden por defecto. En el parser fijado, -S/-t/-f sustituyen el criterio de orden según la última selección; -r se activa al aparecer y repetirla no lo invierte otra vez. Las opciones de vista -1/-l/-n también tienen efectos de estado: no presuponer que su combinación sea independiente del orden. Estas reglas requieren ensayo con el cliente real.

<a id="ssh-x-cmd-cd"></a>

### cd

Unidad: [SSH-I-SFTP-CMD-CD](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-cd). Fuente: [sftp.1:392](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L392).

```text
cd [path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Ruta remota opcional; sin argumento vuelve al directorio donde empezó la sesión. |
| Predeterminado | Se mantiene el directorio remoto actual hasta cambiarlo. |
| Efecto y límites | Cambia el contexto de rutas remotas de las siguientes órdenes; no modifica el cwd del cliente ni sale de un chroot. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
cd xfer-lab-20261022/sftp
```

**Qué estás viendo.** Comprobar con pwd. No asumir que la raíz presentada sea / del servidor o que el inicio coincida siempre con home.

Casos pendientes:

- [ ] Ruta relativa/absoluta válida y cd sin argumento: observar directorio remoto.
- [ ] Ruta inexistente, archivo como directorio o permiso insuficiente: fallo; verificar cwd antes de la siguiente operación.

<a id="ssh-x-cmd-lcd"></a>

### lcd

Unidad: [SSH-I-SFTP-CMD-LCD](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-lcd). Fuente: [sftp.1:547](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L547).

```text
lcd [path]
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Ruta local opcional; sin ella utiliza el home del usuario local. |
| Predeterminado | Directorio local heredado al arrancar el cliente, hasta cambiarlo. |
| Efecto y límites | Cambia resolución de entradas/destinos locales de put/get. No cambia el directorio remoto. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
lcd ./xfer-lab-20261022/origen
```

**Qué estás viendo.** Comprobar con lpwd. Un ../ de get se interpreta desde este lugar, no desde pwd remoto.

Casos pendientes:

- [ ] Ruta local relativa/absoluta y omisión: observar lpwd sin cambiar pwd.
- [ ] Ruta ausente, no directorio o no accesible: error; no continuar con una suposición de cwd válida.

<a id="ssh-x-cmd-pwd"></a>

### pwd

Unidad: [SSH-I-SFTP-CMD-PWD](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-pwd). Fuente: [sftp.1:705](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L705).

```text
pwd
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Sin argumentos en la sintaxis pública. |
| Predeterminado | Consulta del directorio remoto actual. |
| Efecto y límites | Muestra el contexto remoto desde el que se resuelven rutas. En chroot o servidor virtual puede representar una raíz restringida; no revela necesariamente un path utilizable por una shell distinta. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
pwd
```

**Qué estás viendo.** Contrastar con cd. No equivale a un inventario del filesystem ni a identificación de la cuenta.

Casos pendientes:

- [ ] Antes y después de cd: ruta remota coherente.
- [ ] Sesión confinada o directorio inicial distinto del home: registrar el namespace y adaptar rutas.

<a id="ssh-x-cmd-lpwd"></a>

### lpwd

Unidad: [SSH-I-SFTP-CMD-LPWD](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-cmd-lpwd). Fuente: [sftp.1:590](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L590).

```text
lpwd
```

**Qué estás viendo.** Sintaxis pública; los marcadores son rutas/valores y no deben copiarse como nombres literales.

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Sin argumentos en la sintaxis pública. |
| Predeterminado | Consulta del cwd local del cliente SFTP. |
| Efecto y límites | Muestra el contexto local utilizado por transferencias. No consulta el servidor ni una shell remota. |

Ejemplo en el intérprete, con los directorios del paso correspondiente de la práctica:

```text
lpwd
```

**Qué estás viendo.** Comparar con pwd; los dos directorios pueden llamarse igual sin ser el mismo recurso.

Casos pendientes:

- [ ] Antes/después de lcd: ruta local cambia y remota no.
- [ ] Cliente Linux frente a Windows: registrar representación de ruta del ejecutable real, sin extrapolar separadores/permisos.

## Flags y opciones que no debemos intercambiar

| Forma | Significado en este bloque |
| --- | --- |
| `scp -P` / `sftp -P` | Puerto remoto; en ssh es -p. |
| `scp -p` | Preservación de metadatos solicitada. |
| `scp -r` | Recursión que sigue enlaces del árbol. |
| `get/put -R` | Recursión SFTP sin seguir enlaces; no es sftp -R, que configura solicitudes simultáneas. |
| `sftp -a` / `get -a` / `reget` | Reanudación con supuesto de prefijo coincidente; no es rsync -a. |
| `scp/sftp -l` | Límite en Kbit/s documentados; no es el formato largo ls -l. |
| `rsync -P` | --partial + --progress; no es un puerto. |
| `rsync -i` | Describir cambios; ssh -i selecciona identidad. |

El parser fijado también acepta algunos alias de flags interactivas, como -P por -p y -r por -R en get/put. Son compatibilidad del parser, no la sintaxis pública elegida para enseñar; comprobar el ejecutable antes de depender de ellos.

Para lotes, una orden con prefijo `-` ignora su error a efectos de parada. `@` reduce el eco; no oculta necesariamente errores, rutas, tráfico o registros. Los detalles de todas las órdenes no seleccionadas se conservan en el inventario.

## Cobertura y fuentes

20 fichas, 40 casos de referencia pendientes y nueve flags de ls desarrolladas en su tabla. Los enlaces de las 29 unidades inventariadas son recíprocos. La práctica añade ocho criterios de aceptación, y la introducción rsync cuatro; ninguno se declara ejecutado.

Las reglas de repetición y rango se contrastaron con el código de la misma versión, por ejemplo la última -P de estos frontends, el rechazo de una segunda sftp -b y la escala por 1024 de sus límites. Son conclusiones documentales pendientes de ensayo con el binario real.

- [scp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1) y [scp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c).
- [sftp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1), [sftp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c) y [sftp-client.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-client.c).
- [Referencia de conexión SSH](03-referencia-conexion.md): selección de configuración/identidades y confianza.
- [Introducción rsync sobre SSH](10-rsync-sobre-ssh.md): protocolo externo fijado a su propia versión.

Quedan pendientes las demás opciones y órdenes, transferencias remoto-remoto, modos legacy completos, solicitudes/extensiones SFTP, confinamiento y pruebas por plataforma. Los campos documentados no cierran las familias del guion general.
