# Guion de contenidos · MySQL

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

MySQL Community Server, SQL y herramientas oficiales, con referencia inicial a la rama documental 8.4. Registrar la versión exacta del laboratorio antes de desarrollar sintaxis y defaults; las ramas posteriores y las ediciones comerciales se comparan explícitamente. MariaDB no se considera intercambiable: documentar sus diferencias cuando forme parte de XAMPP o de un stack web. Incluir administración y consulta, no solo SQL básico.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### MYSQL-T01 · Modelo de datos y preparación

- [ ] Modelo relacional, entidades, relaciones, claves, dependencias, normalización y paso a SQL.
- [ ] Servidor/cliente, instancia, schema/database, tabla, fila, columna, conexión y sesión.
- [ ] Instalación Linux/Windows/Compose, paquetes, servicio, socket, TCP, archivos, logs y versiones.
- [ ] Juego de caracteres, collation, Unicode, zonas horarias, SQL modes y sensibilidad a mayúsculas.

### MYSQL-T02 · Lenguaje y tipos

- [ ] Identificadores, literales, comentarios, delimitadores, palabras reservadas, expresiones y precedencia.
- [ ] Todos los tipos numéricos, texto/binarios, fechas, JSON y espaciales de la versión objetivo.
- [ ] NULL y lógica ternaria, conversiones implícitas/explícitas, comparación y coerción.
- [ ] Inventario completo de operadores y funciones built-in, con firma, tipos, NULL, rangos y ejemplos.

### MYSQL-T03 · Definición y modificación

- [ ] CREATE/ALTER/DROP/RENAME/TRUNCATE para todos los objetos admitidos.
- [ ] Restricciones PK, UNIQUE, FK, CHECK, DEFAULT, NOT NULL y AUTO_INCREMENT.
- [ ] Índices, columnas generadas/invisibles, particionado, tablas temporales y tablespaces.
- [ ] Efectos de DDL sobre transacciones, bloqueos, replicación y compatibilidad de cambios.

### MYSQL-T04 · Consulta y escritura

- [ ] SELECT completo: filtros, agrupación, orden, joins, subconsultas, CTE recursivas y funciones de ventana.
- [ ] Operaciones de conjuntos, consultas preparadas, cursores y EXPLAIN.
- [ ] INSERT, REPLACE, UPDATE, DELETE, carga y exportación; duplicados y escritura masiva.
- [ ] Seguridad de consultas: parámetros, inyección SQL, privilegios y exposición de datos.

### MYSQL-T05 · Transacciones y concurrencia

- [ ] ACID, InnoDB, autocommit, commit, rollback, savepoints y aislamiento.
- [ ] MVCC, read views, locks, gap locks, deadlocks, timeouts y reintentos.
- [ ] Lecturas de bloqueo, DDL atómico, XA y límites transaccionales.

### MYSQL-T06 · Programación almacenada

- [ ] Vistas, procedimientos, funciones, triggers y eventos: crear, alterar, consultar y retirar.
- [ ] Variables locales/de sesión/de sistema, control de flujo, handlers, SIGNAL, RESIGNAL y diagnostics.
- [ ] DEFINER, SQL SECURITY, determinismo, privilegios y efectos en binlog/replicación.
- [ ] Separar cliente DELIMITER del SQL enviado al servidor.

### MYSQL-T07 · Seguridad y administración

- [ ] Cuentas usuario@host, plugins de autenticación, roles y privilegios estáticos/dinámicos.
- [ ] TLS, certificados, contraseñas, bloqueo, expiración, acceso remoto y mínimo privilegio.
- [ ] Configuración, variables de sesión/globales/persistidas, conexiones, recursos y componentes/plugins.
- [ ] Metadatos, INFORMATION_SCHEMA, performance_schema, sys, status, logs y auditoría según edición.

### MYSQL-T08 · Rendimiento y operación

- [ ] Optimización, estadísticas, índices, planes, buffer pool, I/O y consultas lentas.
- [ ] Copias lógicas/físicas, consistencia, binlog, restauración y recuperación a un punto en el tiempo.
- [ ] Replicación, GTID, filtros, lag, failover, Group Replication e InnoDB Cluster según componentes.
- [ ] Actualización, compatibilidad, migración, rollback soportado, capacidad y recuperación ante corrupción.
- [ ] Shell, X Protocol, conectores y APIs; diferencias Community/Enterprise/NDB y extensiones.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="mysql-c001"></a>MYSQL-C001 | `mysql` conexión | `--host`, `--port`, `--user`, `--password` sin valor literal, `--socket`, `--protocol`, `--database`, `--connect-timeout`, `--ssl-mode`, `--ssl-ca`, `--ssl-cert`, `--ssl-key` | Autenticación, socket frente a TCP, validación TLS y errores de conexión. |
| <a id="mysql-c002"></a>MYSQL-C002 | `mysql` ejecución y salida | `--execute`, `--batch`, `--raw`, `--silent`, `--table`, `--vertical`, `--xml`, `--html`, `--default-character-set`, `--show-warnings`, `--safe-updates` | Scripts, NULL, cabeceras, escape de datos, filas y códigos de retorno. |
| <a id="mysql-c003"></a>MYSQL-C003 | `mysql` opciones restantes | `--help`, `--verbose`, `--defaults-file`, `--defaults-extra-file`, `--no-defaults`, `--login-path`, `--local-infile` y catálogo del cliente | Precedencia, orden de opciones, plugins y carga de archivos locales. |
| <a id="mysql-c004"></a>MYSQL-C004 | Órdenes del cliente mysql | `help`, `?`, `\h`, `\q`, `\c`, `\g`, `\G`, `source`, `\.`, `tee`, `notee`, `pager`, `nopager`, `delimiter`, `status`, `charset`, `prompt`, `warnings`, `nowarning`, `system` si existe | Inventariar todos los comandos del cliente y distinguirlos del SQL del servidor. |
| <a id="mysql-c005"></a>MYSQL-C005 | `mysqld` | `--help --verbose`, `--version`, `--defaults-file`, `--initialize`, `--initialize-insecure`, `--validate-config`, `--console` según plataforma | Inicialización, configuración y proceso; no usar inicialización insegura como receta por defecto. |
| <a id="mysql-c006"></a>MYSQL-C006 | `mysqladmin` | `ping`, `status`, `extended-status`, `processlist`, `variables`, `version`, `flush-*`, `shutdown`, `kill`, `create`, `drop`, `password` y opciones del catálogo | Disponibilidad frente a autenticación; acciones destructivas y datos sensibles. |
| <a id="mysql-c007"></a>MYSQL-C007 | `mysqldump` | `--single-transaction`, `--quick`, `--databases`, `--all-databases`, `--routines`, `--events`, `--triggers`, `--no-data`, `--no-create-info`, `--where`, `--result-file`, `--set-gtid-purged`, `--source-data` según versión | Qué incluye la copia, consistencia, motores, bloqueo y posición de recuperación. |
| <a id="mysql-c008"></a>MYSQL-C008 | `mysqlpump`, `mysql_upgrade` y utilidades históricas | Disponibilidad, deprecación/retirada por versión y alternativa oficial | No presentar herramientas retiradas como parte de la instalación actual. |
| <a id="mysql-c009"></a>MYSQL-C009 | `mysqlbinlog` | `--start-datetime`, `--stop-datetime`, `--start-position`, `--stop-position`, `--read-from-remote-server`, `--base64-output`, `--verbose` | Eventos, transacciones, posición y recuperación puntual sin repetir cambios. |
| <a id="mysql-c010"></a>MYSQL-C010 | `mysqlcheck`, `mysqlshow`, `mysqlimport` | `--all-databases`, operaciones check/analyze/optimize; columnas/índices; delimitadores y carga por herramienta | Soporte por motor y coste; separar programa cliente de sentencia SQL. |
| <a id="mysql-c011"></a>MYSQL-C011 | `mysql_config_editor`, `mysql_secure_installation` | `set`, `print`, `remove`, `--login-path`; pasos del asistente | Almacenamiento de credenciales y limitaciones; no exponer contraseñas en argv. |
| <a id="mysql-c012"></a>MYSQL-C012 | MySQL Shell `mysqlsh` | `--sql`, `--js`, `--py`, `--uri`, `--file`, `--execute`; `\connect`, `\status`, `\sql`, `\js`, `\py`, `\help` | Modos, protocolo clásico/X y shell separado del cliente mysql. |
| <a id="mysql-c013"></a>MYSQL-C013 | Shell utilities / AdminAPI | `util.dumpInstance`, `dumpSchemas`, `dumpTables`, `loadDump`, `checkForServerUpgrade`; `dba`, cluster, replica set, cluster set según versión | Firma y opciones de cada API, compatibilidad, consistencia y componentes requeridos. |
| <a id="mysql-c014"></a>MYSQL-C014 | Tipos numéricos | `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INT`, `BIGINT`, `DECIMAL`, `NUMERIC`, `FLOAT`, `DOUBLE`, `BIT`, aliases | Rangos, precisión/escala, signo, redondeo, overflow y representación. |
| <a id="mysql-c015"></a>MYSQL-C015 | Tipos temporales | `DATE`, `TIME`, `DATETIME`, `TIMESTAMP`, `YEAR` | Rangos, fracciones, zonas horarias, valores inválidos y SQL mode. |
| <a id="mysql-c016"></a>MYSQL-C016 | Tipos de cadenas | `CHAR`, `VARCHAR`, `BINARY`, `VARBINARY`, familias `TEXT`/`BLOB`, `ENUM`, `SET` | Longitud en caracteres/bytes, collation, espacios, índices y almacenamiento. |
| <a id="mysql-c017"></a>MYSQL-C017 | Tipos JSON y espaciales | `JSON`, `GEOMETRY`, `POINT`, `LINESTRING`, `POLYGON`, colecciones y multigeometrías | Validación, SRID, índices y conversión. |
| <a id="mysql-c018"></a>MYSQL-C018 | Operadores | Aritméticos, comparativos, lógicos, bit a bit, asignación, `IS NULL`, `<=>`, `IN`, `BETWEEN`, `LIKE`, `REGEXP`, `EXISTS`, `ANY`, `ALL` | Ficha por operador, precedencia, NULL, coerción y semántica de conjuntos vacíos. |
| <a id="mysql-c019"></a>MYSQL-C019 | Funciones escalares | Familias numéricas, cadenas, fechas, conversión, control de flujo, información y bloqueo | Una ficha por función del índice oficial: firma, parámetros opcionales, retorno y casos límite. |
| <a id="mysql-c020"></a>MYSQL-C020 | Funciones agregadas y de ventana | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP_CONCAT`, agregados JSON; ranking, distribución, `LAG`, `LEAD`, first/last/nth | NULL, duplicados, orden, partición y window frame; completar catálogo oficial. |
| <a id="mysql-c021"></a>MYSQL-C021 | Funciones especializadas | JSON, espaciales, regex, cifrado/hash, compresión, UUID, GTID, replicación, performance_schema y uso interno documentado | Registrar disponibilidad, determinismo, costes y restricciones por versión/edición. |
| <a id="mysql-c022"></a>MYSQL-C022 | `CREATE DATABASE`, `ALTER DATABASE`, `DROP DATABASE`, `USE` | `IF [NOT] EXISTS`, `CHARACTER SET`, `COLLATE`, `READ ONLY` cuando exista | Schema activo, herencia de collation y eliminación completa. |
| <a id="mysql-c023"></a>MYSQL-C023 | `CREATE TABLE` | `TEMPORARY`, `IF NOT EXISTS`, columnas, constraints, `ENGINE`, charset/collation, `LIKE`, `AS SELECT`, opciones de tabla/partición | Integridad, claves, defaults, generated/invisible y diferencias con copia de datos. |
| <a id="mysql-c024"></a>MYSQL-C024 | `ALTER TABLE` | `ADD`, `DROP`, `MODIFY`, `CHANGE`, `RENAME`, índices, constraints, `ALGORITHM`, `LOCK`, operaciones de partición | Rebuild, bloqueo, validación, orden de columnas y compatibilidad. |
| <a id="mysql-c025"></a>MYSQL-C025 | `DROP TABLE`, `TRUNCATE TABLE`, `RENAME TABLE` | Múltiples tablas, `IF EXISTS`, referencias externas y tablas temporales | DDL, commit implícito, auto_increment y recuperación. |
| <a id="mysql-c026"></a>MYSQL-C026 | `CREATE INDEX`, `DROP INDEX` | `UNIQUE`, `FULLTEXT`, `SPATIAL`, expresiones, prefijos, orden, visibilidad y opciones por motor | Selectividad, cobertura, índices funcionales y límites. |
| <a id="mysql-c027"></a>MYSQL-C027 | `CREATE/ALTER/DROP TABLESPACE` y objetos especiales | Logfile groups, servers, spatial reference systems, resource groups y todas las sentencias DDL del índice | Dependencias del motor, privilegios y exclusiones justificadas por edición. |
| <a id="mysql-c028"></a>MYSQL-C028 | `SELECT` proyección y filtros | `DISTINCT`, expresiones, aliases, `FROM`, `WHERE`, `ORDER BY`, `LIMIT`, `OFFSET` | Orden lógico, NULL, paginación estable y columnas ambiguas. |
| <a id="mysql-c029"></a>MYSQL-C029 | `SELECT` agrupación y joins | `GROUP BY`, `HAVING`, `WITH ROLLUP`, `INNER`, `LEFT`, `RIGHT`, `CROSS`, `NATURAL`, `USING`, `ON` | Cardinalidad, duplicados, filas no relacionadas y ONLY_FULL_GROUP_BY. |
| <a id="mysql-c030"></a>MYSQL-C030 | Subconsultas, CTE y conjuntos | Escalares, correlacionadas, derivadas/lateral según versión; `WITH`, `RECURSIVE`, `UNION`, `INTERSECT`, `EXCEPT` | Materialización, ciclos, duplicados y disponibilidad de cada operador. |
| <a id="mysql-c031"></a>MYSQL-C031 | Ventanas y consultas de bloqueo | `OVER`, `PARTITION BY`, `ORDER BY`, `ROWS`, `RANGE`, `WINDOW`; `FOR UPDATE`, `FOR SHARE`, `NOWAIT`, `SKIP LOCKED` | Frame, aislamiento, bloqueo y colas concurrentes. |
| <a id="mysql-c032"></a>MYSQL-C032 | `INSERT`, `REPLACE` | `VALUES`, `SET`, `SELECT`, varias filas, `IGNORE`, `ON DUPLICATE KEY UPDATE`, `DEFAULT` | Filas afectadas, claves duplicadas, triggers y efectos de REPLACE. |
| <a id="mysql-c033"></a>MYSQL-C033 | `UPDATE`, `DELETE` | `WHERE`, joins, subconsultas, `ORDER BY`, `LIMIT` cuando admita la forma elegida | Consulta previa, cambios masivos y comprobación transaccional. |
| <a id="mysql-c034"></a>MYSQL-C034 | `LOAD DATA`, `LOAD XML`, `SELECT ... INTO` | `LOCAL`, `INFILE`, `OUTFILE`, `DUMPFILE`, campos, líneas, charset y `secure_file_priv` | Archivos cliente/servidor, permisos y escape de contenido. |
| <a id="mysql-c035"></a>MYSQL-C035 | Transacciones | `START TRANSACTION`, `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `RELEASE SAVEPOINT`, `ROLLBACK TO`, `SET TRANSACTION`, `XA` | Autocommit, aislamiento, read only, locks, deadlock y reintento. |
| <a id="mysql-c036"></a>MYSQL-C036 | Bloqueos y administración de sesión | `LOCK TABLES`, `UNLOCK TABLES`, `LOCK INSTANCE FOR BACKUP`, `UNLOCK INSTANCE`, `KILL`, `DO`, `HANDLER` | Bloqueo frente a transacción, sesión propia/ajena y privilegios. |
| <a id="mysql-c037"></a>MYSQL-C037 | `CREATE/ALTER/DROP VIEW` | `OR REPLACE`, `ALGORITHM`, `DEFINER`, `SQL SECURITY`, `WITH CHECK OPTION` | Vista actualizable, seguridad y comprobación de filtros. |
| <a id="mysql-c038"></a>MYSQL-C038 | Procedimientos y funciones | `CREATE`, `ALTER`, `DROP`, `CALL`, parámetros `IN`, `OUT`, `INOUT`, `RETURNS`, characteristics | Invocación, permisos, determinismo y límites por tipo de rutina. |
| <a id="mysql-c039"></a>MYSQL-C039 | Cuerpo de programas almacenados | `DECLARE`, `SET`, `IF`, `CASE`, `LOOP`, `WHILE`, `REPEAT`, `LEAVE`, `ITERATE`, cursores, handlers, `RETURN` | Ámbito, orden de declaración, fin de cursor y control de errores. |
| <a id="mysql-c040"></a>MYSQL-C040 | Errores y diagnostics | `SIGNAL`, `RESIGNAL`, `GET DIAGNOSTICS`, `SQLSTATE`, `MYSQL_ERRNO`, `MESSAGE_TEXT` | Validación de negocio, excepción y diagnóstico original. |
| <a id="mysql-c041"></a>MYSQL-C041 | Triggers | `CREATE TRIGGER`, `DROP TRIGGER`, `BEFORE`, `AFTER`, `INSERT`, `UPDATE`, `DELETE`, `OLD`, `NEW`, `FOLLOWS`, `PRECEDES` | Orden, recursión, restricciones y cambios por fila. |
| <a id="mysql-c042"></a>MYSQL-C042 | Eventos | `CREATE EVENT`, `ALTER EVENT`, `DROP EVENT`, `ON SCHEDULE`, `AT`, `EVERY`, `STARTS`, `ENDS`, `ON COMPLETION`, `ENABLE`, `DISABLE` | Zona horaria, event_scheduler, recurrencia y privilegios del DEFINER. |
| <a id="mysql-c043"></a>MYSQL-C043 | Consultas preparadas | `PREPARE`, `EXECUTE`, `DEALLOCATE PREPARE`, `USING`; APIs de conectores | Parámetros frente a concatenación, tipos y alcance de sesión. |
| <a id="mysql-c044"></a>MYSQL-C044 | Cuentas y roles | `CREATE USER`, `ALTER USER`, `DROP USER`, `RENAME USER`, `CREATE ROLE`, `DROP ROLE`, `SET ROLE`, `SET DEFAULT ROLE` | usuario@host, plugin, expiración, bloqueo y roles activos. |
| <a id="mysql-c045"></a>MYSQL-C045 | Privilegios | `GRANT`, `REVOKE`, `SHOW GRANTS`, `SHOW CREATE USER`, `WITH GRANT OPTION`, `WITH ADMIN OPTION` | Ámbito global/schema/tabla/columna/rutina; catálogo de privilegios estáticos y dinámicos. |
| <a id="mysql-c046"></a>MYSQL-C046 | Metadatos y estado | Catálogo completo `SHOW`: databases/tables/columns/create/index/engines/plugins/variables/status/processlist/warnings/errors y restantes | Distinguir metadatos, contadores y configuración de sesión/global. |
| <a id="mysql-c047"></a>MYSQL-C047 | Configuración SQL | `SET SESSION`, `SET GLOBAL`, `SET PERSIST`, `SET PERSIST_ONLY`, `RESET PERSIST` | Privilegio, reinicio, variables dinámicas/solo lectura y persistencia. |
| <a id="mysql-c048"></a>MYSQL-C048 | Planes y mantenimiento | `EXPLAIN`, `EXPLAIN ANALYZE`, `ANALYZE TABLE`, `CHECK TABLE`, `OPTIMIZE TABLE`, `REPAIR TABLE` | Estimación frente a ejecución real; compatibilidad y coste por motor. |
| <a id="mysql-c049"></a>MYSQL-C049 | Logs y replicación | `FLUSH`, `PURGE BINARY LOGS`, `SHOW BINARY LOGS`, `SHOW BINLOG EVENTS`, `CHANGE REPLICATION SOURCE TO`, `START/STOP/RESET REPLICA`, GTID y Group Replication | Ficha por sentencia y opción; retención, consistencia, retraso y operaciones peligrosas. |
| <a id="mysql-c050"></a>MYSQL-C050 | Catálogos de configuración y metadatos | `my.cnf`/`my.ini`, variables/status, plugins/components; INFORMATION_SCHEMA, performance_schema y sys | Una ficha por variable/tabla/columna relevante; reconciliar índices completos con inclusiones/exclusiones. |
| <a id="mysql-c051"></a>MYSQL-C051 | Conectores y APIs opcionales | C API, Connector/Python, Connector/J, PDO/mysqli, X DevAPI, Router, NDB/Enterprise según alcance elegido | No mezclar comandos SQL con APIs; inventariar paquetes y funcionalidades incluidas o excluidas. |

## Casos integradores que deben desarrollarse

- [ ] **MYSQL-P01.** Diseñar una base de datos relacional con PK/FK/CHECK y demostrar rechazos de datos inválidos.
- [ ] **MYSQL-P02.** Resolver la misma consulta con join, subconsulta y CTE; comparar resultados y plan.
- [ ] **MYSQL-P03.** Probar NULL, collation, zona horaria, overflow y SQL mode con entradas límite.
- [ ] **MYSQL-P04.** Ejecutar transacciones concurrentes, provocar un deadlock y documentar la estrategia de reintento.
- [ ] **MYSQL-P05.** Crear procedimiento, función, trigger y evento; probar SIGNAL y seguridad del DEFINER.
- [ ] **MYSQL-P06.** Crear una cuenta de aplicación con mínimo privilegio y verificar tanto consultas permitidas como denegadas.
- [ ] **MYSQL-P07.** Obtener copia con rutinas/eventos, restaurar en instancia nueva y verificar datos, usuarios y objetos incluidos.
- [ ] **MYSQL-P08.** Recuperar hasta un punto concreto con binlog y demostrar qué transacción queda fuera.
- [ ] **MYSQL-P09.** Diagnosticar consulta lenta, conexión rechazada, acceso denegado, bloqueo y réplica retrasada.
- [ ] **MYSQL-P10.** Reconciliar todos los índices oficiales de sentencias, funciones, operadores, programas, opciones y variables de la versión objetivo.

## Materiales derivados y relaciones

Los materiales nuevos siguen pendientes. Registrar sus enlaces reales y los IDs cubiertos en la ficha de cada unidad; una mención en este guion no acredita que un recurso existente cubra todas sus variantes.

| Formato | Contenido que debe extraerse | Estado |
| --- | --- | --- |
| Guía divulgativa | Modelo mental, conceptos y decisiones de uso. | Pendiente |
| Guía técnica | Sintaxis completa por versión, configuración y laboratorios. | Pendiente |
| Cheatsheet Markdown | Consultas y operaciones con interpretación de salida. | Pendiente |
| Cheatsheet visual | Relaciones, flujos y decisiones; enlazar al detalle técnico. | Pendiente |
| Referencia | Fichas de todas las opciones, argumentos y casos inventariados. | Pendiente |

### Recursos existentes o guiones relacionados

- [XAMPP](xampp.md), [LAMP](lampp.md), [LEMP](lempp.md) y [WordPress](wordpress.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [MySQL 8.4 Reference Manual](https://dev.mysql.com/doc/refman/8.4/en/)
- [SQL Statements](https://dev.mysql.com/doc/refman/8.4/en/sql-statements.html)
- [Functions and Operators](https://dev.mysql.com/doc/refman/8.4/en/functions.html)
- [MySQL Programs](https://dev.mysql.com/doc/refman/8.4/en/programs.html)
- [MySQL Shell](https://dev.mysql.com/doc/mysql-shell/en/)
- [MariaDB documentation para contrastar variantes](https://mariadb.com/docs/)
