# SSH · Referencia de validación y acceso del servidor

[Índice](README.md) · [Práctica de servidor](06-servidor-linux.md) · [Inventario](../../../Documentaciones/guiones/ssh/README.md)

Esta entrega desarrolla **cinco opciones de sshd y 16 directivas servidor** para comprobar y aplicar una política básica de acceso. Las demás opciones, límites, algoritmos, certificados, confinamiento y túneles conservan su desarrollo pendiente.

## Referencia, entorno y estado

| Campo | Alcance |
| --- | --- |
| Producto | OpenSSH Portable 10.6p1, commit a8c72b842423f0774f542d3c2197247c3dd28d74. |
| Consulta | 21 de octubre de 2026. |
| Entorno | Semántica upstream; recorrido Linux/systemd. Paquete, PAM, rutas y activación requieren contraste en cada distribución/build. |
| Requisitos | Binario identificado, acceso a configuración/host keys, cuenta y contexto de conexión conocidos. |
| Privilegios | Los tests deben poder leer recursos del daemon, normalmente mediante administración. Consultar versión no concede acceso remoto. |
| Efectos | -t/-T/-C no abren escucha ni aplican cambios. Editar archivos y recargar sí puede afectar conexiones nuevas y disponibilidad. |
| Estado | Documentado mediante manuales y parsers; todos los ensayos funcionales pendientes. |
| Unidades padre | SSH-C020…SSH-C025, con relaciones a SSH-T02/T05/T08 y SSH-P09. |

Los defaults son **upstream**, no valores garantizados del paquete instalado. La práctica explica cómo identificar unidad, archivo y argumentos efectivos. No introducir cambios en algoritmos o PAM para hacer coincidir una salida con esta referencia.

## Sintaxis de los modos seleccionados

```text
sshd -V
sshd -t [-f archivo]
sshd -T [-f archivo] [-C especificación]...
```

**Qué estás viendo.** Son formas de comprobación, no la sinopsis completa de todos los modos del daemon. No hay destino ni comando remoto posicional. En los ejemplos `ssh_server_bin` contiene la ruta absoluta ya comprobada en la práctica.

La interfaz cliente `ssh -G` y la interfaz servidor `sshd -T -C` responden preguntas diferentes. La primera selecciona cómo intenta conectar un cliente; la segunda muestra política del daemon para datos simulados de una conexión.

## Selección, contexto e interpretación

- Los nombres de directiva no distinguen mayúsculas; consultar la gramática de sus valores sin normalizarlos arbitrariamente.
- Un escalar suele conservar la primera asignación global. Los `Match` aplicables pueden seleccionar valores diferentes; entre varios bloques coincidentes importa el primero que los fije.
- Las listas Allow/Deny se acumulan en su contexto aplicable. `AuthorizedKeysFile` y `AuthenticationMethods` no se reemplazan ni acumulan por una regla universal de “gana el último”.
- Las opciones `-o/-f` del servicio pueden hacer distinta su política respecto de una invocación de test sin esos argumentos. Revisar unidad e includes.
- Las comprobaciones pueden consultar archivos, cuentas y resolución. No son una evaluación aislada de cualquier archivo ajeno.
- Un resultado cero de sintaxis no acredita escucha, acceso al firewall, autenticación, PAM, apertura de sesión ni recarga del proceso correcto.

Las fichas indican efectos y restricciones; la [práctica](06-servidor-linux.md) desarrolla copia, candidato, aplicación y restauración. Para cualquier ensayo registrar binario/paquete, precondición, comando o fragmento, stdout/stderr, retorno, contexto y resultado observado. Los comandos de ejemplo son alternativas, no un script para aplicar todas las políticas a la vez.

## Reversión y evidencia común

| Operación | Comprobación y cierre |
| --- | --- |
| Consultar versión/configuración | Leer retorno y campos; no hay configuración en vivo que revertir por la consulta. |
| Modificar candidato | Conservar principal/includes originales; ningún daemon debe cargar el archivo inválido de prueba. |
| Instalar y recargar | Copia administrativa, acceso independiente y retorno de validación/recarga; verificar nuevas conexiones. |
| Retirar un método o restringir cuentas | Probar acceso permitido y denegado; una sesión antigua o un fallo de red no son esa evidencia. |
| Restaurar | Recuperar todos los archivos realmente modificados, validar, recargar/arrancar según estado y abrir conexión nueva. |

No incluir privadas de host/usuario ni secretos en la evidencia. Las configuraciones y registros pueden revelar cuentas, orígenes y rutas. La reversión del archivo principal no revierte firewall, unidades, cuentas o includes cambiados por otros procedimientos.

## Opciones de sshd

<a id="ssh-s-opt-74"></a>

### sshd -t

Unidad: [SSH-I-SSHD-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sshd-opt-74). Fuente: [sshd.8:230](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L230).

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Sin argumento. |
| Predeterminado | Sin -t no se solicita este modo de comprobación. |
| Repetición y selección | Repetir -t conserva el modo simple; al mezclar -t/-T, la última asignación del parser decide el modo. Usar una sola forma. |
| Efecto y límites | Comprueba configuración y coherencia de claves, sin iniciar una escucha. Puede necesitar privilegios para leer host keys y preparación de ejecución del paquete. No prueba PAM, acceso de usuarios, red ni que la unidad use ese archivo. |

```sh
sudo "$ssh_server_bin" -t -f /root/ssh-lab-20261021-01/sshd_config.candidato
```

**Qué estás viendo.** Habitualmente no hay salida en éxito; exigir retorno cero. Un error de sintaxis, clave o preparación detiene el cambio.

Casos pendientes:

- [ ] Candidato válido y otro con directiva inexistente: solo el primero debe validar.
- [ ] Host key/configuración ilegible o falta de preparación: localizar el recurso; no corregir el fallo suprimiendo controles.

<a id="ssh-s-opt-54"></a>

### sshd -T

Unidad: [SSH-I-SSHD-OPT-54](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sshd-opt-54). Fuente: [sshd.8:216](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L216).

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Sin argumento; -C puede aportar contexto. |
| Predeterminado | Sin -T no se solicita salida de configuración efectiva con validación ampliada. |
| Repetición y selección | Repetir -T conserva el modo ampliado; evitar mezcla con -t, que puede cambiarlo. |
| Efecto y límites | Valida, imprime configuración efectiva por stdout y sale. Incorpora las comprobaciones de -t. Sin -C no representa automáticamente todas las cuentas/orígenes que tengan Match. Puede consultar cuentas/resolución al evaluar. |

```sh
sudo "$ssh_server_bin" -T -f /etc/ssh/sshd_config -C user=alumno,addr=192.0.2.20,host=cliente.example,laddr=192.0.2.10,lport=22
```

**Qué estás viendo.** Relacionar campos con la política esperada y comprobar retorno; tener texto por stdout no prueba conexión ni recarga.

Casos pendientes:

- [ ] Mismo archivo, dos usuarios/orígenes: comparar reglas Match aplicables.
- [ ] Argumentos de unidad distintos o archivo incorrecto: identificar discrepancia antes de dar por validado el servicio.

<a id="ssh-s-opt-43"></a>

### sshd -C

Unidad: [SSH-I-SSHD-OPT-43](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sshd-opt-43). Fuente: [sshd.8:96](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L96).

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Especificación obligatoria: user=, addr=, host=, laddr=, lport=, rdomain= o bandera invalid-user sin valor. Pares separados por comas o varias -C. |
| Predeterminado | Sin parámetros no se simula una conexión concreta para Match. |
| Repetición y selección | Varias -C completan la especificación; repetir una misma clave asigna el último valor en el parser fijado. Evitar contradicciones. |
| Efecto y límites | Se utiliza con -T. addr es origen remoto visto por sshd; host, nombre resuelto de ese origen; laddr/lport son extremo local del servidor. rdomain depende del sistema. invalid-user simula cuenta desconocida, no crea una cuenta. |

```sh
sudo "$ssh_server_bin" -T -f /etc/ssh/sshd_config -C user=alumno -C addr=192.0.2.20,host=cliente.example,laddr=192.0.2.10,lport=22
```

**Qué estás viendo.** Usar datos reales desde la perspectiva del servidor. No intercambiar host con hostname del destino ni el puerto NAT externo con lport.

Casos pendientes:

- [ ] Datos completos frente a otro origen/usuario: observar cambio de política; contexto incompleto puede impedir evaluar criterios.
- [ ] Nombre de parámetro no admitido, puerto inválido o -C sin -T: error de comprobación.

<a id="ssh-s-opt-66"></a>

### sshd -f

Unidad: [SSH-I-SSHD-OPT-66](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sshd-opt-66). Fuente: [sshd.8:155](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L155).

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Ruta obligatoria al archivo de configuración. |
| Predeterminado | /etc/ssh/sshd_config en upstream. |
| Repetición y selección | La última -f selecciona el principal; no fusiona varios archivos. |
| Efecto y límites | Selecciona qué configuración se comprueba o carga. Include conserva sus reglas propias: las rutas relativas de includes se basan en /etc/ssh, no en la carpeta del candidato. El código reconoce none para no cargar el principal y usar defaults; no es una política de bastionado. |

```sh
sudo "$ssh_server_bin" -t -f /root/ssh-lab-20261021-01/sshd_config.candidato
```

**Qué estás viendo.** Se valida el candidato, no se reconfigura el daemon en marcha. No hacer que el candidato sea un enlace que modifique el principal al editar.

Casos pendientes:

- [ ] Archivo propio fuera de /etc/ssh con includes absolutos/relativos: confirmar fuentes realmente leídas.
- [ ] Ruta inexistente, sin permisos o argumento ausente: error; none no elimina necesidad de claves/preparación en los tests.

<a id="ssh-s-opt-56"></a>

### sshd -V

Unidad: [SSH-I-SSHD-OPT-56](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-sshd-opt-56). Fuente: [sshd.8:267](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L267).

| Propiedad | Comportamiento |
| --- | --- |
| Argumentos | Sin argumento ni necesidad de destino. |
| Predeterminado | Sin -V se sigue la invocación solicitada. |
| Repetición y selección | La primera -V alcanzada imprime versión y termina. |
| Efecto y límites | Consulta del binario, no del daemon que ya está escuchando ni del cliente. En el código upstream escribe en stderr y sale con 0 de forma temprana. |

```sh
sudo "$ssh_server_bin" -V
```

**Qué estás viendo.** Anotar ruta/build y distinguirlo de ssh -V. Paquetes antiguos pueden no admitir la opción; sus metadatos dan la alternativa.

Casos pendientes:

- [ ] Dos binarios o una actualización pendiente de recargar/reiniciar: no inferir la versión del proceso solo desde el archivo.
- [ ] Mensaje en stderr con retorno cero y build sin opción: resultados diferentes.

## Directivas de sshd_config

<a id="ssh-s-cfg-include"></a>

### Include

Unidad: [SSH-I-SERVER-INCLUDE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-include). Fuente: [sshd_config.5:972](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L972).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Una o varias rutas/patrones obligatorios; glob procesado en orden léxico, rutas relativas bajo /etc/ssh. |
| Predeterminado upstream | No hay inclusiones implícitas upstream; el archivo suministrado por el paquete puede declararlas. |
| Contexto | Global y Match |
| Repetición y selección | Cada Include se procesa donde aparece; no es una asignación escalar. Puede usarse condicionalmente dentro de Match. |
| Efecto y límites | Amplía las fuentes leídas. Un patrón sin coincidencias puede no producir error en el parser; por eso -t correcto no demuestra que se cargó el fragmento esperado. El orden de lecturas afecta a escalares y listas. |

```sshconfig
Include /etc/ssh/sshd_config.d/*.conf
```

**Qué estás viendo.** Revisar archivos presentes y salida -T. El prefijo 99 no significa prioridad final sobre una asignación anterior; no confiar en un fichero que nunca se incluyó.

Casos pendientes:

- [ ] Dos fragmentos con un escalar distinto: verificar el primer valor global y las excepciones Match.
- [ ] Patrón vacío, archivo ilegible y ciclo de inclusión: distinguir ausencia permitida, error de lectura y límite de profundidad.

<a id="ssh-s-cfg-match"></a>

### Match

Unidad: [SSH-I-SERVER-MATCH](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-match). Fuente: [sshd_config.5:1283](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1283).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | All; Invalid-User; o pares criterio/patrón. Criterios 10.6p1: User, Group, Host, LocalAddress, LocalPort, Version, RDomain, Address. |
| Predeterminado upstream | Sin Match, las directivas son globales. |
| Contexto | Introduce bloque Match |
| Repetición y selección | Cada bloque dura hasta el siguiente Match o EOF; si varios bloques satisfechos fijan el mismo escalar, se aplica su primera instancia correspondiente. |
| Efecto y límites | Los criterios de una línea se combinan y los patrones admiten listas/comodines/negación según su gramática. Address admite CIDR válido. Version compara la versión de sshd, no el banner del cliente. Solo se permiten directivas del subconjunto Match. |

```sshconfig
Match User alumno Address 192.0.2.0/24
    PasswordAuthentication no
```

**Qué estás viendo.** Consultar con -T -C para dentro/fuera del criterio. Match All abre un bloque que coincide con todos; no restablece el contexto global ni habilita directivas globales como UsePAM o StrictModes.

Casos pendientes:

- [ ] Dos criterios, patrón negado y dos bloques satisfechos: observar selección y primera asignación aplicable.
- [ ] CIDR inválido, criterio no soportado por el paquete o directiva solo global dentro del bloque: validación debe rechazarlos.

<a id="ssh-s-cfg-permitrootlogin"></a>

### PermitRootLogin

Unidad: [SSH-I-SERVER-PERMITROOTLOGIN](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-permitrootlogin). Fuente: [sshd_config.5:1544](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1544).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes, prohibit-password, forced-commands-only o no; alias heredado without-password. |
| Predeterminado upstream | prohibit-password en upstream. |
| Contexto | Global y Match |
| Repetición y selección | Escalar: primera asignación global; puede ser sustituida por el Match aplicable. |
| Efecto y límites | Controla entrada SSH directa de root. prohibit-password retira password y keyboard-interactive para root; no impide todas sus autenticaciones. forced-commands-only admite pública con command forzado y excluye otros métodos. no deniega el acceso remoto directo. |

```sshconfig
PermitRootLogin no
```

**Qué estás viendo.** No crea una cuenta administrativa alternativa ni modifica sudo. Confirmar recuperación como usuario ordinario antes de aplicarlo.

Casos pendientes:

- [ ] no para root y acceso ordinario por clave: política efectiva y acceso administrativo separado.
- [ ] prohibit-password/forced-commands-only en entorno específico: no confundirlos con prohibición total; valor desconocido: error.

<a id="ssh-s-cfg-pubkeyauthentication"></a>

### PubkeyAuthentication

Unidad: [SSH-I-SERVER-PUBKEYAUTHENTICATION](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-pubkeyauthentication). Fuente: [sshd_config.5:1855](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1855).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no. |
| Predeterminado upstream | yes. |
| Contexto | Global y Match |
| Repetición y selección | Escalar con primera asignación y excepciones Match. |
| Efecto y límites | Permite el método de clave pública, pero no autoriza automáticamente claves, algoritmos, cuentas ni certificados. Puede formar parte de una secuencia AuthenticationMethods. |

```sshconfig
PubkeyAuthentication yes
```

**Qué estás viendo.** Exigir firma/autenticación completada, además de la pública autorizada. Ofrecer una clave no prueba éxito.

Casos pendientes:

- [ ] Clave autorizada frente a otra no autorizada: resultado de autenticación distinto.
- [ ] no combinado con AuthenticationMethods publickey: política no satisfacible; validar y revisar métodos antes de aplicar.

<a id="ssh-s-cfg-passwordauthentication"></a>

### PasswordAuthentication

Unidad: [SSH-I-SERVER-PASSWORDAUTHENTICATION](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-passwordauthentication). Fuente: [sshd_config.5:1458](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1458).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no. |
| Predeterminado upstream | yes upstream; comprobar cambios del paquete. |
| Contexto | Global y Match |
| Repetición y selección | Escalar con selección global/Match. |
| Efecto y límites | Controla el método password. no no elimina peticiones de contraseña por keyboard-interactive/PAM ni cambia la contraseña del usuario. |

```sshconfig
PasswordAuthentication no
```

**Qué estás viendo.** Comparar métodos ofrecidos y política contextual. Una prueba con BatchMode que no pregunta no demuestra que el servidor haya retirado password.

Casos pendientes:

- [ ] Cliente limitado a password: método retirado no permite autenticación; abortar si aparece una petición inesperada.
- [ ] no con keyboard-interactive aún permitido: comprobar que los mecanismos son distintos, sin modificar una política MFA por rutina.

<a id="ssh-s-cfg-kbdinteractiveauthentication"></a>

### KbdInteractiveAuthentication

Unidad: [SSH-I-SERVER-KBDINTERACTIVEAUTHENTICATION](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-kbdinteractiveauthentication). Fuente: [sshd_config.5:1026](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1026).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no; ChallengeResponseAuthentication es alias obsoleto del parser. |
| Predeterminado upstream | yes upstream; algunos paquetes suministran no. |
| Contexto | Global y Match |
| Repetición y selección | Escalar, incluida la selección por el alias; revisar orden y Match. |
| Efecto y límites | Habilita el método interactivo, que puede transportar contraseñas, OTP u otros desafíos según backend. Desactivarlo puede romper MFA; no es simplemente otra grafía de PasswordAuthentication. |

```sshconfig
KbdInteractiveAuthentication no
```

**Qué estás viendo.** Perfil simple de laboratorio; no aplicarlo si el entorno exige un segundo factor por ese método.

Casos pendientes:

- [ ] Cliente limitado a keyboard-interactive: contrastar oferta/denegación con logs.
- [ ] Alias previo contradictorio y bloque Match: comprobar valor real; OTP/PAM requieren ensayo específico del backend.

<a id="ssh-s-cfg-authenticationmethods"></a>

### AuthenticationMethods

Unidad: [SSH-I-SERVER-AUTHENTICATIONMETHODS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-authenticationmethods). Fuente: [sshd_config.5:212](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L212).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | any o una o varias secuencias. Métodos: publickey, password, keyboard-interactive, gssapi-with-mic, hostbased, none. Comas encadenan requisitos; espacios separan alternativas. |
| Predeterminado upstream | any: basta un método habilitado aceptado, no significa acceso sin autenticar. |
| Contexto | Global y Match |
| Repetición y selección | Primera lista efectiva; varias secuencias se escriben en esa misma asignación. Match puede seleccionar otra. |
| Efecto y límites | Cada secuencia exige completar sus métodos en orden; los métodos deben estar habilitados. keyboard-interactive:pam/bsdauth limita dispositivo cuando existe. publickey,publickey exige claves distintas; dos claves no acreditan por sí solas dos factores independientes. none se relaciona con cuentas sin contraseña y PermitEmptyPasswords, no se usa aquí. |

```sshconfig
AuthenticationMethods publickey
```

**Qué estás viendo.** El perfil exige pública; no reemplazar una secuencia MFA existente por este ejemplo. Como gramática, publickey,password publickey,keyboard-interactive expresa dos alternativas que empiezan por pública.

Casos pendientes:

- [ ] Método único frente a secuencias de laboratorio: verificar orden, éxito parcial y método siguiente.
- [ ] Método desconocido/deshabilitado o reutilización de la misma clave en publickey,publickey: error o rechazo según fase.

<a id="ssh-s-cfg-usepam"></a>

### UsePAM

Unidad: [SSH-I-SERVER-USEPAM](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-usepam). Fuente: [sshd_config.5:2122](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L2122).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no; depende de compilación con PAM. |
| Predeterminado upstream | no upstream; Ubuntu/Debian y otros paquetes pueden configurar yes. |
| Contexto | Solo global |
| Repetición y selección | Escalar global; no permitido dentro de Match. |
| Efecto y límites | Integra autenticación PAM por password/keyboard-interactive y controles de cuenta/sesión para todos los métodos. Con yes, una clave correcta todavía puede ser rechazada por cuenta/política PAM. No cambiarlo para eludir un problema de acceso. |

```sshconfig
UsePAM yes
```

**Qué estás viendo.** El ejemplo ilustra la directiva; la práctica conserva la política del paquete. PAM habilitado requiere daemon privilegiado según la referencia.

Casos pendientes:

- [ ] Pública válida y cuenta rechazada por PAM: distinguir firma de autorización de cuenta.
- [ ] Directiva en Match o build sin PAM: registrar validación/soporte; no asumir que una opción reconocida implica backend operativo.

<a id="ssh-s-cfg-allowusers"></a>

### AllowUsers

Unidad: [SSH-I-SERVER-ALLOWUSERS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-allowusers). Fuente: [sshd_config.5:190](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L190).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Patrones de nombres separados por espacios; USER@HOST y origen CIDR admitidos. Un número no se interpreta como UID. |
| Predeterminado upstream | Sin esta restricción, ninguna lista AllowUsers limita los nombres; siguen vigentes las demás políticas. |
| Contexto | Global y Match |
| Repetición y selección | Acumula patrones al repetirse dentro de la configuración aplicable; no funciona como reemplazo escalar. Evaluar también Match. |
| Efecto y límites | Exige coincidencia con la lista si está definida. DenyUsers tiene prioridad; permitir aquí no evita restricciones de grupos, métodos o cuenta. |

```sshconfig
AllowUsers alumno adminlab
```

**Qué estás viendo.** Comprobar nombres reales y cuenta de recuperación. Añadir una lista no borra automáticamente una lista previa más amplia.

Casos pendientes:

- [ ] Cuenta permitida/no incluida y patrón USER@HOST visto desde el servidor: resultados por política, no por red.
- [ ] Patrón negado sin alternativa positiva o lista repetida: inspeccionar coincidencia/acumulación antes de aplicar.

<a id="ssh-s-cfg-allowgroups"></a>

### AllowGroups

Unidad: [SSH-I-SERVER-ALLOWGROUPS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-allowgroups). Fuente: [sshd_config.5:135](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L135).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Patrones de nombres de grupo, separados por espacios; grupo primario o suplementario. No son GID numéricos. |
| Predeterminado upstream | Sin lista no hay esta restricción de grupo; siguen las demás. |
| Contexto | Global y Match |
| Repetición y selección | Acumula listas repetidas en el contexto aplicable; comprobar Match y pertenencias reales. |
| Efecto y límites | Requiere pertenecer a un grupo coincidente si existe lista. DenyGroups prevalece; AllowUsers y otras condiciones también deben cumplirse. |

```sshconfig
AllowGroups ssh-lab-admins
```

**Qué estás viendo.** Ese grupo es un marcador de laboratorio que debe existir y tener miembros revisados; la directiva no lo crea ni añade usuarios.

Casos pendientes:

- [ ] Grupo primario y suplementario: ambos pueden permitir; usuario sin coincidencia: rechazo.
- [ ] Grupo inexistente, nombre frente a GID y pertenencia cambiante: revisar servicio de identidades, no conceder grupos a ciegas.

<a id="ssh-s-cfg-denyusers"></a>

### DenyUsers

Unidad: [SSH-I-SERVER-DENYUSERS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-denyusers). Fuente: [sshd_config.5:687](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L687).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Patrones de nombres; puede limitar USER@HOST y origen CIDR; números no se interpretan como UID. |
| Predeterminado upstream | Sin lista no excluye usuarios por esta directiva. |
| Contexto | Global y Match |
| Repetición y selección | Acumula patrones repetidos; no sustituye la lista previa. |
| Efecto y límites | Deniega usuarios coincidentes antes de que AllowUsers pueda permitirlos. No deshabilita la cuenta para otros servicios ni finaliza automáticamente sus sesiones abiertas. |

```sshconfig
DenyUsers cuenta_bloqueada_lab
```

**Qué estás viendo.** Para una prueba de denegación usar una cuenta de laboratorio conocida y un acceso de recuperación distinto. No deducir existencia de cuenta solo del error al cliente.

Casos pendientes:

- [ ] Usuario presente en AllowUsers y DenyUsers: prevalece denegación.
- [ ] Patrón de origen y repetición: comprobar alcance exacto para no excluir recuperación.

<a id="ssh-s-cfg-denygroups"></a>

### DenyGroups

Unidad: [SSH-I-SERVER-DENYGROUPS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-denygroups). Fuente: [sshd_config.5:670](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L670).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Patrones de nombres de grupos primarios/suplementarios; no GID. |
| Predeterminado upstream | Sin lista no hay exclusión por esta directiva. |
| Contexto | Global y Match |
| Repetición y selección | Acumula patrones repetidos en la configuración aplicable. |
| Efecto y límites | Deniega si algún grupo coincide, antes de AllowGroups. Una pertenencia adicional puede provocar rechazo aunque otra pertenencia esté permitida. |

```sshconfig
DenyGroups ssh-lab-bloqueados
```

**Qué estás viendo.** Revisar todos los grupos de la cuenta y el backend de identidad. No sustituye la revocación de claves ni retira sesiones existentes.

Casos pendientes:

- [ ] Usuario con grupo permitido y otro denegado: rechazo por el denegado.
- [ ] Cambio de pertenencia y lista repetida: contrastar resolución actual y conexión nueva.

<a id="ssh-s-cfg-strictmodes"></a>

### StrictModes

Unidad: [SSH-I-SERVER-STRICTMODES](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-strictmodes). Fuente: [sshd_config.5:1992](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1992).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no. |
| Predeterminado upstream | yes. |
| Contexto | Solo global |
| Repetición y selección | Escalar solo global; no permitido dentro de Match. |
| Efecto y límites | Comprueba modos/propiedad de archivos de usuario y home antes de aceptar el acceso correspondiente. No elimina otras comprobaciones; ChrootDirectory mantiene sus verificaciones incluso si se desactiva. |

```sshconfig
StrictModes yes
```

**Qué estás viendo.** Corregir propietario/modos/ACL y fuente efectiva. No utilizar no como solución a un Permission denied sin identificar la causa.

Casos pendientes:

- [ ] Pública autorizada con archivos correctos frente a escritura insegura en un laboratorio: correlacionar logs.
- [ ] Directiva dentro de Match: error; cambiar solo chmod no prueba que se hayan revisado ACL, propietario o contexto SELinux.

<a id="ssh-s-cfg-authorizedkeysfile"></a>

### AuthorizedKeysFile

Unidad: [SSH-I-SERVER-AUTHORIZEDKEYSFILE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-authorizedkeysfile). Fuente: [sshd_config.5:303](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L303).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Una o varias rutas/patrones y tokens admitidos: %%, %h, %u, %U; none debe aparecer solo. Rutas relativas al home de la cuenta después de expansión. |
| Predeterminado upstream | .ssh/authorized_keys y .ssh/authorized_keys2. |
| Contexto | Global y Match |
| Repetición y selección | Primera lista efectiva; expresar varias rutas en esa lista. No asumir acumulación al repetir la directiva; Match puede seleccionar otra. |
| Efecto y límites | Selecciona archivos de públicas para cuentas válidas. none omite esa fuente de archivos, pero no elimina una autorización por AuthorizedKeysCommand o CA. No es known_hosts ni una ubicación para privadas. |

```sshconfig
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
```

**Qué estás viendo.** Revisar el valor de -T -C y después permisos/contenido de los archivos expandidos de la cuenta. No convertir la ruta relativa en relativa al candidato.

Casos pendientes:

- [ ] Dos archivos y una pública duplicada: retirar una sola entrada puede dejar autorización vigente.
- [ ] none mezclado con rutas, argumento ausente o archivo ilegible: distinguir parser y acceso durante autenticación.

<a id="ssh-s-cfg-disableforwarding"></a>

### DisableForwarding

Unidad: [SSH-I-SERVER-DISABLEFORWARDING](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-disableforwarding). Fuente: [sshd_config.5:708](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L708).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | yes o no. |
| Predeterminado upstream | no en el registro de defaults upstream. |
| Contexto | Global y Match |
| Repetición y selección | Escalar; puede establecerse por Match. yes prevalece sobre otras opciones de forwarding de OpenSSH. |
| Efecto y límites | Deshabilita forwarding X11, de agente, TCP y StreamLocal. No es un aislamiento de red de la cuenta: una shell con programas/permisos suficientes puede retransmitir tráfico por otros medios. |

```sshconfig
DisableForwarding yes
```

**Qué estás viendo.** Comprobar el contexto y contrastar solicitudes de canal en el bloque de túneles. No asumir que bloquear el cliente baste para imponer política servidor.

Casos pendientes:

- [ ] Contexto con yes y solicitud de canal: denegación esperada por política.
- [ ] Opciones de forwarding más permisivas junto a yes: verificar prevalencia; revisar dependencias legítimas antes de aplicar.

<a id="ssh-s-cfg-loglevel"></a>

### LogLevel

Unidad: [SSH-I-SERVER-LOGLEVEL](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-server-loglevel). Fuente: [sshd_config.5:1187](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5#L1187).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG, DEBUG1, DEBUG2 o DEBUG3; DEBUG equivale a DEBUG1. |
| Predeterminado upstream | INFO. |
| Contexto | Global y Match |
| Repetición y selección | Escalar, con posible selección contextual; argumentos de arranque del daemon también pueden fijar logging. |
| Efecto y límites | Determina detalle del registro servidor, no el nivel -v del cliente. DEBUG puede revelar información de sesiones y debe limitarse a diagnóstico controlado. El destino depende de syslog/unidad/opciones. |

```sshconfig
LogLevel INFO
```

**Qué estás viendo.** Correlacionar intento y proceso correctos; un log sin el mensaje esperado no acredita por sí solo ausencia de intento. No promete auditoría completa de comandos.

Casos pendientes:

- [ ] INFO frente a VERBOSE temporal: comprobar utilidad y metadatos, restaurando al terminar.
- [ ] Nivel desconocido, unidad/proceso de sesión distinto y falta de permisos de lectura: diagnosticar por separado.

## Matriz de métodos: errores frecuentes

| Configuración o prueba | Interpretación |
| --- | --- |
| `PasswordAuthentication no` con keyboard-interactive habilitado | Se retiró un método; todavía puede existir un desafío de contraseña por otro mecanismo. |
| `UsePAM yes` con ambos métodos de contraseña desactivados | Los controles PAM de cuenta/sesión pueden seguir interviniendo en accesos por clave. |
| `AuthenticationMethods publickey,password` | Se requieren ambos métodos consecutivos, habilitados y satisfechos. No es una alternativa. |
| `AuthenticationMethods publickey password` | Son alternativas de un método, no dos factores obligatorios. |
| `BatchMode yes` en el cliente | Suprime interacción del cliente; no demuestra que el servidor haya prohibido contraseñas. |
| `Server accepts key` | Aceptación de una pública en consulta; todavía puede faltar firma, otro método o autorización de cuenta. |
| `StrictModes no` | No arregla el origen de permisos/propiedad inseguros ni elimina todas las comprobaciones. |
| `DisableForwarding yes` con shell disponible | Bloquea funciones de forwarding de OpenSSH; no proporciona confinamiento completo de la cuenta. |
| Nueva orden cliente sobre ControlMaster existente | Puede reutilizar una autenticación anterior; la prueba del cambio exige una conexión nueva. |

## Compatibilidad y cierre de cobertura

Las 21 fichas tienen enlace recíproco al inventario y **42 casos pendientes de ensayo**. El guion conserva abiertas sus familias. La instalación por distribución se recoge en la práctica con fuentes del paquete; no se ha instalado ni probado un servidor mediante esta documentación.

Los parsers fijados respaldan las reglas de repetición y contexto. En particular, el booleano servidor común acepta yes/no; no se deben trasladar automáticamente alias true/false de algunas directivas cliente. El registro `servconf.h` confirma defaults y opciones solo globales; su reconocimiento no garantiza que el backend esté compilado o disponible.

Para actualizar, comparar manual, parser, registro de directivas y paquete; después repetir los casos afectados con un entorno identificado. Quedan por desarrollar el resto de opciones de sshd y directivas servidor, límites de conexiones, algoritmos, rutas/puertos, confinamiento, restricciones por clave, certificados y todas las diferencias de Windows.

## Fuentes fijadas

- [sshd.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8) y [sshd.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c): semántica pública, selección de modos y -C/-f.
- [sshd_config.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5): directivas, contexto, métodos y tokens.
- [servconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.c): lectura de configuración, repetición, includes y parámetros simulados.
- [servconf.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.h): registro de directivas/defaults y disponibilidad por compilación.
- [Recorrido y fuentes de distribución](06-servidor-linux.md#fuentes-y-cobertura).
