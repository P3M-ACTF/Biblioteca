# Guiones de contenidos

Estos documentos definen **qué debemos cubrir** antes de redactar guías, manuales, cheatsheets Markdown o recursos visuales. Constituyen un temario mantenible y un inventario de unidades enlazables; las explicaciones se desarrollan después en los formatos adecuados.

## Catálogo

| Guion | Alcance |
| --- | --- |
| [GitHub](github.md) | Plataforma, Git como base, GitHub CLI, APIs, colaboración, automatización, seguridad y administración. |
| [SSH](ssh.md) | Protocolo, autenticación, configuración, transferencias y túneles. Incluye [inventario detallado de OpenSSH Portable 10.6p1](ssh/README.md). |
| [MySQL](mysql.md) | Modelo relacional, SQL, funciones, herramientas cliente y servidor, administración, seguridad y recuperación. |
| [Stack XAMPP](xampp.md) | Paquete local en Windows/Linux y reproducción funcional por componentes con Docker Compose. |
| [Stack LAMPP / LAMP](lampp.md) | Instalación nativa Linux de Apache, base de datos y PHP; variantes y despliegue con Compose. |
| [Stack LEMPP / LEMP](lempp.md) | Instalación nativa Linux de Nginx, base de datos y PHP-FPM; variantes y despliegue con Compose. |
| [WordPress](wordpress.md) | Instalación local y Compose, edición, administración, desarrollo, WP-CLI, seguridad y migraciones. |
| [Windows](windows.md) | Cliente y Server, PowerShell/CMD, consultas, administración local y dominio, permisos, servicios y automatización. |
| [GNU/Linux](gnu-linux.md) | Base común y diferencias entre Debian, Ubuntu, Arch/Manjaro y RHEL/Fedora/derivadas. |

Recursos comunes: [plantilla de unidad](PLANTILLA.md) y [guion transversal de Docker Compose](comun-compose.md).

## Organización

Cada guion contiene alcance, temario, inventario técnico, casos integradores, relaciones y fuentes. Los temas comparten contenidos mediante enlaces; por ejemplo, WordPress remite al guion de MySQL y los cuatro despliegues web reutilizan el guion de Compose. Las particularidades de cada stack se documentan en su propio guion.

Conservamos los nombres solicitados **LAMPP** y **LEMPP**, pero identificamos sus bases habituales como **LAMP** y **LEMP**. No se presupone un significado universal para una segunda «P». PHP y phpMyAdmin tienen apartados explícitos; Perl/Python son variantes que se deben identificar cuando se incluyan. XAMPP para Linux y su ruta `/opt/lampp` se estudian en XAMPP: no se confunden con la instalación por paquetes del sistema.

Los guiones son documentación de planificación. Las tablas contienen nombres y variantes para investigar y explicar; no son recetas ejecutables. En particular, una lista de subcomandos no implica que todos acepten las mismas opciones.

## Qué significa cubrir un contenido

Una unidad puede ser un concepto, un comando, una opción, un argumento posicional, una directiva, una clave de configuración, una operación de interfaz, un endpoint o un caso de uso. Para desarrollarla debemos registrar:

1. Objetivo y situación en la que se utiliza.
2. Producto, versión, edición, sistema, shell, paquete o módulo y requisitos.
3. Sintaxis y **cada** opción/argumento: tipo, valores, valor predeterminado, obligatoriedad, repetición y exclusiones.
4. Alcance y privilegios: usuario, equipo, dominio, sesión, servicio, contenedor o red; consulta o modificación; persistencia.
5. Ejemplo mínimo, variantes y combinaciones relevantes; entradas vacías, caracteres especiales, espacios y Unicode.
6. Salida, campos, unidades, códigos de retorno y señales de éxito o error. Indicar qué buscamos en cada salida.
7. Efectos secundarios, riesgos concretos, comprobación del resultado y reversión cuando proceda.
8. Errores habituales, causas, diagnóstico y recuperación.
9. Fuente oficial y evidencia de prueba. Separar lo documentado de lo observado.
10. Enlaces a los materiales derivados y cobertura que aporta cada uno.

No hace falta enumerar el producto cartesiano de todas las opciones. Sí hay que cubrir cada opción admitida, dependencias, incompatibilidades, valores límite y combinaciones con un comportamiento distinto. Las combinaciones equivalentes se agrupan indicando el criterio.

## IDs y enlaces

Los prefijos son `GH`, `SSH`, `MYSQL`, `XAMPP`, `LAMP`, `LEMP`, `WP`, `WIN`, `LIN` y `CMP`. `T` identifica un bloque temático, `C` una unidad técnica y `P` un caso integrador. Los números son identificadores, no posiciones que debamos renumerar al insertar contenidos.

Las tablas técnicas tienen anclas explícitas. Por ejemplo, [SSH-C001](ssh.md#ssh-c001) puede citarse desde una guía o una chuleta aunque se reorganice el temario. Al desglosar la unidad, asignar sufijos estables (`SSH-C001-O001`, `SSH-C001-A001`, `SSH-C001-K001`) a opciones, argumentos y casos. Añadir sus anclas al desarrollar las fichas. No reutilizar un ID retirado: mantener una nota o redirección a su sustituto.

Los enlaces a materiales existentes son puntos de partida, no validaciones de cobertura. No crear enlaces a archivos que todavía no existen: registrar «Pendiente» hasta disponer del recurso.

## Estados de seguimiento

| Estado | Significado |
| --- | --- |
| Inventariado | El elemento y sus límites están identificados. |
| Documentado | Existe explicación con fuente y versión; puede faltar la prueba. |
| Verificado | Se ha probado el comportamiento en el entorno registrado. |
| No aplicable | No existe en la versión/edición objetivo; registrar el motivo y la fuente. |
| Retirado | Se conserva como referencia histórica y se identifica la alternativa. |

Las casillas del temario y de los casos se mantienen vacías hasta que el bloque tenga sus unidades documentadas y su evidencia correspondiente. Una casilla marcada no sustituye el registro detallado de cobertura. Los inventarios iniciales no tienen todavía estado «Verificado».

## Cuándo se puede decir «completo»

«Completo» debe referirse a una versión y un alcance declarados. GitHub cambia como servicio, y Windows y GNU/Linux incorporan herramientas opcionales: sin esos límites no existe una lista cerrada de todos los comandos posibles.

- [ ] Fijar producto, edición, versión o fecha de corte, plataforma y componentes incluidos. Registrar exclusiones justificadas.
- [ ] Capturar el catálogo oficial y el catálogo del entorno: CLI, módulos, ayuda, APIs y configuración. Guardar versión y fecha de cada captura.
- [ ] Comparar ese catálogo con las fichas: **cada elemento oficial debe corresponder a una unidad o a una exclusión justificada**. Registrar faltantes, adiciones y retiradas.
- [ ] Desglosar todos los subcomandos, opciones, argumentos posicionales, parámetros comunes, valores, directivas y operaciones GUI/API dentro del alcance.
- [ ] Documentar casos correctos, errores, permisos, persistencia, salidas y combinaciones relevantes; probar los procedimientos que se publican como verificados.
- [ ] Revisar diferencias de versión, edición, distribución, shell y arquitectura. No atribuir a todas las variantes una prueba realizada en una sola.
- [ ] Enlazar los materiales derivados con los IDs que cubren y revisar enlaces y formato.

El estado actual es **primera versión de los guiones**, con el [inventario de SSH ampliado y contrastado para OpenSSH Portable 10.6p1](ssh/README.md). Los demás inventarios mantienen su cobertura inicial. Ninguno es todavía una referencia técnica desarrollada y verificada por completo: faltan fichas, defaults por entorno y pruebas funcionales. No se han ejecutado las operaciones de administración incluidas.

## Flujo de mantenimiento

1. Añadir o corregir la unidad en su guion y conservar su ID.
2. Desglosarla con la [plantilla](PLANTILLA.md), elegir el entorno y contrastar su referencia oficial.
3. Redactar y probar el contenido técnico; extraer después las versiones divulgativa, Markdown y visual según su utilidad.
4. Enlazar cada derivado desde la unidad y citar el ID desde el derivado. Una infografía resume; la referencia conserva las variantes completas.
5. Cuando cambie una herramienta, comparar el nuevo catálogo, actualizar unidades afectadas y volver a verificar sus casos. Aprovechar el diff de Git; no mantener otro historial duplicado por rutina.

No hay automatizaciones ni workflows nuevos asociados a estos guiones. Las comprobaciones de documentación se pueden realizar localmente.

[Volver a Biblioteca](../../README.md)
