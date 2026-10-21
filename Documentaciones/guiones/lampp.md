# Guion de contenidos · Stack LAMPP / LAMP local y Docker Compose

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Stack Linux + Apache HTTP Server + MySQL o MariaDB + PHP, con phpMyAdmin como componente opcional explícito. «Local» significa instalación nativa en una máquina física o VM Linux. Conservar LAMPP como nombre de catálogo, sin atribuir una expansión universal a la segunda P. Separar esta instalación de XAMPP para Linux. Incluir Debian/Ubuntu, RHEL/derivadas y Arch con rutas, paquetes y políticas verificadas por versión.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### LAMP-T01 · Arquitectura e instalación nativa

- [ ] Flujo navegador → Apache → PHP/SAPI → base de datos; estáticos frente a dinámicos.
- [ ] Inventario, compatibilidad, repositorios, paquetes, servicios y rutas por distribución.
- [ ] MySQL frente a MariaDB; mod_php frente a PHP-FPM; módulos y MPM compatibles.
- [ ] Arranque, habilitación, firewall, SELinux/AppArmor y prueba de cada componente.

### LAMP-T02 · Apache y publicación

- [ ] Jerarquía de configuración, includes, sitios, módulos, MIME y Directory.
- [ ] VirtualHosts por nombre/IP/puerto; DNS/hosts, DocumentRoot, aliases y logs.
- [ ] Rewrite, redirecciones, autenticación/autorización, TLS, HTTP y reverse proxy cuando se incluya.
- [ ] Catálogo completo de directivas globales y de módulos habilitados; contexto, herencia y valores por versión.

### LAMP-T03 · PHP y aplicación

- [ ] SAPI, ini, extensiones, OPcache, FPM/pools, usuarios y sockets si se usa FPM.
- [ ] Filesystem, propietarios/grupos, escritura de aplicación y mínimo privilegio.
- [ ] Formularios, sesiones, ficheros, errores, conexión PDO/mysqli y consultas parametrizadas.
- [ ] Composer y dependencias como extensión del despliegue; no incorporar un curso completo de PHP por defecto.

### LAMP-T04 · Base de datos y phpMyAdmin

- [ ] Instalar/asegurar motor elegido, crear schema/cuenta y restringir exposición.
- [ ] Configurar conexión por socket/TCP y TLS cuando aplique; charset y collation.
- [ ] phpMyAdmin con autenticación adecuada y acceso restringido; importación/exportación y límites.
- [ ] Derivar sintaxis y administración completas al [guion MySQL](mysql.md), anotando diferencias MariaDB.

### LAMP-T05 · Compose

- [ ] Cubrir todas las unidades del [guion común](comun-compose.md).
- [ ] Variantes Apache+mod_php en un servicio y Apache+PHP-FPM en servicios separados.
- [ ] MySQL/MariaDB y phpMyAdmin separados, red interna y puertos publicados de forma deliberada.
- [ ] Build de extensiones, archivos de configuración, volúmenes, salud y bootstrap de la base.

### LAMP-T06 · Operación y recuperación

- [ ] Logs, estado, métricas, rendimiento, capacidad, cachés y rotación.
- [ ] Copias consistentes, restauración, migración nativo↔Compose y cambio de servidor web.
- [ ] Actualizaciones, seguridad de cabeceras, secretos, permisos y retirada de diagnósticos.
- [ ] Errores 403/404/500/502/503, rewrite, PHP, socket, credenciales y TLS.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="lamp-c001"></a>LAMP-C001 | Paquetes y servicios por distribución | Debian/Ubuntu `apache2`; RHEL/Arch `httpd`; PHP y motor según repositorio; `systemctl` | Inventariar paquete/unidad/ruta/versionado antes de documentar órdenes de instalación. |
| <a id="lamp-c002"></a>LAMP-C002 | `apache2ctl`, `apachectl`, `httpd` | `-v`, `-V`, `-t`, `-S`, `-M`, `-l`, `-L`, `-D`, `-f`, `-d`, `-k` según wrapper | Versión, módulos, vhosts, sintaxis y configuración efectiva. |
| <a id="lamp-c003"></a>LAMP-C003 | Herramientas Debian de Apache | `a2ensite`, `a2dissite`, `a2enmod`, `a2dismod`, `a2enconf`, `a2disconf`; flags documentadas | No extrapolar estos helpers a RHEL/Arch. |
| <a id="lamp-c004"></a>LAMP-C004 | Apache: base y recursos | `ServerRoot`, `Listen`, `ServerName`, `Include`, `IncludeOptional`, `LoadModule`, `User`, `Group`, `Timeout`, `KeepAlive`, `MaxKeepAliveRequests`, MPM | Proceso, sockets, concurrencia y límites. |
| <a id="lamp-c005"></a>LAMP-C005 | Apache: vhosts y filesystem | `VirtualHost`, `DocumentRoot`, `Directory`, `Location`, `Files`, variantes Match, `Alias`, `DirectoryIndex`, `Options`, `AllowOverride` | Contexto, precedencia, symlinks y diferencias URL/ruta de disco. |
| <a id="lamp-c006"></a>LAMP-C006 | Apache: acceso | `Require`, `RequireAll`, `RequireAny`, `RequireNone`, `AuthType`, `AuthName`, `AuthUserFile`, `AuthBasicProvider` | Autenticación/autorización, IP/usuario/grupo y códigos HTTP. |
| <a id="lamp-c007"></a>LAMP-C007 | Apache: rewrite y proxy | `RewriteEngine`, `RewriteCond`, `RewriteRule`, flags; `Redirect`, `ProxyPass`, `ProxyPassReverse`, `ProxyPassMatch`, `SetHandler` | URLs amigables, prefijos, loops, FPM y reverse proxy. |
| <a id="lamp-c008"></a>LAMP-C008 | Apache: TLS y logs | `SSLEngine`, `SSLCertificateFile`, `SSLCertificateKeyFile`, `SSLProtocol`, `SSLCipherSuite`, `SSLVerifyClient`, `ErrorLog`, `LogLevel`, `LogFormat`, `CustomLog`, `Header` | Cadena, nombre del certificado, protocolo, trazabilidad y cabeceras. |
| <a id="lamp-c009"></a>LAMP-C009 | Índices Apache | Índice completo de directivas y módulos habilitados, `htpasswd`, `rotatelogs`, `ab` y programas incluidos | Una ficha por directiva/opción; contexto y disponibilidad; benchmarks solo en laboratorio. |
| <a id="lamp-c010"></a>LAMP-C010 | `php` | `-v`, `-m`, `-i`, `--ini`, `-l`, `-r`, `-f`, `-d`, `-n`, `-S`, `-t`, `--help` y resto del catálogo | CLI/web, extensión, configuración y servidor de desarrollo. |
| <a id="lamp-c011"></a>LAMP-C011 | `php-fpm` si se utiliza | `-t`, `-tt`, `-i`, `-m`, `-v`, `-y`, `-c`, `-d`, `-F`, `-D` según versión | Validar pools, configuración y comportamiento de ejecución. |
| <a id="lamp-c012"></a>LAMP-C012 | PHP/pools y extensiones | `php.ini`, `conf.d`, `extension`, `zend_extension`, `user`, `group`, `listen`, permisos del socket, `pm`, `pm.max_children`, límites y OPcache | Una ficha por directiva incluida y contraste con catálogo completo por SAPI. |
| <a id="lamp-c013"></a>LAMP-C013 | Base de datos y configuración | Instalación, servicio, `bind-address`, socket, TLS, cuentas, privilegios y variables del motor elegido | Separar motor/configuración/cuenta; enlazar todas las unidades aplicables de MySQL. |
| <a id="lamp-c014"></a>LAMP-C014 | phpMyAdmin | Instalación por paquete/archivo/imagen, vhost o alias, `config.inc.php`, `auth_type`, servidores, cookies y almacenamiento opcional | No asumir que phpMyAdmin es parte obligatoria de LAMP ni publicar su panel sin restricción. |
| <a id="lamp-c015"></a>LAMP-C015 | Consulta HTTP y TLS | `curl -I`, `-v`, `--resolve`, `--cacert`; `openssl s_client` con servidor/nombre/cadena | Verificar código, vhost, cabeceras y certificado sin normalizar desactivar validación. |
| <a id="lamp-c016"></a>LAMP-C016 | Compose Apache/PHP | Imagen/build, módulos, extensiones, vhost, UID/GID y rutas; todas las unidades CMP | Variante monolítica web frente a FPM separado; configuración real dentro del contenedor. |
| <a id="lamp-c017"></a>LAMP-C017 | Compose datos y operación | Volúmenes, init SQL, secrets, red, healthcheck, backups y restauración | Contraseña de inicialización no cambia automáticamente una base ya creada. |
| <a id="lamp-c018"></a>LAMP-C018 | SELinux/AppArmor y permisos | Contextos de contenido, escritura, conexión SQL; perfiles y logs de denegación | Resolver la causa sin desactivar controles de acceso. |

## Casos integradores que deben desarrollarse

- [ ] **LAMP-P01.** Instalar stack nativo en una distribución elegida y documentar el contraste de paquetes/rutas en las otras familias.
- [ ] **LAMP-P02.** Publicar dos sitios, uno estático y otro PHP con base de datos y cuenta restringida.
- [ ] **LAMP-P03.** Configurar HTTPS y rewrite; explicar cómo diagnosticar un bucle y un fallo de certificado.
- [ ] **LAMP-P04.** Cambiar de mod_php a FPM en laboratorio y comparar permisos, configuración y logs.
- [ ] **LAMP-P05.** Crear el equivalente Compose, validar PHP/SQL y demostrar persistencia y aislamiento de red.
- [ ] **LAMP-P06.** Restaurar en un proyecto limpio y migrar un sitio entre nativo y Compose conservando datos/URLs.
- [ ] **LAMP-P07.** Completar catálogo de Apache, PHP/FPM y herramientas de las versiones incluidas sin duplicar el catálogo MySQL/Compose.

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

- [XAMPP](xampp.md), [LEMP](lempp.md), [WordPress](wordpress.md), [MySQL](mysql.md), [GNU/Linux](gnu-linux.md) y [Compose](comun-compose.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [Apache HTTP Server 2.4](https://httpd.apache.org/docs/2.4/)
- [PHP manual](https://www.php.net/manual/en/)
- [phpMyAdmin documentation](https://docs.phpmyadmin.net/en/latest/)
- [Docker Compose](https://docs.docker.com/reference/cli/docker/compose/)
- [Docker Official Image: PHP](https://hub.docker.com/_/php)
- [MySQL reference](https://dev.mysql.com/doc/refman/8.4/en/)
- [Apache directive index](https://httpd.apache.org/docs/2.4/mod/directives.html)
