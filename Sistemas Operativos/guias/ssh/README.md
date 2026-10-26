# SSH · Guías y referencias

[Volver a Biblioteca](../../../README.md) · [Guion completo de SSH](../../../Documentaciones/guiones/ssh.md) · [Inventario versionado](../../../Documentaciones/guiones/ssh/README.md)

Entregas desarrolladas a partir del guion: comprender la confianza y autenticación en SSH, realizar una conexión controlada e interpretar opciones y errores; después, gestionar el ciclo básico de claves de usuario, aplicar cambios controlados en el servidor Linux, transferir datos comprobando el resultado, utilizar túneles TCP/bastiones con política limitada, gestionar certificados/CA/revocación y confinar una cuenta SFTP. La documentación utiliza como base **OpenSSH Portable 10.6p1**, sin afirmar que esa sea la versión instalada en todos los equipos.

## Ruta de lectura

| Documento | Qué aporta |
| --- | --- |
| [1. Fundamentos](01-fundamentos.md) | Cliente/servidor, cifrado, claves de host/usuario, fingerprints, confianza, autenticación, autorización y sesiones. |
| [2. Conexión básica](02-conexion-basica.md) | Procedimiento para cliente Linux o Windows y servidor Linux ya preparado; configuración propia, verificación de host, comandos y diagnóstico. |
| [3. Referencia de conexión](03-referencia-conexion.md) | Argumentos, defaults upstream, repetición, efectos y casos de 16 opciones de ssh y seis directivas. |
| [4. Claves de usuario y agente](04-claves-y-agente.md) | Generación protegida, instalación de pública, prueba de identidad, agente, cambio de frase, rotación y retirada. |
| [5. Referencia de claves](05-referencia-claves.md) | 21 opciones de ssh-keygen/ssh-add/ssh-agent/ssh-copy-id y tres directivas, limitadas a los modos descritos. |
| [6. Servidor Linux](06-servidor-linux.md) | Instalación, servicio/socket, candidato, política de acceso, validación contextual, recarga y restauración. |
| [7. Referencia de servidor](07-referencia-servidor.md) | Cinco opciones de sshd y 16 directivas de configuración, con defaults, contexto y casos. |
| [8. SFTP y SCP](08-transferencias.md) | Subida/descarga, nombres con espacios, hashes, lotes y reanudación sobre prefijo conocido. |
| [9. Referencia de transferencias](09-referencia-transferencias.md) | 11 opciones, nueve órdenes SFTP y nueve flags de ls. |
| [10. rsync sobre SSH](10-rsync-sobre-ssh.md) | Introducción con dry-run, barra final, parciales, contenido y revisión de borrados. |
| [11. Túneles y bastiones](11-tuneles-y-bastiones.md) | Recorrido -L/-R/-D, ProxyJump, excepción limitada, fallos y cierre de listeners. |
| [12. Referencia de túneles](12-referencia-tuneles.md) | Ocho opciones, seis directivas cliente y cinco servidor; argumentos, defaults, precedencia y casos. |
| [13. Certificados, CA y KRL](13-certificados-ca-krl.md) | Emisión de usuario/host, principals, confianza, revocación candidata y recuperación. |
| [14. Referencia de certificados](14-referencia-certificados.md) | 18 fichas, 17 subopciones de certificado y seis directivas KRL; gramáticas y diferencias de parser. |
| [15. Evidencia local de certificados](15-verificacion-certificados-windows.md) | Resultados offline en Windows 9.5p2; distingue lo probado de los ensayos de conexión pendientes. |
| [16. SFTP confinado](16-sftp-confinado.md) | Cuenta dedicada, raíz/datos, autenticación, restricciones, ensayos negativos, filtros y retirada. |
| [17. Referencia de SFTP confinado](17-referencia-sftp-confinado.md) | Diez opciones de servidor, cinco directivas y 29 solicitudes de protocolo; efectos y límites. |

Los comandos de ejemplo usan datos ficticios y requieren sustitución. Las salidas esquemáticas explican qué buscar; no se presentan como capturas de pruebas ejecutadas.

## Alcance del primer bloque

- Fundamentos para distinguir identidad del servidor, identidad del usuario y permisos de la cuenta.
- Destino, usuario, puerto, IPv4/IPv6, archivo de configuración y configuración efectiva.
- Identidad ya disponible, shell/comando, PTY, stdin y retorno remoto.
- Diagnóstico por fases y conservación deliberada de evidencias.
- Casos de error y diferencias entre el contrato del manual y ciertos estados del parser versionado.

Los bloques siguientes amplían servidor, claves/agentes, bastionado, transferencias, túneles, certificados/CA y revocación; su cobertura exhaustiva y la automatización avanzada siguen abiertas. Las herramientas auxiliares citadas aquí se utilizan con un propósito limitado; no se declara cubierto todo su catálogo.

## Cobertura y estado

**Documentado** significa que existe explicación con referencia oficial y versión. **Verificado funcionalmente** exige ejecutar los casos en un entorno registrado; ninguno se marca así por estar escrito.

| Familia del guion | Cobertura de esta entrega | Estado |
| --- | --- | --- |
| SSH-T01 | Introducción a protocolo, cifrado, identidad y confianza; no agota algoritmos ni certificados. | Desarrollo parcial documentado. |
| SSH-C001 | Destino/usuario/puerto, familias IP, versión, diagnóstico y retorno del comando. | Documentado para el bloque; pruebas pendientes. |
| SSH-C002 | Selección -i y mecanismo -o; las demás opciones de identidad/criptografía siguen pendientes. | Desarrollo parcial documentado. |
| SSH-C003 | -T, -t, -n, -E y -e; quedan otras funciones de sesión/forwarding. | Desarrollo parcial documentado. |
| SSH-C005 | -F y -G; quedan multiplexación, tags y otras funciones. | Desarrollo parcial documentado. |
| SSH-C007/C008/C009 | Seis directivas concretas de identidad, confianza y establecimiento. | Desarrollo parcial documentado. |
| SSH-C013 | Inspección de una fingerprint de host con ssh-keygen. | Uso introductorio; referencia completa pendiente. |
| SSH-P01/P02/P03/P09 | Escenarios de conexión, configuración, comando y diagnóstico. | Casos descritos parcialmente; ejecución pendiente. |

### Segundo bloque: ciclo básico de claves

La [práctica de claves y agente](04-claves-y-agente.md) desarrolla generación, correspondencia de pública/privada, despliegue, selección de una sola identidad, agente POSIX dedicado y comprobaciones de cliente Windows. Distingue cambio de frase, retirada del agente y revocación de autorizaciones, con prueba positiva de la clave nueva y negativa de la anterior.

La [referencia de claves](05-referencia-claves.md) enlaza 24 fichas con el inventario: 21 opciones y tres directivas. Contiene 48 casos de referencia y la práctica añade ocho criterios de aceptación, todos **pendientes de ensayo**. La cobertura es parcial en SSH-T04, SSH-C007/C012/C013/C016/C017/C018/C023/C026 y SSH-P01/P02/P09; no cierra esas familias ni los modos de CA, KRL, FIDO, conversión y restricciones avanzadas.

### Tercer bloque: servidor Linux

La [práctica de servidor](06-servidor-linux.md) recorre instalación por familia de paquetes, identificación de servicio/socket, configuración candidata, política de acceso y recuperación por consola. Distingue sintaxis, configuración efectiva por contexto y pruebas de conexiones nuevas. No cambia puerto, algoritmos, política PAM ni unidades de activación; el perfil de clave simple exige precondiciones y no sustituye MFA.

La [referencia de servidor](07-referencia-servidor.md) añade 21 fichas: cinco opciones y 16 directivas, con 42 casos de referencia y ocho criterios de aceptación en la práctica, todos **pendientes de ensayo**. Desarrollo parcial de SSH-T02/T05/T08 y SSH-C020…C025, relacionado con SSH-P09; no acredita cobertura completa por distribución ni bastionado terminado.

### Cuarto bloque: transferencias

La [práctica SFTP/SCP](08-transferencias.md) distingue sus protocolos, copias/árboles, metadatos, hashes, reanudación y ejecución por lotes. La [referencia](09-referencia-transferencias.md) añade 20 fichas —11 opciones y nueve órdenes— y una tabla de nueve flags de ls: 29 unidades inventariadas enlazadas en ambos sentidos, con 40 casos de referencia y ocho criterios de aceptación pendientes.

La [introducción rsync sobre SSH](10-rsync-sobre-ssh.md) fija su propia referencia, rsync 3.5.1, e incluye cuatro criterios pendientes. Es un desarrollo introductorio de SSH-C033; el catálogo completo corresponde a GNU/Linux. Cobertura parcial de SSH-T06, SSH-C027/C028/C029/C033 y SSH-P04; no cierra las familias, el protocolo legacy ni las diferencias por plataforma.

### Quinto bloque: túneles TCP y bastiones

La [práctica de túneles](11-tuneles-y-bastiones.md) comprueba direcciones de -L/-R/-D, SOCKS local, acceso a T mediante ProxyJump, confianza separada y cierre/restauración. Parte de una excepción deliberada al DisableForwarding del bloque de servidor, limitada a cuenta, origen y destinos propios; mantiene agente sin reenviar y listeners en loopback.

La [referencia](12-referencia-tuneles.md) contiene 19 fichas —ocho opciones y 11 directivas— con enlaces recíprocos al inventario y 38 casos pendientes. La práctica añade diez criterios de aceptación pendientes. Cobertura parcial de SSH-T07, SSH-C002/C003/C004/C010/C024 y SSH-P05/P06: sockets Unix, SOCKS remoto, TUN/TAP, X11, multihop avanzado y diferencias por plataforma siguen abiertos.

### Sexto bloque: certificados y revocación

La [práctica de certificados](13-certificados-ca-krl.md) separa CA de usuario/host, limita principals y tiempos, prepara confianza y perfiles que exigen certificados, y desarrolla KRL candidata, sustitución atómica y restauración. La [referencia](14-referencia-certificados.md) añade 18 fichas (11 opciones y siete directivas), 17 subopciones de certificado y seis directivas KRL: 41 unidades inventariadas con enlaces recíprocos.

Las 36 casillas integradoras y los diez criterios del laboratorio permanecen pendientes. La [evidencia local](15-verificacion-certificados-windows.md) registra 71 operaciones/comprobaciones offline con claves efímeras en Windows OpenSSH 9.5p2; no acredita conexiones Linux ni ejecución de Portable 10.6p1. Cobertura parcial de SSH-T04/T08, SSH-C007/C009/C014/C015/C023/C026 y SSH-P08; siguen abiertas firmas de datos, FIDO, PKCS#11 y automatización avanzada.

### Séptimo bloque: SFTP confinado

La [práctica de cuenta confinada](16-sftp-confinado.md) separa raíz de root y datos del usuario, pública fuera de la zona de subida, servicio forzado, PTY/rc y bloqueo de forwarding. Compara transferencias permitidas, marcador exterior inaccesible, modo de solo lectura y filtros con transportes nuevos, y retira la cuenta antes de quitar el confinamiento.

La [referencia](17-referencia-sftp-confinado.md) enlaza 44 unidades: 15 fichas —diez opciones y cinco directivas— y las 29 solicitudes del dispatcher. Contiene 30 casos de ficha y 58 variantes por solicitud, más diez criterios de práctica, todos pendientes de laboratorio. La inspección local del perfil con ssh -G no acredita el servidor Linux. Cobertura parcial de SSH-T05/T06, SSH-C024/C028/C029/C030 y SSH-P07.

Las tablas siguientes corresponden al primer bloque de conexión.

### Opciones desarrolladas

| Unidad inventariada | Ficha técnica | Prueba funcional |
| --- | --- | --- |
| [SSH-I-SSH-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6c) | [-l · usuario remoto](03-referencia-conexion.md#ssh-r-opt-6c) | Pendiente |
| [SSH-I-SSH-OPT-70](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-70) | [-p · puerto del servidor](03-referencia-conexion.md#ssh-r-opt-70) | Pendiente |
| [SSH-I-SSH-OPT-34](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-34) | [-4 · usar IPv4](03-referencia-conexion.md#ssh-r-opt-34) | Pendiente |
| [SSH-I-SSH-OPT-36](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-36) | [-6 · usar IPv6](03-referencia-conexion.md#ssh-r-opt-36) | Pendiente |
| [SSH-I-SSH-OPT-56](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-56) | [-V · mostrar la versión](03-referencia-conexion.md#ssh-r-opt-56) | Pendiente |
| [SSH-I-SSH-OPT-76](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-76) | [-v · aumentar el diagnóstico](03-referencia-conexion.md#ssh-r-opt-76) | Pendiente |
| [SSH-I-SSH-OPT-71](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-71) | [-q · reducir mensajes del cliente](03-referencia-conexion.md#ssh-r-opt-71) | Pendiente |
| [SSH-I-SSH-OPT-46](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-46) | [-F · elegir el archivo de configuración](03-referencia-conexion.md#ssh-r-opt-46) | Pendiente |
| [SSH-I-SSH-OPT-47](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-47) | [-G · imprimir la configuración efectiva](03-referencia-conexion.md#ssh-r-opt-47) | Pendiente |
| [SSH-I-SSH-OPT-6F](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6f) | [-o · pasar una directiva en la línea de comandos](03-referencia-conexion.md#ssh-r-opt-6f) | Pendiente |
| [SSH-I-SSH-OPT-69](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-69) | [-i · seleccionar un archivo de identidad](03-referencia-conexion.md#ssh-r-opt-69) | Pendiente |
| [SSH-I-SSH-OPT-54](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-54) | [-T · no asignar pseudoterminal](03-referencia-conexion.md#ssh-r-opt-54) | Pendiente |
| [SSH-I-SSH-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-74) | [-t · solicitar pseudoterminal](03-referencia-conexion.md#ssh-r-opt-74) | Pendiente |
| [SSH-I-SSH-OPT-6E](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-6e) | [-n · no leer la entrada estándar](03-referencia-conexion.md#ssh-r-opt-6e) | Pendiente |
| [SSH-I-SSH-OPT-45](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-45) | [-E · añadir el diagnóstico a un archivo](03-referencia-conexion.md#ssh-r-opt-45) | Pendiente |
| [SSH-I-SSH-OPT-65](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-opt-65) | [-e · elegir el carácter de escape](03-referencia-conexion.md#ssh-r-opt-65) | Pendiente |

### Directivas desarrolladas

| Unidad inventariada | Ficha técnica | Prueba funcional |
| --- | --- | --- |
| [SSH-I-CLIENT-BATCHMODE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-batchmode) | [BatchMode](03-referencia-conexion.md#ssh-r-cfg-batchmode) | Pendiente |
| [SSH-I-CLIENT-CONNECTTIMEOUT](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-connecttimeout) | [ConnectTimeout](03-referencia-conexion.md#ssh-r-cfg-connecttimeout) | Pendiente |
| [SSH-I-CLIENT-CONNECTIONATTEMPTS](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-connectionattempts) | [ConnectionAttempts](03-referencia-conexion.md#ssh-r-cfg-connectionattempts) | Pendiente |
| [SSH-I-CLIENT-STRICTHOSTKEYCHECKING](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-stricthostkeychecking) | [StrictHostKeyChecking](03-referencia-conexion.md#ssh-r-cfg-stricthostkeychecking) | Pendiente |
| [SSH-I-CLIENT-IDENTITIESONLY](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-identitiesonly) | [IdentitiesOnly](03-referencia-conexion.md#ssh-r-cfg-identitiesonly) | Pendiente |
| [SSH-I-CLIENT-USERKNOWNHOSTSFILE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-userknownhostsfile) | [UserKnownHostsFile](03-referencia-conexion.md#ssh-r-cfg-userknownhostsfile) | Pendiente |

## Criterio para registrar una prueba

Ejecutar los casos de la práctica y las fichas, registrando únicamente la información necesaria:

| Campo | Evidencia |
| --- | --- |
| Entorno | SO/build, shell, ruta y versión de cliente; versión y plataforma del servidor. |
| Precondición | Configuración, identidad autorizada y referencia de confianza disponibles. |
| Acción | Comando exacto, con datos de laboratorio y sin secretos. |
| Resultado | stdout, stderr/log, retorno y campos que confirman el comportamiento. |
| Clasificación | Coincide con la referencia, diferencia de versión/plataforma o hipótesis por investigar. |
| Recuperación | Sesión cerrada y reversión de los cambios realizados, si los hubiera. |

No incluir privadas, contraseñas, frases de paso ni volcados innecesarios de configuración real. Los logs pueden revelar metadatos aunque no contengan secretos.

Una casilla del guion general permanece abierta mientras falten otras unidades de su familia o pruebas requeridas. La [plantilla de unidad](../../../Documentaciones/guiones/PLANTILLA.md) conserva el criterio completo.

## Recursos relacionados

- [Chuleta de administración SSH](../../chuletas/ssh-admin.md): consulta rápida existente; tiene un alcance más amplio que esta entrega.
- [Nota de claves la primera vez](../../notas/ssh-claves-primer-uso.md): introducción a creación/despliegue de claves.
- [Plantilla sshd_config](../../plantillas/sshd_config.ejemplo): ejemplo existente con rutas/opciones que deben revisarse por paquete; seguir la práctica de servidor antes de aplicar cambios.
- [Catálogo de contenidos de SSH](../../../Documentaciones/guiones/ssh/README.md): temas restantes e IDs para ampliar materiales.

## Fuentes y mantenimiento

La referencia técnica enlaza a las líneas de manual relevantes y al código de la versión fijada cuando explica repetición o estados internos. La guía conceptual enlaza a los RFC de arquitectura y autenticación.

Para actualizar esta entrega, comparar la nueva versión con las unidades inventariadas, corregir las fichas afectadas y repetir sus casos. Las comprobaciones de enlaces/estructura no acreditan conectividad ni comportamiento real de SSH.
