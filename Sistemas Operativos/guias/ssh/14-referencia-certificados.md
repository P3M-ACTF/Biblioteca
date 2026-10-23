# SSH · Referencia de certificados y KRL

[Índice](README.md) · [Práctica](13-certificados-ca-krl.md) · [Evidencia local](15-verificacion-certificados-windows.md) · [Inventario](../../../Documentaciones/guiones/ssh/README.md)

Base documental: **OpenSSH Portable 10.6p1**, commit a8c72b842423f0774f542d3c2197247c3dd28d74, consulta del 23 de octubre de 2026. Incluye **18 fichas** (11 opciones, tres directivas cliente y cuatro servidor), 17 subopciones de certificado y seis directivas de especificación KRL. La cobertura de cada modo queda delimitada; no se declara completo ssh-keygen.

Las 36 casillas de las fichas son casos integradores todavía pendientes. La evidencia local de Windows 9.5p2 acredita determinados subcasos offline y no cierra los casos de autenticación, despliegue, FIDO o Portable 10.6p1.

## Reglas de lectura

Los nombres y rutas se preparan según la práctica; las órdenes que emiten certificados o KRL escriben archivos y requieren destinos libres/candidatos. Los snippets de configuración son fragmentos que deben integrarse en el contexto apropiado, no un único archivo para concatenar.

En ssh-keygen, `-f` cambia de papel con el modo: privada al crear claves, certificado a inspeccionar o KRL de entrada/salida. Su [ficha inicial](05-referencia-claves.md) no desarrolla todos esos modos. No mezclar flags de modo esperando que el parser siempre rechace la combinación: algunas rutas tienen prioridad.

| Concepto | Dónde se interpreta | Qué no acredita por sí solo |
| --- | --- | --- |
| Key ID / serial | Inventario, logs y ámbito de CA. | Autorización de cuenta o unicidad entre CAs. |
| Principals | Verificador de usuario o de nombre de host. | Existencia de la cuenta ni pertenencia de una IP a un nombre. |
| Intervalo | Reloj del verificador. | Que -L haya rechazado certificados pasados. |
| Critical option | Verificador que debe entenderla. | Que una extensión desconocida se trate igual. |
| KRL | Extremo donde se instala y consulta. | Distribución automática, cierre de sesiones o protección frente a rollback. |

## Opciones de ssh-keygen
<a id="ssh-pki-opt-73"></a>

### -s · CA según el modo

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-73) · [ssh-keygen.1:598](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L598)

**Sintaxis.** `-s ca_key`.

**Default y repetición.** No selecciona CA por defecto. En firma es necesaria y se combina con -I. Repetir -s reasigna la ruta; no acumula CA.

**Argumentos y efectos.** En emisión ordinaria lee la privada de CA para firmar una o varias públicas posicionales; el certificado se escribe junto a cada pública como nombre-cert.pub. La firma mediante agente/PKCS#11 requiere otros modos (-U/-D), fuera de esta práctica. En -k, -s indica la pública de CA para entradas serial/id: no firma la KRL ni necesita su privada.

```sh
ssh-keygen -s ./ca_usuario_lab -I usuario-lab-1001 -n operador-lab -V -5m:+1h -z 1001 -O clear ./usuario_v1.pub
```

**Qué estás viendo.** El certificado procede de la pública posicional y de esa CA. Cambiar la CA cambia el ámbito de serial/ID; no confundir la función de -s en firma con su función en revocación.

**Casos pendientes de ensayo completo.**

- [ ] PKI-01.1: Emitir con una CA de laboratorio e inspeccionar Signing CA, principal y serial.
- [ ] PKI-01.2: Crear KRL de serial con -s ca_usuario_lab.pub; comprobar revocado y mismo serial de otra CA no revocado.

<a id="ssh-pki-opt-49"></a>

### -I · identificador de certificado

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-49) · [ssh-keygen.1:377](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L377)

**Sintaxis.** `-I certificate_identity`.

**Default y repetición.** Obligatorio en emisión; no se genera automáticamente. Repetir asigna el último valor del parser.

**Argumentos y efectos.** Es el key ID, una cadena registrada con el certificado y utilizable en logs o revocación id:. No es el principal, el comentario de la pública ni el serial numérico. Una revocación por ID alcanza los certificados con ese ID de la CA seleccionada, por lo que su política de unicidad debe ser deliberada.

```sh
ssh-keygen -s ./ca_usuario_lab -I usuario-lab-1001 -n operador-lab -V -5m:+1h -z 1001 ./usuario_v1.pub
```

**Qué estás viendo.** Key ID debe contener el identificador esperado, pero la autorización se compara con Principals. No incluir datos personales o secretos en el identificador.

**Casos pendientes de ensayo completo.**

- [ ] PKI-02.1: Inspeccionar Key ID y distinguirlo del principal/serial.
- [ ] PKI-02.2: Revocar por id con la CA correcta y comprobar un certificado con otro ID no revocado.

<a id="ssh-pki-opt-6e"></a>

### -n · principals de usuario o host

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-6e) · [ssh-keygen.1:469](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L469)

**Sintaxis.** `-n principal[,principal...]`.

**Default y repetición.** Si se omite, se puede emitir un certificado sin principals con aviso; TrustedUserCAKeys no lo acepta para usuarios. Repetir -n reemplaza la cadena; no concatena listas.

**Argumentos y efectos.** Lista de identidades representadas: roles/nombres de usuario en certificado de usuario y nombres de host con -h. Para varias, usar una lista separada por comas. Un principal no crea una cuenta; AuthorizedPrincipalsFile puede mapearlo a una cuenta local. El ámbito de confianza y su formato determinan la autorización.

```sh
ssh-keygen -s ./ca_usuario_lab -I usuario-lab-1001 -n operador-lab,lector-lab -V -5m:+1h -z 1001 ./usuario_v1.pub
```

**Qué estás viendo.** Principals muestra dos entradas. Confirmar que solo la cuenta/contexto pretendidos aceptan esos nombres. En el certificado de host se utiliza el nombre lógico que C valida.

**Casos pendientes de ensayo completo.**

- [ ] PKI-03.1: Emitir una lista de dos principals e inspeccionar ambos.
- [ ] PKI-03.2: Con -n primero -n segundo, comprobar que queda segundo; el rechazo de un principal no autorizado requiere conexión real.

<a id="ssh-pki-opt-56"></a>

### -V · intervalo de validez

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-56) · [ssh-keygen.1:647](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L647)

**Sintaxis.** `-V validity_interval`.

**Default y repetición.** Sin -V, el intervalo va desde Epoch a un futuro sin límite práctico; la práctica siempre lo acota. Repetir -V vuelve a asignar tiempos.

**Argumentos y efectos.** Usar inicio:fin o +duración. Fechas YYYYMMDD o YYYYMMDDHHMM[SS] usan zona local; sufijo Z significa UTC. Se admiten relativos con unidades de TIME FORMATS (s/m/h/d/w), always al inicio, forever al final y segundos Epoch hexadecimales 0x... en extremos. El parser también admite inicio relativo positivo. El intervalo debe tener fin mayor que inicio.

El manual describe también un instante único. El parser fijado parse_cert_times solo trata especialmente +duración y exige dos extremos en las otras formas: una fecha absoluta aislada se rechaza. Escribir always:20300101Z o un inicio explícito cuando corresponda. +duración retrodata el inicio aproximadamente un minuto y lo redondea; no describirlo como un instante exacto now. Un certificado caducado puede emitirse e inspeccionarse: la aceptación temporal se comprueba al autenticar.

```sh
ssh-keygen -s ./ca_usuario_lab -I usuario-lab-1001 -n operador-lab -V -5m:+1h -z 1001 ./usuario_v1.pub
```

**Qué estás viendo.** Valid muestra el intervalo calculado en el reloj del firmante. Registrar zona/fecha y verificar sincronización en ambos verificadores. El parser acepta tiempos expresados; no demuestra validez frente al reloj de B/C.

**Casos pendientes de ensayo completo.**

- [ ] PKI-04.1: Emitir con -5m:+1h e inspeccionar los dos extremos; repetir con fechas UTC explícitas en un archivo nuevo.
- [ ] PKI-04.2: Comprobar rechazo de intervalo vacío/invertido y de fecha aislada; emitir intervalo pasado y observar que -L puede leerlo.

<a id="ssh-pki-opt-7a"></a>

### -z · serial o versión KRL

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-7a) · [ssh-keygen.1:830](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L830)

**Sintaxis.** `-z serial_number | -z +serial_number`.

**Default y repetición.** Serial por defecto 0. El número de CLI es decimal uint64 (0–18446744073709551615); no aceptar por analogía 0x... porque el parser usa base 10.

**Argumentos y efectos.** En emisión fija serial; el prefijo + lo incrementa por cada pública de esa misma invocación, sin persistencia entre órdenes ni garantía de unicidad global. Evitar llegar al máximo en un lote. La reasignación numérica no desactiva el indicador de autoincremento activado previamente: no combinar repeticiones esperando una regla general de último gana. En -k/-k -u representa la versión administrativa de KRL; la práctica la fija explícitamente.

El formato serial: de una especificación KRL sí admite decimal/hex/octal y excluye 0. Es una gramática distinta de -z. La versión de KRL no equivale al serial, a una fecha ni a una protección automática frente a rollback; verificar versión/procedencia en el despliegue.

```sh
ssh-keygen -s ./ca_usuario_lab -I lote-lab -n operador-lab -V -5m:+1h -z +1001 ./usuario_v1.pub ./usuario_v2.pub
```

**Qué estás viendo.** Se esperan seriales 1001 y 1002 para las públicas indicadas; no ejecutar sobre certificados que se quieran conservar sin copia. Mantener un registro de emisión por CA.

**Casos pendientes de ensayo completo.**

- [ ] PKI-05.1: Emitir un lote a dos nombres libres y comprobar incremento; verificar que otro proceso no lleva ese contador.
- [ ] PKI-05.2: Aceptar el máximo en una emisión individual y rechazar desbordamiento/hex en CLI; diferenciar la versión al generar una KRL.

<a id="ssh-pki-opt-68"></a>

### -h · tipo host

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-68) · [ssh-keygen.1:371](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L371)

**Sintaxis.** `-h`.

**Default y repetición.** La emisión es de tipo usuario sin -h. Es una flag, sin argumento; repetirla no crea otros certificados. El parser fija el tipo host y borra las flags predeterminadas de permisos de usuario.

**Argumentos y efectos.** Firma una pública como identidad de servidor; -n contiene nombres de host. Debe corresponder a una HostKey privada de B y desplegarse mediante HostCertificate. No reutilizar un certificado de usuario como host ni trasladar opciones estándar de usuario al host.

```sh
ssh-keygen -s ./ca_host_lab -I host-lab-2001 -h -n servidor.lab.example -V -5m:+1d -z 2001 ./host_lab.pub
```

**Qué estás viendo.** Type debe indicar host certificate; Signing CA debe ser la CA de host y el principal debe coincidir con el nombre validado por C.

**Casos pendientes de ensayo completo.**

- [ ] PKI-06.1: Emitir host e inspeccionar tipo/nombre/CA.
- [ ] PKI-06.2: Intentar autenticación con tipo o nombre incorrecto en laboratorio recuperable: comprobar rechazo en el extremo correspondiente.

<a id="ssh-pki-opt-4f"></a>

### -O · opciones por modo

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-4f) · [ssh-keygen.1:476](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L476)

**Sintaxis.** `-O option`.

**Default y repetición.** Repetible. Las opciones se guardan y procesan en orden en el modo seleccionado. En certificados de usuario, PTY, agent/port/X11 forwarding y user-rc están permitidos por defecto, sujetos al verificador.

**Argumentos y efectos.** En emisión aplica las 17 opciones públicas de la tabla siguiente; no asumir que clear borra critical options ni extensiones arbitrarias. Las flags permit/no- cambian bits en orden; force-command y source-address duplicados provocan error en este parser. Las opciones de FIDO, moduli, firmas de datos y otros modos tienen gramáticas distintas y siguen fuera del bloque.

```sh
ssh-keygen -s ./ca_usuario_lab -I usuario-lab-1001 -n operador-lab -V -5m:+1h -z 1001 -O clear -O permit-pty ./usuario_v1.pub
```

**Qué estás viendo.** Extensions debe incluir permit-pty y no los permisos eliminados. Esto no habilita PTY contra una prohibición del servidor ni autoriza por sí solo la cuenta.

**Casos pendientes de ensayo completo.**

- [ ] PKI-07.1: Comparar permisos predeterminados, clear y clear seguido de permit-pty en certificados separados.
- [ ] PKI-07.2: Añadir force-command antes de clear e inspeccionar que permanece; no interpretar clear como eliminación de toda restricción.

<a id="ssh-pki-opt-4c"></a>

### -L · inspeccionar certificados

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-4c) · [ssh-keygen.1:412](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L412)

**Sintaxis.** `-L -f certificate_file`.

**Default y repetición.** Sin argumento propio; -f selecciona el archivo. Es una flag de inspección, no un modo de verificación criptográfica ni autenticación.

**Argumentos y efectos.** Imprime tipo, pública, CA, ID, serial, intervalo, principals, críticas y extensiones de certificados legibles. El archivo puede contener varios certificados; el parser fijado lo recorre por líneas. Repetir -L no acumula archivos; usar el archivo/entrada según su sintaxis. Una pública ordinaria no es un certificado.

```sh
ssh-keygen -L -f ./usuario_v1-cert.pub
```

**Qué estás viendo.** Leer cada campo conforme al registro de emisión. Que el retorno sea 0 no acredita firma, confianza, tiempo actual ni permiso en B; incluso un certificado expirado puede imprimirse.

**Casos pendientes de ensayo completo.**

- [ ] PKI-08.1: Inspeccionar certificados user/host y correlacionar campos con la emisión.
- [ ] PKI-08.2: Comparar un certificado pasado con una pública ordinaria: el primero puede leerse; la segunda no se interpreta como certificado.

<a id="ssh-pki-opt-6b"></a>

### -k · crear una KRL

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-6b) · [ssh-keygen.1:401](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L401)

**Sintaxis.** `-k -f krl_file [opciones] entradas...`.

**Default y repetición.** Sin -u genera una KRL nueva; no conserva automáticamente revocaciones de un archivo anterior. Es una flag de modo y su repetición no acumula contenidos.

**Argumentos y efectos.** Lee públicas/certificados o especificaciones de texto y escribe una KRL binaria. El parser toma gen_krl antes que otros modos: no mezclar -k/-Q esperando rechazo universal. -s pública_CA da el ámbito para serial/id; -z fija versión y -C puede fijar comentario. Se puede generar una lista vacía desde un archivo de especificación vacío.

Revocar directamente un certificado suele producir entrada por serial o ID si el serial es 0/no disponible. Revocar la pública subyacente o la CA tiene mayor alcance. No escribir sobre la KRL activa de sshd: generar candidata, consultar y sustituir atómicamente. La generación no despliega la lista ni prueba su autenticidad de origen.

```sh
ssh-keygen -k -f ./usuarios-v2.krl -s ./ca_usuario_lab.pub -z 2 ./revocar-usuario.txt
```

**Qué estás viendo.** El ejemplo crea desde cero: utilizarlo solo con nombre libre/candidato y conjunto completo deliberado. Para conservar una KRL previa se utiliza la copia con -k -u de la práctica.

**Casos pendientes de ensayo completo.**

- [ ] PKI-09.1: Crear KRL vacía y consultar un certificado no revocado.
- [ ] PKI-09.2: Crear una KRL de serial y comprobar revocado/no revocado/mismo serial de otra CA.

<a id="ssh-pki-opt-51"></a>

### -Q · consultar o listar KRL

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-51) · [ssh-keygen.1:576](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L576)

**Sintaxis.** `-Q -f krl_file [publicas_o_certificados...] | -Q -l -f krl_file`.

**Default y repetición.** Sin argumento propio. Con -l lista el contenido; con archivos posicionales los consulta. Si cualquiera está revocado o hay error, retorna no cero; 0 solo indica que ninguna consulta resultó revocada y no hubo error.

**Argumentos y efectos.** No usar -L para consultar KRL ni confundir -l de listado de KRL con su uso de fingerprints en otro modo. El resultado ok no demuestra que el certificado sea válido, esté firmado por una CA confiable o pueda autenticar: solo evalúa la lista. Comprobar stderr cuando el archivo es ilegible o corrupto.

```sh
ssh-keygen -Q -f ./usuarios-v2.krl ./usuario_v1-cert.pub
```

**Qué estás viendo.** En la implementación contrastada una revocación consultada da REVOKED y retorno 1; errores pueden terminar con otro no cero. Un script debe distinguir fallo de herramienta y revocación mediante contexto/salida, conservando el contrato público de no cero.

**Casos pendientes de ensayo completo.**

- [ ] PKI-10.1: Consultar revocado y no revocado por separado y registrar cada retorno inmediato.
- [ ] PKI-10.2: Listar con -Q -l y probar archivo ausente/corrupto fuera del despliegue activo; no etiquetar esos errores como revocación confirmada.

<a id="ssh-pki-opt-75"></a>

### -u · actualizar KRL

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-75) · [ssh-keygen.1:641](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L641)

**Sintaxis.** `-k -u -f krl_file entradas...`.

**Default y repetición.** Solo significa actualización de KRL al combinarse con -k. Repetir -u vuelve a marcar la flag; no añade entradas por sí sola.

**Argumentos y efectos.** Carga la KRL existente y añade las entradas solicitadas. No es una operación de desrevocación ni un contador global. Preparar copia candidata y fijar una versión coherente. Actualizar la copia no cambia la que consultan C/B hasta desplegarla.

```sh
ssh-keygen -k -u -f ./usuarios-v2.krl -s ./ca_usuario_lab.pub -z 2 ./revocar-usuario.txt
```

**Qué estás viendo.** usuarios-v2.krl debe ser una copia válida de la lista anterior. Comprobar tanto entradas antiguas como nuevas y un control no revocado antes de sustituir.

**Casos pendientes de ensayo completo.**

- [ ] PKI-11.1: Actualizar una KRL con serial previo añadiendo id y comprobar que ambas revocaciones permanecen.
- [ ] PKI-11.2: Comprobar que actualización sobre una ruta inexistente falla; conservar el archivo activo y probar la candidata completa.

## Directivas cliente

Seleccionar Host/Match/Include conforme al cliente. CertificateFile acumula; no aplicar esa regla a todas las listas. Las sintaxis plurales de revocación indicadas se contrastaron con el parser 10.6p1, sin afirmar que versiones anteriores las admitan.

<a id="ssh-pki-client-certificatefile"></a>

### CertificateFile

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-certificatefile) · [ssh_config.5:495](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L495)

**Sintaxis.** `CertificateFile ruta`.

**Default y repetición.** Sin lista explícita, ssh puede buscar el certificado asociado a IdentityFile añadiendo -cert.pub. Varias directivas añaden certificados y se prueban en secuencia; no reemplazan la lista anterior.

**Argumentos y efectos.** Contiene el certificado público de usuario, no la privada. Requiere privada correspondiente por IdentityFile/-i, agente o proveedor compatible. Acepta ~, tokens y variables según el manual; resolver rutas desde el contexto real. Los duplicados exactos pueden descartarse en el parser. No extrapolar el literal none o la sintaxis de listas de otras directivas.

```sshconfig
Host destino-ca
    IdentityFile ./id_usuario_lab
    CertificateFile ./usuario_v1-cert.pub
```

**Qué estás viendo.** Permite separar nombre de privada y de certificado. Para probar un certificado revocado, usar un perfil con solo ese certificado y sin otra vía de autenticación.

**Casos pendientes de ensayo completo.**

- [ ] PKI-12.1: Inspeccionar selección efectiva y completar autenticación con la privada correspondiente.
- [ ] PKI-12.2: Sin privada correspondiente, comprobar fallo; con dos CertificateFile comprobar por qué una credencial alternativa puede invalidar un ensayo negativo.

<a id="ssh-pki-client-hostkeyalias"></a>

### HostKeyAlias

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-hostkeyalias) · [ssh_config.5:1129](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1129)

**Sintaxis.** `HostKeyAlias nombre_logico`.

**Default y repetición.** Sin alias explícito se usa el nombre de destino conforme a la configuración. Directiva escalar; primera asignación aplicable.

**Argumentos y efectos.** Cambia el nombre usado al buscar/guardar confianza de host y validar certificados; no cambia el destino TCP ni prueba su relación con DNS. En el código fijado el alias se usa directamente para known_hosts, sin añadir automáticamente [host]:puerto; por eso la práctica usa servidor.lab.example para entrada y principal.

```sshconfig
Host destino-ca
    HostName 192.0.2.10
    Port 2222
    HostKeyAlias servidor.lab.example
```

**Qué estás viendo.** Confiar en una CA para ese alias y verificar el mismo principal en el certificado. Si se elimina el alias, revisar tanto nombre esperado como formato de known_hosts; no alternarlos a ciegas.

**Casos pendientes de ensayo completo.**

- [ ] PKI-13.1: Inspeccionar alias/destino y autenticar el host certificado con el nombre previsto.
- [ ] PKI-13.2: En un perfil aparte usar otro alias no certificado; comprobar rechazo estricto sin cambiar la CA para que pase.

<a id="ssh-pki-client-revokedhostkeys"></a>

### RevokedHostKeys

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-revokedhostkeys) · [ssh_config.5:1872](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1872)

**Sintaxis.** `RevokedHostKeys ruta [ruta...] | none`.

**Default y repetición.** Sin archivos de revocación configurados no se consulta una lista externa de este tipo. En 10.6p1 el parser acepta una lista en una asignación; la primera lista aplicable decide, no acumula líneas repetidas.

**Argumentos y efectos.** Cada archivo contiene públicas de host revocadas o una KRL. none debe ir solo. El manual público habla de un archivo; el parser/estructura de esta versión admiten varios. No extrapolar esa ampliación a 9.5p2: la práctica usa un único archivo. Acepta ~, tokens y variables del cliente. Si la ruta configurada no existe/no se puede leer, la verificación de host falla para los destinos a los que aplique.

```sshconfig
Host destino-ca
    RevokedHostKeys ./hosts-v1.krl
```

**Qué estás viendo.** Su función es revocar identidad del servidor en C; no controla autorización del usuario en B. Comprobar la KRL local antes de conectar y mantener un perfil de recuperación verificado.

**Casos pendientes de ensayo completo.**

- [ ] PKI-14.1: Con KRL legible no revocadora, completar la comprobación de host del laboratorio.
- [ ] PKI-14.2: Con candidata que revoque el host o CA, comprobar rechazo anterior a autenticación de usuario; ruta ausente es un caso de error distinto.

## Directivas servidor

Comprobar contexto Global/Match y -t/-T/-C mediante el bloque de servidor. Las rutas y políticas se preparan antes de la recarga; los defaults upstream no describen necesariamente un paquete del distribuidor.

<a id="ssh-pki-server-trustedusercakeys"></a>

### TrustedUserCAKeys

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-trustedusercakeys) · [sshd_config.5:2062](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L2062)

**Sintaxis.** `TrustedUserCAKeys archivo | none`.

**Default y repetición.** Sin CA de usuario configurada por esta vía. Escalar, Global/Match; evaluar contexto y primera asignación efectiva conforme a sshd_config.

**Argumentos y efectos.** Archivo de públicas de CA, una por línea, con comentarios/vacías permitidos. Confía en certificados de usuario firmados por esas CA, sujetos a cuenta/principals/política. Sin AuthorizedPrincipalsFile, el nombre de la cuenta debe estar en los principals; con archivo se compara la lista autorizada. Certificados sin principals no se aceptan por esta vía.

```sshconfig
Match User alumno Address 192.0.2.20/32
    TrustedUserCAKeys /etc/ssh/ca-lab/usuario.pub
```

**Qué estás viendo.** Solo públicas verificadas, administradas por root. Una CA confiable amplía quién puede emitir credenciales; no copiar la privada ni añadir una CA desconocida para arreglar una prueba.

**Casos pendientes de ensayo completo.**

- [ ] PKI-15.1: Validar -T -C para la excepción y un contexto ajeno; probar CA prevista.
- [ ] PKI-15.2: Presentar un certificado de otra CA o sin principals y comprobar rechazo con la ruta de confianza original.

<a id="ssh-pki-server-authorizedprincipalsfile"></a>

### AuthorizedPrincipalsFile

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-authorizedprincipalsfile) · [sshd_config.5:363](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L363)

**Sintaxis.** `AuthorizedPrincipalsFile ruta | none`.

**Default y repetición.** Default none: debe aparecer el nombre de usuario destino en el certificado. Escalar, Global/Match; primera asignación efectiva.

**Argumentos y efectos.** Una entrada por línea, con principal y posibles opciones de clave; comentarios/vacías permitidos. Acepta %%, %h, %U y %u; rutas absolutas o relativas al home tras expansión. Sirve para CA de TrustedUserCAKeys y usuarios válidos; no se consulta para CA autorizadas por una línea cert-authority de authorized_keys. En esa otra vía existe principals=, fuera del desarrollo detallado de este bloque.

```sshconfig
Match User alumno Address 192.0.2.20/32
    AuthorizedPrincipalsFile /etc/ssh/principals-lab/%u
```

**Qué estás viendo.** El archivo de alumno contiene operador-lab: es la autorización para ese principal en esa cuenta. Mantenerlo fuera del control de edición de alumno si la política la administra root. Las opciones de cada línea requieren su propia revisión de restricciones.

**Casos pendientes de ensayo completo.**

- [ ] PKI-16.1: Con operador-lab en el archivo de alumno, comprobar acceso certificado y logs.
- [ ] PKI-16.2: Preparar candidato sin ese principal y comprobar rechazo; el certificado no debe crear otra cuenta ni ampliar el ámbito.

<a id="ssh-pki-server-hostcertificate"></a>

### HostCertificate

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-hostcertificate) · [sshd_config.5:869](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L869)

**Sintaxis.** `HostCertificate ruta`.

**Default y repetición.** Por defecto sshd no carga certificados de host. Solo Global; varias directivas añaden archivos de certificado para las HostKey correspondientes.

**Argumentos y efectos.** Es un certificado público cuyo contenido debe corresponder a una HostKey privada ya configurada. No reemplaza HostKey ni crea una clave de host. B lo presenta al cliente, que debe confiar en su CA y validar el nombre/tiempo/revocación. Las opciones estándar de certificados de usuario no se trasladan a host.

```sshconfig
HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
```

**Qué estás viendo.** Se sitúa antes de Match en el candidato. Validar con el binario real y comprobar en una conexión nueva qué certificado presenta B. El perfil de práctica exige algoritmo de certificado para evitar que una clave de host ordinaria enmascare el ensayo.

**Casos pendientes de ensayo completo.**

- [ ] PKI-17.1: Validar certificado de la HostKey existente y completar verificación desde C.
- [ ] PKI-17.2: En candidato recuperable, probar un certificado de otra pública y comprobar fallo/certificado no utilizable; no sustituir privadas de host para hacer coincidir el ejemplo.

<a id="ssh-pki-server-revokedkeys"></a>

### RevokedKeys

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-revokedkeys) · [sshd_config.5:1906](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1906)

**Sintaxis.** `RevokedKeys ruta [ruta...] | none`.

**Default y repetición.** Sin archivos de revocación por esta directiva. Global/Match. En 10.6p1 el parser acepta una lista en una asignación, con primera lista efectiva; none va solo.

**Argumentos y efectos.** Archivo(s) de públicas revocadas o KRL; la gramática plural se constata en servconf.c aunque el manual describa un archivo. La práctica usa uno por compatibilidad. Una ruta ilegible puede rechazar autenticación por pública de todos los usuarios afectados. Se puede consultar en cada intento: mantener cada archivo íntegro y sustituirlo atómicamente, no modificarlo in situ con -k -u.

```sshconfig
Match User alumno Address 192.0.2.20/32
    RevokedKeys /etc/ssh/revocaciones-lab/usuarios.krl
```

**Qué estás viendo.** Es revocación de credenciales de usuario en B, distinta de RevokedHostKeys en C. Candidato legible y contexto correcto antes de activar; después probar conexiones nuevas, porque una sesión anterior no demuestra el estado actual.

**Casos pendientes de ensayo completo.**

- [ ] PKI-18.1: Desplegar atómicamente la candidata y comprobar v1 revocado/v2 no revocado con perfiles aislados.
- [ ] PKI-18.2: Probar error de lectura solo en entorno dedicado/candidato; restaurar sin dejar bloqueado el acceso de recuperación.

## Subopciones -O de certificados de usuario

Cada fila es una unidad del inventario. Se añade como argumento `-O opción` a una emisión de usuario de la práctica; los argumentos con espacios se citan completos. Los efectos descritos requieren además que el verificador autorice la cuenta, confíe en la CA y permita la operación. No se declaran ensayadas las restricciones de sesión, críticas desconocidas o FIDO mediante la mera inspección `-L`.

| Unidad y sintaxis | Valor, default, repetición y efecto | Caso por desarrollar/ensayar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-pki-cert-clear"></a>[clear](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-clear) · `clear` | Borra bits de permisos habilitados, incluidos los predeterminados. No borra force-command, source-address ni extensiones arbitrarias ya almacenadas. El orden con permit/no- importa. | Pendiente: Comparar defaults → clear → clear + permit-pty; inspeccionar críticas por separado. | [ssh-keygen.1:1004](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1004) |
| <a id="ssh-pki-cert-critical"></a>[critical](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-critical) · `critical:<name>[=<contents>]` | Añade una crítica arbitraria; sin contents crea valor vacío y con valor lo codifica como string. Usar nombre con sufijo de dominio propio. El verificador debe entenderla y rechaza una crítica desconocida. | Pendiente: Emitir critical:prueba@lab.example=valor e inspeccionar; rechazo en autenticación sigue pendiente. | [ssh-keygen.1:1009](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1009) |
| <a id="ssh-pki-cert-extension"></a>[extension](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-extension) · `extension:<name>[=<contents>]` | Añade extensión arbitraria con la misma gramática de contenido. Una extensión desconocida puede ignorarse; no sirve para imponer una restricción que el verificador no conoce. | Pendiente: Comparar crítica desconocida y extension:prueba@lab.example=valor con CA de laboratorio. | [ssh-keygen.1:1010](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1010) |
| <a id="ssh-pki-cert-force-command"></a>[force-command](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-force-command) · `force-command=<command>` | Crítica que fuerza el comando en vez del solicitado. Sin default. Argumento no vacío; duplicarlo se rechaza. Citar todo el argumento si contiene espacios. Se combina con restricciones de cuenta/clave/ForceCommand y exige revisar su interacción. | Pendiente: Usar '-O force-command=hostname' y solicitar otro comando en laboratorio; -L solo acredita el campo. | [ssh-keygen.1:1024](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1024) |
| <a id="ssh-pki-cert-no-agent-forwarding"></a>[no-agent-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-agent-forwarding) · `no-agent-forwarding` | Retira el permiso de delegar agente, permitido en el conjunto predeterminado de certificados de usuario. Repetir no- vuelve a borrar el bit. | Pendiente: Inspeccionar ausencia de permit-agent-forwarding y comprobar petición de delegación denegada. | [ssh-keygen.1:1030](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1030) |
| <a id="ssh-pki-cert-no-port-forwarding"></a>[no-port-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-port-forwarding) · `no-port-forwarding` | Retira el permiso de forwarding de puertos, presente en defaults. No controla por sí solo qué comandos puede ejecutar la cuenta. | Pendiente: Inspeccionar y pedir un canal de forwarding propio permitido por el resto de la política: debe denegarse por el certificado. | [ssh-keygen.1:1035](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1035) |
| <a id="ssh-pki-cert-no-pty"></a>[no-pty](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-pty) · `no-pty` | Retira permiso de PTY. No impide necesariamente ejecutar comandos/shell sin PTY. | Pendiente: Comparar comando con -T y solicitud de PTY -tt; registrar las fases por separado. | [ssh-keygen.1:1038](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1038) |
| <a id="ssh-pki-cert-no-user-rc"></a>[no-user-rc](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-user-rc) · `no-user-rc` | Retira ejecución de ~/.ssh/rc por sshd. No equivale a impedir todo script ejecutado desde una shell. | Pendiente: En laboratorio con rc inocuo identificado, comprobar que su marcador no se ejecuta; no modificar rc ajenos. | [ssh-keygen.1:1041](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1041) |
| <a id="ssh-pki-cert-no-x11-forwarding"></a>[no-x11-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-x11-forwarding) · `no-x11-forwarding` | Retira permiso de X11 forwarding, presente en defaults. No altera la configuración del display local. | Pendiente: Inspeccionar ausencia de permit-X11-forwarding; ensayo real requiere entorno X11 preparado y queda pendiente. | [ssh-keygen.1:1048](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1048) |
| <a id="ssh-pki-cert-permit-agent-forwarding"></a>[permit-agent-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-permit-agent-forwarding) · `permit-agent-forwarding` | Habilita el bit de delegación tras clear/no-agent-forwarding. No supera AllowAgentForwarding/DisableForwarding u otras restricciones de B. | Pendiente: Inspeccionar clear + permiso y comprobar que una política servidor no sigue pudiendo denegar. | [ssh-keygen.1:1051](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1051) |
| <a id="ssh-pki-cert-permit-port-forwarding"></a>[permit-port-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-permit-port-forwarding) · `permit-port-forwarding` | Habilita el bit de forwarding tras clear/no-port-forwarding. Los destinos/listeners siguen sujetos a la política de B. | Pendiente: Inspeccionar y comparar destino permitido/denegado del laboratorio; el certificado no amplía PermitOpen. | [ssh-keygen.1:1056](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1056) |
| <a id="ssh-pki-cert-permit-pty"></a>[permit-pty](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-permit-pty) · `permit-pty` | Habilita PTY tras clear/no-pty. No supera PermitTTY no ni restricciones adicionales. | Pendiente: Inspeccionar clear + permit-pty y comprobar solicitud de PTY en servidor preparado. | [ssh-keygen.1:1059](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1059) |
| <a id="ssh-pki-cert-permit-user-rc"></a>[permit-user-rc](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-permit-user-rc) · `permit-user-rc` | Habilita ejecución de ~/.ssh/rc tras clear/no-user-rc, sujeta al resto de la política. | Pendiente: Comparar marcador rc inocuo con y sin permiso en cuenta dedicada; limpiar solo ese archivo. | [ssh-keygen.1:1062](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1062) |
| <a id="ssh-pki-cert-permit-x11-forwarding"></a>[permit-x11-forwarding](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-permit-x11-forwarding) · `permit-X11-forwarding` | Habilita el bit X11 tras clear/no-x11-forwarding. El parser compara sin distinguir mayúsculas, pero se conserva la grafía del manual. | Pendiente: Inspeccionar flag y probar solo con X11 preparado; no habilitar X11 del servidor por rutina. | [ssh-keygen.1:1068](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1068) |
| <a id="ssh-pki-cert-no-touch-required"></a>[no-touch-required](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-no-touch-required) · `no-touch-required` | Exención de presencia física para firmas FIDO ecdsa-sk/ed25519-sk. No es un permiso predeterminado ni se aplica a una Ed25519 ordinaria; requiere política/dispositivo compatibles. | Pendiente: Inspección puede mostrar la extensión, pero no demuestra comportamiento de hardware; FIDO real pendiente. | [ssh-keygen.1:1071](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1071) |
| <a id="ssh-pki-cert-source-address"></a>[source-address](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-source-address) · `source-address=<CIDR[,CIDR...]>` | Crítica que limita el origen observado por B; no tiene default. Acepta redes IPv4/IPv6 en CIDR, no nombres DNS. Duplicarla o proporcionar lista inválida se rechaza. | Pendiente: Comparar origen admitido y otro excluido, teniendo en cuenta NAT/proxy; no deducirlo del origen de C antes de NAT. | [ssh-keygen.1:1079](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1079) |
| <a id="ssh-pki-cert-verify-required"></a>[verify-required](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-keygen-cert-verify-required) · `verify-required` | Exige verificación del usuario en firmas FIDO, por ejemplo PIN/biometría según dispositivo. No es lo mismo que presencia táctil ni una contraseña del servidor. | Pendiente: Inspección de extensión y prueba con autenticador compatible son comprobaciones distintas; hardware pendiente. | [ssh-keygen.1:1086](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1086) |

Las flags permit/no- se reasignan en orden; no todas las opciones usan ese modelo. Las críticas conocidas force-command/source-address son únicas por emisión y las arbitrarias se almacenan aparte. clear no es una orden de limpieza universal. Las opciones auxiliares del parser no enumeradas en esta tabla conservan su clasificación en el inventario; no se convierten en interfaz pública por reconocerlas.

## Directivas de especificación KRL

Son líneas de texto de entrada para `ssh-keygen -k`; no se pegan en sshd_config ni constituyen una KRL binaria. El archivo admite comentarios/vacías según su parser. La práctica usa nombres nuevos y candidatos; ninguna de estas entradas se despliega por generar el archivo.

| Unidad y sintaxis | Argumentos y alcance | Caso por desarrollar/ensayar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-pki-krl-serial"></a>[serial](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-serial) · `serial: <serial>[-<serial>]` | Enteros de 64 bits distintos de 0; decimal, hexadecimal u octal. Rango inclusivo inicio-fin. Requiere -s CA_publica para delimitar emisor; no es la gramática decimal de -z. | Pendiente: Revocar 1001-1002 y consultar ambos límites; comprobar mismo serial de otra CA no revocado y serial 0 inválido. | [ssh-keygen.1:1208](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1208) |
| <a id="ssh-pki-krl-id"></a>[id](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-id) · `id: <key_id>` | Cadena exacta de key ID, ligada a la CA de -s. Puede alcanzar varios certificados con el mismo identificador. No compara el principal ni el comentario. | Pendiente: Añadir ID a una KRL con serial previo mediante -k -u y comprobar conservación; otro ID sigue no revocado. | [ssh-keygen.1:1219](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1219) |
| <a id="ssh-pki-krl-key"></a>[key](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-key) · `key: <public_key>` | Pública SSH completa tipo/base64, con el resto del formato de pública. Un certificado listado por esta directiva se trata como clave pública ordinaria; es un alcance distinto de su serial/ID. | Pendiente: Revocar la pública subyacente y consultar certificados de esa clave; contrastar con otro material no revocado. | [ssh-keygen.1:1226](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1226) |
| <a id="ssh-pki-krl-sha1"></a>[sha1](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-sha1) · `sha1: <public_key>` | Se proporciona la pública, no una huella escrita a mano: la KRL almacena su hash SHA1. Es un mecanismo de representación de revocación, distinto de elegir una firma de autenticación SHA1. | Pendiente: Crear una KRL candidata con esa directiva y consultar una clave/certificado correspondiente; comparar control no revocado. | [ssh-keygen.1:1229](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1229) |
| <a id="ssh-pki-krl-sha256"></a>[sha256](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-sha256) · `sha256: <public_key>` | Proporciona pública completa y almacena hash SHA256. La KRL resultante no está soportada antes de OpenSSH 7.9 según el manual. | Pendiente: Consultar en la versión registrada y contrastar compatibilidad antes de distribuir a verificadores antiguos. | [ssh-keygen.1:1231](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1231) |
| <a id="ssh-pki-krl-hash"></a>[hash](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-krl-hash) · `hash: <SHA256:fingerprint>` | Recibe la huella SHA256 (p. ej. obtenida con ssh-keygen -l -E sha256), no la pública. No acepta una huella MD5/SHA1 en esta gramática; requiere verificadores compatibles con KRL SHA256. | Pendiente: Extraer solo la huella SHA256 de la pública de laboratorio, crear candidata y consultar el material exacto. | [ssh-keygen.1:1235](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L1235) |

## Formatos de confianza y campos de certificado

Una pública ordinaria tiene tipo, base64 y comentario opcional. Un certificado añade datos firmados: tipo user/host, serial, key ID, principals, validez, críticas y extensiones. Su CA firma esos datos; la inspección no demuestra que el verificador confíe en ella.

| Archivo o forma | Uso y campos relevantes | Límite |
| --- | --- | --- |
| known_hosts con @cert-authority | Marcador, patrón/lista de nombres, tipo y base64 de la pública de CA, comentario opcional. | Limitar a nombres pretendidos; una CA para * amplía mucho el ámbito. HostKeyAlias cambia el nombre consultado/validado. |
| known_hosts con @revoked | Marca la pública listada como no aceptable. | No intercambiar con una especificación serial: ni con la lista de principals. El desarrollo completo de sus patrones/hashing sigue pendiente. |
| Archivo TrustedUserCAKeys | Una pública de CA por línea. | Confianza de usuarios, distinta de CA de host en C. |
| Archivo AuthorizedPrincipalsFile | Principal por línea con posibles opciones previas. | Relaciona principals con una cuenta válida; no crea cuentas. El catálogo de opciones de línea no se cierra aquí. |
| authorized_keys cert-authority / principals= | Vía alternativa de confianza y restricción por cuenta. | No usa AuthorizedPrincipalsFile; sigue pendiente su desarrollo exhaustivo. |
| KRL binaria | Cabecera/versiones y secciones de revocación según PROTOCOL.krl. | No es una lista de texto ni se distribuye sola; su versión no impide por sí sola un rollback. |

El manual admite nombres/patrones de host en los principals de certificados de host. La práctica usa un nombre exacto para que el ámbito sea revisable. No extrapolar patrones de known_hosts a todas las otras listas de SSH.

## Evidencia y límites de verificación

La [verificación local](15-verificacion-certificados-windows.md) registra 71 operaciones/comprobaciones con claves efímeras en Windows OpenSSH 9.5p2. No es una ejecución de Portable 10.6p1. Entre los subcasos observados están generación/inspección, seriales, orden de flags, KRL vacía, serial/ID/clave/CA, las seis directivas KRL y errores de consulta.

Los rechazos de autenticación por principal, CA, host name, fecha, crítica desconocida o revocación distribuida requieren C/B y sus logs. Todas las casillas integradoras permanecen abiertas hasta realizar ese laboratorio; tampoco se han probado autenticadores FIDO, PKCS#11 o configuraciones con varias rutas de revocación de 10.6p1.

Conservar la distinción entre revocar un certificado concreto, revocar la clave que lo sustenta y revocar su CA. Retirar una identidad del agente o borrar un .pub en C no revoca la autorización en B.

## Fuentes y mantenimiento

- [ssh-keygen.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.c): parse_cert_times, add_cert_option, seriales, dispatch de modos y generación/consulta KRL.
- [readconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.c): CertificateFile, HostKeyAlias y lista efectiva de RevokedHostKeys.
- [servconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.c) y [servconf.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.h): contextos, repetición y lista RevokedKeys.
- [sshconnect.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshconnect.c): nombre de known_hosts y comprobación de host con HostKeyAlias.
- [sshd(8)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8): known_hosts, cert-authority y principals=.
- [PROTOCOL.krl](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/PROTOCOL.krl): formato binario de KRL, distinto de la especificación de texto.
- Manuales públicos por unidad enlazados en las fichas/tablas.

Al actualizar la versión, contrastar manuales, parser y capacidades del binario; conservar IDs, registrar discrepancias y repetir pruebas. No cerrar familias del guion por completar solo uno de sus modos.
