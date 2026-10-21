# Guion de contenidos · Stack XAMPP local y Docker Compose

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

XAMPP como distribución de Apache Friends en Windows/Linux: Apache, MariaDB, PHP, Perl y utilidades realmente incluidas en cada instalador. Registrar inventario y versiones del paquete; no inferir que el componente rotulado «MySQL» es Oracle MySQL. XAMPP está orientado a desarrollo. La variante Compose será una **reproducción funcional por componentes**, con imágenes cuya procedencia y mantenimiento se verifiquen; no se presupone una imagen Docker oficial de XAMPP ni equivalencia binaria con el instalador.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### XAMPP-T01 · Inventario y preparación

- [ ] Componentes y versiones del instalador, requisitos, descarga, integridad, licencia y soporte.
- [ ] Windows/Linux: permisos de instalación, rutas, puertos, firewall, PATH y conflictos con instalaciones previas.
- [ ] Diferencia entre XAMPP en /opt/lampp y LAMP instalado mediante paquetes.

### XAMPP-T02 · Instalación y control local

- [ ] Instalar, iniciar/parar componentes, instalar como servicio cuando exista y verificar tras reinicio.
- [ ] Panel de Windows y script/manager Linux: botones, campos, logs, configuración y administración.
- [ ] Desinstalación y actualización conservando proyectos, configuración y bases de datos.

### XAMPP-T03 · Apache, PHP y base de datos

- [ ] DocumentRoot, VirtualHost, hosts/DNS local, módulos, Directory, rewrite y HTTPS de laboratorio.
- [ ] php.ini, extensiones, límites de subida, sesiones, errores, timezone y diferencias CLI/web.
- [ ] MariaDB incluida, cuentas, privilegios, importación/exportación, copia y restauración.
- [ ] phpMyAdmin: autenticación, acceso local, configuración y límites; Perl y componentes opcionales sin activarlos por rutina.

### XAMPP-T04 · Variante Compose

- [ ] Aplicar todo el [guion común de Compose](comun-compose.md): proyecto, redes, volúmenes, secretos y operación.
- [ ] Comparar paquete monolítico con servicios Apache/PHP, MariaDB y phpMyAdmin separados.
- [ ] Fijar tags/digests compatibles; documentar divergencias frente al paquete XAMPP.
- [ ] Proyectos, configuración y base persistentes; bootstrap solo en volumen vacío y comprobación de disponibilidad.

### XAMPP-T05 · Seguridad, mantenimiento y diagnóstico

- [ ] Acceso de desarrollo en loopback; cuentas, paneles, credenciales y funciones de diagnóstico.
- [ ] Conflictos 80/443/3306, antivirus/UAC, servicio detenido, permisos, ruta o extensión incorrecta.
- [ ] Distinguir error HTTP, PHP y SQL; logs por componente y pruebas de restauración.
- [ ] Migrar a LAMP/LEMP o Compose con componentes mantenidos y configuración adaptada al entorno.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="xampp-c001"></a>XAMPP-C001 | Panel XAMPP Windows | Start, Stop, Service, Shell, Config, Netstat, Logs, Admin, Explorer y opciones disponibles | Estado real, PID, puerto, permisos y persistencia como servicio. |
| <a id="xampp-c002"></a>XAMPP-C002 | Script `/opt/lampp/lampp` | `start`, `stop`, `restart`, `reload`, `status`, comandos por componente y ayuda realmente disponibles | Inventariar acciones de la versión instalada, códigos y logs; no asumir paridad con systemctl. |
| <a id="xampp-c003"></a>XAMPP-C003 | Instalador y manager Linux | Permisos del .run, opciones documentadas, manager y desinstalador de esa versión | Instalación, ruta efectiva, actualización y conservación de datos. |
| <a id="xampp-c004"></a>XAMPP-C004 | Apache de XAMPP | `httpd -v`, `-V`, `-t`, `-S`, `-M`, `-k`; archivos efectivos del paquete | Validación, vhosts, módulos y ruta del ejecutable que se está utilizando. |
| <a id="xampp-c005"></a>XAMPP-C005 | Configuración Apache | `Listen`, `ServerName`, `DocumentRoot`, `Directory`, `Require`, `AllowOverride`, `Options`, `DirectoryIndex`, `VirtualHost`, `ErrorLog`, `CustomLog` | Un sitio, varios sitios, permisos y restricciones de acceso al panel. |
| <a id="xampp-c006"></a>XAMPP-C006 | Rewrite y TLS | `RewriteEngine`, `RewriteCond`, `RewriteRule`, `SSLEngine`, `SSLCertificateFile`, `SSLCertificateKeyFile`, `Redirect` | URLs amigables, HTTPS local y bucles; ampliar directivas en LAMP. |
| <a id="xampp-c007"></a>XAMPP-C007 | PHP CLI del paquete | `-v`, `--ini`, `-m`, `-i`, `-l`, `-r`, `-f`, `-d`, `-n`, `-S`, `-t` | CLI frente a SAPI web; phpinfo temporal y retirada posterior. |
| <a id="xampp-c008"></a>XAMPP-C008 | `php.ini` | `extension`, `zend_extension`, `extension_dir`, `date.timezone`, `memory_limit`, `upload_max_filesize`, `post_max_size`, `max_execution_time`, `display_errors`, `log_errors`, `error_log`, sesiones | Archivo cargado, unidad de medida, precedencia y efecto tras recarga. |
| <a id="xampp-c009"></a>XAMPP-C009 | Base de datos XAMPP | `mysql`/`mariadb`, `mysqldump`/`mariadb-dump`, servicio y `my.ini`/`my.cnf` según paquete | Versión real, binario, socket/TCP, importación y permisos; diferencias con MySQL. |
| <a id="xampp-c010"></a>XAMPP-C010 | phpMyAdmin | `config.inc.php`, `auth_type`, `host`, `port`, socket, `blowfish_secret`, controluser y almacenamiento de configuración si se usa | Autenticación, usuarios SQL, cookies y acceso local; secretos fuera de Git. |
| <a id="xampp-c011"></a>XAMPP-C011 | Perl y componentes opcionales | Versión, módulos, shebang/CGI; FTP, correo y utilidades solo si están incluidas | Identificar función, superficie de red y cómo mantenerlos desactivados si no se necesitan. |
| <a id="xampp-c012"></a>XAMPP-C012 | Rutas, hosts y puertos | `htdocs`, logs, configuración del paquete, archivo hosts, resolución y escucha | No confundir ruta de disco con URL ni localhost del host con el del contenedor. |
| <a id="xampp-c013"></a>XAMPP-C013 | Compose Apache/PHP | Imagen PHP Apache o build propio; `docker-php-ext-install`, `docker-php-ext-enable`, `docker-php-ext-configure` según imagen | Extensiones, vhost, DocumentRoot y diferencias respecto a XAMPP. |
| <a id="xampp-c014"></a>XAMPP-C014 | Compose MariaDB/phpMyAdmin | Variables de la imagen elegida, archivos de inicialización, healthcheck y dependencias | Volumen nuevo frente a inicializado, mínimo privilegio y consola accesible solo donde se necesite. |
| <a id="xampp-c015"></a>XAMPP-C015 | Compose y Dockerfile | Todas las unidades [CMP](comun-compose.md), incluidas flags y claves no enumeradas aquí | Aplicar inventario común y añadir únicamente particularidades de este stack. |
| <a id="xampp-c016"></a>XAMPP-C016 | Copias y actualización | Exportación SQL, proyectos, configuración, verificaciones y restauración en entorno distinto | No sustituir una copia consistente por copiar el datadir en uso. |

## Casos integradores que deben desarrollarse

- [ ] **XAMPP-P01.** Instalar XAMPP local, comprobar versiones reales y publicar un proyecto PHP con conexión SQL sin usar root en la aplicación.
- [ ] **XAMPP-P02.** Crear dos VirtualHosts y HTTPS local; validar resolución, certificado, logs y DocumentRoot.
- [ ] **XAMPP-P03.** Cambiar un límite de PHP y demostrar qué SAPI y qué archivo de configuración lo aplican.
- [ ] **XAMPP-P04.** Resolver puerto ocupado, acceso denegado SQL, error 403 y extensión PHP ausente de forma independiente.
- [ ] **XAMPP-P05.** Reproducir el proyecto en Compose, registrar diferencias y comprobar que los datos sobreviven a la recreación.
- [ ] **XAMPP-P06.** Restaurar copia de archivos/SQL en un entorno limpio y realizar una actualización reversible.

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

- [LAMP](lampp.md), [LEMP](lempp.md), [MySQL](mysql.md), [WordPress](wordpress.md) y [Compose](comun-compose.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [Apache Friends](https://www.apachefriends.org/)
- [XAMPP Windows FAQ](https://www.apachefriends.org/faq_windows.html)
- [XAMPP Linux FAQ](https://www.apachefriends.org/faq_linux.html)
- [Apache HTTP Server 2.4](https://httpd.apache.org/docs/2.4/)
- [PHP manual](https://www.php.net/manual/en/)
- [phpMyAdmin documentation](https://docs.phpmyadmin.net/en/latest/)
- [Docker Compose](https://docs.docker.com/reference/cli/docker/compose/)
- [Docker Official Image: PHP](https://hub.docker.com/_/php)
- [MySQL reference](https://dev.mysql.com/doc/refman/8.4/en/)
