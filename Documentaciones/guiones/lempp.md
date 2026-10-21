# Guion de contenidos · Stack LEMPP / LEMP local y Docker Compose

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Stack Linux + Nginx + MySQL o MariaDB + PHP-FPM; phpMyAdmin es opcional. «Local» significa instalación nativa Linux. Conservar LEMPP como etiqueta solicitada, sin asumir una segunda P estandarizada. Nginx sirve contenido y comunica con PHP-FPM mediante FastCGI: no ejecuta PHP por sí solo. Separar Nginx Open Source de componentes comerciales y extensiones no instaladas.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### LEMP-T01 · Arquitectura e instalación

- [ ] Flujo HTTP, eventos/workers, estáticos, FastCGI y base de datos.
- [ ] Paquetes, repositorios, versiones, usuarios, rutas, servicios y políticas por distribución.
- [ ] PHP-FPM por socket Unix o TCP; pools, permisos y límites.

### LEMP-T02 · Configuración Nginx

- [ ] Contextos main/events/http/server/location, includes y herencia.
- [ ] Virtual hosts, server_name, listen, root/alias, index y selección del servidor/location.
- [ ] try_files, rewrite, return, redirecciones y URLs amigables; no hay soporte de .htaccess.
- [ ] FastCGI, parámetros, SCRIPT_FILENAME, PATH_INFO y evitar ejecución de uploads.
- [ ] TLS, cabeceras, logs, buffers, límites, compresión, caché, proxy y balanceo cuando se incluyan.
- [ ] Índices completos de directivas, módulos y variables de la versión/compilación.

### LEMP-T03 · PHP, datos y administración

- [ ] Configuración web/CLI, extensiones, OPcache, errores y límites PHP.
- [ ] Schemas, cuentas, charset/collation, secretos y conexión con mínimo privilegio.
- [ ] phpMyAdmin con location/FastCGI y acceso restringido; alternativa CLI.
- [ ] Permisos de contenido, SELinux/AppArmor y escritura de aplicación.

### LEMP-T04 · Compose

- [ ] Cubrir todas las unidades del [guion común](comun-compose.md).
- [ ] Servicios Nginx, PHP-FPM, motor SQL y phpMyAdmin opcional.
- [ ] Código disponible en las rutas esperadas por Nginx y FPM; volúmenes y configuración de solo lectura donde proceda.
- [ ] Red interna, resolución por servicio, puerto de FPM sin publicar, salud y orden de arranque.

### LEMP-T05 · Operación y mantenimiento

- [ ] Validar antes de recargar, graceful reload, logs, rotación y estado.
- [ ] Rendimiento de workers/FPM, caché coherente, sesiones y límites de subida.
- [ ] Copias, restauración, migración Apache↔Nginx y actualización reversible.
- [ ] Diagnóstico de 403/404/413/500/502/504, upstream, sockets y rutas erróneas.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="lemp-c001"></a>LEMP-C001 | `nginx` | `-h`, `-v`, `-V`, `-t`, `-T`, `-q`, `-s`, `-p`, `-c`, `-g`, `-e` según versión | Versión/compilación, validar/volcar configuración, señales y rutas; no registrar secretos del volcado. |
| <a id="lemp-c002"></a>LEMP-C002 | Servicio Nginx | `systemctl status/start/stop/restart/reload/enable/disable nginx`, `journalctl -u nginx` | Estado, persistencia, reload frente a restart y fallos de configuración. |
| <a id="lemp-c003"></a>LEMP-C003 | Nginx contexto y proceso | `user`, `worker_processes`, `worker_connections`, `events`, `http`, `server`, `location`, `include`, `pid`, `error_log` | Ámbito, herencia, concurrencia y límites del SO. |
| <a id="lemp-c004"></a>LEMP-C004 | Nginx selección y contenido | `listen`, `server_name`, `default_server`, `root`, `alias`, `index`, `try_files`, `autoindex`, `types`, `default_type` | Puerto/nombre, orden de locations, barra final, ruta física y 404. |
| <a id="lemp-c005"></a>LEMP-C005 | Nginx redirección y acceso | `return`, `rewrite`, flags, `if`, `map`, `allow`, `deny`, `satisfy`, `auth_basic`, `auth_basic_user_file` | Orden de evaluación, uso correcto de contextos y bucles. |
| <a id="lemp-c006"></a>LEMP-C006 | Nginx FastCGI | `fastcgi_pass`, `fastcgi_index`, `fastcgi_param`, `fastcgi_split_path_info`, `fastcgi_intercept_errors`, `fastcgi_read_timeout`, `fastcgi_buffers` | Socket/TCP, SCRIPT_FILENAME, SCRIPT_NAME y PATH_INFO; upstream inaccesible. |
| <a id="lemp-c007"></a>LEMP-C007 | Nginx TLS y cabeceras | `ssl_certificate`, `ssl_certificate_key`, `ssl_protocols`, `ssl_ciphers`, `ssl_session_cache`, `add_header`, `proxy_set_header` | Nombre/cadena, herencia de cabeceras y separación TLS/proxy. |
| <a id="lemp-c008"></a>LEMP-C008 | Nginx logs, caché y límites | `log_format`, `access_log`, `client_max_body_size`, `sendfile`, `gzip`, `expires`, `fastcgi_cache`, `proxy_cache`, `limit_req`, `limit_conn` y directivas relacionadas | Tiempos, tamaño de subida, contenido privado y coherencia de caché. |
| <a id="lemp-c009"></a>LEMP-C009 | Nginx proxy y upstream | `upstream`, `server` dentro de upstream, `proxy_pass`, `proxy_redirect`, timeouts, buffering y balanceo | URI con/sin barra, cabeceras, disponibilidad y diferencia con fastcgi_pass. |
| <a id="lemp-c010"></a>LEMP-C010 | Catálogo Nginx | Todas las directivas, variables y módulos instalados; flags de compilación | Una ficha por elemento del índice oficial, contexto y disponibilidad; excluir justificadamente módulos ausentes. |
| <a id="lemp-c011"></a>LEMP-C011 | `php-fpm` | `-t`, `-tt`, `-y`, `-c`, `-d`, `-F`, `-D`, `-i`, `-m`, `-v`, `--help` según versión | Configuración efectiva, validación y proceso en host/contenedor. |
| <a id="lemp-c012"></a>LEMP-C012 | Pool PHP-FPM | `user`, `group`, `listen`, `listen.owner`, `listen.group`, `listen.mode`, `listen.allowed_clients`, `pm`, `pm.max_children`, `pm.start_servers`, `pm.max_requests` | Usuario, socket, procesos, memoria y denegaciones. |
| <a id="lemp-c013"></a>LEMP-C013 | PHP-FPM diagnóstico y límites | `request_terminate_timeout`, `request_slowlog_timeout`, `slowlog`, `catch_workers_output`, `clear_env`, `security.limit_extensions`, `php_value`, `php_admin_value` | Bloqueos, variables, sobrescritura de ini y restricciones. |
| <a id="lemp-c014"></a>LEMP-C014 | PHP y extensiones | CLI/ini/OPcache; todas las unidades aplicables del [guion LAMP](lampp.md) | Evitar duplicar fichas; añadir diferencias de SAPI y pools. |
| <a id="lemp-c015"></a>LEMP-C015 | SQL y phpMyAdmin | Motor elegido, servicio, cuenta/schema y configuración de phpMyAdmin | Acceso por red interna, autenticación y rutas estáticas/PHP del panel. |
| <a id="lemp-c016"></a>LEMP-C016 | Compose Nginx/FPM | Imagen/build, configuración, extensiones y código compartido en rutas consistentes | Nginx no encuentra archivo, Primary script unknown, volumen y UID/GID. |
| <a id="lemp-c017"></a>LEMP-C017 | Compose SQL y ciclo de vida | Volúmenes, healthchecks, redes, init, backups; todas las unidades CMP | Persistencia, estado saludable, copias y restauración coherentes. |

## Casos integradores que deben desarrollarse

- [ ] **LEMP-P01.** Publicar un sitio PHP y uno estático con distintos server_name y explicar la selección de location.
- [ ] **LEMP-P02.** Comparar root y alias con rutas reales; resolver un 404 y un Primary script unknown.
- [ ] **LEMP-P03.** Configurar PHP-FPM por socket y por TCP privado; provocar y diagnosticar un 502.
- [ ] **LEMP-P04.** Aplicar HTTPS, límites de subida y URLs amigables sin .htaccess; comprobar códigos y logs.
- [ ] **LEMP-P05.** Crear el despliegue Compose con Nginx/FPM/SQL y verificar rutas, red interna y persistencia.
- [ ] **LEMP-P06.** Migrar un sitio desde Apache, restaurar una copia y medir el efecto de una configuración de caché segura.
- [ ] **LEMP-P07.** Reconciliar catálogo completo de Nginx/FPM y diferencias por compilación, paquete y versión.

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

- [LAMP](lampp.md), [XAMPP](xampp.md), [WordPress](wordpress.md), [MySQL](mysql.md), [GNU/Linux](gnu-linux.md) y [Compose](comun-compose.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [Nginx documentation](https://nginx.org/en/docs/)
- [Nginx directive index](https://nginx.org/en/docs/dirindex.html)
- [Nginx command-line parameters](https://nginx.org/en/docs/switches.html)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [PHP manual](https://www.php.net/manual/en/)
- [phpMyAdmin documentation](https://docs.phpmyadmin.net/en/latest/)
- [Docker Compose](https://docs.docker.com/reference/cli/docker/compose/)
- [Docker Official Image: PHP](https://hub.docker.com/_/php)
- [MySQL reference](https://dev.mysql.com/doc/refman/8.4/en/)
