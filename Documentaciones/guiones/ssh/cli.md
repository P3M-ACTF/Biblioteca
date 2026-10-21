# SSH · Inventario de opciones CLI

[Índice de SSH](README.md) · [Guion general](../ssh.md)

Base: **OpenSSH Portable 10.6p1**, commit `a8c72b842423f0774f542d3c2197247c3dd28d74`. Cada fila registra una opción pública del manual versionado, sus argumentos y el trabajo que debemos desarrollar. Las opciones detectadas solo en el código se recogen aparte. No son recetas ejecutables ni una declaración de pruebas funcionales.

## Convenciones y casos obligatorios

`<nombre>` representa un argumento; `[...]`, una parte opcional; `...`, repetición. Las alternativas de una misma fila dependen del modo: no son combinables libremente. Los nombres técnicos conservan la grafía del manual. Debemos desarrollar para **cada opción**:

- [ ] Omisión y valor predeterminado, valor válido y error de valor/argumento ausente.
- [ ] Tipo, rango, unidades, repetición, exclusiones, precedencia e interacción con configuración.
- [ ] Privilegios, plataforma, archivo/dispositivo/red afectados y persistencia.
- [ ] stdout, stderr, código de retorno y comprobación del efecto.
- [ ] Casos específicos indicados en la fila, más las variantes de la [matriz de casos](formatos-y-casos.md#matriz-de-casos).

No introducir contraseñas/passphrases reales en argumentos, historial ni evidencias. Registrar las opciones de ese tipo para explicar sus riesgos y alternativas interactivas.

## ssh

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh [-46AaCfGgKkMNnqsTtVvXxYyZ] [-B <bind_interface>] [-b <bind_address>] [-c <cipher_spec>] [-D [<bind_address>:]<port>] [-E <log_file>] [-e <escape_char>] [-F <configfile>] [-I <pkcs11>] [-i <identity_file>] [-J <destination>] [-L <address>] [-l <login_name>] [-m <mac_spec>] [-O <ctl_cmd>] [-o <option>] [-P <tag>] [-p <port>] [-R <address>] [-S <ctl_path>] [-W <host>:<port>] [-w <local_tun>[:<remote_tun>]] <destination> [<command> [<argument> ...]]
ssh [-Q <query_option>]
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-opt-34"></a>SSH-I-SSH-OPT-34 | `-4` | Limitar la conexión a IPv4. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-34). | [ssh.1:109](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L109) |
| <a id="ssh-i-ssh-opt-36"></a>SSH-I-SSH-OPT-36 | `-6` | Limitar la conexión a IPv6. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-36). | [ssh.1:114](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L114) |
| <a id="ssh-i-ssh-opt-41"></a>SSH-I-SSH-OPT-41 | `-A` | Reenviar el agente de autenticación y delimitar su riesgo. | [ssh.1:119](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L119) |
| <a id="ssh-i-ssh-opt-61"></a>SSH-I-SSH-OPT-61 | `-a` | Desactivar el reenvío del agente. | [ssh.1:136](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L136) |
| <a id="ssh-i-ssh-opt-42"></a>SSH-I-SSH-OPT-42 | `-B <bind_interface>` | Seleccionar interfaz de origen. | [ssh.1:139](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L139) |
| <a id="ssh-i-ssh-opt-62"></a>SSH-I-SSH-OPT-62 | `-b <bind_address>` | Seleccionar dirección de origen. | [ssh.1:145](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L145) |
| <a id="ssh-i-ssh-opt-43"></a>SSH-I-SSH-OPT-43 | `-C` | Solicitar compresión y evaluar su efecto según versión. | [ssh.1:152](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L152) |
| <a id="ssh-i-ssh-opt-63"></a>SSH-I-SSH-OPT-63 | `-c <cipher_spec>` | Seleccionar lista y orden de cifrados. | [ssh.1:167](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L167) |
| <a id="ssh-i-ssh-opt-44"></a>SSH-I-SSH-OPT-44 | `-D [<bind_address>:] <port>` | Crear un proxy SOCKS y delimitar su escucha. | [ssh.1:178](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L178) |
| <a id="ssh-i-ssh-opt-45"></a>SSH-I-SSH-OPT-45 | `-E <log_file>` | Enviar el diagnóstico al archivo indicado. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-45). | [ssh.1:218](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L218) |
| <a id="ssh-i-ssh-opt-65"></a>SSH-I-SSH-OPT-65 | `-e <escape_char>` | Elegir carácter de escape o desactivarlo. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-65). | [ssh.1:223](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L223) |
| <a id="ssh-i-ssh-opt-46"></a>SSH-I-SSH-OPT-46 | `-F <configfile>` | Elegir archivo cliente y controlar la lectura de configuración. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-46). | [ssh.1:236](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L236) |
| <a id="ssh-i-ssh-opt-66"></a>SSH-I-SSH-OPT-66 | `-f` | Pasar a segundo plano después de autenticar. | [ssh.1:248](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L248) |
| <a id="ssh-i-ssh-opt-47"></a>SSH-I-SSH-OPT-47 | `-G` | Mostrar configuración cliente efectiva y salir. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-47). | [ssh.1:276](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L276) |
| <a id="ssh-i-ssh-opt-67"></a>SSH-I-SSH-OPT-67 | `-g` | Permitir acceso remoto a un puerto de forwarding local. | [ssh.1:285](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L285) |
| <a id="ssh-i-ssh-opt-49"></a>SSH-I-SSH-OPT-49 | `-I <pkcs11>` | Cargar proveedor PKCS#11. | [ssh.1:290](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L290) |
| <a id="ssh-i-ssh-opt-69"></a>SSH-I-SSH-OPT-69 | `-i <identity_file>` | Seleccionar un archivo de identidad; puede ser una pública cuya privada correspondiente está disponible en el agente. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-69). | [ssh.1:296](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L296) |
| <a id="ssh-i-ssh-opt-4a"></a>SSH-I-SSH-OPT-4A | `-J <destination>` | Acceder mediante uno o varios bastiones. | [ssh.1:326](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L326) |
| <a id="ssh-i-ssh-opt-4b"></a>SSH-I-SSH-OPT-4B | `-K` | Activar autenticación/delegación GSSAPI según soporte. | [ssh.1:344](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L344) |
| <a id="ssh-i-ssh-opt-6b"></a>SSH-I-SSH-OPT-6B | `-k` | Desactivar delegación GSSAPI. | [ssh.1:348](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L348) |
| <a id="ssh-i-ssh-opt-4c"></a>SSH-I-SSH-OPT-4C | `-L [<bind_address>:]<port>:<host>:<hostport>`; `-L [<bind_address>:]<port>:<remote_socket>`; `-L <local_socket>:<host>:<hostport>`; `-L <local_socket>:<remote_socket>` | Desarrollar las cuatro formas de forwarding local TCP/socket Unix. | [ssh.1:351](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L351) |
| <a id="ssh-i-ssh-opt-6c"></a>SSH-I-SSH-OPT-6C | `-l <login_name>` | Elegir usuario remoto. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-6c). | [ssh.1:410](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L410) |
| <a id="ssh-i-ssh-opt-4d"></a>SSH-I-SSH-OPT-4D | `-M` | Crear/seleccionar conexión maestra y confirmar sesiones según repetición. | [ssh.1:414](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L414) |
| <a id="ssh-i-ssh-opt-6d"></a>SSH-I-SSH-OPT-6D | `-m <mac_spec>` | Seleccionar lista y orden de MAC. | [ssh.1:436](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L436) |
| <a id="ssh-i-ssh-opt-4e"></a>SSH-I-SSH-OPT-4E | `-N` | Establecer conexión sin ejecutar un comando remoto. | [ssh.1:445](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L445) |
| <a id="ssh-i-ssh-opt-6e"></a>SSH-I-SSH-OPT-6E | `-n` | Desconectar la entrada estándar del proceso cliente. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-6e). | [ssh.1:454](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L454) |
| <a id="ssh-i-ssh-opt-4f"></a>SSH-I-SSH-OPT-4F | `-O <ctl_cmd>` | Ejecutar cada operación de control sobre la conexión maestra. | [ssh.1:480](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L480) |
| <a id="ssh-i-ssh-opt-6f"></a>SSH-I-SSH-OPT-6F | `-o <option>` | Pasar una directiva cliente; enlazar todo ssh_config. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-6f). | [ssh.1:508](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L508) |
| <a id="ssh-i-ssh-opt-50"></a>SSH-I-SSH-OPT-50 | `-P <tag>` | Asignar etiqueta para selección mediante Match. | [ssh.1:515](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L515) |
| <a id="ssh-i-ssh-opt-70"></a>SSH-I-SSH-OPT-70 | `-p <port>` | Seleccionar puerto remoto. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-70). | [ssh.1:526](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L526) |
| <a id="ssh-i-ssh-opt-51"></a>SSH-I-SSH-OPT-51 | `-Q <query_option>` | Consultar cada familia de algoritmos o capacidad. | [ssh.1:531](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L531) |
| <a id="ssh-i-ssh-opt-71"></a>SSH-I-SSH-OPT-71 | `-q` | Reducir mensajes del cliente. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-71). | [ssh.1:570](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L570) |
| <a id="ssh-i-ssh-opt-52"></a>SSH-I-SSH-OPT-52 | `-R [<bind_address>:]<port>:<host>:<hostport>`; `-R [<bind_address>:]<port>:<local_socket>`; `-R <remote_socket>:<host>:<hostport>`; `-R <remote_socket>:<local_socket>`; `-R [<bind_address>:]<port>` | Desarrollar las cinco formas de forwarding remoto, incluido SOCKS. | [ssh.1:574](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L574) |
| <a id="ssh-i-ssh-opt-53"></a>SSH-I-SSH-OPT-53 | `-S <ctl_path>` | Elegir socket de control para multiplexación. | [ssh.1:652](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L652) |
| <a id="ssh-i-ssh-opt-73"></a>SSH-I-SSH-OPT-73 | `-s` | Solicitar un subsistema remoto. | [ssh.1:665](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L665) |
| <a id="ssh-i-ssh-opt-54"></a>SSH-I-SSH-OPT-54 | `-T` | Desactivar asignación de pseudoterminal. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-54). | [ssh.1:677](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L677) |
| <a id="ssh-i-ssh-opt-74"></a>SSH-I-SSH-OPT-74 | `-t` | Solicitar/forzar pseudoterminal y distinguir repetición. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-74). | [ssh.1:680](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L680) |
| <a id="ssh-i-ssh-opt-56"></a>SSH-I-SSH-OPT-56 | `-V` | Mostrar versión. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-56). | [ssh.1:691](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L691) |
| <a id="ssh-i-ssh-opt-76"></a>SSH-I-SSH-OPT-76 | `-v` | Aumentar diagnóstico, incluida repetición. [Ficha desarrollada](../../../Sistemas%20Operativos/guias/ssh/03-referencia-conexion.md#ssh-r-opt-76). | [ssh.1:694](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L694) |
| <a id="ssh-i-ssh-opt-57"></a>SSH-I-SSH-OPT-57 | `-W <host>:<port>` | Reenviar entrada/salida a host:puerto. | [ssh.1:706](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L706) |
| <a id="ssh-i-ssh-opt-77"></a>SSH-I-SSH-OPT-77 | `-w <local_tun>[:<remote_tun>]` | Solicitar dispositivos TUN/TAP y validar permisos. | [ssh.1:722](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L722) |
| <a id="ssh-i-ssh-opt-58"></a>SSH-I-SSH-OPT-58 | `-X` | Solicitar X11 con restricciones. | [ssh.1:757](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L757) |
| <a id="ssh-i-ssh-opt-78"></a>SSH-I-SSH-OPT-78 | `-x` | Desactivar X11. | [ssh.1:778](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L778) |
| <a id="ssh-i-ssh-opt-59"></a>SSH-I-SSH-OPT-59 | `-Y` | Solicitar X11 confiable y delimitar su riesgo. | [ssh.1:781](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L781) |
| <a id="ssh-i-ssh-opt-79"></a>SSH-I-SSH-OPT-79 | `-y` | Enviar logs por syslog. | [ssh.1:786](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L786) |
| <a id="ssh-i-ssh-opt-5a"></a>SSH-I-SSH-OPT-5A | `-Z` | Listar en orden las claves públicas que se intentarían para el destino y salir. | [ssh.1:792](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1#L792) |

## sshd

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
sshd [-46DdeGiqTtV] [-C <connection_spec>] [-c <host_certificate_file>] [-E <log_file>] [-f <config_file>] [-g <login_grace_time>] [-h <host_key_file>] [-o <option>] [-p <port>] [-u <len>]
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-sshd-opt-34"></a>SSH-I-SSHD-OPT-34 | `-4` | Limitar la escucha a IPv4. | [sshd.8:88](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L88) |
| <a id="ssh-i-sshd-opt-36"></a>SSH-I-SSHD-OPT-36 | `-6` | Limitar la escucha a IPv6. | [sshd.8:92](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L92) |
| <a id="ssh-i-sshd-opt-43"></a>SSH-I-SSHD-OPT-43 | `-C <connection_spec>` |Evaluar Match con user/host/addr/laddr/lport/rdomain. [Ficha de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md#ssh-s-opt-43) | [sshd.8:96](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L96) |
| <a id="ssh-i-sshd-opt-63"></a>SSH-I-SSHD-OPT-63 | `-c <host_certificate_file>` | Cargar certificado de host. | [sshd.8:122](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L122) |
| <a id="ssh-i-sshd-opt-44"></a>SSH-I-SSHD-OPT-44 | `-D` | Ejecutar en primer plano sin daemonizar. | [sshd.8:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L131) |
| <a id="ssh-i-sshd-opt-64"></a>SSH-I-SSHD-OPT-64 | `-d` | Modo diagnóstico y repetición. | [sshd.8:137](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L137) |
| <a id="ssh-i-sshd-opt-45"></a>SSH-I-SSHD-OPT-45 | `-E <log_file>` | Registrar logs en un archivo. | [sshd.8:149](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L149) |
| <a id="ssh-i-sshd-opt-65"></a>SSH-I-SSHD-OPT-65 | `-e` | Registrar logs en stderr. | [sshd.8:153](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L153) |
| <a id="ssh-i-sshd-opt-66"></a>SSH-I-SSHD-OPT-66 | `-f <config_file>` |Elegir archivo de configuración. [Ficha de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md#ssh-s-opt-66) | [sshd.8:155](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L155) |
| <a id="ssh-i-sshd-opt-47"></a>SSH-I-SSHD-OPT-47 | `-G` | Mostrar configuración antes de comprobar claves y salir. | [sshd.8:161](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L161) |
| <a id="ssh-i-sshd-opt-67"></a>SSH-I-SSHD-OPT-67 | `-g <login_grace_time>` | Modificar el tiempo de gracia de autenticación. | [sshd.8:170](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L170) |
| <a id="ssh-i-sshd-opt-68"></a>SSH-I-SSHD-OPT-68 | `-h <host_key_file>` | Cargar clave privada de host. | [sshd.8:176](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L176) |
| <a id="ssh-i-sshd-opt-69"></a>SSH-I-SSHD-OPT-69 | `-i` | Ejecutar desde inetd. | [sshd.8:190](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L190) |
| <a id="ssh-i-sshd-opt-6f"></a>SSH-I-SSHD-OPT-6F | `-o <option>` | Aplicar una directiva servidor; enlazar todo sshd_config. | [sshd.8:195](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L195) |
| <a id="ssh-i-sshd-opt-70"></a>SSH-I-SSHD-OPT-70 | `-p <port>` | Seleccionar puerto de escucha y evaluar repetición/precedencia. | [sshd.8:201](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L201) |
| <a id="ssh-i-sshd-opt-71"></a>SSH-I-SSHD-OPT-71 | `-q` | Reducir logs. | [sshd.8:211](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L211) |
| <a id="ssh-i-sshd-opt-54"></a>SSH-I-SSHD-OPT-54 | `-T` |Validar y mostrar configuración efectiva, con Match si se indica. [Ficha de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md#ssh-s-opt-54) | [sshd.8:216](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L216) |
| <a id="ssh-i-sshd-opt-74"></a>SSH-I-SSHD-OPT-74 | `-t` |Validar configuración y claves sin iniciar el servicio. [Ficha de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md#ssh-s-opt-74) | [sshd.8:230](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L230) |
| <a id="ssh-i-sshd-opt-75"></a>SSH-I-SSHD-OPT-75 | `-u <len>` | Controlar longitud de nombres en utmp y consultas de nombres. | [sshd.8:236](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L236) |
| <a id="ssh-i-sshd-opt-56"></a>SSH-I-SSHD-OPT-56 | `-V` |Mostrar versión. [Ficha de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md#ssh-s-opt-56) | [sshd.8:267](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8#L267) |

## scp

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
scp [-346ABCOpqRrTv] [-c <cipher>] [-D <sftp_server_path>] [-F <ssh_config>] [-i <identity_file>] [-J <destination>] [-l <limit>] [-o <ssh_option>] [-P <port>] [-S <program>] [-X <sftp_option>] <source>... <target>
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-scp-opt-33"></a>SSH-I-SCP-OPT-33 | `-3` | Copiar entre remotos pasando por el equipo cliente. | [scp.1:77](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L77) |
| <a id="ssh-i-scp-opt-34"></a>SSH-I-SCP-OPT-34 | `-4` | Usar IPv4. | [scp.1:89](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L89) |
| <a id="ssh-i-scp-opt-36"></a>SSH-I-SCP-OPT-36 | `-6` | Usar IPv6. | [scp.1:93](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L93) |
| <a id="ssh-i-scp-opt-41"></a>SSH-I-SCP-OPT-41 | `-A` | Permitir forwarding de agente hacia el remoto. | [scp.1:97](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L97) |
| <a id="ssh-i-scp-opt-42"></a>SSH-I-SCP-OPT-42 | `-B` | Trabajar en modo batch sin interacción. | [scp.1:102](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L102) |
| <a id="ssh-i-scp-opt-43"></a>SSH-I-SCP-OPT-43 | `-C` | Solicitar compresión SSH. | [scp.1:104](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L104) |
| <a id="ssh-i-scp-opt-63"></a>SSH-I-SCP-OPT-63 | `-c <cipher>` | Seleccionar cifrado de transporte. | [scp.1:111](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L111) |
| <a id="ssh-i-scp-opt-44"></a>SSH-I-SCP-OPT-44 | `-D <sftp_server_path>` | Usar servidor SFTP local para pruebas directas. | [scp.1:115](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L115) |
| <a id="ssh-i-scp-opt-46"></a>SSH-I-SCP-OPT-46 | `-F <ssh_config>` |Elegir configuración cliente SSH. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-46) | [scp.1:120](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L120) |
| <a id="ssh-i-scp-opt-69"></a>SSH-I-SCP-OPT-69 | `-i <identity_file>` | Elegir archivo de identidad. | [scp.1:126](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L126) |
| <a id="ssh-i-scp-opt-4a"></a>SSH-I-SCP-OPT-4A | `-J <destination>` | Configurar bastión. | [scp.1:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L131) |
| <a id="ssh-i-scp-opt-6c"></a>SSH-I-SCP-OPT-6C | `-l <limit>` |Limitar velocidad y explicar sus unidades. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-6c) | [scp.1:144](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L144) |
| <a id="ssh-i-scp-opt-4f"></a>SSH-I-SCP-OPT-4F | `-O` |Forzar el protocolo SCP antiguo y estudiar quoting/globbing. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-4f) | [scp.1:146](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L146) |
| <a id="ssh-i-scp-opt-6f"></a>SSH-I-SCP-OPT-6F | `-o <ssh_option>` | Aplicar directiva ssh_config. | [scp.1:153](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L153) |
| <a id="ssh-i-scp-opt-50"></a>SSH-I-SCP-OPT-50 | `-P <port>` |Elegir puerto; distinguir -P de -p. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-50) | [scp.1:267](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L267) |
| <a id="ssh-i-scp-opt-70"></a>SSH-I-SCP-OPT-70 | `-p` |Preservar tiempos y modos. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-70) | [scp.1:274](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L274) |
| <a id="ssh-i-scp-opt-71"></a>SSH-I-SCP-OPT-71 | `-q` | Reducir mensajes/progreso. | [scp.1:277](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L277) |
| <a id="ssh-i-scp-opt-52"></a>SSH-I-SCP-OPT-52 | `-R` | Copia remoto-remoto originada en el remoto; registrar deprecación de 10.6. | [scp.1:281](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L281) |
| <a id="ssh-i-scp-opt-72"></a>SSH-I-SCP-OPT-72 | `-r` |Copiar árboles de directorios. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-scp-72) | [scp.1:292](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L292) |
| <a id="ssh-i-scp-opt-53"></a>SSH-I-SCP-OPT-53 | `-S <program>` | Elegir programa SSH. | [scp.1:297](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L297) |
| <a id="ssh-i-scp-opt-54"></a>SSH-I-SCP-OPT-54 | `-T` | Desactivar la comprobación estricta de nombres recibidos; estudiar riesgo. | [scp.1:304](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L304) |
| <a id="ssh-i-scp-opt-76"></a>SSH-I-SCP-OPT-76 | `-v` | Diagnosticar transporte y transferencia. | [scp.1:314](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L314) |
| <a id="ssh-i-scp-opt-58"></a>SSH-I-SCP-OPT-58 | `-X <sftp_option>` | Configurar cada parámetro de transferencia SFTP. | [scp.1:323](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1#L323) |

## sftp

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
sftp [-46AaCfNpqrv] [-B <buffer_size>] [-b <batchfile>] [-c <cipher>] [-D <sftp_server_command>] [-F <ssh_config>] [-i <identity_file>] [-J <destination>] [-l <limit>] [-o <ssh_option>] [-P <port>] [-R <num_requests>] [-S <program>] [-s <subsystem> | sftp_server] [-X <sftp_option>] <destination>
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-sftp-opt-34"></a>SSH-I-SFTP-OPT-34 | `-4` | Usar IPv4. | [sftp.1:100](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L100) |
| <a id="ssh-i-sftp-opt-36"></a>SSH-I-SFTP-OPT-36 | `-6` | Usar IPv6. | [sftp.1:104](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L104) |
| <a id="ssh-i-sftp-opt-41"></a>SSH-I-SFTP-OPT-41 | `-A` | Reenviar el agente. | [sftp.1:108](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L108) |
| <a id="ssh-i-sftp-opt-61"></a>SSH-I-SFTP-OPT-61 | `-a` |Reanudar transferencias y tratar archivos parciales. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-sftp-61) | [sftp.1:113](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L113) |
| <a id="ssh-i-sftp-opt-42"></a>SSH-I-SFTP-OPT-42 | `-B <buffer_size>` | Elegir tamaño de buffer. | [sftp.1:118](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L118) |
| <a id="ssh-i-sftp-opt-62"></a>SSH-I-SFTP-OPT-62 | `-b <batchfile>` |Leer lote desde archivo o stdin. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-sftp-62) | [sftp.1:125](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L125) |
| <a id="ssh-i-sftp-opt-43"></a>SSH-I-SFTP-OPT-43 | `-C` | Solicitar compresión. | [sftp.1:163](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L163) |
| <a id="ssh-i-sftp-opt-63"></a>SSH-I-SFTP-OPT-63 | `-c <cipher>` | Seleccionar cifrado. | [sftp.1:167](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L167) |
| <a id="ssh-i-sftp-opt-44"></a>SSH-I-SFTP-OPT-44 | `-D <sftp_server_command>` | Conectar directamente con un servidor SFTP local. | [sftp.1:171](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L171) |
| <a id="ssh-i-sftp-opt-46"></a>SSH-I-SFTP-OPT-46 | `-F <ssh_config>` |Elegir archivo ssh_config. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-sftp-46) | [sftp.1:178](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L178) |
| <a id="ssh-i-sftp-opt-66"></a>SSH-I-SFTP-OPT-66 | `-f` | Solicitar sincronización a disco cuando la extensión lo permita. | [sftp.1:184](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L184) |
| <a id="ssh-i-sftp-opt-69"></a>SSH-I-SFTP-OPT-69 | `-i <identity_file>` | Elegir identidad. | [sftp.1:188](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L188) |
| <a id="ssh-i-sftp-opt-4a"></a>SSH-I-SFTP-OPT-4A | `-J <destination>` | Elegir bastión. | [sftp.1:193](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L193) |
| <a id="ssh-i-sftp-opt-6c"></a>SSH-I-SFTP-OPT-6C | `-l <limit>` |Limitar velocidad. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-sftp-6c) | [sftp.1:206](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L206) |
| <a id="ssh-i-sftp-opt-4e"></a>SSH-I-SFTP-OPT-4E | `-N` | Mantener salida de órdenes en modo batch. | [sftp.1:208](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L208) |
| <a id="ssh-i-sftp-opt-6f"></a>SSH-I-SFTP-OPT-6F | `-o <ssh_option>` | Aplicar directiva ssh_config. | [sftp.1:212](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L212) |
| <a id="ssh-i-sftp-opt-50"></a>SSH-I-SFTP-OPT-50 | `-P <port>` |Elegir puerto. [Ficha de transferencias](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md#ssh-x-sftp-50) | [sftp.1:328](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L328) |
| <a id="ssh-i-sftp-opt-70"></a>SSH-I-SFTP-OPT-70 | `-p` | Preservar modos/tiempos. | [sftp.1:330](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L330) |
| <a id="ssh-i-sftp-opt-71"></a>SSH-I-SFTP-OPT-71 | `-q` | Reducir salida/progreso. | [sftp.1:333](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L333) |
| <a id="ssh-i-sftp-opt-52"></a>SSH-I-SFTP-OPT-52 | `-R <num_requests>` | Elegir número de solicitudes concurrentes. | [sftp.1:337](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L337) |
| <a id="ssh-i-sftp-opt-72"></a>SSH-I-SFTP-OPT-72 | `-r` | Transferir recursivamente. | [sftp.1:342](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L342) |
| <a id="ssh-i-sftp-opt-53"></a>SSH-I-SFTP-OPT-53 | `-S <program>` | Elegir programa SSH. | [sftp.1:347](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L347) |
| <a id="ssh-i-sftp-opt-73"></a>SSH-I-SFTP-OPT-73 | `-s <subsystem> \| sftp_server` | Elegir subsistema o ruta de servidor remoto. | [sftp.1:354](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L354) |
| <a id="ssh-i-sftp-opt-76"></a>SSH-I-SFTP-OPT-76 | `-v` | Aumentar diagnóstico. | [sftp.1:360](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L360) |
| <a id="ssh-i-sftp-opt-58"></a>SSH-I-SFTP-OPT-58 | `-X <sftp_option>` | Configurar solicitudes/buffer mediante clave=valor. | [sftp.1:363](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1#L363) |

## ssh-add

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh-add [-CcDdKkLlNPqvXx] [-E <fingerprint_hash>] [-H <hostkey_file>] [-h <destination_constraint>] [-S <provider>] [-t <life>] [<file>...]
ssh-add -s <pkcs11> [-Cv] [<certificate> ...]
ssh-add -e <pkcs11>
ssh-add -T <pubkey> ...
ssh-add -Q
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-add-opt-43"></a>SSH-I-SSH-ADD-OPT-43 | `-C` | Operar solo sobre certificados. | [ssh-add.1:99](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L99) |
| <a id="ssh-i-ssh-add-opt-63"></a>SSH-I-SSH-ADD-OPT-63 | `-c` | Exigir confirmación antes de usar la identidad. | [ssh-add.1:102](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L102) |
| <a id="ssh-i-ssh-add-opt-44"></a>SSH-I-SSH-ADD-OPT-44 | `-D` | Retirar todas las identidades del agente. | [ssh-add.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L110) |
| <a id="ssh-i-ssh-add-opt-64"></a>SSH-I-SSH-ADD-OPT-64 | `-d` |Retirar identidades seleccionadas. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-add-64) | [ssh-add.1:112](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L112) |
| <a id="ssh-i-ssh-add-opt-45"></a>SSH-I-SSH-ADD-OPT-45 | `-E <fingerprint_hash>` | Elegir hash de huellas: md5/sha256. | [ssh-add.1:130](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L130) |
| <a id="ssh-i-ssh-add-opt-65"></a>SSH-I-SSH-ADD-OPT-65 | `-e <pkcs11>` | Retirar claves de un proveedor PKCS#11. | [ssh-add.1:138](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L138) |
| <a id="ssh-i-ssh-add-opt-48"></a>SSH-I-SSH-ADD-OPT-48 | `-H <hostkey_file>` | Elegir archivos known_hosts para restricciones por destino; repetición. | [ssh-add.1:141](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L141) |
| <a id="ssh-i-ssh-add-opt-68"></a>SSH-I-SSH-ADD-OPT-68 | `-h <destination_constraint>` | Restringir ruta de uso de la clave a destinos/saltos concretos. | [ssh-add.1:158](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L158) |
| <a id="ssh-i-ssh-add-opt-4b"></a>SSH-I-SSH-ADD-OPT-4B | `-K` | Cargar claves residentes FIDO. | [ssh-add.1:219](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L219) |
| <a id="ssh-i-ssh-add-opt-6b"></a>SSH-I-SSH-ADD-OPT-6B | `-k` | Operar solo sobre claves privadas sin certificados. | [ssh-add.1:221](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L221) |
| <a id="ssh-i-ssh-add-opt-4c"></a>SSH-I-SSH-ADD-OPT-4C | `-L` |Listar claves públicas completas. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-add-4c) | [ssh-add.1:224](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L224) |
| <a id="ssh-i-ssh-add-opt-50"></a>SSH-I-SSH-ADD-OPT-50 | `-P` | No pedir PIN al cargar claves desde token. | [ssh-add.1:227](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L227) |
| <a id="ssh-i-ssh-add-opt-6c"></a>SSH-I-SSH-ADD-OPT-6C | `-l` |Listar fingerprints. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-add-6c) | [ssh-add.1:232](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L232) |
| <a id="ssh-i-ssh-add-opt-4e"></a>SSH-I-SSH-ADD-OPT-4E | `-N` | No asignar automáticamente caducidad a certificados añadidos. | [ssh-add.1:234](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L234) |
| <a id="ssh-i-ssh-add-opt-51"></a>SSH-I-SSH-ADD-OPT-51 | `-Q` | Consultar extensiones del protocolo del agente. | [ssh-add.1:241](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L241) |
| <a id="ssh-i-ssh-add-opt-71"></a>SSH-I-SSH-ADD-OPT-71 | `-q` | Reducir mensajes tras éxito. | [ssh-add.1:244](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L244) |
| <a id="ssh-i-ssh-add-opt-53"></a>SSH-I-SSH-ADD-OPT-53 | `-S <provider>` | Elegir proveedor de autenticador FIDO. | [ssh-add.1:246](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L246) |
| <a id="ssh-i-ssh-add-opt-73"></a>SSH-I-SSH-ADD-OPT-73 | `-s <pkcs11>` | Cargar claves del proveedor PKCS#11 y certificados asociados. | [ssh-add.1:250](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L250) |
| <a id="ssh-i-ssh-add-opt-54"></a>SSH-I-SSH-ADD-OPT-54 | `-T <pubkey> ...` |Probar uso de las claves privadas mediante firma/verificación. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-add-54) | [ssh-add.1:256](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L256) |
| <a id="ssh-i-ssh-add-opt-74"></a>SSH-I-SSH-ADD-OPT-74 | `-t <life>` |Limitar vida de una identidad. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-add-74) | [ssh-add.1:260](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L260) |
| <a id="ssh-i-ssh-add-opt-76"></a>SSH-I-SSH-ADD-OPT-76 | `-v` | Aumentar diagnóstico hasta el límite documentado. | [ssh-add.1:265](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L265) |
| <a id="ssh-i-ssh-add-opt-58"></a>SSH-I-SSH-ADD-OPT-58 | `-X` | Desbloquear el agente. | [ssh-add.1:275](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L275) |
| <a id="ssh-i-ssh-add-opt-78"></a>SSH-I-SSH-ADD-OPT-78 | `-x` | Bloquear el agente con contraseña. | [ssh-add.1:277](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L277) |

## ssh-agent

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh-agent [-c | s] [-DdU] [-T | A <directory> | -a <bind_address>] [-E <fingerprint_hash>] [-O <option>] [-P <allowed_providers>] [-t <life>]
ssh-agent [-U] [-T | A <directory> | -a <bind_address>] [-E <fingerprint_hash>] [-O <option>] [-P <allowed_providers>] [-t <life>] <command> [<arg> ...]
ssh-agent [-c | s] -k
ssh-agent -u
ssh-agent -V
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-agent-opt-61"></a>SSH-I-SSH-AGENT-OPT-61 | `-a <bind_address>` | Elegir socket Unix concreto. | [ssh-agent.1:77](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L77) |
| <a id="ssh-i-ssh-agent-opt-41"></a>SSH-I-SSH-AGENT-OPT-41 | `-A <socket_path>` | Elegir directorio de sockets con prefijo user:/shared: y tokens. | [ssh-agent.1:86](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L86) |
| <a id="ssh-i-ssh-agent-opt-63"></a>SSH-I-SSH-AGENT-OPT-63 | `-c` | Emitir asignaciones para C shell. | [ssh-agent.1:107](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L107) |
| <a id="ssh-i-ssh-agent-opt-44"></a>SSH-I-SSH-AGENT-OPT-44 | `-D` | Ejecutar en primer plano. | [ssh-agent.1:112](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L112) |
| <a id="ssh-i-ssh-agent-opt-64"></a>SSH-I-SSH-AGENT-OPT-64 | `-d` | Ejecutar en diagnóstico con logs en stderr. | [ssh-agent.1:117](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L117) |
| <a id="ssh-i-ssh-agent-opt-45"></a>SSH-I-SSH-AGENT-OPT-45 | `-E <fingerprint_hash>` | Elegir hash de fingerprints. | [ssh-agent.1:122](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L122) |
| <a id="ssh-i-ssh-agent-opt-6b"></a>SSH-I-SSH-AGENT-OPT-6B | `-k` |Terminar el agente identificado por SSH_AGENT_PID. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-agent-6b) | [ssh-agent.1:130](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L130) |
| <a id="ssh-i-ssh-agent-opt-4f"></a>SSH-I-SSH-AGENT-OPT-4F | `-O <option>` | Desarrollar las tres políticas de proveedor/FIDO admitidas. | [ssh-agent.1:134](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L134) |
| <a id="ssh-i-ssh-agent-opt-50"></a>SSH-I-SSH-AGENT-OPT-50 | `-P <allowed_providers>` | Permitir proveedores que coincidan con una lista de patrones. | [ssh-agent.1:184](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L184) |
| <a id="ssh-i-ssh-agent-opt-73"></a>SSH-I-SSH-AGENT-OPT-73 | `-s` |Emitir asignaciones para shell Bourne. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-agent-73) | [ssh-agent.1:199](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L199) |
| <a id="ssh-i-ssh-agent-opt-54"></a>SSH-I-SSH-AGENT-OPT-54 | `-T` | Elegir directorio temporal aleatorio para el socket. | [ssh-agent.1:204](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L204) |
| <a id="ssh-i-ssh-agent-opt-74"></a>SSH-I-SSH-AGENT-OPT-74 | `-t <life>` |Asignar vida predeterminada a identidades. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-agent-74) | [ssh-agent.1:209](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L209) |
| <a id="ssh-i-ssh-agent-opt-55"></a>SSH-I-SSH-AGENT-OPT-55 | `-U` | Conservar sockets antiguos sin limpieza automática. | [ssh-agent.1:217](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L217) |
| <a id="ssh-i-ssh-agent-opt-75"></a>SSH-I-SSH-AGENT-OPT-75 | `-u` | Limpiar sockets antiguos y salir; distinguir -u/-uu. | [ssh-agent.1:222](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L222) |
| <a id="ssh-i-ssh-agent-opt-56"></a>SSH-I-SSH-AGENT-OPT-56 | `-V` | Mostrar versión. | [ssh-agent.1:236](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L236) |

## ssh-keygen

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh-keygen [-q] [-a <rounds>] [-b <bits>] [-C <comment>] [-f <output_keyfile>] [-m <format>] [-N <new_passphrase>] [-O <option>] [-t ecdsa | ecdsa-sk | ed25519 | ed25519-sk | mldsa44-ed25519 | rsa] [-w <provider>] [-Z <cipher>]
ssh-keygen -p [-a <rounds>] [-f <keyfile>] [-m <format>] [-N <new_passphrase>] [-P <old_passphrase>] [-Z <cipher>]
ssh-keygen -i [-f <input_keyfile>] [-m <key_format>]
ssh-keygen -e [-f <input_keyfile>] [-m <key_format>]
ssh-keygen -y [-f <input_keyfile>]
ssh-keygen -c [-a <rounds>] [-C <comment>] [-f <keyfile>] [-P <passphrase>]
ssh-keygen -l [-v] [-E <fingerprint_hash>] [-f <input_keyfile>]
ssh-keygen -B [-f <input_keyfile>]
ssh-keygen -D <pkcs11>
ssh-keygen -F <hostname> [-lv] [-f <known_hosts_file>]
ssh-keygen -H [-f <known_hosts_file>]
ssh-keygen -K [-a <rounds>] [-w <provider>]
ssh-keygen -R <hostname> [-f <known_hosts_file>]
ssh-keygen -r <hostname> [-g] [-f <input_keyfile>]
ssh-keygen -M generate [-O <option>] <output_file>
ssh-keygen -M screen [-f <input_file>] [-O <option>] <output_file>
ssh-keygen -I <certificate_identity> -s <ca_key> [-hU] [-D <pkcs11_provider>] [-n <principals>] [-O <option>] [-V <validity_interval>] [-z <serial_number>] <file>...
ssh-keygen -L [-f <input_keyfile>]
ssh-keygen -A [-a <rounds>] [-f <prefix_path>]
ssh-keygen -k -f <krl_file> [-u] [-s <ca_public>] [-z <version_number>] <file>...
ssh-keygen -Q [-l] -f <krl_file> <file>...
ssh-keygen -Y find-principals [-O <option>] -s <signature_file> -f <allowed_signers_file>
ssh-keygen -Y match-principals -I <signer_identity> -f <allowed_signers_file>
ssh-keygen -Y check-novalidate [-O <option>] -n <namespace> -s <signature_file>
ssh-keygen -Y sign [-O <option>] -f <key_file> -n <namespace> <file>...
ssh-keygen -Y verify [-O <option>] -f <allowed_signers_file> -I <signer_identity> -n <namespace> -s <signature_file> [-r <revocation_file>]
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-keygen-opt-41"></a>SSH-I-SSH-KEYGEN-OPT-41 | `-A` | Generar claves de host ausentes. | [ssh-keygen.1:273](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L273) |
| <a id="ssh-i-ssh-keygen-opt-61"></a>SSH-I-SSH-KEYGEN-OPT-61 | `-a <rounds>` |Elegir rondas de KDF. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-61) | [ssh-keygen.1:285](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L285) |
| <a id="ssh-i-ssh-keygen-opt-42"></a>SSH-I-SSH-KEYGEN-OPT-42 | `-B` | Mostrar fingerprint bubblebabble. | [ssh-keygen.1:293](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L293) |
| <a id="ssh-i-ssh-keygen-opt-62"></a>SSH-I-SSH-KEYGEN-OPT-62 | `-b <bits>` | Elegir tamaño de clave según algoritmo. | [ssh-keygen.1:295](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L295) |
| <a id="ssh-i-ssh-keygen-opt-43"></a>SSH-I-SSH-KEYGEN-OPT-43 | `-C <comment>` |Definir comentario. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-43) | [ssh-keygen.1:308](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L308) |
| <a id="ssh-i-ssh-keygen-opt-63"></a>SSH-I-SSH-KEYGEN-OPT-63 | `-c` | Cambiar comentario de clave existente. | [ssh-keygen.1:310](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L310) |
| <a id="ssh-i-ssh-keygen-opt-44"></a>SSH-I-SSH-KEYGEN-OPT-44 | `-D <pkcs11>` | Enumerar claves de un proveedor PKCS#11. | [ssh-keygen.1:314](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L314) |
| <a id="ssh-i-ssh-keygen-opt-45"></a>SSH-I-SSH-KEYGEN-OPT-45 | `-E <fingerprint_hash>` |Elegir hash de fingerprint. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-45) | [ssh-keygen.1:322](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L322) |
| <a id="ssh-i-ssh-keygen-opt-65"></a>SSH-I-SSH-KEYGEN-OPT-65 | `-e` | Exportar a formato externo. | [ssh-keygen.1:330](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L330) |
| <a id="ssh-i-ssh-keygen-opt-46"></a>SSH-I-SSH-KEYGEN-OPT-46 | `-F <hostname> \| [hostname]:port` | Buscar host o host:puerto en known_hosts. | [ssh-keygen.1:339](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L339) |
| <a id="ssh-i-ssh-keygen-opt-66"></a>SSH-I-SSH-KEYGEN-OPT-66 | `-f <filename>` |Elegir archivo de entrada/salida según modo. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-66) | [ssh-keygen.1:350](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L350) |
| <a id="ssh-i-ssh-keygen-opt-67"></a>SSH-I-SSH-KEYGEN-OPT-67 | `-g` | Generar registros DNS genéricos según modo. | [ssh-keygen.1:352](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L352) |
| <a id="ssh-i-ssh-keygen-opt-48"></a>SSH-I-SSH-KEYGEN-OPT-48 | `-H` | Aplicar hashing a nombres de known_hosts. | [ssh-keygen.1:356](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L356) |
| <a id="ssh-i-ssh-keygen-opt-68"></a>SSH-I-SSH-KEYGEN-OPT-68 | `-h` | Firmar un certificado de host. | [ssh-keygen.1:371](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L371) |
| <a id="ssh-i-ssh-keygen-opt-49"></a>SSH-I-SSH-KEYGEN-OPT-49 | `-I <certificate_identity>` | Elegir identificador del certificado. | [ssh-keygen.1:377](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L377) |
| <a id="ssh-i-ssh-keygen-opt-69"></a>SSH-I-SSH-KEYGEN-OPT-69 | `-i` | Importar una clave en formato externo. | [ssh-keygen.1:382](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L382) |
| <a id="ssh-i-ssh-keygen-opt-4b"></a>SSH-I-SSH-KEYGEN-OPT-4B | `-K` | Descargar claves residentes FIDO. | [ssh-keygen.1:392](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L392) |
| <a id="ssh-i-ssh-keygen-opt-6b"></a>SSH-I-SSH-KEYGEN-OPT-6B | `-k` | Crear KRL. | [ssh-keygen.1:401](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L401) |
| <a id="ssh-i-ssh-keygen-opt-4c"></a>SSH-I-SSH-KEYGEN-OPT-4C | `-L` | Mostrar datos de certificado. | [ssh-keygen.1:412](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L412) |
| <a id="ssh-i-ssh-keygen-opt-6c"></a>SSH-I-SSH-KEYGEN-OPT-6C | `-l` |Mostrar fingerprint de clave. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-6c) | [ssh-keygen.1:414](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L414) |
| <a id="ssh-i-ssh-keygen-opt-4d"></a>SSH-I-SSH-KEYGEN-OPT-4D | `-M generate`; `-M screen` | Generar o filtrar candidatos DH; separar los dos modos. | [ssh-keygen.1:422](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L422) |
| <a id="ssh-i-ssh-keygen-opt-6d"></a>SSH-I-SSH-KEYGEN-OPT-6D | `-m <key_format>` | Elegir formato de clave/importación/exportación. | [ssh-keygen.1:442](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L442) |
| <a id="ssh-i-ssh-keygen-opt-4e"></a>SSH-I-SSH-KEYGEN-OPT-4E | `-N <new_passphrase>` | Asignar passphrase nueva sin convertirla en ejemplo público. | [ssh-keygen.1:467](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L467) |
| <a id="ssh-i-ssh-keygen-opt-6e"></a>SSH-I-SSH-KEYGEN-OPT-6E | `-n <principals>` | Elegir principals al firmar certificados. | [ssh-keygen.1:469](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L469) |
| <a id="ssh-i-ssh-keygen-opt-4f"></a>SSH-I-SSH-KEYGEN-OPT-4F | `-O <option>` | Desglosar opciones por modo: firma, certificados, DH, FIDO y cambio de requisitos. | [ssh-keygen.1:476](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L476) |
| <a id="ssh-i-ssh-keygen-opt-50"></a>SSH-I-SSH-KEYGEN-OPT-50 | `-P <passphrase>` | Proporcionar passphrase previa; documentar exposición en argv y alternativa interactiva. | [ssh-keygen.1:542](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L542) |
| <a id="ssh-i-ssh-keygen-opt-70"></a>SSH-I-SSH-KEYGEN-OPT-70 | `-p` |Cambiar passphrase y requisitos compatibles. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-70) | [ssh-keygen.1:544](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L544) |
| <a id="ssh-i-ssh-keygen-opt-51"></a>SSH-I-SSH-KEYGEN-OPT-51 | `-Q` | Consultar revocación mediante KRL y listar su contenido con -l. | [ssh-keygen.1:576](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L576) |
| <a id="ssh-i-ssh-keygen-opt-71"></a>SSH-I-SSH-KEYGEN-OPT-71 | `-q` | Reducir mensajes. | [ssh-keygen.1:581](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L581) |
| <a id="ssh-i-ssh-keygen-opt-52"></a>SSH-I-SSH-KEYGEN-OPT-52 | `-R <hostname> \| [hostname]:port` | Retirar entradas de host de known_hosts. | [ssh-keygen.1:584](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L584) |
| <a id="ssh-i-ssh-keygen-opt-72"></a>SSH-I-SSH-KEYGEN-OPT-72 | `-r <hostname>` | Generar registros SSHFP. | [ssh-keygen.1:594](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L594) |
| <a id="ssh-i-ssh-keygen-opt-73"></a>SSH-I-SSH-KEYGEN-OPT-73 | `-s <ca_key>` | Elegir CA para firmar una clave pública. | [ssh-keygen.1:598](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L598) |
| <a id="ssh-i-ssh-keygen-opt-74"></a>SSH-I-SSH-KEYGEN-OPT-74 | `-t ecdsa \| ecdsa-sk \| ed25519 \| ed25519-sk \| mldsa44-ed25519 \| rsa` |Elegir tipo de clave, incluidos tipos híbridos presentes en esta versión. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-74) | [ssh-keygen.1:611](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L611) |
| <a id="ssh-i-ssh-keygen-opt-55"></a>SSH-I-SSH-KEYGEN-OPT-55 | `-U` | Usar una clave del agente al firmar certificados o datos con -Y sign. | [ssh-keygen.1:631](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L631) |
| <a id="ssh-i-ssh-keygen-opt-75"></a>SSH-I-SSH-KEYGEN-OPT-75 | `-u` | Actualizar KRL existente. | [ssh-keygen.1:641](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L641) |
| <a id="ssh-i-ssh-keygen-opt-56"></a>SSH-I-SSH-KEYGEN-OPT-56 | `-V <validity_interval>` | Establecer intervalo de validez de certificado. | [ssh-keygen.1:647](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L647) |
| <a id="ssh-i-ssh-keygen-opt-76"></a>SSH-I-SSH-KEYGEN-OPT-76 | `-v` | Aumentar diagnóstico. | [ssh-keygen.1:714](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L714) |
| <a id="ssh-i-ssh-keygen-opt-77"></a>SSH-I-SSH-KEYGEN-OPT-77 | `-w <provider>` | Elegir proveedor FIDO. | [ssh-keygen.1:724](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L724) |
| <a id="ssh-i-ssh-keygen-opt-59"></a>SSH-I-SSH-KEYGEN-OPT-59 | `-Y find-principals`; `-Y match-principals`; `-Y check-novalidate`; `-Y sign`; `-Y verify` | Desglosar los cinco modos de firma/verificación de datos. | [ssh-keygen.1:728](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L728) |
| <a id="ssh-i-ssh-keygen-opt-79"></a>SSH-I-SSH-KEYGEN-OPT-79 | `-y` |Derivar clave pública desde privada. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-keygen-79) | [ssh-keygen.1:820](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L820) |
| <a id="ssh-i-ssh-keygen-opt-5a"></a>SSH-I-SSH-KEYGEN-OPT-5A | `-Z <cipher>` | Elegir cifrado para guardar la clave privada. | [ssh-keygen.1:823](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L823) |
| <a id="ssh-i-ssh-keygen-opt-7a"></a>SSH-I-SSH-KEYGEN-OPT-7A | `-z <serial_number>` | Asignar serial de certificado/incremento o versión de KRL según modo. | [ssh-keygen.1:830](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L830) |

## ssh-keyscan

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh-keyscan [-46cDHqv] [-f <file>] [-O <option>] [-p <port>] [-T <timeout>] [-t <type>] [<host> | addrlist namelist]
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-keyscan-opt-34"></a>SSH-I-SSH-KEYSCAN-OPT-34 | `-4` | Consultar IPv4. | [ssh-keyscan.1:64](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L64) |
| <a id="ssh-i-ssh-keyscan-opt-36"></a>SSH-I-SSH-KEYSCAN-OPT-36 | `-6` | Consultar IPv6. | [ssh-keyscan.1:68](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L68) |
| <a id="ssh-i-ssh-keyscan-opt-63"></a>SSH-I-SSH-KEYSCAN-OPT-63 | `-c` | Solicitar certificados de host en vez de claves simples. | [ssh-keyscan.1:72](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L72) |
| <a id="ssh-i-ssh-keyscan-opt-44"></a>SSH-I-SSH-KEYSCAN-OPT-44 | `-D` | Emitir registros SSHFP. | [ssh-keyscan.1:74](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L74) |
| <a id="ssh-i-ssh-keyscan-opt-66"></a>SSH-I-SSH-KEYSCAN-OPT-66 | `-f <file>` | Leer hosts/CIDR/aliases desde archivo o stdin. | [ssh-keyscan.1:80](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L80) |
| <a id="ssh-i-ssh-keyscan-opt-48"></a>SSH-I-SSH-KEYSCAN-OPT-48 | `-H` | Aplicar hashing a nombres de la salida. | [ssh-keyscan.1:102](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L102) |
| <a id="ssh-i-ssh-keyscan-opt-4f"></a>SSH-I-SSH-KEYSCAN-OPT-4F | `-O <option>` | Elegir parámetros, incluido hashalg para SSHFP. | [ssh-keyscan.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L110) |
| <a id="ssh-i-ssh-keyscan-opt-70"></a>SSH-I-SSH-KEYSCAN-OPT-70 | `-p <port>` | Elegir puerto. | [ssh-keyscan.1:124](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L124) |
| <a id="ssh-i-ssh-keyscan-opt-71"></a>SSH-I-SSH-KEYSCAN-OPT-71 | `-q` | Omitir comentarios/banner. | [ssh-keyscan.1:128](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L128) |
| <a id="ssh-i-ssh-keyscan-opt-54"></a>SSH-I-SSH-KEYSCAN-OPT-54 | `-T <timeout>` | Elegir timeout de conexión/lectura. | [ssh-keyscan.1:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L131) |
| <a id="ssh-i-ssh-keyscan-opt-74"></a>SSH-I-SSH-KEYSCAN-OPT-74 | `-t <type>` | Elegir lista de tipos de clave. | [ssh-keyscan.1:139](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L139) |
| <a id="ssh-i-ssh-keyscan-opt-76"></a>SSH-I-SSH-KEYSCAN-OPT-76 | `-v` | Aumentar diagnóstico. | [ssh-keyscan.1:150](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1#L150) |

## sftp-server

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
sftp-server [-ehR] [-d <start_directory>] [-f <log_facility>] [-l <log_level>] [-P <denied_requests>] [-p <allowed_requests>] [-u <umask>]
sftp-server -Q <protocol_feature>
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-sftp-server-opt-64"></a>SSH-I-SFTP-SERVER-OPT-64 | `-d <start_directory>` | Elegir directorio inicial con %%/%d/%u y chroot. | [sftp-server.8:66](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L66) |
| <a id="ssh-i-sftp-server-opt-65"></a>SSH-I-SFTP-SERVER-OPT-65 | `-e` | Enviar logs a stderr. | [sftp-server.8:77](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L77) |
| <a id="ssh-i-sftp-server-opt-66"></a>SSH-I-SFTP-SERVER-OPT-66 | `-f <log_facility>` | Elegir facility syslog. | [sftp-server.8:81](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L81) |
| <a id="ssh-i-sftp-server-opt-68"></a>SSH-I-SFTP-SERVER-OPT-68 | `-h` | Mostrar uso. | [sftp-server.8:87](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L87) |
| <a id="ssh-i-sftp-server-opt-6c"></a>SSH-I-SFTP-SERVER-OPT-6C | `-l <log_level>` | Elegir nivel de log. | [sftp-server.8:91](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L91) |
| <a id="ssh-i-sftp-server-opt-50"></a>SSH-I-SFTP-SERVER-OPT-50 | `-P <denied_requests>` | Denegar solicitudes concretas antes de aplicar la lista permitida. | [sftp-server.8:102](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L102) |
| <a id="ssh-i-sftp-server-opt-70"></a>SSH-I-SFTP-SERVER-OPT-70 | `-p <allowed_requests>` | Permitir solo solicitudes enumeradas y contemplar operaciones implícitas del cliente. | [sftp-server.8:123](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L123) |
| <a id="ssh-i-sftp-server-opt-51"></a>SSH-I-SFTP-SERVER-OPT-51 | `-Q <protocol_feature>` | Consultar tipos de solicitudes mediante requests. | [sftp-server.8:131](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L131) |
| <a id="ssh-i-sftp-server-opt-52"></a>SSH-I-SFTP-SERVER-OPT-52 | `-R` | Operar en modo de solo lectura. | [sftp-server.8:141](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L141) |
| <a id="ssh-i-sftp-server-opt-75"></a>SSH-I-SFTP-SERVER-OPT-75 | `-u <umask>` | Establecer umask. | [sftp-server.8:147](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8#L147) |

## ssh-copy-id

Sinopsis del manual; los grupos compactos de flags enumeran opciones y **no** indican que deban combinarse todas. Los argumentos de cada modo se desarrollan por separado.

```text
ssh-copy-id [-f] [-n] [-s] [-x] [-i [<identity_file>]] [-t <target_path>] [-F <ssh_config>] [-o <ssh_option>]... [-p <port>] [<user>@]<hostname>
ssh-copy-id -h | -?
```

| ID | Opción y argumentos | Contenido y casos que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-copy-id-opt-69"></a>SSH-I-SSH-COPY-ID-OPT-69 | `-i [<identity_file>]` |Seleccionar pública; tratar ausencia del argumento y selección predeterminada. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-copy-id-69) | [contrib/ssh-copy-id.1:71](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L71) |
| <a id="ssh-i-ssh-copy-id-opt-66"></a>SSH-I-SSH-COPY-ID-OPT-66 | `-f` | Forzar instalación sin comprobar duplicación. | [contrib/ssh-copy-id.1:88](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L88) |
| <a id="ssh-i-ssh-copy-id-opt-6e"></a>SSH-I-SSH-COPY-ID-OPT-6E | `-n` |Mostrar qué se instalaría sin modificar authorized_keys. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-copy-id-6e) | [contrib/ssh-copy-id.1:93](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L93) |
| <a id="ssh-i-ssh-copy-id-opt-73"></a>SSH-I-SSH-COPY-ID-OPT-73 | `-s` | Instalar mediante SFTP. | [contrib/ssh-copy-id.1:97](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L97) |
| <a id="ssh-i-ssh-copy-id-opt-74"></a>SSH-I-SSH-COPY-ID-OPT-74 | `-t <target_path>` | Elegir ruta de destino. | [contrib/ssh-copy-id.1:105](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L105) |
| <a id="ssh-i-ssh-copy-id-opt-70"></a>SSH-I-SSH-COPY-ID-OPT-70 | `-p <port>` |Elegir puerto SSH. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-copy-id-70) | [contrib/ssh-copy-id.1:108](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L108) |
| <a id="ssh-i-ssh-copy-id-opt-46"></a>SSH-I-SSH-COPY-ID-OPT-46 | `-F <ssh_config>` |Elegir configuración SSH. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-copy-id-46) | [contrib/ssh-copy-id.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L110) |
| <a id="ssh-i-ssh-copy-id-opt-6f"></a>SSH-I-SSH-COPY-ID-OPT-6F | `-o <ssh_option>` |Pasar una opción a SSH. [Ficha del ciclo básico](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md#ssh-k-ssh-copy-id-6f) | [contrib/ssh-copy-id.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L110) |
| <a id="ssh-i-ssh-copy-id-opt-78"></a>SSH-I-SSH-COPY-ID-OPT-78 | `-x` | Activar tracing y evaluar datos que podrían aparecer. | [contrib/ssh-copy-id.1:121](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L121) |
| <a id="ssh-i-ssh-copy-id-opt-68"></a>SSH-I-SSH-COPY-ID-OPT-68 | `-h` | Mostrar ayuda. | [contrib/ssh-copy-id.1:126](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L126) |
| <a id="ssh-i-ssh-copy-id-opt-3f"></a>SSH-I-SSH-COPY-ID-OPT-3F | `-?` | Mostrar ayuda como alternativa a -h. | [contrib/ssh-copy-id.1:126](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L126) |

## Argumentos posicionales y formas de invocación

Estas unidades son distintas de los argumentos que consume una opción. Debemos cubrir su posición, obligatoriedad, repetición, delimitadores y quoting local/remoto.

| ID | Programa y forma | Casos que debemos desarrollar |
| --- | --- | --- |
| <a id="ssh-i-pos-01"></a>SSH-I-POS-01 | `ssh <destination> [<command> [<argument>...]]` | Usuario, alias/hostname/IP, URI, IPv6, -- cuando proceda, comando frente a shell y doble interpretación del quoting. |
| <a id="ssh-i-pos-02"></a>SSH-I-POS-02 | `sshd Sin destino posicional` | Configurar por archivo/opciones; no pasar usuario/host como si fuera un cliente. |
| <a id="ssh-i-pos-03"></a>SSH-I-POS-03 | `scp <source>... <target>` | Local/remoto/remoto-remoto, varios orígenes, URI, host:puerto, espacios, dos puntos, symlinks, wildcard y barra final. |
| <a id="ssh-i-pos-04"></a>SSH-I-POS-04 | `sftp <destination>` | Usuario/host/URI/IPv6 y ruta remota opcional; no confundir puerto en URI con -P. |
| <a id="ssh-i-pos-05"></a>SSH-I-POS-05 | `ssh-add [<file>...]` | Sin archivos: identidades predeterminadas; lista explícita, certificados, stdin con - y pública frente a privada según operación. |
| <a id="ssh-i-pos-06"></a>SSH-I-POS-06 | `ssh-add -s <pkcs11> [<certificate>...]` | Token, certificados asociados y manejo del PIN. |
| <a id="ssh-i-pos-07"></a>SSH-I-POS-07 | `ssh-add -T <pubkey>...` | Una o varias claves públicas; resultado individual y código agregado. |
| <a id="ssh-i-pos-08"></a>SSH-I-POS-08 | `ssh-agent [<command> [<arg>...]]` | Proceso hijo, entorno, duración del agente y salida del comando; frente a emitir variables al shell. |
| <a id="ssh-i-pos-09"></a>SSH-I-POS-09 | `ssh-keygen Argumentos según modo` | Ficheros de datos con -Y sign; stdin; pública/privada/certificado/KRL; restricciones e incompatibilidad de modos. |
| <a id="ssh-i-pos-10"></a>SSH-I-POS-10 | `ssh-keyscan [<host> \| <addrlist> <namelist>]...` | Host/IP, CIDR, aliases, listas, stdin -f -, timeout y host sin respuesta. |
| <a id="ssh-i-pos-11"></a>SSH-I-POS-11 | `sftp-server Sin destino posicional público` | Subsistema por stdio, configuración de logging/directorio/solicitudes; comparar internal-sftp. |
| <a id="ssh-i-pos-12"></a>SSH-I-POS-12 | `ssh-copy-id [<user>@]<hostname>` | Destino, identidad elegida y ruta de authorized_keys; instalación normal frente a SFTP. |

## Opciones fuera de la interfaz pública documentada

El contraste entre manual y las cadenas `getopt()` detecta las siguientes entradas. Debemos explicar su estado y respuesta; **no recomendarlas como comandos administrativos normales**. «Reconocida por el parser» no significa soportada.

| ID | Programa / opción | Clasificación y caso que debemos desarrollar | Fuente |
| --- | --- | --- | --- |
| <a id="ssh-i-ssh-compat-31"></a>SSH-I-SSH-COMPAT-31 | `ssh -1` | Rechazada: protocolo SSH 1 retirado. | [ssh.c:707](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.c#L707) |
| <a id="ssh-i-ssh-compat-32"></a>SSH-I-SSH-COMPAT-32 | `ssh -2` | Compatibilidad: aceptada e ignorada. | [ssh.c:710](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.c#L710) |
| <a id="ssh-i-sshd-compat-62"></a>SSH-I-SSHD-COMPAT-62 | `sshd -b <argumento>` | Compatibilidad: argumento histórico del protocolo 1, ignorado. | [sshd.c:1415](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c#L1415) |
| <a id="ssh-i-sshd-compat-6b"></a>SSH-I-SSHD-COMPAT-6B | `sshd -k <argumento>` | Compatibilidad: argumento histórico del protocolo 1, ignorado. | [sshd.c:1436](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c#L1436) |
| <a id="ssh-i-sshd-compat-51"></a>SSH-I-SSHD-COMPAT-51 | `sshd -Q` | Aceptada e ignorada. | [sshd.c:1409](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c#L1409) |
| <a id="ssh-i-sshd-compat-52"></a>SSH-I-SSHD-COMPAT-52 | `sshd -R` | Rechazada por este ejecutable. | [sshd.c:1406](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c#L1406) |
| <a id="ssh-i-sshd-compat-72"></a>SSH-I-SSHD-COMPAT-72 | `sshd -r` | Obsoleta: emite aviso. | [sshd.c:1403](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c#L1403) |
| <a id="ssh-i-scp-compat-31"></a>SSH-I-SCP-COMPAT-31 | `scp -1` | Rechazada: protocolo SSH 1 retirado. | [scp.c:494](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L494) |
| <a id="ssh-i-scp-compat-32"></a>SSH-I-SCP-COMPAT-32 | `scp -2` | Compatibilidad: aceptada e ignorada. | [scp.c:497](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L497) |
| <a id="ssh-i-scp-compat-64"></a>SSH-I-SCP-COMPAT-64 | `scp -d` | Interna: exigir destino de tipo directorio en protocolo SCP. | [scp.c:601](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L601) |
| <a id="ssh-i-scp-compat-66"></a>SSH-I-SCP-COMPAT-66 | `scp -f` | Interna: extremo emisor del protocolo SCP. | [scp.c:604](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L604) |
| <a id="ssh-i-scp-compat-73"></a>SSH-I-SCP-COMPAT-73 | `scp -s` | Compatibilidad: aceptada e ignorada. | [scp.c:531](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L531) |
| <a id="ssh-i-scp-compat-74"></a>SSH-I-SCP-COMPAT-74 | `scp -t` | Interna: extremo receptor del protocolo SCP. | [scp.c:608](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L608) |
| <a id="ssh-i-scp-compat-4d"></a>SSH-I-SCP-COMPAT-4D | `scp -M <argumento>` | Token con argumento en getopt sin rama de tratamiento propia; cae en uso/error. | [scp.c:490](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c#L490) |
| <a id="ssh-i-sftp-compat-31"></a>SSH-I-SFTP-COMPAT-31 | `sftp -1` | Rechazada: protocolo SSH 1 retirado. | [sftp.c:2579](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c#L2579) |
| <a id="ssh-i-sftp-compat-32"></a>SSH-I-SFTP-COMPAT-32 | `sftp -2` | Compatibilidad: aceptada silenciosamente. | [sftp.c:2582](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c#L2582) |
| <a id="ssh-i-sftp-compat-68"></a>SSH-I-SFTP-COMPAT-68 | `sftp -h` | Mostrar uso y terminar; comprobar código de salida, no equipararlo sin prueba a éxito. | [sftp.c:2665](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c#L2665) |
| <a id="ssh-i-ssh-add-compat-4d"></a>SSH-I-SSH-ADD-COMPAT-4D | `ssh-add -M <argumento>` | Argumento histórico de claves alojadas: obsoleto e ignorado. | [ssh-add.c:891](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.c#L891) |
| <a id="ssh-i-ssh-add-compat-6d"></a>SSH-I-SSH-ADD-COMPAT-6D | `ssh-add -m <argumento>` | Argumento histórico: obsoleto e ignorado. | [ssh-add.c:890](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.c#L890) |
| <a id="ssh-i-ssh-keygen-compat-58"></a>SSH-I-SSH-KEYGEN-COMPAT-58 | `ssh-keygen -X` | Alias interno de importación de clave; preferir la opción pública -i. | [ssh-keygen.c:3529](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.c#L3529) |
| <a id="ssh-i-ssh-keygen-compat-6f"></a>SSH-I-SSH-KEYGEN-COMPAT-6F | `ssh-keygen -o` | Aceptada sin efecto: el formato nuevo ya es predeterminado. | [ssh-keygen.c:3470](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.c#L3470) |
| <a id="ssh-i-sftp-server-compat-63"></a>SSH-I-SFTP-SERVER-COMPAT-63 | `sftp-server -c` | Invocación interna como shell: ignorar el resto de argumentos. | [sftp-server.c:1954](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c#L1954) |

## Herramientas internas y extensiones

`ssh-keysign`, `ssh-pkcs11-helper`, `ssh-sk-helper`, `sshd-session` y `sshd-auth` se inventarían como auxiliares del producto. Su ejecución directa, protocolo interno y flags no forman parte de este catálogo público. Debemos explicar función, permisos, rutas y relación con el proceso que los invoca. `internal-sftp` comparte los argumentos públicos de `sftp-server`; no es un ejecutable separado. `ssh-copy-id` pertenece a `contrib` y su empaquetado puede variar. `rsync`, PuTTY y componentes específicos de Windows tienen inventarios separados.
