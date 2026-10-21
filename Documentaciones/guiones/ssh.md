# Guion de contenidos · SSH y OpenSSH

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Secure Shell (SSH): fundamentos del protocolo y referencia de OpenSSH cliente/servidor, incluyendo implementación portable y Windows OpenSSH. Distinguir versión del protocolo, versión del producto y modificaciones del distribuidor. Cubrir Linux, Windows y diferencias con clientes opcionales como PuTTY; el catálogo completo de PuTTY se mantiene como extensión separada si se incorpora.

**Estado:** temario e inventario de familias definidos. El [inventario versionado de OpenSSH Portable 10.6p1](ssh/README.md) desglosa las opciones y directivas de su referencia upstream y registra el contraste con los parsers. El desarrollo completo por unidad, los defaults de cada compilación, las variantes Linux/Windows y las pruebas funcionales siguen pendientes. Las tablas son puntos de trabajo; aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de declarar la referencia completa.

## Temario

### SSH-T01 · Protocolo y modelo de confianza

- [ ] TCP, negociación, intercambio de claves, cifrado, integridad y autenticación.
- [ ] Claves de host frente a claves de usuario; fingerprint y verificación por canal independiente.
- [ ] RSA frente a algoritmos de firma RSA; Ed25519, ECDSA, FIDO2 y algoritmos disponibles según versión.
- [ ] Host key checking, TOFU, certificados SSH y diferencia con certificados TLS/X.509.

### SSH-T02 · Instalación y servicio

- [ ] Paquetes cliente/servidor y capacidades Windows; archivos, usuarios y privilegios del daemon.
- [ ] Escucha, sockets, firewall, nombre de servicio por distribución y gestión con systemd o Service Control Manager.
- [ ] Versiones, compatibilidad, actualizaciones y diferencias entre documentación upstream y paquete instalado.

### SSH-T03 · Conexión y configuración cliente

- [ ] Destino, usuario, puerto, IPv4/IPv6, URI y sesión interactiva frente a comando remoto.
- [ ] Precedencia de opciones, configuración personal/global, Host, Match, Include y expansión de tokens.
- [ ] TTY, escapes, shell, quoting, variables, códigos de salida y multiplexación.

### SSH-T04 · Autenticación y claves

- [ ] Generación, formatos, passphrase, permisos/ACL, instalación, rotación y revocación.
- [ ] authorized_keys y restricciones por clave; agentes, almacenamiento y riesgo de agent forwarding.
- [ ] Password, publickey, keyboard-interactive, MFA/PAM, GSSAPI y host-based según plataforma.
- [ ] FIDO2, PKCS#11, tokens y llaves residentes; recuperación y acceso de emergencia.

### SSH-T05 · Servidor y bastionado

- [ ] sshd_config, Include y Match; autenticación, usuarios/grupos, root y cuentas de servicio.
- [ ] Sesiones, forwarding, chroot, ForceCommand, internal-sftp, logs y límites.
- [ ] Validar sintaxis/configuración efectiva antes de recargar; conservar una sesión de recuperación.
- [ ] Bastionado por riesgo y compatibilidad; no desactivar la verificación de host como solución habitual.

### SSH-T06 · Transferencias y automatización

- [ ] SFTP frente a SCP y rsync sobre SSH; versiones de protocolo y modo legacy.
- [ ] Copias recursivas, metadatos, enlaces, rutas, reanudación, lotes y límites de velocidad.
- [ ] Comandos no interactivos, BatchMode, timeouts, stdin/stdout/stderr y tareas programadas.

### SSH-T07 · Túneles y acceso indirecto

- [ ] Forwarding local, remoto y dinámico; bind address, GatewayPorts y exposición.
- [ ] Jump hosts, ProxyJump/ProxyCommand, cadenas de salto y restricciones de destino.
- [ ] X11, TUN/TAP, socket Unix, SOCKS y túneles inversos; requisitos y riesgos.

### SSH-T08 · PKI SSH, auditoría y diagnóstico

- [ ] CA de usuario y host, principals, períodos de validez, seriales, critical options y extensiones.
- [ ] Known hosts, certificados, DNS SSHFP, KRL y rotación de host keys.
- [ ] Logs cliente/servidor, negociación, permisos, políticas, conectividad y errores de autenticación.
- [ ] Auditoría de sesiones y límites de lo que registra OpenSSH sin instrumentación adicional.

## Inventario versionado

El [desglose de OpenSSH Portable 10.6p1](ssh/README.md) añade una unidad por opción/directiva y referencias a las líneas de una versión fijada:

- [Opciones CLI y argumentos por modo](ssh/cli.md).
- [Configuración cliente y servidor](ssh/configuracion.md).
- [Modos, formatos, órdenes SFTP y casos](ssh/formatos-y-casos.md).

Las unidades SSH-C001…SSH-C033 de este documento se conservan como familias padre. Los nuevos IDs permiten enlazar cada elemento desde guías y cheatsheets sin renumerar el guion.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="ssh-c001"></a>SSH-C001 | `ssh` conexión | Destino `[usuario@]host`, URI `ssh://`; comando y argumentos; `-l`, `-p`, `-4`, `-6`, `-V`, `-v`, `-q` | Usuario/puerto correcto, IPv6, versión, diagnóstico y código remoto. |
| <a id="ssh-c002"></a>SSH-C002 | `ssh` identidad y criptografía | `-i`, `-I`, `-A`, `-a`, `-K`, `-k`, `-c`, `-m`, `-Q`, `-o` según versión/plataforma | Clave frente a agente, GSSAPI, algoritmos ofrecidos y política efectiva. |
| <a id="ssh-c003"></a>SSH-C003 | `ssh` sesión y proceso | `-t`, `-T`, `-n`, `-f`, `-N`, `-s`, `-e`, `-E`, `-y`, `-X`, `-x`, `-Y`, `-C` | TTY, stdin, background, subsistema, escapes, logs, X11 y compresión. |
| <a id="ssh-c004"></a>SSH-C004 | `ssh` red y proxy | `-B`, `-b`, `-J`, `-W`, `-L`, `-R`, `-D`, `-w`, `-g` | Interfaz/dirección, salto y forwarding; origen y destino vistos desde cada host. |
| <a id="ssh-c005"></a>SSH-C005 | `ssh` configuración y control | `-F`, `-G`, `-M`, `-S`, `-O`, `-P`, `-Z` si están disponibles | Configuración efectiva, sockets de control, operaciones de multiplexación y flags recientes. |
| <a id="ssh-c006"></a>SSH-C006 | `ssh_config` selección | `Host`, `Match`, `Include`, `HostName`, `User`, `Port`, `Tag`, `CanonicalizeHostname`, `CanonicalDomains` | Orden, primera asignación aplicable, condiciones, patrones negados y tokens. |
| <a id="ssh-c007"></a>SSH-C007 | `ssh_config` identidad | `IdentityFile`, `IdentityAgent`, `IdentitiesOnly`, `AddKeysToAgent`, `CertificateFile`, `PreferredAuthentications`, `BatchMode`, `PubkeyAuthentication` | Varias identidades, agente, certificados e interacción prohibida. |
| <a id="ssh-c008"></a>SSH-C008 | `ssh_config` confianza | `StrictHostKeyChecking`, `UserKnownHostsFile`, `GlobalKnownHostsFile`, `UpdateHostKeys`, `VerifyHostKeyDNS`, `HostKeyAlias`, `CheckHostIP`, `HashKnownHosts` | Host nuevo, cambio legítimo, suplantación y validación independiente. |
| <a id="ssh-c009"></a>SSH-C009 | `ssh_config` transporte | `ConnectTimeout`, `ConnectionAttempts`, `ServerAliveInterval`, `ServerAliveCountMax`, `TCPKeepAlive`, `AddressFamily`, `BindAddress`, `BindInterface`, `IPQoS` | Corte de red, NAT, resolución y tiempos de espera. |
| <a id="ssh-c010"></a>SSH-C010 | `ssh_config` sesión y túnel | `ProxyJump`, `ProxyCommand`, `ControlMaster`, `ControlPath`, `ControlPersist`, `LocalForward`, `RemoteForward`, `DynamicForward`, `ExitOnForwardFailure`, `RequestTTY`, `RemoteCommand`, `SendEnv`, `SetEnv` | Concurrencia, fallo del bind, variables permitidas y persistencia. |
| <a id="ssh-c011"></a>SSH-C011 | `ssh_config` políticas restantes | Catálogo completo de directivas: algoritmos, rekey, X11, GSSAPI, PKCS#11, FIDO y opciones por versión | Crear una ficha para cada directiva no enumerada aquí; defaults upstream frente a distribución. |
| <a id="ssh-c012"></a>SSH-C012 | `ssh-keygen` generación y formato | `-t`, `-b`, `-a`, `-C`, `-f`, `-N`, `-p`, `-m`, `-e`, `-i`, `-y`, `-c` | Tipo, KDF, comentario, passphrase, conversión y extracción de pública; no registrar secretos. |
| <a id="ssh-c013"></a>SSH-C013 | `ssh-keygen` fingerprints y hosts | `-l`, `-E`, `-B`, `-F`, `-R`, `-H`, `-A`, `-r` | Huella, búsqueda/eliminación, hashing, generación de host keys y SSHFP. |
| <a id="ssh-c014"></a>SSH-C014 | `ssh-keygen` CA y certificados | `-s`, `-I`, `-n`, `-V`, `-z`, `-h`, `-O`, `-L` | Firma, principals, validez, seriales y restricciones; usuario frente a host. |
| <a id="ssh-c015"></a>SSH-C015 | `ssh-keygen` KRL, firma y dispositivos | `-k`, `-u`, `-Q`, `-Y`, `-w`, `-K`, `-D`, `-M` según versión | Revocación, firmas de datos, providers FIDO/PKCS#11 y moduli; fichas separadas por modo. |
| <a id="ssh-c016"></a>SSH-C016 | `ssh-add` | `-l`, `-L`, `-d`, `-D`, `-t`, `-c`, `-h`, `-H`, `-s`, `-e`, `-S`, `-K`, `-T`, `-q`, `-v`, `-E`, `-k`, `-C`, `-x`, `-X` según versión | Identidades, vida útil, confirmación, restricciones por destino, tokens y bloqueo del agente. |
| <a id="ssh-c017"></a>SSH-C017 | `ssh-agent` | `-a`, `-c`, `-s`, `-D`, `-d`, `-k`, `-t`, `-P`, `-O`, comando | Socket, entorno, shells, providers y ciclo de vida; Windows como servicio aparte. |
| <a id="ssh-c018"></a>SSH-C018 | `ssh-copy-id` | `-i`, `-p`, `-F`, `-o`, `-f`, `-n`, `-s` según paquete | Instalar pública, evitar duplicados y verificar acceso; herramienta no presente en todos los sistemas. |
| <a id="ssh-c019"></a>SSH-C019 | `ssh-keyscan` | `-4`, `-6`, `-c`, `-D`, `-f`, `-H`, `-p`, `-T`, `-t`, `-v` | Recoger claves no autentica su origen; comparar fingerprint por otro canal. |
| <a id="ssh-c020"></a>SSH-C020 | `sshd` | `-t`, `-T`, `-C`, `-f`, `-D`, `-d`, `-e`, `-E`, `-p`, `-o`, `-h`, `-c`, `-i`, `-u`, `-V`, `-4`, `-6`, `-q` según versión | Sintaxis frente a configuración efectiva por usuario/host/IP; daemon en primer plano. |
| <a id="ssh-c021"></a>SSH-C021 | `sshd_config` acceso | `Port`, `ListenAddress`, `AddressFamily`, `HostKey`, `HostCertificate`, `Include`, `Match`, `AllowUsers`, `AllowGroups`, `DenyUsers`, `DenyGroups` | Selección de interfaz y restricciones; políticas globales y condicionales. |
| <a id="ssh-c022"></a>SSH-C022 | `sshd_config` autenticación | `PermitRootLogin`, `PasswordAuthentication`, `PubkeyAuthentication`, `KbdInteractiveAuthentication`, `AuthenticationMethods`, `UsePAM`, `PermitEmptyPasswords`, `MaxAuthTries`, `LoginGraceTime` | MFA, contraseña frente a keyboard-interactive y orden de métodos. |
| <a id="ssh-c023"></a>SSH-C023 | `sshd_config` claves y CA | `AuthorizedKeysFile`, `AuthorizedKeysCommand`, `AuthorizedKeysCommandUser`, `TrustedUserCAKeys`, `AuthorizedPrincipalsFile`, `AuthorizedPrincipalsCommand`, `RevokedKeys`, `StrictModes` | Usuarios, ACL, principals y revocación; opciones de comando relacionadas. |
| <a id="ssh-c024"></a>SSH-C024 | `sshd_config` sesiones y red | `Subsystem`, `ForceCommand`, `ChrootDirectory`, `PermitTTY`, `X11Forwarding`, `AllowTcpForwarding`, `AllowStreamLocalForwarding`, `PermitOpen`, `PermitListen`, `GatewayPorts`, `DisableForwarding`, `AllowAgentForwarding`, `PermitTunnel` | SFTP-only, jaula, túneles y destinos autorizados. |
| <a id="ssh-c025"></a>SSH-C025 | `sshd_config` límites y auditoría | `LogLevel`, `SyslogFacility`, `MaxSessions`, `MaxStartups`, `ClientAliveInterval`, `ClientAliveCountMax`, `AcceptEnv`, `SetEnv`, `PerSourceMaxStartups` y resto del catálogo | Carga, abuso, inactividad y defaults por versión; inventariar todas las directivas restantes. |
| <a id="ssh-c026"></a>SSH-C026 | `authorized_keys`, `known_hosts`, `allowed_signers` | Formato, marcadores, patrones, `@cert-authority`, `@revoked`; `command`, `from`, `restrict`, `no-pty`, `no-agent-forwarding`, `permitopen`, `expiry-time` y catálogo completo | Restricciones por clave y rol de cada archivo; no intercambiar formatos. |
| <a id="ssh-c027"></a>SSH-C027 | `scp` | `-3`, `-4`, `-6`, `-A`, `-B`, `-C`, `-D`, `-F`, `-i`, `-J`, `-l`, `-O`, `-o`, `-P`, `-p`, `-q`, `-r`, `-R`, `-S`, `-T`, `-v`, `-X` según versión | Local/remoto/remoto-remoto, puerto mayúscula, metadatos y modo legacy. |
| <a id="ssh-c028"></a>SSH-C028 | `sftp` CLI | `-4`, `-6`, `-A`, `-a`, `-B`, `-b`, `-C`, `-c`, `-D`, `-F`, `-f`, `-i`, `-J`, `-l`, `-N`, `-o`, `-P`, `-p`, `-q`, `-R`, `-r`, `-S`, `-s`, `-v`, `-X` según versión | Lotes, reanudación, subsistema, buffers, concurrencia y opciones de transporte. |
| <a id="ssh-c029"></a>SSH-C029 | `sftp` interactivo | `help`, `bye`, `exit`, `quit`, `cd`, `lcd`, `pwd`, `lpwd`, `ls`, `lls`, `mkdir`, `lmkdir`, `rmdir`, `rm`, `rename`, `get`, `put`, `reget`, `reput`, `chmod`, `chown`, `chgrp`, `ln`, `symlink`, `copy`, `cp`, `df`, `version`, `progress`, `lumask`, `!` según versión | Inventariar argumentos y flags de cada orden; enlaces, globbing y operaciones locales/remotas. |
| <a id="ssh-c030"></a>SSH-C030 | `sftp-server`, `internal-sftp` | `-d`, `-e`, `-f`, `-l`, `-P`, `-p`, `-Q`, `-R`, `-u` según versión | Directorio, umask, logs, operaciones permitidas/denegadas y solo lectura. |
| <a id="ssh-c031"></a>SSH-C031 | Herramientas auxiliares OpenSSH | `ssh-keysign`, `ssh-pkcs11-helper`, `ssh-sk-helper`, `sshd-session`, `sshd-auth` si el paquete los incluye | Inventario de ejecutables internos; no tratarlos como interfaces de usuario estables. |
| <a id="ssh-c032"></a>SSH-C032 | Windows OpenSSH | Capacidades OpenSSH.Client/Server, servicios sshd/ssh-agent, reglas de firewall, `administrators_authorized_keys`, ACL y rutas | Diferencias con POSIX, cuenta Administrators, shell predeterminada y registros de eventos. |
| <a id="ssh-c033"></a>SSH-C033 | `rsync` sobre SSH | `-e`, `-a`, `-v`, `-z`, `-P`, `--partial`, `--delete`, `--dry-run`, barra final | Dependencia externa, sincronización y borrado; ampliar catálogo en GNU/Linux. |

## Casos integradores que deben desarrollarse

- [ ] **SSH-P01.** Conectar por contraseña y migrar a clave con passphrase; verificar huella, permisos y acceso antes de retirar el método anterior.
- [ ] **SSH-P02.** Definir aliases para varios hosts con distintas identidades y demostrar con ssh -G qué configuración se aplica.
- [ ] **SSH-P03.** Comparar una sesión interactiva y un comando remoto; capturar salida, error y código de retorno.
- [ ] **SSH-P04.** Copiar y reanudar una transferencia; contrastar scp, sftp y rsync con rutas que contienen espacios.
- [ ] **SSH-P05.** Crear túneles local, remoto y SOCKS en laboratorio; verificar exactamente dónde escucha cada puerto y quién puede alcanzarlo.
- [ ] **SSH-P06.** Acceder mediante bastión con ProxyJump y comprobar que no se requiere agent forwarding indiscriminado.
- [ ] **SSH-P07.** Crear una cuenta SFTP confinada y probar tanto la operación permitida como el escape/operación que debe denegarse.
- [ ] **SSH-P08.** Emitir certificados con CA de laboratorio, limitar principals/validez y demostrar revocación mediante KRL.
- [ ] **SSH-P09.** Aplicar un cambio de sshd con validación y sesión de recuperación; diagnosticar bloqueo por firewall, permisos, cuenta y algoritmo.
- [ ] **SSH-P10.** Reconciliar todas las opciones y directivas de los manuales de la versión portable/Windows elegida, también las omitidas del inventario inicial.

## Materiales derivados y relaciones

Los materiales nuevos siguen pendientes. Registrar sus enlaces reales y los IDs cubiertos en la ficha de cada unidad; una mención en este guion no acredita que un recurso existente cubra todas sus variantes.

| Formato | Contenido que debe extraerse | Estado |
| --- | --- | --- |
| Guía divulgativa | [Fundamentos de SSH](../../Sistemas%20Operativos/guias/ssh/01-fundamentos.md). | Documentación inicial disponible. |
| Guía técnica | [Conexión básica](../../Sistemas%20Operativos/guias/ssh/02-conexion-basica.md). | Primer bloque documentado; pruebas pendientes. |
| Cheatsheet Markdown | Consultas y operaciones con interpretación de salida. | Pendiente |
| Cheatsheet visual | Relaciones, flujos y decisiones; enlazar al detalle técnico. | Pendiente |
| Referencia | [16 opciones y seis directivas](../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md). | Desarrollo parcial; resto del catálogo pendiente. |

### Primera entrega desarrollada

[Fundamentos, conexión básica y referencia de opciones](../../Sistemas%20Operativos/guias/ssh/README.md): 16 opciones y seis directivas documentadas para la referencia Portable 10.6p1, con pruebas funcionales pendientes. Los demás elementos de cada familia mantienen su estado; no se marcan bloques completos por disponer de una introducción.

### Segunda entrega desarrollada

[Ciclo básico de claves y agente](../../Sistemas%20Operativos/guias/ssh/04-claves-y-agente.md) y [referencia de 21 opciones y tres directivas](../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md): generación, protección, despliegue, selección, retirada del agente y rotación/revocación de autorizaciones. Alcance parcial de las familias; pruebas funcionales pendientes. Certificados/CA, KRL, dispositivos, conversión y restricciones avanzadas siguen abiertos.

### Recursos existentes o guiones relacionados

- [Guion GNU/Linux](gnu-linux.md) y [guion Windows](windows.md).
- [Chuleta SSH existente](../../Sistemas%20Operativos/chuletas/ssh-admin.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [OpenSSH manual pages](https://www.openssh.com/manual.html)
- [ssh(1)](https://man.openbsd.org/ssh.1)
- [ssh_config(5)](https://man.openbsd.org/ssh_config.5)
- [sshd_config(5)](https://man.openbsd.org/sshd_config.5)
- [OpenSSH release notes](https://www.openssh.com/releasenotes.html)
- [Windows OpenSSH](https://learn.microsoft.com/en-us/windows-server/administration/openssh/overview)
