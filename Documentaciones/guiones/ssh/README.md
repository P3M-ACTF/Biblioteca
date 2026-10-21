# SSH · Inventario versionado de contenidos

[Guion general de SSH](../ssh.md) · [Catálogo de guiones](../README.md)

Este inventario desglosa el guion de SSH para que podamos desarrollar y enlazar **cada opción, argumento, directiva, modo y caso**. Mantiene los IDs del guion general como unidades padre y añade IDs específicos sin renumerarlos.

## Referencia y límites

- **Producto:** OpenSSH Portable **10.6p1**.
- **Tag:** `V_10_6_P1`, publicado el 6 de octubre de 2026.
- **Commit:** [`a8c72b842423f0774f542d3c2197247c3dd28d74`](https://github.com/openssh/openssh-portable/tree/a8c72b842423f0774f542d3c2197247c3dd28d74).
- **Consulta:** 21 de octubre de 2026.
- **Fuente:** repositorio upstream que enlaza la [página de OpenSSH Portable](https://www.openssh.com/portable.html), sus manuales y los parsers de esta versión.
- **Plataforma:** interfaz upstream portable; soporte real condicionado por compilación y sistema. Es una referencia documental, no una indicación para actualizar los equipos.

No se declara una referencia funcional terminada: la sintaxis, valores predeterminados, explicaciones y laboratorios se desarrollan después. El contraste realizado cierra la **enumeración de opciones públicas y nombres principales de directiva** de los manuales indicados; también recoge compatibilidad detectada en sus parsers. Las gramáticas de las tablas son puntos de desarrollo y no sustituyen el manual completo.

## Documentos

| Documento | Contenido | Unidades inventariadas |
| --- | --- | ---: |
| [Opciones CLI](cli.md) | Diez herramientas, sinopsis por modo, opciones/argumentos y entradas no públicas del parser. | 261 |
| [Configuración](configuracion.md) | Cliente/servidor, contexto global/Match y nombres heredados. | 256 |
| [Formatos y casos](formatos-y-casos.md) | SFTP interactivo, modos, subopciones, claves, KRL, tokens, entorno, archivos, solicitudes y laboratorios. | 348 |
| **Total** | IDs específicos añadidos al guion. | **865** |

## Cobertura de opciones públicas

| Herramienta | Manual de referencia | Opciones públicas individuales |
| --- | --- | ---: |
| `ssh` | [ssh.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1) | 46 |
| `sshd` | [sshd.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8) | 20 |
| `scp` | [scp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1) | 23 |
| `sftp` | [sftp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1) | 25 |
| `ssh-add` | [ssh-add.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1) | 23 |
| `ssh-agent` | [ssh-agent.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1) | 15 |
| `ssh-keygen` | [ssh-keygen.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1) | 42 |
| `ssh-keyscan` | [ssh-keyscan.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1) | 12 |
| `sftp-server` | [sftp-server.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8) | 10 |
| `ssh-copy-id` | [contrib/ssh-copy-id.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1) | 11 |
| **Total** | Opciones, no combinaciones ni modos. | **227** |

En la CLI se registran además **22 entradas** que no tienen sección pública propia y **12 unidades de argumentos posicionales/formas de invocación**. Las opciones reconocidas por getopt pueden ser ignoradas, rechazadas, heredadas o internas: no se presentan como soportadas solo por aparecer en el parser.

En configuración se registran **104 directivas cliente**, **107 servidor** y **45 nombres heredados**. En SFTP se recogen **32 órdenes/símbolos documentados**, **5 alias adicionales del parser** y **29 solicitudes de protocolo**. Las solicitudes SFTP no son órdenes del intérprete. La matriz final contiene **37 casos integradores**, cada uno con variantes por unidad.

## Relación con el guion general

| Unidades padre | Desarrollo del inventario |
| --- | --- |
| SSH-C001…SSH-C005 | CLI de ssh, multiplexación, consultas, escapes y forwarding. |
| SSH-C006…SSH-C011 | Cada directiva cliente y sus gramáticas comunes. |
| SSH-C012…SSH-C019 | Herramientas de claves/agente/instalación y sus modos/subopciones. |
| SSH-C020…SSH-C025 | CLI de sshd y cada directiva servidor. |
| SSH-C026 | authorized_keys, known_hosts y allowed_signers. |
| SSH-C027…SSH-C030 | scp, sftp interactivo, transferencia y servidor SFTP. |
| SSH-C031 | Función de auxiliares internos; su protocolo/CLI interna queda fuera del catálogo público. |
| SSH-C032 | Diferencias Windows, pendientes de inventario y pruebas con build concreto. |
| SSH-C033 | rsync es externo a OpenSSH; su catálogo se desarrolla en GNU/Linux. |

## Primer bloque desarrollado

La [guía de fundamentos y conexión básica](../../../Sistemas%20Operativos/guias/ssh/README.md) desarrolla los conceptos iniciales, 16 opciones de ssh y seis directivas de cliente. Incluye práctica, interpretación de salida y casos pendientes de ensayo. La matriz de esa guía distingue cobertura documental de verificación funcional; las casillas del guion general no se cierran por esta entrega parcial.

## Segundo bloque desarrollado

La [práctica de claves y agente](../../../Sistemas%20Operativos/guias/ssh/04-claves-y-agente.md) continúa con generación protegida, despliegue de pública, firma mediante agente, cambio de frase, rotación y retirada. Su [referencia](../../../Sistemas%20Operativos/guias/ssh/05-referencia-claves.md) desarrolla 21 opciones y tres directivas en los modos delimitados, con enlaces recíprocos y pruebas funcionales pendientes. Los modos restantes de cada herramienta conservan su estado abierto.

## Tercer bloque desarrollado

La [práctica de servidor Linux](../../../Sistemas%20Operativos/guias/ssh/06-servidor-linux.md) desarrolla instalación, servicio/socket, validación, política de acceso y restauración. La [referencia de servidor](../../../Sistemas%20Operativos/guias/ssh/07-referencia-servidor.md) añade cinco opciones y 16 directivas con enlaces recíprocos, contexto y pruebas pendientes. La cobertura de plataformas y el resto de directivas siguen abiertos.

## Cuarto bloque desarrollado

La [práctica SFTP/SCP](../../../Sistemas%20Operativos/guias/ssh/08-transferencias.md) y su [referencia](../../../Sistemas%20Operativos/guias/ssh/09-referencia-transferencias.md) desarrollan 20 fichas y las nueve flags de ls: 29 unidades inventariadas con enlaces recíprocos, copias, integridad, reanudación y lotes. La [introducción rsync](../../../Sistemas%20Operativos/guias/ssh/10-rsync-sobre-ssh.md) corresponde a la herramienta externa de SSH-C033/GNU/Linux. Todos los ensayos siguen pendientes; las demás opciones, órdenes y plataformas permanecen abiertas.

## Estado de verificación

- **Inventariado y contrastado:** nombres/sinopsis de las opciones públicas, directivas principales, compatibilidad del parser, órdenes/alias SFTP y solicitudes de protocolo incluidas.
- **Desarrollo parcial disponible:** las 16 opciones y seis directivas de la guía anterior tienen fichas documentadas. Queda desarrollar el resto de unidades y ampliar diferencias de entorno según la [plantilla común](../PLANTILLA.md).
- **Pendiente de prueba funcional:** todos los casos administrativos, conexiones reales, claves/dispositivos y laboratorios. No se ha instalado ni ejecutado OpenSSH 10.6p1 para producir este inventario.
- **Pendiente por plataforma:** paquetes Linux, cambios del distribuidor, Windows OpenSSH, nombres de servicio, rutas y permisos/ACL. No extrapolar defaults de upstream a esos paquetes.
- **Fuera del catálogo público:** protocolo y flags internos de helpers, API de código, opciones de configure/build y herramientas externas. Su función y disponibilidad sí deben explicarse en el guion.

### Comprobaciones del inventario

El contraste de las opciones de nueve parsers getopt y del script ssh-copy-id no deja opciones sin clasificar en el alcance indicado. Los nombres únicos de configuración se corresponden con las entradas del parser: **128 cliente y 128 servidor**, incluyendo alias y compatibilidad. Las **37 órdenes/alias SFTP** coinciden con la tabla de despacho. Estas comprobaciones verifican enumeración y correspondencia; no prueban el comportamiento de los comandos.

### Cómo ampliar o actualizar

1. Elegir otra versión/tag, identificar su commit y comparar las fuentes de la tabla siguiente.
2. Comparar tablas de opciones de los manuales con getopt, directivas con los parsers y órdenes/solicitudes SFTP con sus tablas de despacho.
3. Añadir IDs para elementos nuevos; conservar los retirados y documentar alias, cambios de argumentos y defaults.
4. Desarrollar cada unidad con sus casos y enlazar guías/cheatsheets mediante su ancla.
5. Repetir el contraste con los binarios y ayudas del entorno real antes de marcar procedimientos como verificados.

Los IDs semánticos no deben renumerarse. Los IDs numéricos de archivos, argumentos posicionales y casos se conservan al ampliar el inventario; añadir entradas al final o asignar sufijos.

## Fuentes fijadas

Los SHA son identificadores de blobs del árbol upstream versionado, útiles para detectar cambios de fuente. Esta tabla registra procedencia; no afirma haber realizado una verificación criptográfica local del tag o de una distribución descargada.

| Fuente | SHA Git del blob |
| --- | --- |
| [contrib/ssh-copy-id](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id) | `afb9beca497d32d7db1100db8248b37e470cc318` |
| [contrib/ssh-copy-id.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1) | `dbdb45ab8226771e4236a22b5da1b8dd280a6ece` |
| [Makefile.in](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/Makefile.in) | `ffc13e069f2db09514b90c2ab4e3170e40e31061` |
| [moduli.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/moduli.5) | `5086a6d42aff50fe9c5c1066a74ec531cf4f6175` |
| [readconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.c) | `9b557dedffcc6a1527e67b9f38f28c552ba2058d` |
| [scp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.1) | `6daf594207219c1b076081b0a8fac7ce5210471b` |
| [scp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/scp.c) | `54ada858f29afdfb3a7a608c7a423ae163c6a7cf` |
| [servconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.c) | `044043b7498a92e37a422fb61fe18a548e81785a` |
| [servconf.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/servconf.h) | `f31668549106e2886ce67ee046cb184cbaa3ed9a` |
| [sftp-server.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.8) | `711067eb186406e9922091ea67c6132c67f6af5d` |
| [sftp-server.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp-server.c) | `f87fc5825c22eaf028da7b83920e27f3340e36c9` |
| [sftp.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.1) | `a30338ba5df7d1310d6254cecc0b55b93936d211` |
| [sftp.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sftp.c) | `ecbaefd611806f9b76f18fd0d9a4eba76f25ccc1` |
| [ssh_config.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5) | `e65bc12529f1593de55d33a2818d41ca70714e8d` |
| [ssh-add.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1) | `bc97faad8714ffc45c11d1052915dd39b613a71c` |
| [ssh-add.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.c) | `515272a35075c67cb9cf1a3d261a6b1d897fbae3` |
| [ssh-agent.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1) | `96fa85e9c89b876d49e6c1ce13346f980b0ab7cb` |
| [ssh-agent.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.c) | `9951345dd923ce629ae069f1df6a8d13614b26b6` |
| [ssh-keygen.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1) | `d4da3844cb91b86718922ccd64ec8c66b9d497d0` |
| [ssh-keygen.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.c) | `5c2d645ac7cce140b56a7e2b2f521a87607e9ec1` |
| [ssh-keyscan.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.1) | `7446b862fff27bea00f12b367774202973ec0b14` |
| [ssh-keyscan.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keyscan.c) | `c43bebf12f05e080102726f6112816c41e8cfec3` |
| [ssh-keysign.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keysign.8) | `e53c55a712f7594912ee7701c33d9e86cb9698e6` |
| [ssh-pkcs11-helper.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-pkcs11-helper.8) | `5edc98507e0c59edc41eda89e5b9c8f5455a4d94` |
| [ssh-sk-helper.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-sk-helper.8) | `e9b2ae12b102d6a39d91b78012f764525341b6d1` |
| [ssh.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.1) | `557cf66d33ca3583dcf1f467624a749762c38a01` |
| [ssh.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh.c) | `fe660efbd0240016bc149ffa6b147290998e2263` |
| [sshd_config.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5) | `3560ec8b87af3a956d963cf7f550fc8049adfad7` |
| [sshd.8](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.8) | `92842e3455539fca4a81ed9de0adfc1eb97f0442` |
| [sshd.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd.c) | `da2aba936d9bbfc06b4a262e542010ee1963c7c8` |
| [version.h](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/version.h) | `13d871d01244f5ec21a1e75360eff7948dae3876` |

[Notas oficiales de versión](https://www.openssh.com/releasenotes.html) · [Criterios de cobertura de Biblioteca](../README.md#cuándo-se-puede-decir-completo)
