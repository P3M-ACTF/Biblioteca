# SSH · Guías y referencias

[Volver a Biblioteca](../../../README.md) · [Guion completo de SSH](../../../Documentaciones/guiones/ssh.md) · [Inventario versionado](../../../Documentaciones/guiones/ssh/README.md)

Entregas desarrolladas a partir del guion: comprender la confianza y autenticación en SSH, realizar una conexión controlada e interpretar opciones y errores; después, gestionar el ciclo básico de claves de usuario. La documentación utiliza como base **OpenSSH Portable 10.6p1**, sin afirmar que esa sea la versión instalada en todos los equipos.

## Ruta de lectura

| Documento | Qué aporta |
| --- | --- |
| [1. Fundamentos](01-fundamentos.md) | Cliente/servidor, cifrado, claves de host/usuario, fingerprints, confianza, autenticación, autorización y sesiones. |
| [2. Conexión básica](02-conexion-basica.md) | Procedimiento para cliente Linux o Windows y servidor Linux ya preparado; configuración propia, verificación de host, comandos y diagnóstico. |
| [3. Referencia de conexión](03-referencia-conexion.md) | Argumentos, defaults upstream, repetición, efectos y casos de 16 opciones de ssh y seis directivas. |
| [4. Claves de usuario y agente](04-claves-y-agente.md) | Generación protegida, instalación de pública, prueba de identidad, agente, cambio de frase, rotación y retirada. |
| [5. Referencia de claves](05-referencia-claves.md) | 21 opciones de ssh-keygen/ssh-add/ssh-agent/ssh-copy-id y tres directivas, limitadas a los modos descritos. |

Los comandos de ejemplo usan datos ficticios y requieren sustitución. Las salidas esquemáticas explican qué buscar; no se presentan como capturas de pruebas ejecutadas.

## Alcance del primer bloque

- Fundamentos para distinguir identidad del servidor, identidad del usuario y permisos de la cuenta.
- Destino, usuario, puerto, IPv4/IPv6, archivo de configuración y configuración efectiva.
- Identidad ya disponible, shell/comando, PTY, stdin y retorno remoto.
- Diagnóstico por fases y conservación deliberada de evidencias.
- Casos de error y diferencias entre el contrato del manual y ciertos estados del parser versionado.

Quedan para otros bloques la instalación/administración del servidor, la gestión completa de claves/agentes, bastionado, transferencias, túneles, certificados/CA, revocación y automatización avanzada. Las herramientas auxiliares citadas aquí se utilizan con un propósito limitado; no se declara cubierto todo su catálogo.

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
- [Plantilla sshd_config](../../plantillas/sshd_config.ejemplo): recurso para futuros cambios de servidor; esta práctica no lo modifica.
- [Catálogo de contenidos de SSH](../../../Documentaciones/guiones/ssh/README.md): temas restantes e IDs para ampliar materiales.

## Fuentes y mantenimiento

La referencia técnica enlaza a las líneas de manual relevantes y al código de la versión fijada cuando explica repetición o estados internos. La guía conceptual enlaza a los RFC de arquitectura y autenticación.

Para actualizar esta entrega, comparar la nueva versión con las unidades inventariadas, corregir las fichas afectadas y repetir sus casos. Las comprobaciones de enlaces/estructura no acreditan conectividad ni comportamiento real de SSH.
