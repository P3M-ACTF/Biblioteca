# SSH · Referencia de túneles y bastiones

[Índice](README.md) · [Práctica de túneles](11-tuneles-y-bastiones.md) · [Inventario](../../../Documentaciones/guiones/ssh/README.md)

Referencia documental de **OpenSSH Portable 10.6p1**, consultada el 22 de octubre de 2026. Ocho opciones de ssh, seis directivas cliente y cinco servidor: **19 fichas y 38 casos pendientes**. No se presentan resultados de ejecución.

## Cómo leer las fichas

C es el cliente, B el servidor SSH/bastión y T el destino posterior. Preparar identidades, confianza, servicios HTTP propios y excepción de política mediante la práctica antes de ejecutar ejemplos. Los nombres/direcciones son ficticios y deben sustituirse. Los fragmentos de configuración son alternativas explicadas, no un archivo para concatenar íntegramente.

Las opciones de forwarding pueden acumular solicitudes; otras opciones asignan un escalar o rechazan repetición. Para las directivas cliente escalares rige la primera asignación aplicable. En servidor se debe evaluar Global/Match/Include con `sshd -T -C` conforme al [procedimiento de servidor](06-servidor-linux.md); no deducir el valor efectivo solo leyendo una línea.

Los puertos y bind son argumentos, no garantías de escucha. Con IPv6, usar corchetes para distinguir los dos puntos de la dirección del separador de puerto. Los puertos privilegiados, sockets Unix, familias IP y disponibilidad dependen del SO/build y la cuenta. La práctica utiliza puertos TCP no privilegiados y direcciones loopback explícitas.

## Dirección y límites de política

| Solicitud | Listener o flujo inicial | Salida final | Controles relevantes en B |
| --- | --- | --- | --- |
| -L / LocalForward | Listener en C. | B → destino. | AllowTcpForwarding local/yes, PermitOpen y restricciones por clave. |
| -D / DynamicForward | SOCKS en C. | B → destino solicitado. | Mismos controles de apertura TCP; no configura las aplicaciones. |
| -R / RemoteForward estático | Listener solicitado en B. | C → destino. | AllowTcpForwarding remote/yes, PermitListen, GatewayPorts y restricciones por clave. |
| -W / canal del salto | Stdin/stdout de C. | B → host:puerto. | Permiso local y PermitOpen; no crea shell ni listener local. |
| Agent forwarding | Socket delegado, si se autoriza. | Operaciones en el agente de C. | AllowAgentForwarding y restricciones por clave. |

[DisableForwarding](07-referencia-servidor.md#ssh-s-cfg-disableforwarding) ya tiene ficha en el bloque de servidor: `yes` bloquea estas capacidades aunque otras directivas las permitan. `sshd -T -C` no evalúa todas las restricciones de una clave particular. No confundir permiso para abrir un canal con disponibilidad del servicio o autorización dentro de su protocolo.

## Opciones de ssh
<a id="ssh-t-opt-4c"></a>

### -L · forwarding local

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-4c) · [Manual ssh.1:351](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L351)

**Sintaxis.** `-L [bind_address:]port:host:hostport`.

**Default y repetición.** No activa forwarding si no se solicita. Escucha en C; B abre la conexión al destino. Cada -L añade una solicitud: no sustituye la anterior.

**Argumentos y efectos.** El bind pertenece a C; host y hostport se interpretan desde B. Fijar 127.0.0.1 evita depender del GatewayPorts del cliente. Un bind vacío o * solicita todas las interfaces; IPv6 se encierra entre corchetes. Puertos TCP numéricos: escucha 1–65535 y destino 1–65535; el parser también reconoce nombres de servicio TCP. Privilegios, conflictos y política pueden impedir abrirlos. El parser rechaza escucha local 0.

El manual enumera además [bind_address:]port:remote_socket, local_socket:host:hostport y local_socket:remote_socket. Su desarrollo de rutas/permisos/limpieza Unix queda pendiente; no extrapolar la validación TCP a esas formas.

```sh
ssh -N -a -F ./ssh-tuneles.conf -L 127.0.0.1:18000:127.0.0.1:8000 salto-lab
```

**Qué estás viendo.** El listener está en C:18000 y la respuesta de prueba debe venir de B:8000. PermitOpen y AllowTcpForwarding de B pueden rechazar el canal cuando se usa el listener.

**Casos pendientes de ensayo.**

- [ ] T-01.1: Con B:8000 activo, comprobar respuesta y listener loopback; cerrar y comprobar su retirada.
- [ ] T-01.2: Ocupar el puerto con un proceso propio: comprobar fallo de bind con ExitOnForwardFailure yes y conservar intacto el proceso previo.

<a id="ssh-t-opt-52"></a>

### -R · forwarding remoto

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-52) · [Manual ssh.1:574](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L574)

**Sintaxis.** `-R [bind_address:]port:host:hostport`.

**Default y repetición.** No crea escucha remota por defecto. Cada -R añade una solicitud. B escucha y C abre el destino; depende de autorización del servidor.

**Argumentos y efectos.** bind_address y port pertenecen a B; host y hostport al recorrido desde C. GatewayPorts del servidor condiciona la dirección real y PermitListen la solicitud permitida. Puerto remoto 0 pide asignación dinámica; se informa en ejecución y, con -O forward, se imprime en stdout. Los demás puertos TCP numéricos son 1–65535; destino 0 no vale. Usar puertos no privilegiados y no asumir que una solicitud aceptada demuestra disponibilidad del destino.

El manual también recoge [bind_address:]port:local_socket, remote_socket:host:hostport, remote_socket:local_socket y [bind_address:]port sin destino (SOCKS remoto 4/5, con conexiones desde C). Esos modos, la asignación dinámica y la recuperación del puerto con multiplexación requieren casos adicionales. PermitRemoteOpen del cliente puede restringir destinos de SOCKS remoto; PermitOpen del servidor no controla el destino estático que abre C.

```sh
ssh -N -a -F ./ssh-tuneles.conf -R 127.0.0.1:19000:127.0.0.1:9000 salto-lab
```

**Qué estás viendo.** La petición HTTP a B:19000 debe devolver el fichero servido por C:9000. GatewayPorts yes en B puede forzar wildcard incluso si se pidió loopback; la práctica exige no.

**Casos pendientes de ensayo.**

- [ ] T-02.1: Con política y puerto permitidos, comprobar dirección de escucha en B y respuesta de C; cerrar y comprobar retirada.
- [ ] T-02.2: Solicitar un puerto no incluido en PermitListen en el candidato de laboratorio: comprobar rechazo y retorno sin modificar la política activa por rutina.

<a id="ssh-t-opt-44"></a>

### -D · proxy SOCKS local

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-44) · [Manual ssh.1:178](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L178)

**Sintaxis.** `-D [bind_address:]port`.

**Default y repetición.** No hay proxy dinámico por defecto. Varias -D añaden listeners. Soporta SOCKS4/5; la aplicación tiene que utilizar ese proxy.

**Argumentos y efectos.** La escucha está en C; cada destino lo solicita la aplicación y B abre la conexión final. Bind explícito 127.0.0.1 para uso local; vacío/* amplían interfaces. Puerto numérico local 1–65535, sin 0; el parser admite nombres de servicio. La política TCP/PermitOpen de B sigue aplicándose. DNS depende del cliente y de la modalidad SOCKS utilizada.

```sh
ssh -N -a -F ./ssh-tuneles.conf -D 127.0.0.1:1080 salto-lab
```

**Qué estás viendo.** No aparece una shell ni se modifica el proxy del sistema. Usar la petición curl socks5h de la práctica, evitando que NO_PROXY omita el túnel. El ejemplo con IP numérica no prueba resolución DNS.

**Casos pendientes de ensayo.**

- [ ] T-03.1: Forzar curl por el proxy y comprobar que 127.0.0.1:8000 corresponde a B.
- [ ] T-03.2: Comparar un destino autorizado y otro deliberadamente denegado en el laboratorio; distinguir rechazo de canal de cierre del transporte.

<a id="ssh-t-opt-4a"></a>

### -J · seleccionar bastiones

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-4a) · [Manual ssh.1:326](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L326)

**Sintaxis.** `-J [user@]host[:port][,...]`.

**Default y repetición.** Sin -J ni configuración de proxy la conexión es directa. Es abreviatura de ProxyJump. Usar una lista por comas; repetir -J produce error en esta versión.

**Argumentos y efectos.** También se acepta la forma URI ssh://[user@]host[:port]. Cada salto tiene su propia configuración Host, puerto, usuario, identidad y confianza. Las opciones CLI del destino no se aplican en general a los bastiones. No combinar -J con ProxyCommand en CLI: el parser puede rechazar esa mezcla. El orden de evaluación de las directivas ProxyJump/ProxyCommand se explica en su ficha; no usar una regla general de última opción gana.

```sh
ssh -F ./ssh-tuneles.conf -J salto-lab destino-lab hostname
```

**Qué estás viendo.** C verifica/autentica cada servidor con sus datos. B solo necesita poder abrir el TCP del siguiente salto y permitir ese canal; la clave de T permanece en C y ForwardAgent no sigue siendo válido.

**Casos pendientes de ensayo.**

- [ ] T-04.1: Llegar a T con un único salto y confirmar hostname y huella esperados sin reenviar agente.
- [ ] T-04.2: En una invocación solo de inspección -G, repetir -J: comprobar rechazo; el caso de varios saltos en lista sigue pendiente de ensayo específico.

<a id="ssh-t-opt-57"></a>

### -W · canal de entrada/salida estándar

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-57) · [Manual ssh.1:706](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L706)

**Sintaxis.** `-W host:port`.

**Default y repetición.** Sin -W no se conecta stdio directamente a ese destino. Implica -N, -T, ExitOnForwardFailure y ClearAllForwardings; estas últimas opciones pueden sobreescribirse mediante configuración/-o según el manual.

**Argumentos y efectos.** El servidor B abre host:port y conecta el flujo a stdin/stdout de ssh en C. No crea listener local, no es una shell, no equivale a SOCKS y no autentica por sí mismo el protocolo final. IPv6 requiere [dirección]:puerto; puerto de destino válido no nulo. En el parser fijado se rechaza un segundo -W y su combinación con operaciones de multiplexación -O.

```sh
ssh -a -F ./ssh-tuneles.conf -W 198.51.100.30:22 salto-lab
```

**Qué estás viendo.** Con el destino de laboratorio permitido, puede aparecer el banner del SSH de T como flujo bruto. No escribir comandos de shell ni secretos ahí. Cerrar este proceso identificado con Ctrl+C; una conexión SSH completa a T se hace mediante ProxyJump.

**Casos pendientes de ensayo.**

- [ ] T-05.1: Abrir el canal hacia el servicio SSH propio de T, identificar el flujo bruto y cerrarlo; no registrar esto como login en T.
- [ ] T-05.2: Solicitar un destino excluido por PermitOpen: comprobar denegación del canal y distinguirla de un fallo de autenticación en B.

<a id="ssh-t-opt-4e"></a>

### -N · transporte sin comando remoto

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-4e) · [Manual ssh.1:445](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L445)

**Sintaxis.** `-N`.

**Default y repetición.** No toma argumento. Sin ella se puede solicitar shell/comando según la invocación. En este parser fija SessionType none y desactiva la petición de PTY; repetir -N no añade sesiones.

**Argumentos y efectos.** Se utiliza para forwarding sin ejecutar un comando en B. No crea ningún túnel por sí sola, no envía el proceso al fondo y no convierte una cuenta en un servicio dedicado seguro. Es incompatible con otro tipo de sesión solicitado, como -s, según el estado del parser.

```sh
ssh -N -a -F ./ssh-tuneles.conf -L 127.0.0.1:18000:127.0.0.1:8000 salto-lab
```

**Qué estás viendo.** El proceso permanece en primer plano para conservar el transporte; la falta de prompt remoto es esperada. Consultar el listener y la aplicación desde otra terminal.

**Casos pendientes de ensayo.**

- [ ] T-06.1: Verificar un túnel funcional sin shell remota y cerrarlo en su terminal.
- [ ] T-06.2: Inspeccionar -G -N sin forwards: comprobar sessiontype none sin atribuirle una escucha que no se pidió.

<a id="ssh-t-opt-41"></a>

### -A · solicitar agent forwarding

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-41) · [Manual ssh.1:119](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L119)

**Sintaxis.** `-A`.

**Default y repetición.** Sin argumento. Solicita reenviar el agente; ForwardAgent por defecto es no. Entre las flags -A y -a, el parser va reasignando el valor: la última de esas flags prevalece.

**Argumentos y efectos.** Requiere agente local utilizable y permiso del servidor. Un proceso con acceso al socket delegado puede solicitar operaciones con las identidades del agente; en el forwarding ordinario no se copian las privadas, pero sí se delega su uso. No es necesario para ProxyJump. La práctica mantiene esta delegación desactivada.

```sh
ssh -F none -G -A alumno@192.0.2.10
```

**Qué estás viendo.** Solo imprime configuración: buscar forwardagent yes. No conecta ni demuestra que exista agente, autorización o socket remoto. Es un ejemplo de inspección, no una recomendación de activar la delegación.

**Casos pendientes de ensayo.**

- [ ] T-07.1: Con -G y configuración aislada, comparar -A frente a -a y registrar forwardagent.
- [ ] T-07.2: Comparar -A -a y -a -A con -G; comprobar la reasignación sin conectar ni modificar el agente.

<a id="ssh-t-opt-61"></a>

### -a · impedir agent forwarding

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-61) · [Manual ssh.1:136](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L136)

**Sintaxis.** `-a`.

**Default y repetición.** Sin argumento. Fija ForwardAgent no; entre -a/-A prevalece la última flag. No elimina identidades del agente ni impide que ssh lo use localmente.

**Argumentos y efectos.** Separa la autenticación del cliente C de la delegación de agente a B. IdentityAgent none en la configuración de la práctica desactiva además el uso local del agente; son controles diferentes. La política del servidor puede bloquear la delegación aunque el cliente la solicite.

```sh
ssh -a -F ./ssh-tuneles.conf destino-lab hostname
```

**Qué estás viendo.** El cliente puede autenticar T con su IdentityFile a través del bastión manteniendo ForwardAgent no. No necesita un socket de agente delegado en B.

**Casos pendientes de ensayo.**

- [ ] T-08.1: Inspeccionar -G -a y comprobar forwardagent no.
- [ ] T-08.2: Ejecutar ProxyJump con -a y las identidades de la práctica; comprobar acceso a T sin delegación.

## Directivas de ssh_config

Se seleccionan mediante Host/Match/Include en el cliente. Los ejemplos se integran en el archivo propio de la práctica, evitando solicitudes duplicadas.

<a id="ssh-t-client-proxyjump"></a>

### ProxyJump

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-proxyjump) · [Manual ssh_config.5:1651](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1651)

**Sintaxis.** `ProxyJump [user@]host[:port][,...] | none`.

**Default y repetición.** Default: sin salto. Directiva escalar; la primera asignación aplicable decide. ProxyJump y ProxyCommand compiten: la primera de ambas que resulte aplicable impide utilizar la otra.

**Argumentos y efectos.** La lista admite varios saltos, procesados en orden, y URI ssh:// según el manual. none elimina el uso de ProxyJump en ese contexto. Las reglas del host destino no se heredan en general por los bastiones; definir Host separado para cada uno. Verificar por separado configuración e identidad de B y T.

```sshconfig
Host destino-lab
    ProxyJump salto-lab
```

**Qué estás viendo.** ssh -F ./ssh-tuneles.conf -G destino-lab debe mostrar el salto previsto; no valida conectividad. La autenticación final continúa desde C.

**Casos pendientes de ensayo.**

- [ ] T-09.1: Inspeccionar el alias destino y comprobar salto, usuario, puerto e identidad propios.
- [ ] T-09.2: Probar en un archivo de inspección la precedencia con ProxyCommand, invirtiendo el orden; no conectar usando un comando de proxy no revisado.

<a id="ssh-t-client-localforward"></a>

### LocalForward

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-localforward) · [Manual ssh_config.5:1405](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1405)

**Sintaxis.** `LocalForward [bind_address:]port host:hostport`.

**Default y repetición.** Default: ninguna solicitud. Se pueden especificar varias directivas y añadir -L; no se trata como un escalar que reemplaza todo lo anterior.

**Argumentos y efectos.** Dos argumentos: escucha en C y destino visto desde B. IPv6 entre corchetes. También acepta rutas de sockets Unix; una / en el argumento lo identifica como ruta. Para TCP valen las restricciones de puertos de -L. El bind explícito prevalece sobre el default de interfaz; GatewayPorts cliente es una directiva distinta de la del servidor.

```sshconfig
Host salto-lab
    LocalForward 127.0.0.1:18000 127.0.0.1:8000
```

**Qué estás viendo.** Ejemplo alternativo al -L de la práctica; no usar ambos con el mismo listener. Incluirlo bajo el Host deseado para no activar el túnel en otros destinos.

**Casos pendientes de ensayo.**

- [ ] T-10.1: Sustituir -L por una única LocalForward y repetir la comprobación HTTP.
- [ ] T-10.2: Inspeccionar con -G un archivo con dos LocalForward a puertos propios distintos; comprobar acumulación, sin confundirla con prueba de bind.

<a id="ssh-t-client-remoteforward"></a>

### RemoteForward

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-remoteforward) · [Manual ssh_config.5:1786](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1786)

**Sintaxis.** `RemoteForward [bind_address:]port [host:hostport]`.

**Default y repetición.** Default: ninguna solicitud. Varias líneas acumulan forwards y pueden coexistir con -R.

**Argumentos y efectos.** Primer argumento: escucha B; segundo: destino abierto por C. Si se omite destino, solicita SOCKS remoto 4/5 y PermitRemoteOpen del cliente puede limitar sus destinos. Admite además sockets Unix y puerto remoto 0, que requieren desarrollo adicional. Sin bind explícito pide uso loopback; vacío/* pide todas las interfaces, sujeto al GatewayPorts de B.

```sshconfig
Host salto-lab
    RemoteForward 127.0.0.1:19000 127.0.0.1:9000
```

**Qué estás viendo.** Alternativa al -R, no otra solicitud sobre el mismo puerto. Confirmar listener efectivo en B y contenido originado en C. El permiso de escucha no limita por sí solo el destino al que C conecta.

**Casos pendientes de ensayo.**

- [ ] T-11.1: Usar una única RemoteForward estática y verificar respuesta de C.
- [ ] T-11.2: Comparar configuración de dos RemoteForward con -G; el ensayo de SOCKS remoto/puerto 0 queda registrado aparte, sin marcarlo cubierto.

<a id="ssh-t-client-dynamicforward"></a>

### DynamicForward

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-dynamicforward) · [Manual ssh_config.5:789](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L789)

**Sintaxis.** `DynamicForward [bind_address:]port`.

**Default y repetición.** Default: ninguna solicitud. Varias líneas acumulan listeners y se pueden añadir -D.

**Argumentos y efectos.** Un argumento de escucha local TCP; SOCKS4/5 y destinos abiertos desde B. Bind explícito de loopback; IPv6 entre corchetes. Las aplicaciones y su DNS no se configuran automáticamente. El puerto local 0 no es aceptado por el parser fijado.

```sshconfig
Host salto-lab
    DynamicForward 127.0.0.1:1080
```

**Qué estás viendo.** Alternativa al -D. Ver listener en C y usar el proxy explícitamente en la aplicación; -G solo demuestra la configuración leída.

**Casos pendientes de ensayo.**

- [ ] T-12.1: Repetir la petición curl por una DynamicForward y registrar respuesta.
- [ ] T-12.2: Intentar el puerto local 0 en un archivo de inspección aislado: comprobar rechazo de configuración; no confundirlo con RemoteForward 0.

<a id="ssh-t-client-exitonforwardfailure"></a>

### ExitOnForwardFailure

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-exitonforwardfailure) · [Manual ssh_config.5:857](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L857)

**Sintaxis.** `ExitOnForwardFailure yes | no`.

**Default y repetición.** Default no. Directiva escalar: primera asignación aplicable. yes termina si no se pueden establecer todos los forwards solicitados.

**Argumentos y efectos.** Cubre fallos de establecimiento, como bind o rechazo de un forward remoto. No prueba las conexiones posteriores hacia el destino final. En -L/-D la autorización de un canal puede fallar después de haber creado el listener. No sustituye un health check del servicio.

```sshconfig
Host salto-lab destino-lab
    ExitOnForwardFailure yes
```

**Qué estás viendo.** Un puerto propio ocupado debe producir fallo de establecimiento. Un HTTP de destino detenido puede dejar SSH/listener activos mientras curl falla.

**Casos pendientes de ensayo.**

- [ ] T-13.1: Provocar conflicto solo con un listener propio y observar retorno del intento fallido.
- [ ] T-13.2: Detener únicamente el HTTP de prueba de B con un -L activo; comprobar fallo de aplicación y permanencia del transporte, restaurar HTTP y repetir.

<a id="ssh-t-client-forwardagent"></a>

### ForwardAgent

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-forwardagent) · [Manual ssh_config.5:920](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L920)

**Sintaxis.** `ForwardAgent yes | no | /ruta/socket | $VARIABLE`.

**Default y repetición.** Default no. Directiva escalar: primera asignación aplicable. Puede seleccionar socket de agente mediante ruta o variable de entorno, según el manual.

**Argumentos y efectos.** Solicita delegación remota del agente. No es IdentityAgent, que selecciona el agente utilizado localmente por ssh. El servidor puede rechazar la delegación; DisableForwarding yes también la bloquea. No copiar privadas ni habilitar forwarding para solucionar un error de ProxyJump.

```sshconfig
Host salto-lab destino-lab
    ForwardAgent no
```

**Qué estás viendo.** El acceso mediante claves y bastión debe seguir funcionando sin delegación. La presencia de una variable SSH_AUTH_SOCK en cualquier shell no demuestra por sí sola que este transporte haya reenviado un agente.

**Casos pendientes de ensayo.**

- [ ] T-14.1: Confirmar forwardagent no con -G para B y T.
- [ ] T-14.2: Autenticar mediante ProxyJump sin delegación; los modos con ruta/variable y delegación real requieren un ensayo separado con agente de prueba.

## Directivas de sshd_config

Todos los ejemplos servidor pertenecen a un candidato revisado y recuperable. No recargar sin validar sintaxis, contexto y acceso nuevo; restaurar al terminar. Los valores indicados son defaults upstream, no el estado supuesto del paquete instalado.

<a id="ssh-t-server-allowtcpforwarding"></a>

### AllowTcpForwarding

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-allowtcpforwarding) · [Manual sshd_config.5:171](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L171)

**Sintaxis.** `AllowTcpForwarding yes | all | no | local | remote`.

**Default y repetición.** Default yes; all es equivalente. Global y Match. Primera asignación efectiva dentro del contexto evaluado, siguiendo las reglas de sshd_config.

**Argumentos y efectos.** local permite solicitudes con salida desde B (-L/-D/-W y el canal usado para el siguiente salto); remote permite escuchas solicitadas en B por -R. Los nombres se interpretan desde la perspectiva del cliente SSH. DisableForwarding yes prevalece y las restricciones por clave pueden reducir permisos. Esto no restringe por sí solo lo que una cuenta con shell completa puede ejecutar.

```sshconfig
Match User alumno Address 192.0.2.20/32
    AllowTcpForwarding local
```

**Qué estás viendo.** Fragmento alternativo para un candidato: permitiría el lado local pero no -R. La práctica completa necesita yes porque demuestra ambos sentidos; nunca añadir este ejemplo al activo sin integrar el contexto.

**Casos pendientes de ensayo.**

- [ ] T-15.1: Con candidato local y -T -C, comprobar valor efectivo para la cuenta/origen y el contexto ajeno.
- [ ] T-15.2: En laboratorio recuperable, comprobar -L permitido y -R denegado con política local; restaurar la política de la práctica después.

<a id="ssh-t-server-permitopen"></a>

### PermitOpen

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-permitopen) · [Manual sshd_config.5:1509](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1509)

**Sintaxis.** `PermitOpen host:port [host:port ...] | any | none`.

**Default y repetición.** Default any. Global y Match. Lista de una asignación: separar permisos por espacios en la misma línea; no esperar acumulación entre líneas repetidas.

**Argumentos y efectos.** Acepta nombre:puerto, IPv4:puerto y [IPv6]:puerto. * puede representar todo el host o todo el puerto; fuera de ese comodín no hay globbing ni resolución DNS para comparar el nombre solicitado. any/none van solos. Controla destinos de canales TCP abiertos desde B, incluido ProxyJump; no los destinos estáticos de -R abiertos desde C. Requiere también permiso general de forwarding y autorización de la clave.

```sshconfig
Match User alumno Address 192.0.2.20/32
    PermitOpen 127.0.0.1:8000 198.51.100.30:22
```

**Qué estás viendo.** Permite los dos destinos textuales usados por -L/-D y el salto de la práctica. Un alias o nombre que resuelva a la misma IP no es necesariamente la misma solicitud autorizada.

**Casos pendientes de ensayo.**

- [ ] T-16.1: Con -T -C, revisar que ambos destinos aparecen en una única lista efectiva.
- [ ] T-16.2: Probar un destino autorizado y un nombre/IP diferente excluido, en servicios propios; comprobar que el listener local no acredita autorización del canal.

<a id="ssh-t-server-permitlisten"></a>

### PermitListen

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-permitlisten) · [Manual sshd_config.5:1467](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1467)

**Sintaxis.** `PermitListen port | host:port [host:port ...] | any | none`.

**Default y repetición.** Default any. Global y Match. Lista efectiva de una asignación; varias entradas se escriben en la misma línea, sin asumir acumulación entre directivas.

**Argumentos y efectos.** Restringe direcciones/puertos solicitados para -R. Un puerto sin host permite cualquier host de escucha en ese permiso; host admite patrones según el manual y * puede reemplazar el puerto. any/none van solos. Para IPv6 usar [dirección]:puerto. GatewayPorts puede restringir o transformar además la escucha real. localhost implícito es una solicitud distinta de 127.0.0.1 o ::1 explícitos.

```sshconfig
Match User alumno Address 192.0.2.20/32
    PermitListen 127.0.0.1:19000
```

**Qué estás viendo.** La práctica usa exactamente esa dirección en -R. Esto autoriza una solicitud concreta, no verifica que el puerto esté libre ni que C pueda abrir su servicio final.

**Casos pendientes de ensayo.**

- [ ] T-17.1: Comprobar lista efectiva con -T -C y -R explícito permitido en el laboratorio.
- [ ] T-17.2: Comparar la solicitud explícita con la implícita localhost y un puerto excluido, registrando rechazo y dirección real sin ampliar la regla por rutina.

<a id="ssh-t-server-gatewayports"></a>

### GatewayPorts

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-gatewayports) · [Manual sshd_config.5:759](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L759)

**Sintaxis.** `GatewayPorts no | yes | clientspecified`.

**Default y repetición.** Default no. Global y Match. Directiva escalar de servidor, distinta de GatewayPorts cliente (yes/no).

**Argumentos y efectos.** no fuerza las escuchas remotas a uso local/loopback; yes fuerza wildcard; clientspecified permite que el cliente seleccione la dirección. Por ello no basta con pedir 127.0.0.1 en -R si el servidor tiene yes. Se combina con PermitListen, firewall y política general; un listener loopback tampoco autentica otros usuarios locales.

```sshconfig
Match User alumno Address 192.0.2.20/32
    GatewayPorts no
```

**Qué estás viendo.** Comprobar el valor efectivo y observar en B el listener de -R. No activar yes para resolver un problema de aplicación: cambia la exposición.

**Casos pendientes de ensayo.**

- [ ] T-18.1: Con no efectivo, comprobar escucha remota limitada a loopback y respuesta de prueba.
- [ ] T-18.2: Comparar no/yes/clientspecified solo en candidatos con -T -C; los ensayos de exposición wildcard requieren un laboratorio aislado adicional y quedan pendientes.

<a id="ssh-t-server-allowagentforwarding"></a>

### AllowAgentForwarding

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-allowagentforwarding) · [Manual sshd_config.5:126](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L126)

**Sintaxis.** `AllowAgentForwarding yes | no`.

**Default y repetición.** Default yes. Global y Match. Directiva escalar del contexto efectivo; DisableForwarding yes anula la capacidad aunque aquí figure yes.

**Argumentos y efectos.** Controla la delegación solicitada por el cliente, no su uso local del agente. no evita esta facilidad de sshd pero no convierte una cuenta con shell completa en un entorno aislado: puede ejecutar herramientas propias. Para la práctica se mantiene no y no se requiere agente delegado para acceder a T.

```sshconfig
Match User alumno Address 192.0.2.20/32
    AllowAgentForwarding no
```

**Qué estás viendo.** El -T -C debe mostrar no; comprobar además que la autenticación a T funciona sin delegar el agente. No inferir una política completa únicamente de la ausencia de SSH_AUTH_SOCK.

**Casos pendientes de ensayo.**

- [ ] T-19.1: Inspeccionar contexto de laboratorio y ajeno, junto con DisableForwarding.
- [ ] T-19.2: Mantener no en B y comprobar ProxyJump con claves en C; el ensayo de una solicitud real de agente denegada requiere agente dedicado y sigue pendiente.

## Comprobación, cierre y ampliación

Registrar versión/build, SO, shell, contexto, comando, stdout/stderr, retorno y resultado de la aplicación para cada caso. Un `-G` correcto no acredita bind, red, autorización ni funcionamiento del servicio. Un Ctrl+C deliberado cierra el proceso del ejercicio; su retorno no debe clasificarse como caída espontánea de red.

Cerrar únicamente los procesos identificados, comprobar retirada de listeners y restaurar el candidato/archivo activo mediante el procedimiento de servidor. No borrar carpetas desconocidas ni terminar procesos ajenos para liberar puertos.

Esta entrega desarrolla parcialmente SSH-T07, SSH-C002/C003/C004/C010/C024 y SSH-P05/P06. Quedan sockets Unix/StreamLocal, SOCKS remoto, asignación remota de puerto 0, multiplexación, TUN/TAP, X11, delegación avanzada, cadenas multihop y pruebas por plataforma. Sus formas se identifican para mantener el catálogo, pero no se declaran desarrolladas por completo ni verificadas.

## Fuentes y actualización

- Manuales versionados enlazados en cada ficha: referencia pública de Portable 10.6p1.
- [ssh.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.c): asignación -A/-a/-N, tratamiento de -J/-W y comprobaciones de compatibilidad.
- [readconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.c): parse_forward, puertos locales/remotos y acumulación de solicitudes.
- [servconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.c): selección de listas PermitOpen/PermitListen y valores de política.
- [Referencia de conexión](03-referencia-conexion.md): -F, -G, -o, identidad, confianza y diagnóstico.
- [Referencia de claves](05-referencia-claves.md): uso local del agente, separado de su delegación.
- [Referencia de servidor](07-referencia-servidor.md): -t/-T/-C, Match, Include y DisableForwarding.

Ante una actualización, comparar manual y parser de la nueva versión, conservar los IDs y repetir los casos afectados. Las comprobaciones estructurales de Markdown no sustituyen esas pruebas.
