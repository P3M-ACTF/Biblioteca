# SSH · Referencia de SFTP confinado

[Índice](README.md) · [Práctica](16-sftp-confinado.md) · [Inventario](../../../Documentaciones/guiones/ssh/README.md)

Base documental: **OpenSSH Portable 10.6p1**, commit a8c72b842423f0774f542d3c2197247c3dd28d74, consulta del 26 de octubre de 2026. Incluye **15 fichas** —diez opciones públicas de sftp-server y cinco directivas— y las **29 solicitudes** del dispatcher: 44 unidades inventariadas con enlaces recíprocos.

Los treinta casos de las fichas y los pares de comprobación de cada solicitud siguen **pendientes de laboratorio**. Una revisión de fuentes, una lista -Q o la configuración cliente -G no acreditan aislamiento ni ejecución del servidor.

## Cómo leer los ejemplos

Las opciones de sftp-server se muestran como argumentos de internal-sftp en el candidato de la práctica. La consulta/ayuda se realiza sobre el ejecutable externo si está instalado e identificado; internal-sftp no es un binario independiente que deba buscarse en PATH.

C es el cliente y B el servidor Linux. Las rutas, usuario, claves y archivos deben estar preparados en un laboratorio recuperable. Los fragmentos son alternativas; no concatenarlos ni activar varias ForceCommand sobre la misma cuenta.

| Capa | Qué controla | Prueba que requiere |
| --- | --- | --- |
| Autenticación/cuenta | Pública, política y estado de cuenta. | Nueva autenticación y log de B. |
| ChrootDirectory + filesystem | Raíz y operaciones permitidas al UID. | Sesión real, rutas, permisos/ACL y marcador exterior. |
| ForceCommand + sesión/canales | Servicio de sesión, PTY, rc y forwarding explícito. | SFTP positivo y shell/comando/canal negativos por separado. |
| -R / -P / -p | Operaciones del protocolo que tramita SFTP. | Solicitudes reales y efecto sobre contenido. |

[AuthorizedKeysFile](07-referencia-servidor.md#ssh-s-cfg-authorizedkeysfile), [DisableForwarding](07-referencia-servidor.md#ssh-s-cfg-disableforwarding) y las directivas de autenticación ya tienen fichas en servidor. Aquí se reutilizan para la cuenta confinada sin declararlas nuevas.

## Opciones públicas de sftp-server

No intercambiar flags del cliente y del servidor: en el cliente sftp, -P selecciona puerto, -p preserva atributos y -R lleva una concurrencia; aquí -P/-p son filtros y -R activa solo lectura. El [inventario CLI](../../../Documentaciones/guiones/ssh/cli.md) mantiene sus gramáticas separadas.

<a id="ssh-sftp-opt-64"></a>

### -d · directorio inicial

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-64) · [sftp-server.8:66](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L66)

**Sintaxis.** `-d start_directory`.

**Default y repetición.** Sin -d se utiliza el home de la cuenta. Repetir asigna otro directorio; la última opción procesada decide.

**Argumentos y efectos.** Es el cwd inicial del servidor SFTP, no una raíz de seguridad. Dentro de ChrootDirectory, /datos significa el datos de esa raíz. El manual documenta %% (porcentaje), %d (home) y %u (usuario); el parser de 10.6p1 reconoce además %U (UID), que se mantiene como detalle de implementación. También expande ~ según el usuario.

Si chdir falla, el código registra error y puede continuar en el cwd anterior: no confiar en -d para impedir acceso a otras rutas. ChrootDirectory y permisos delimitan el filesystem; un -d correcto no los sustituye.

```sshconfig
ForceCommand internal-sftp -d /datos -u 0077 -e -l VERBOSE
```

**Qué estás viendo.** Confirmar pwd en una sesión nueva y el chroot real. No asumir fallo de autenticación ni cierre del transporte por un directorio inicial inexistente.

**Casos pendientes.**

- [ ] SFTP-01.1: Con raíz válida y /datos existente, comprobar pwd y transferencia dentro de ella.
- [ ] SFTP-01.2: En candidato aislado indicar un -d inexistente y registrar log/cwd resultante; no atribuirle un confinamiento que no implementa.

<a id="ssh-sftp-opt-65"></a>

### -e · log en stderr

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-65) · [sftp-server.8:77](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L77)

**Sintaxis.** `-e`.

**Default y repetición.** Sin -e se utiliza syslog. Flag sin argumento; repetirla mantiene activado stderr.

**Argumentos y efectos.** Dirige diagnóstico/log a stderr, dejando stdout para el protocolo SFTP. Con internal-sftp sobre SSH ese stderr puede llegar a C; no significa que las transacciones se hayan guardado en el journal de B. El nivel se fija aparte mediante -l.

```sshconfig
ForceCommand internal-sftp -d /datos -e -l VERBOSE
```

**Qué estás viendo.** Capturar stderr de una sesión de laboratorio y correlacionar las transacciones con el log de autenticación separado de sshd. Evitar datos reales en los ejemplos de nombres/rutas.

**Casos pendientes.**

- [ ] SFTP-02.1: Registrar una transferencia con -e -l VERBOSE y localizar mensajes en C.
- [ ] SFTP-02.2: Comparar con una variante syslog preparada; verificar su destino real, incluido /dev/log si la plataforma lo requiere.

<a id="ssh-sftp-opt-66"></a>

### -f · facility syslog

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-66) · [sftp-server.8:81](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L81)

**Sintaxis.** `-f log_facility`.

**Default y repetición.** Default AUTH. Repetir reasigna el valor. El dominio público es DAEMON, USER, AUTH, LOCAL0, LOCAL1, LOCAL2, LOCAL3, LOCAL4, LOCAL5, LOCAL6 y LOCAL7.

**Argumentos y efectos.** Selecciona facility para mensajes enviados a syslog; no sustituye el nivel -l ni crea socket/reglas de recogida. Si se usa -e, el canal observado es stderr. La SyslogFacility de sshd no configura automáticamente internal-sftp.

```sshconfig
ForceCommand internal-sftp -d /datos -f AUTH -l INFO
```

**Qué estás viendo.** Es una alternativa para un entorno que ya tenga logging funcional dentro/fuera de la jaula según su SO. No añadir un /dev/log arbitrario ni desactivar el chroot para obtener logs.

**Casos pendientes.**

- [ ] SFTP-03.1: Con ruta syslog preparada, comprobar facility y operación registrados.
- [ ] SFTP-03.2: Probar un valor fuera del dominio solo en un proceso/candidato de laboratorio; registrar error y retorno, sin asumir un tratamiento uniforme entre versiones.

<a id="ssh-sftp-opt-68"></a>

### -h · mostrar uso

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-68) · [sftp-server.8:87](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L87)

**Sintaxis.** `-h`.

**Default y repetición.** No inicia sesión de protocolo. El código fijado escribe la sinopsis en stderr y termina con 1, no con 0.

**Argumentos y efectos.** Se consulta sobre el ejecutable externo identificado, no pasando -h al cliente sftp ni ejecutando internal-sftp como un binario de PATH. La salida describe la CLI disponible en ese paquete; no acredita funcionamiento dentro del chroot.

```sh
"$sftp_server_bin" -h
```

**Qué estás viendo.** sftp_server_bin representa una ruta real confirmada. Clasificar el retorno de ayuda según su contrato; no presentarlo como un fallo de transferencia.

**Casos pendientes.**

- [ ] SFTP-04.1: Obtener ayuda del binario de laboratorio y registrar versión/paquete, canal y retorno.
- [ ] SFTP-04.2: Comparar con manual/compilación; una flag reconocida por getopt no se declara soportada solo por aparecer en el código.

<a id="ssh-sftp-opt-6c"></a>

### -l · nivel de log

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-6c) · [sftp-server.8:91](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L91)

**Sintaxis.** `-l log_level`.

**Default y repetición.** Default ERROR. Valores: QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2, DEBUG3. DEBUG y DEBUG1 equivalen. Repetir asigna nivel.

**Argumentos y efectos.** INFO/VERBOSE registran transacciones; niveles debug añaden detalle. LogLevel de sshd no se traslada automáticamente al proceso interno: pasar -l explícitamente cuando se necesite. Nivel y destino (-e/-f) son decisiones distintas.

```sshconfig
ForceCommand internal-sftp -d /datos -e -l VERBOSE
```

**Qué estás viendo.** Correlacionar solicitud/usuario/ruta y resultado. Un mensaje Permission denied puede proceder del filtro, -R o filesystem: el nivel ayuda a separar la fase, no es una prueba de permisos por sí mismo.

**Casos pendientes.**

- [ ] SFTP-05.1: Comparar ERROR y VERBOSE con operaciones propias permitidas/denegadas.
- [ ] SFTP-05.2: En un candidato aislado probar un nivel inválido y registrar el diagnóstico sin modificar la política activa.

<a id="ssh-sftp-opt-50"></a>

### -P · lista de solicitudes denegadas

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-50) · [sftp-server.8:102](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L102)

**Sintaxis.** `-P request[,request...]`.

**Default y repetición.** Sin lista no se aplica esta denegación adicional. Una segunda -P se rechaza en el parser fijado; usar una lista por comas.

**Argumentos y efectos.** La lista se evalúa antes de -p, además del control -R. Los nombres son los cortos del dispatcher/Q requests: remove, posix-rename, etc. No son comandos rm del cliente, patrones de rutas ni nombres wire completos con @openssh.com. match_list compara cadenas exactas, sin globbing. Evitar espacios/entradas vacías.

No asumir validación anticipada de cada nombre: una errata en una lista denegada puede no bloquear la solicitud pretendida. Denegar remove/rename no impide truncado mediante open ni escritura sobre un handle; no constituye inmutabilidad.

```sshconfig
ForceCommand internal-sftp -d /datos -P remove,rmdir,rename,posix-rename -e -l VERBOSE
```

**Qué estás viendo.** Comprobar las solicitudes reales usadas por el cliente. Las extensiones anunciadas y posibles rutas alternativas pueden cambiar; denegar las dos formas de rename cuando ese sea el objetivo.

**Casos pendientes.**

- [ ] SFTP-06.1: Solicitar remove y las variantes rename en datos propios; comprobar rechazo y registro de su nombre.
- [ ] SFTP-06.2: Confirmar que una escritura permitida puede seguir modificando contenido; una errata -P rm no debe suponerse equivalente a remove.

<a id="ssh-sftp-opt-70"></a>

### -p · lista de solicitudes permitidas

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-70) · [sftp-server.8:123](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L123)

**Sintaxis.** `-p request[,request...]`.

**Default y repetición.** Sin -p no existe lista cerrada adicional. Repetir -p provoca error en esta versión, no acumula.

**Argumentos y efectos.** Si se configura, se rechaza toda solicitud no enumerada, aunque sea implícita del cliente. -P tiene prioridad incluso cuando el mismo nombre figure en -p. Usar nombres exactos de Q requests; * no es una lista universal. Permitir open no restringe sus flags por sí solo: combinar -R si se necesita lectura.

```sshconfig
ForceCommand internal-sftp -R -d /datos -p open,close,read,lstat,fstat,opendir,readdir,realpath,stat,readlink,limits,expand-path -e -l VERBOSE
```

**Qué estás viendo.** Es una lista candidata, no una promesa de compatibilidad con todos los clientes. Registrar negociaciones/metadatos adicionales antes de decidir qué ampliar.

**Casos pendientes.**

- [ ] SFTP-07.1: Con una lista revisada, navegar y descargar; identificar solicitudes implícitas que el cliente necesita.
- [ ] SFTP-07.2: Incluir readlink en -p y denegarlo mediante -P en un candidato aislado: comprobar prioridad de la denegación.

<a id="ssh-sftp-opt-51"></a>

### -Q · consultar capacidades

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-51) · [sftp-server.8:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L131)

**Sintaxis.** `-Q requests`.

**Default y repetición.** Solo requests es la consulta pública documentada. En el parser se consulta e imprime inmediatamente al procesar -Q; termina con 0. Un tipo de consulta desconocido termina con 1.

**Argumentos y efectos.** Enumera nombres de handlers base y extendidos de ese ejecutable. No abre un puerto ni una sesión SFTP y no prueba que el servidor integrado sea el mismo build o que una política vaya a permitirlos. -Q termina antes de procesar opciones posteriores; no usarlo como comprobación de toda una invocación.

```sh
"$sftp_server_bin" -Q requests
```

**Qué estás viendo.** Los nombres cortos, no las cadenas wire de extensión, son los utilizados en -P/-p. Registrar ruta/paquete. Si solo se dispone de internal-sftp integrado, no inventar una ruta externa.

**Casos pendientes.**

- [ ] SFTP-08.1: Consultar requests y contrastar la lista con el inventario de la versión ejecutada.
- [ ] SFTP-08.2: Consultar un tipo inexistente y registrar el error; no presentar esa salida como prueba del chroot.

<a id="ssh-sftp-opt-52"></a>

### -R · servidor de solo lectura

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-52) · [sftp-server.8:141](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L141)

**Sintaxis.** `-R`.

**Default y repetición.** Desactivado sin la flag. Repetir mantiene el modo activado; no toma argumento.

**Argumentos y efectos.** Rechaza handlers marcados como modificación y, dentro de open, aperturas distintas de solo lectura o con creación/truncado. Esto es más amplio que denegar únicamente write. No concede permisos de lectura que el UID no tenga ni modifica los modos de archivo.

La tabla de solicitudes distingue la marca del dispatcher y el caso especial open. fsync está marcado como escritura y se rechaza con -R aunque se describa como sincronización. El detalle proviene del código fijado, no de una clasificación intuitiva de nombres.

```sshconfig
ForceCommand internal-sftp -R -d /datos -e -l VERBOSE
```

**Qué estás viendo.** Una descarga puede funcionar mientras put/rm/chmod fallan en el mismo directorio que es escribible para el UID. Comprobar contenido y logs, no atribuir todo rechazo a permisos POSIX.

**Casos pendientes.**

- [ ] SFTP-09.1: Con fichero legible, comprobar get/ls y rechazo de put/mkdir/remove.
- [ ] SFTP-09.2: Intentar truncado/apertura de escritura y cambio de atributos; mantener un control de lectura permitido.

<a id="ssh-sftp-opt-75"></a>

### -u · umask de nuevas creaciones

[Unidad inventariada](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sftp-server-opt-75) · [sftp-server.8:147](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L147)

**Sintaxis.** `-u umask`.

**Default y repetición.** Sin flag se hereda la máscara del proceso/entorno de la cuenta; no asumir un valor del rc de una shell que no se ejecuta. Repetir aplica la última máscara válida.

**Argumentos y efectos.** El parser acepta un número octal 0000–0777; no una expresión simbólica como u=rwx ni dígitos 8/9. Modula permisos al crear archivos/directorios junto con modo solicitado y ACL. No cambia archivos existentes ni impide chmod/setstat posteriores si se autorizan.

```sshconfig
ForceCommand internal-sftp -d /datos -u 0077 -e -l VERBOSE
```

**Qué estás viendo.** Inspeccionar lo creado y las ACL/default del directorio. El resultado no es siempre 0600: el cliente puede solicitar otro modo, preservar atributos o modificarlos después.

**Casos pendientes.**

- [ ] SFTP-10.1: Crear fichero/directorio y comparar modo pedido, máscara, ACL y resultado.
- [ ] SFTP-10.2: Probar máscara inválida en candidato/proceso de laboratorio; contrastar que umask no revoca permisos de un fichero anterior.

## Directivas de sshd_config

Los contextos indicados se verifican contra servconf.h de 10.6p1. Comprobar los del paquete real con -t/-T/-C, mantener consola y no desactivar controles para resolver un rechazo.

<a id="ssh-sftp-cfg-chrootdirectory"></a>

### ChrootDirectory

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-chrootdirectory) · [sshd_config.5:512](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L512)

**Sintaxis.** `ChrootDirectory ruta | none`.

**Default y repetición.** Default none. Global/Match; escalar con primera asignación efectiva según el contexto. Acepta %%, %h, %U y %u.

**Argumentos y efectos.** Después de autenticar y al iniciar la sesión, sshd comprueba que todos los componentes sean directorios de root sin escritura para grupo/otros. Cambia la raíz y después intenta el home de la cuenta dentro de ella. La jerarquía no debe poder modificarse por otros procesos. Los controles del chroot no se anulan por desactivar StrictModes.

internal-sftp evita copiar shell/binarios/librerías dentro para transferir; una shell interactiva o sftp-server externo tiene otras dependencias. Ni el chroot ni -d son controles de forwarding. Comprobar ACL, mounts y controles del SO además de los modos.

```sshconfig
Match User sftp_lab
    ChrootDirectory /srv/sftp-lab/%u
```

**Qué estás viendo.** /srv/sftp-lab/sftp_lab se convierte en / del usuario. datos puede ser escribible por la cuenta; la raíz y ancestros no. Un fallo de sesión posterior a autenticar puede ser una comprobación de esta jerarquía.

**Casos pendientes.**

- [ ] SFTP-11.1: Validar contexto y realizar sesión SFTP con raíz segura y datos del usuario.
- [ ] SFTP-11.2: En entorno recuperable preparar una raíz de prueba con dueño/modo incorrecto y comprobar rechazo; no aplicar el fallo a un árbol compartido.

<a id="ssh-sftp-cfg-forcecommand"></a>

### ForceCommand

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-forcecommand) · [sshd_config.5:730](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L730)

**Sintaxis.** `ForceCommand comando [argumentos...] | internal-sftp [argumentos...] | none`.

**Default y repetición.** Default none. Global/Match, escalar; el primer valor efectivo decide. No es una lista de comandos permitidos.

**Argumentos y efectos.** Sustituye shell, comando o subsistema solicitado por el cliente e ignora ~/.ssh/rc. Para un comando externo se usa la shell de login con -c; internal-sftp es una ruta interna sin necesidad de shell dentro de la jaula. El comando original está en SSH_ORIGINAL_COMMAND para usos diseñados deliberadamente; no ejecutarlo como entrada confiable.

No bloquea canales de TCP/StreamLocal/agente/X11. Usar DisableForwarding y los controles de sesión necesarios. Con internal-sftp, una petición no SFTP puede autenticarse pero ser rechazada como servicio; separar esas fases.

```sshconfig
Match User sftp_lab
    ForceCommand internal-sftp -d /datos -u 0077 -e -l VERBOSE
    DisableForwarding yes
```

**Qué estás viendo.** Los argumentos que importan para esta cuenta son los de su ForceCommand. Reconciliarlo con restricciones por clave/certificado y otras reglas de cuenta.

**Casos pendientes.**

- [ ] SFTP-12.1: Solicitar SFTP y comprobar que usa la raíz/cwd/política previstos.
- [ ] SFTP-12.2: Solicitar comando/shell y un transporte -N con forwarding por separado: el segundo depende del bloqueo explícito del canal.

<a id="ssh-sftp-cfg-subsystem"></a>

### Subsystem

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-subsystem) · [sshd_config.5:2004](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L2004)

**Sintaxis.** `Subsystem nombre comando [argumentos...]`.

**Default y repetición.** Por defecto no hay subsistemas definidos. En 10.6p1 el registro permite Global y Match; versiones anteriores pueden limitar el contexto.

**Argumentos y efectos.** Asocia un nombre de solicitud, como sftp, con un ejecutable externo o internal-sftp. El parser fijado guarda nombres distintos y conserva la primera definición efectiva de un nombre ya registrado, anotando el duplicado; no asumir acumulación o sustitución. No duplicar sftp en una configuración portable.

internal-sftp acepta las opciones de sftp-server y debe recibir -l/-f explícitos: LogLevel/SyslogFacility de sshd no se heredan como configuración del servidor SFTP interno. Un ForceCommand puede sustituir comando y argumentos del subsistema para la cuenta afectada.

```sshconfig
Subsystem sftp internal-sftp
```

**Qué estás viendo.** Es una definición global ilustrativa si no existía otra. No modificar el subsistema compartido para conseguir una restricción que corresponde al Match de una cuenta.

**Casos pendientes.**

- [ ] SFTP-13.1: Identificar el subsistema efectivo y confirmar SFTP con la versión/paquete real.
- [ ] SFTP-13.2: En candidatos, comparar definiciones repetidas/contexto Match de la versión instalada sin extrapolar el parser 10.6p1 a otra.

<a id="ssh-sftp-cfg-permittty"></a>

### PermitTTY

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-permittty) · [sshd_config.5:1575](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1575)

**Sintaxis.** `PermitTTY yes | no`.

**Default y repetición.** Default yes. Global/Match, escalar; primera asignación efectiva.

**Argumentos y efectos.** Controla la concesión de PTY. no no significa prohibir ejecución de comandos sin PTY ni bloquear forwarding. La práctica combina este control con ForceCommand y DisableForwarding.

```sshconfig
Match User sftp_lab
    PermitTTY no
```

**Qué estás viendo.** La petición de terminal se deniega mientras una sesión SFTP sin PTY puede funcionar. No tratar una falta de prompt como prueba de que todo comando está restringido.

**Casos pendientes.**

- [ ] SFTP-14.1: Comprobar SFTP permitido sin PTY.
- [ ] SFTP-14.2: Solicitar PTY explícita y registrar denegación; comprobar por separado comando sin PTY.

<a id="ssh-sftp-cfg-permituserrc"></a>

### PermitUserRC

[Unidad inventariada](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-permituserrc) · [sshd_config.5:1624](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1624)

**Sintaxis.** `PermitUserRC yes | no`.

**Default y repetición.** Default yes. Global/Match, escalar; primera asignación efectiva.

**Argumentos y efectos.** Controla la ejecución de ~/.ssh/rc por sshd. ForceCommand ya ignora ese archivo; se explicita no para describir la política de la cuenta. No es un control general de todos los scripts o archivos de inicialización del sistema.

```sshconfig
Match User sftp_lab
    PermitUserRC no
```

**Qué estás viendo.** No esperar que un rc de usuario cambie la umask o emita diagnóstico en esta sesión. Usar -u/-l en internal-sftp y conservar la separación entre stdout de protocolo y stderr.

**Casos pendientes.**

- [ ] SFTP-15.1: Inspeccionar valor efectivo para la cuenta y para el administrador ajeno.
- [ ] SFTP-15.2: En cuenta dedicada con marcador rc inocuo, comprobar ausencia de ejecución y SFTP operativo; no modificar rc de usuarios reales.

## Solicitudes de protocolo: argumentos, efecto y filtros

No son órdenes que se escriban directamente en el prompt de sftp. Una orden como get combina varias solicitudes; lcd/lls/!comando son operaciones locales de C. La tabla describe la interfaz semántica de los handlers, no sustituye la gramática binaria del protocolo ni inventa comandos para enviar handles desde una terminal.

Un handle es un identificador opaco de un recurso abierto en **esa sesión**. Los atributos del protocolo base incluyen flags para tamaño, UID/GID, permisos y tiempos; solo se aplican cuando el handler los utiliza y el UID tiene permiso. Un estado de error en una operación de múltiples atributos no garantiza que no se haya aplicado ninguno.

Las 29 filas abarcan los handlers base/extendidos de esta versión, no los mensajes de negociación/respuesta ni una promesa de soporte universal. Cada fila contiene dos variantes pendientes: una operación permitida y una denegada/error (**58 variantes**). Algunas necesitan un cliente de protocolo que pueda elegir la petición concreta; observar una orden CLI no demuestra que se hayan probado todas sus alternativas.

| Unidad | Argumentos y efecto | Control de lectura/filtro | Variantes pendientes | Fuente |
| --- | --- | --- | --- | --- |
| <a id="ssh-sftp-request-open"></a>[open](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-open) | **Argumentos:** ruta, flags portables de apertura y atributos iniciales. Devuelve un handle si puede abrir/crear; admite lectura, escritura, append, create, truncate y exclusive según flags. Sin modo de permisos explícito parte de 0666 al crear, sujeto a umask/ACL. | Caso especial: -R comprueba acceso/creación/truncado dentro del handler; no basta la marca 0 del dispatcher. | **Permitir:** Abrir lectura de archivo propio y leerlo. **Denegar/error:** Solicitar creación/truncado con -R o ruta no autorizada y comprobar que el contenido previo no cambió. | [sftp-server.c:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L131) |
| <a id="ssh-sftp-request-close"></a>[close](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-close) | **Argumentos:** handle de fichero o directorio de esta sesión. Cierra el recurso y devuelve estado; el handle deja de ser válido para lecturas/escrituras posteriores. | No está marcada de escritura; -p/-P aún pueden denegarla. | **Permitir:** Cerrar un handle válido. **Denegar/error:** Reutilizar un handle cerrado/inválido y comprobar error sin considerarlo escape. | [sftp-server.c:132](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L132) |
| <a id="ssh-sftp-request-read"></a>[read](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-read) | **Argumentos:** handle, offset uint64 y longitud uint32. Lee datos desde la posición; la implementación limita el tamaño de lectura a su máximo y devuelve EOF cuando corresponde. El handle debe permitir lectura. | Permitida por -R si acceso y filtros lo permiten. | **Permitir:** Leer rangos de un archivo propio y comparar bytes. **Denegar/error:** Usar un handle cerrado/no legible y separar error de EOF normal. | [sftp-server.c:133](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L133) |
| <a id="ssh-sftp-request-write"></a>[write](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-write) | **Argumentos:** handle, offset uint64 y bloque de datos. Escribe en el recurso abierto; tamaño de datos y máximo de mensaje limitan la petición. El modo append del descriptor puede alterar cómo se aplica la posición. | Marcada de escritura: -R la deniega; negar remove no la bloquea. | **Permitir:** Escribir una copia desechable y verificar contenido. **Denegar/error:** Con -R, comprobar rechazo y que ni tamaño ni contenido cambiaron. | [sftp-server.c:134](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L134) |
| <a id="ssh-sftp-request-lstat"></a>[lstat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-lstat) | **Argumentos:** ruta. Devuelve atributos sin seguir el enlace simbólico final; no entrega automáticamente el contenido del target. | Permitida por -R, sujeta a filtros/permisos de recorrido. | **Permitir:** Consultar enlace y archivo propios y distinguir tipos. **Denegar/error:** Consultar ruta ausente o denegar lstat y registrar fase. | [sftp-server.c:135](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L135) |
| <a id="ssh-sftp-request-fstat"></a>[fstat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-fstat) | **Argumentos:** handle de fichero. Consulta atributos del recurso ya abierto; no recibe otra ruta que sustituya el handle. | Permitida por -R, sujeta a filtros. | **Permitir:** Consultar tamaño/modo del archivo abierto. **Denegar/error:** Usar handle cerrado o denegar fstat y observar efecto en cliente. | [sftp-server.c:136](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L136) |
| <a id="ssh-sftp-request-setstat"></a>[setstat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-setstat) | **Argumentos:** ruta y conjunto de atributos. Puede modificar tamaño, permisos, tiempos y UID/GID según flags y privilegios del UID. Varias modificaciones no constituyen una transacción: un fallo no garantiza revertir las anteriores. | Marcada de escritura; -R la rechaza incluso si el conjunto solicitado parece inocuo. | **Permitir:** Cambiar modo de un archivo desechable permitido. **Denegar/error:** Intentar cambio con -R o propietario/grupo no autorizado; revisar todos los atributos tras un fallo. | [sftp-server.c:137](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L137) |
| <a id="ssh-sftp-request-fsetstat"></a>[fsetstat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-fsetstat) | **Argumentos:** handle y conjunto de atributos. Versión sobre recurso abierto para tamaño/modo/tiempos/UID-GID; sus backends dependen del SO. Mantiene la posibilidad de resultados parciales entre atributos. | Marcada de escritura; filtros y -R no dependen de que el cliente lo llame chmod. | **Permitir:** Modificar atributos de un handle propio abierto. **Denegar/error:** Usar -R o handle inválido; comprobar error y estado final. | [sftp-server.c:138](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L138) |
| <a id="ssh-sftp-request-opendir"></a>[opendir](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-opendir) | **Argumentos:** ruta de directorio. Abre un directorio y devuelve handle para readdir; requiere permisos reales del UID. | Permitida por -R, sujeta a filtros. | **Permitir:** Abrir /datos para listado. **Denegar/error:** Abrir ruta inaccesible/no directorio y distinguir causa. | [sftp-server.c:139](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L139) |
| <a id="ssh-sftp-request-readdir"></a>[readdir](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-readdir) | **Argumentos:** handle de directorio. Devuelve lotes de entradas/atributos hasta EOF; no es una única respuesta garantizada con todo el árbol. | Permitida por -R, sujeta a filtros. | **Permitir:** Recorrer entradas y terminar por EOF. **Denegar/error:** Usar handle de fichero/cerrado o denegar readdir; no atribuir el fallo a archivos inexistentes. | [sftp-server.c:140](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L140) |
| <a id="ssh-sftp-request-remove"></a>[remove](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-remove) | **Argumentos:** ruta de fichero. Elimina una entrada mediante unlink; permisos del directorio y otras reglas del filesystem siguen aplicándose. | Marcada de escritura; -R y -P remove la bloquean. | **Permitir:** Borrar solo una copia desechable. **Denegar/error:** Denegar remove y comprobar que sobreescribir por open/write sigue siendo un control distinto. | [sftp-server.c:141](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L141) |
| <a id="ssh-sftp-request-mkdir"></a>[mkdir](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-mkdir) | **Argumentos:** ruta y atributos iniciales. Crea directorio; utiliza modo pedido o 0777 si falta el de permisos, sujeto a umask/ACL. No aplica por ello todo atributo arbitrario recibido. | Marcada de escritura; -R la deniega. | **Permitir:** Crear directorio nuevo en /datos y revisar modo. **Denegar/error:** Repetir sobre nombre existente o pedirlo con -R; comprobar error sin alterar otro directorio. | [sftp-server.c:142](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L142) |
| <a id="ssh-sftp-request-rmdir"></a>[rmdir](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-rmdir) | **Argumentos:** ruta de directorio. Elimina un directorio vacío mediante rmdir; no equivale a un borrado recursivo. | Marcada de escritura; -R o -P rmdir la deniegan. | **Permitir:** Retirar directorio vacío creado para el ensayo. **Denegar/error:** Intentar sobre uno no vacío o bajo filtro y comprobar permanencia del contenido. | [sftp-server.c:143](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L143) |
| <a id="ssh-sftp-request-realpath"></a>[realpath](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-realpath) | **Argumentos:** ruta; cadena vacía se interpreta como punto. Canoniza desde el cwd/raíz actuales y devuelve nombre. Resolver .. dentro de chroot no recupera la raíz original del host. | Permitida por -R, sujeta a filtros. | **Permitir:** Canonizar /datos/.. y comprobar / de la jaula. **Denegar/error:** Comparar marcador exterior inaccesible y un fallo de ruta; no interpretar cd .. exitoso como escape. | [sftp-server.c:144](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L144) |
| <a id="ssh-sftp-request-stat"></a>[stat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-stat) | **Argumentos:** ruta. Consulta atributos siguiendo el enlace final; puede fallar aunque lstat del enlace funcione si el target no existe/es inaccesible dentro de la raíz. | Permitida por -R, sujeta a filtros. | **Permitir:** Consultar un archivo o enlace interno válido. **Denegar/error:** Comparar lstat del enlace-fuera con stat/get del target que no debe alcanzar el marcador exterior. | [sftp-server.c:145](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L145) |
| <a id="ssh-sftp-request-rename"></a>[rename](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-rename) | **Argumentos:** ruta anterior y nueva. Renombrado del protocolo base; la implementación intenta no sobrescribir un destino existente y puede usar link/unlink o fallback según tipo/filesystem. No prometer equivalencia con la extensión POSIX ni atomicidad universal. | Marcada de escritura; -R la deniega. Revisar también posix-rename para cubrir rutas alternativas del cliente. | **Permitir:** Renombrar una copia a nombre libre. **Denegar/error:** Solicitar destino existente o filtrar rename y comprobar qué forma pidió realmente el cliente. | [sftp-server.c:146](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L146) |
| <a id="ssh-sftp-request-readlink"></a>[readlink](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-readlink) | **Argumentos:** ruta del enlace. Devuelve el texto almacenado del enlace; ese texto puede parecer una ruta de B sin que el proceso pueda resolverla fuera del chroot. | Permitida por -R, sujeta a filtros. | **Permitir:** Leer el target de un enlace creado para el ensayo. **Denegar/error:** Denegar readlink o usar ruta no enlace; distinguir mostrar target de leer su contenido. | [sftp-server.c:147](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L147) |
| <a id="ssh-sftp-request-symlink"></a>[symlink](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-symlink) | **Argumentos:** target y nombre del nuevo enlace en el orden usado por OpenSSH. Crea enlace simbólico; falla si su nombre ya existe. La resolución posterior queda sujeta al chroot y al filesystem, no a que el target parezca absoluto. | Marcada de escritura; -R la deniega. | **Permitir:** Crear enlace a archivo propio interno. **Denegar/error:** Probar enlace hacia marcador exterior: el enlace puede existir, pero get no debe alcanzar el exterior. | [sftp-server.c:148](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L148) |
| <a id="ssh-sftp-request-posix-rename"></a>[posix-rename](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-posix-rename) | **Argumentos:** ruta anterior y nueva. Extensión posix-rename@openssh.com; utiliza rename del SO y puede reemplazar destino conforme a su semántica. Atomicidad/condiciones dependen de filesystem y operación. | Marcada de escritura; -R la deniega. El filtro usa posix-rename, no el nombre wire completo. | **Permitir:** Reemplazar únicamente un destino desechable y comprobar contenido. **Denegar/error:** Denegar posix-rename y rename; registrar negociación/fallback sin asumir que un cliente ensaya ambas. | [sftp-server.c:154](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L154) |
| <a id="ssh-sftp-request-statvfs"></a>[statvfs](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-statvfs) | **Argumentos:** ruta. Extensión de información del filesystem que contiene la ruta: bloques, disponibilidad y otros campos. No define una cuota de la cuenta ni garantiza que toda capacidad visible sea utilizable. | Permitida por -R, sujeta a filtros y soporte del SO. | **Permitir:** Consultar filesystem de /datos. **Denegar/error:** Denegar statvfs o consultar ruta inválida; distinguir información de capacidad de autorización de escritura. | [sftp-server.c:156](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L156) |
| <a id="ssh-sftp-request-fstatvfs"></a>[fstatvfs](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-fstatvfs) | **Argumentos:** handle de fichero. Variante de información del filesystem a partir del recurso abierto; puede no estar soportada por algún build/SO. | Permitida por -R, sujeta a filtros. | **Permitir:** Consultar el recurso de prueba abierto. **Denegar/error:** Usar handle inválido o backend no soportado y registrar estado. | [sftp-server.c:157](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L157) |
| <a id="ssh-sftp-request-hardlink"></a>[hardlink](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-hardlink) | **Argumentos:** ruta existente y nombre nuevo. Extensión hardlink@openssh.com; crea otra entrada al mismo inode cuando filesystem/UID lo permiten. Puede mantener una referencia al contenido aunque se retire otro nombre. | Marcada de escritura; -R la deniega. Un enlace duro no elimina los permisos ni crea acceso a un filesystem exterior no expuesto. | **Permitir:** Crear enlace duro de un archivo propio y comprobar identidad/contenido. **Denegar/error:** Intentar cruce de filesystem o filtro hardlink; no usar archivos ajenos como sonda. | [sftp-server.c:158](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L158) |
| <a id="ssh-sftp-request-fsync"></a>[fsync](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-fsync) | **Argumentos:** handle de fichero. Solicita sincronización del descriptor mediante fsync; no hace que una transferencia previa sea íntegra por sí sola. | Marcada de escritura en este dispatcher: -R la deniega, aunque no incluya un bloque de datos nuevo. | **Permitir:** Sincronizar un archivo propio abierto en perfil permitido. **Denegar/error:** Con -R o filtro, comprobar denegación sin confundirlo con fallo de lectura. | [sftp-server.c:159](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L159) |
| <a id="ssh-sftp-request-lsetstat"></a>[lsetstat](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-lsetstat) | **Argumentos:** ruta y atributos del enlace sin seguir el final. Extensión para modo/tiempos/UID-GID sobre el propio enlace según soporte del SO. Pedir tamaño se rechaza como BAD_MESSAGE en la implementación fijada. | Marcada de escritura; -R la deniega. | **Permitir:** Modificar un atributo admitido de un enlace propio en SO compatible. **Denegar/error:** Solicitar tamaño o usar -R; comprobar estado y que el target no sufrió un cambio inesperado. | [sftp-server.c:160](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L160) |
| <a id="ssh-sftp-request-limits"></a>[limits](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-limits) | **Argumentos:** sin campos específicos de argumento. Devuelve máximos de paquete, lectura, escritura y handles abiertos de esta implementación/entorno. El valor de handles puede depender del límite del proceso. | Permitida por -R; puede ser consulta implícita al arrancar el cliente. | **Permitir:** Registrar valores negociados por el cliente. **Denegar/error:** Denegar limits y observar compatibilidad/fallback; no convertir estos máximos en cuota de disco o límite de sesiones. | [sftp-server.c:161](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L161) |
| <a id="ssh-sftp-request-expand-path"></a>[expand-path](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-expand-path) | **Argumentos:** ruta, admitiendo formas con tilde. Expande rutas y las canoniza; ~ y ~/ tienen tratamiento ligado al directorio de inicio de SFTP. La consulta de otros usuarios depende de NSS/entorno disponible. | Permitida por -R, sujeta a filtros. | **Permitir:** Comparar punto, ~ y /datos según -d/home. **Denegar/error:** Probar nombre/ruta no resoluble o filtro; no atribuir al texto expandido acceso fuera de la jaula. | [sftp-server.c:162](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L162) |
| <a id="ssh-sftp-request-copy-data"></a>[copy-data](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-copy-data) | **Argumentos:** handle lectura, offset lectura uint64, longitud uint64, handle escritura y offset escritura uint64. Copia en el servidor entre recursos ya abiertos; longitud 0 significa hasta EOF. El código rechaza mismo handle/ruta/inode para origen y destino. Requiere handles y permisos adecuados. | Marcada de escritura; -R la deniega. Filtrar copy-data no impide que el cliente descargue/suba usando read/write si esos siguen permitidos. | **Permitir:** Copiar entre dos archivos propios distintos y comparar. **Denegar/error:** Probar mismo recurso o -R/filtro; no presentar rechazo de copia interna como inmutabilidad del contenido. | [sftp-server.c:164](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L164) |
| <a id="ssh-sftp-request-home-directory"></a>[home-directory](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-home-directory) | **Argumentos:** nombre de usuario; vacío selecciona el usuario de la sesión. Devuelve el home de la base de cuentas. Una consulta ajena puede fallar por NSS/datos ausentes dentro de la jaula; devolver un nombre no concede acceso a esa ruta. | Permitida por -R; limitar por política si no es necesaria. | **Permitir:** Consultar el usuario actual y distinguirlo del cwd elegido con -d. **Denegar/error:** Consultar usuario inexistente o denegar home-directory; registrar resultado sin ampliar exposición de cuentas. | [sftp-server.c:165](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L165) |
| <a id="ssh-sftp-request-users-groups-by-id"></a>[users-groups-by-id](../../../Documentaciones/guiones/ssh/formatos-y-casos.md#ssh-i-sftp-request-users-groups-by-id) | **Argumentos:** dos listas codificadas de UID y GID uint32. Devuelve nombres correspondientes mediante la base de cuentas, con cadena vacía para IDs no resueltos. Puede ser una consulta implícita de un listado largo del cliente. | Permitida por -R; no modifica propietarios. El filtro usa el nombre corto, no @openssh.com. | **Permitir:** Consultar los IDs de archivos del laboratorio cuando NSS lo permita. **Denegar/error:** Probar ID no resuelto o denegar la petición; distinguir nombre ausente de fallo del listado base. | [sftp-server.c:167](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L167) |

## Interpretar resultado y ámbito

| Observación | Lectura correcta |
| --- | --- |
| Autenticación aceptada y cierre posterior | Revisar arranque de sesión/chroot/servicio; no asumir que la cuenta obtuvo una shell. |
| Permission denied de una solicitud | Puede proceder de -R, listas, permisos/ACL o controles del SO; correlacionar logs. |
| No such file en un target absoluto | La resolución ocurre dentro de la raíz vigente. Un target escrito como ruta del host no prueba acceso al host. |
| EOF durante read/readdir | Puede ser terminación normal de datos/listado, distinta de una denegación. |
| Operation unsupported en extensión | Comprobar anuncio/soporte, versión y filtros; no es una autorización automática para usar otro método. |
| cd .. o readlink muestran un nombre | Navegar hasta / del chroot o leer texto de un enlace no equivale a escapar. |
| Umask produce un modo inicial | No fija un techo permanente si setstat/fsetstat y permisos permiten cambiarlo después. |

Los códigos del protocolo y el retorno del proceso son niveles distintos. Una solicitud puede fallar y el transporte seguir abierto; una sesión cerrada o un lote abortado no identifica por sí solo la causa. Recoger solicitud, estado/log, efecto sobre datos y retorno cuando corresponda.

-R es una política del servidor SFTP, no un mount read-only del filesystem ni una garantía de ausencia de toda escritura interna del SO. Los filtros por nombre no inspeccionan por sí solos rutas ni todas las intenciones de open/setstat.

## Compatibilidad, verificación y cierre

La práctica utiliza un subsistema existente y ForceCommand por cuenta, sin exigir que un Subsystem en Match sea aceptado por un paquete anterior. El soporte observado en las fuentes 10.6p1 no se declara ejecutado en el Windows 9.5p2 del cliente local.

Se comprueban localmente estructura, enlaces, conservación de IDs y perfil cliente con ssh -G. Los ensayos de sshd/chroot, permisos/ACL, solicitudes, logging y restauración requieren Linux y permanecen pendientes. No se utilizará la lista de otro binario/build como prueba del servidor integrado que se vaya a desplegar.

Cerrar transportes identificados, retirar credenciales de la cuenta de laboratorio, eliminar esa cuenta nueva antes de restaurar una política sin confinamiento y verificar acceso administrativo nuevo. Conservar evidencias sin privadas ni datos ajenos. No usar userdel -r con un home cuyo significado dentro del chroot no coincide con la ruta del host.

## Fuentes y actualización

- Manuales por unidad enlazados en cada ficha; todas las referencias de OpenSSH apuntan al commit fijado.
- [sftp-server.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c): getopt, request_permitted, tablas de handlers, comprobación de open y efectos de cada solicitud.
- [match.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/match.c): match_list compara nombres exactos en estas listas.
- [servconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.c) y [servconf.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.h): contexto, repetición y Subsystem en 10.6p1.
- [session.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/session.c): safely_chroot, selección de servidor interno y rechazo de sesión no SFTP.
- [sshd(8)](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8): fases de autenticación/sesión y restricciones por pública.
- [Referencia de transferencias](09-referencia-transferencias.md): CLI/órdenes ya desarrolladas para copias y lotes.

Actualizar por versión/build: comparar opciones públicas, dispatcher, nombres de extensión y marcas does_write; conservar IDs y repetir casos. Esta entrega desarrolla parcialmente SSH-T05/T06, SSH-C024/C028/C029/C030 y SSH-P07, sin cerrar el catálogo de órdenes SFTP ni toda la seguridad del servidor.
