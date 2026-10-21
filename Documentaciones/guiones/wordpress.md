# Guion de contenidos · WordPress local y Docker Compose

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

WordPress autogestionado: sitio individual y Multisite, interfaz de administración, fundamentos de desarrollo, WP-CLI y REST API. Distinguir WordPress.org de WordPress.com. Cubrir instalación en XAMPP/LAMP/LEMP y Compose sin asumir equivalencia de permisos, rutas o servidor web. Fijar versiones de core, PHP, motor SQL, WP-CLI, temas y plugins antes de desarrollar los procedimientos.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### WP-T01 · Arquitectura y preparación

- [ ] CMS, core, wp-content, wp-admin, wp-includes, uploads, themes, plugins, mu-plugins y base de datos.
- [ ] Requisitos actuales, compatibilidad, licencia, dominios, DNS, HTTP/HTTPS y URLs home/siteurl.
- [ ] Versionado, checksum, descarga y procedencia; desarrollo/pruebas/producción.

### WP-T02 · Instalación local y configuración

- [ ] Instalación sobre XAMPP, LAMP y LEMP; base/cuenta restringida, permisos y servidor web.
- [ ] Asistente web y WP-CLI; wp-config.php, credenciales, salts, prefijo, charset y collation.
- [ ] Permalinks, rewrite Apache y try_files Nginx; HTTPS y reverse proxy.
- [ ] Ajustes generales, lectura, escritura, medios, comentarios, privacidad y salud del sitio.

### WP-T03 · Contenido y edición

- [ ] Entradas, páginas, estados, revisiones, autosaves, programación, taxonomías, metadatos y comentarios.
- [ ] Biblioteca de medios, formatos, tamaños, accesibilidad, texto alternativo y derechos de uso.
- [ ] Editor de bloques: bloques, patrones, estilos, plantillas y template parts; edición del sitio según tema.
- [ ] Menús/navegación, widgets, shortcodes, embeds, feeds y búsqueda.

### WP-T04 · Administración

- [ ] Usuarios, roles, capabilities, sesiones, application passwords y mínimo privilegio.
- [ ] Instalar/activar/actualizar/retirar temas y plugins; procedencia, licencias y compatibilidad.
- [ ] Exportación/importación de contenido frente a copia completa; cron, correo y tareas en segundo plano.
- [ ] Multisite: activación, red, sitios, dominios/rutas, usuarios, superadmins y plugins de red.

### WP-T05 · Desarrollo y APIs

- [ ] Template hierarchy, tema clásico/de bloques, child themes, functions.php y theme.json.
- [ ] Hooks actions/filters, plugin mínimo, opciones, settings, custom post types y taxonomías.
- [ ] Bloques, metadatos, REST, autenticación, permisos, paginación y webhooks mediante extensiones si se usan.
- [ ] Validación, sanitización, escape, nonces, capabilities, consultas preparadas e internacionalización.
- [ ] Separar APIs públicas de funciones internas y del código de plugins de terceros.

### WP-T06 · Compose

- [ ] Aplicar todas las unidades del [guion común](comun-compose.md).
- [ ] Imagen WordPress Apache frente a FPM con Nginx; motor SQL y WP-CLI como tarea puntual.
- [ ] Variables de las imágenes, secrets/_FILE cuando estén admitidos, bootstrap y volumen ya inicializado.
- [ ] Persistencia de base/archivos, UID/GID, bind mounts, readiness, red interna y puertos locales.

### WP-T07 · Seguridad, rendimiento y recuperación

- [ ] Actualizaciones, copias, TLS, permisos de escritura, XML-RPC/REST según uso y panel de acceso.
- [ ] Caché de página/objetos, OPcache, imágenes, consultas, índices, cron y correo.
- [ ] Migración de URL/dominio/servidor, datos serializados, search-replace y despliegues de prueba.
- [ ] Pantalla blanca, fatal error, plugin incompatible, maintenance, login loop, 404, SQL, permisos y SMTP.
- [ ] Recuperación limpia, checksums, auditoría, retención y eliminación de datos.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="wp-c001"></a>WP-C001 | Administración web | Todas las pantallas, operaciones, campos y permisos del core de la versión objetivo | Crear matriz pantalla-operación-rol; estados vacíos, borrador, papelera, restauración y errores. |
| <a id="wp-c002"></a>WP-C002 | `wp`, `wp help`, `wp cli` | `--info`, `--path`, `--url`, `--ssh`, `--http`, `--user`, `--skip-plugins`, `--skip-themes`, `--require`, `--exec`, `--context`, `--quiet`, `--debug`; cmd-dump y param-dump según versión | Capturar todos los comandos y parámetros; distinguir core, paquetes y extensiones. |
| <a id="wp-c003"></a>WP-C003 | `wp core` | `download`, `config` si existe, `install`, `is-installed`, `version`, `check-update`, `update`, `update-db`, `verify-checksums`, `multisite-install`, `multisite-convert` | Flags por subcomando: versión/locale/force, datos de instalación y checksums; no registrar contraseñas. |
| <a id="wp-c004"></a>WP-C004 | `wp config` | `create`, `get`, `set`, `delete`, `list`, `path`, `edit`, `has`, `shuffle-salts`; `--raw`, `--type`, `--format` donde existan | Constantes, valores literales, salts y conexión; crear configuración no equivale a instalar schema. |
| <a id="wp-c005"></a>WP-C005 | `wp db` | `check`, `clean`, `cli`, `columns`, `create`, `drop`, `export`, `import`, `optimize`, `prefix`, `query`, `repair`, `reset`, `search`, `size`, `tables` | Opciones y argumentos de cada orden; cuenta SQL, alcance, datos y recuperación. |
| <a id="wp-c006"></a>WP-C006 | `wp option` | `add`, `delete`, `get`, `list`, `patch`, `pluck`, `update`; formato/autoload donde proceda | Tipo, estructuras JSON, home/siteurl y cambios que pueden impedir acceso. |
| <a id="wp-c007"></a>WP-C007 | `wp site option`, `wp site` | Opciones de red; `create`, `list`, `get`, `update`, `delete`, `activate`, `deactivate`, `archive`, `unarchive`, `spam`, `unspam`, `empty`, `switch-language` según catálogo | Red frente a sitio; --url, ID, dominio/ruta y operaciones destructivas. |
| <a id="wp-c008"></a>WP-C008 | `wp post` | `create`, `list`, `get`, `update`, `delete`, `edit`, `generate`, `exists`, `url`, meta y term | Tipo/estado/autor/fechas, IDs, stdin, formato y force; revisiones y programación. |
| <a id="wp-c009"></a>WP-C009 | `wp post-type`, `wp taxonomy`, `wp term` | Catálogos y operaciones; term `create`, `list`, `get`, `update`, `delete`, `recount`, meta | Slugs, jerarquía, relaciones y registros de tipos/taxonomías. |
| <a id="wp-c010"></a>WP-C010 | `wp comment` | `create`, `list`, `get`, `update`, `delete`, `approve`, `unapprove`, `spam`, `unspam`, `trash`, `untrash`, meta | Moderación, estado, papelera y borrado definitivo. |
| <a id="wp-c011"></a>WP-C011 | `wp media` | `import`, `regenerate`, `image-size`, `fix-orientation` si existe | Adjuntos, tamaños, metadatos, IDs, originales y uso de disco. |
| <a id="wp-c012"></a>WP-C012 | `wp user` | `create`, `list`, `get`, `update`, `delete`, `generate`, `import-csv`, `add-role`, `remove-role`, `set-role`, `list-caps`, `add-cap`, `remove-cap`, `session`, `application-password`, meta | Identidad, reasignación de contenido, roles, capacidades y credenciales fuera de argv/logs. |
| <a id="wp-c013"></a>WP-C013 | `wp role`, `wp cap`, `wp super-admin` | `list`, `create`, `delete`, `reset`, `add`, `remove` según familia | Rol local frente a superadmin de red y autorización efectiva. |
| <a id="wp-c014"></a>WP-C014 | `wp plugin` | `install`, `activate`, `deactivate`, `update`, `delete`, `uninstall`, `list`, `get`, `status`, `is-active`, `is-installed`, `verify-checksums`, auto-updates, path | Opciones por versión, ZIP/repo, network, force y rollback; desactivar frente a desinstalar. |
| <a id="wp-c015"></a>WP-C015 | `wp theme` | `install`, `activate`, `update`, `delete`, `list`, `get`, `status`, `is-active`, `is-installed`, `enable`, `disable`, auto-updates, mod, path | Tema padre/hijo, red, ajustes y cambios de presentación. |
| <a id="wp-c016"></a>WP-C016 | `wp menu`, `wp widget`, `wp sidebar` | Crear/listar/editar/eliminar menús e ítems; widgets/sidebars según catálogo | Equivalencia con interfaz según tipo de tema; no asumir menús clásicos en temas de bloques. |
| <a id="wp-c017"></a>WP-C017 | `wp rewrite` | `list`, `flush`, `structure`; `--hard` y requisitos cuando existan | Reglas generadas, permisos .htaccess y configuración Nginx externa. |
| <a id="wp-c018"></a>WP-C018 | `wp cron` | `event list`, `event run`, `event schedule`, `event delete`, `schedule list`, `test` y resto del catálogo | Eventos vencidos, zona horaria, recurrencia y cron del sistema. |
| <a id="wp-c019"></a>WP-C019 | `wp cache`, `wp transient` | Cache `get`, `set`, `add`, `replace`, `delete`, `flush`, type/supports; transient `get`, `set`, `delete`, `list` | Persistente/no persistente, expiración y caché de objetos frente a página. |
| <a id="wp-c020"></a>WP-C020 | `wp maintenance-mode` | `activate`, `deactivate`, `is-active`, `status` | Actualización interrumpida y diagnóstico del archivo .maintenance. |
| <a id="wp-c021"></a>WP-C021 | `wp search-replace` | Origen/destino/tablas, `--dry-run`, `--all-tables-with-prefix`, `--network`, `--skip-columns`, `--precise`, `--regex`, `--export` según versión | Datos serializados, GUID, alcance y copia previa. |
| <a id="wp-c022"></a>WP-C022 | `wp export`, `wp import` | Archivo/directorio, autores, filtros y plugins/paquetes requeridos | WXR no incluye por sí solo toda la instalación ni garantiza descarga de adjuntos. |
| <a id="wp-c023"></a>WP-C023 | `wp language`, `wp i18n` | core/plugin/theme; instalación/activación/actualización y make-pot/make-json según paquete | Locale, catálogo, traducciones y herramientas de desarrollo. |
| <a id="wp-c024"></a>WP-C024 | `wp eval`, `wp eval-file`, `wp shell` | Código/archivo, carga de WordPress y opciones de contexto | Código arbitrario solo en entorno autorizado, privilegios y errores. |
| <a id="wp-c025"></a>WP-C025 | `wp package`, `wp cli`, extensiones | Instalar/listar/actualizar/retirar paquetes; alias/cache/update/completions y comandos añadidos | Procedencia, versión y reconciliación con cmd-dump del entorno. |
| <a id="wp-c026"></a>WP-C026 | `wp scaffold`, `wp block`, `wp embed`, `wp rewrite` y resto del catálogo | Subcomandos, argumentos y flags de todas las familias detectadas | Completar inventario sin tratar funciones de terceros como core universal. |
| <a id="wp-c027"></a>WP-C027 | `wp-config.php` | `DB_*`, salts/keys, `$table_prefix`, `WP_HOME`, `WP_SITEURL`, `WP_DEBUG`, `WP_DEBUG_LOG`, `WP_DEBUG_DISPLAY`, `SCRIPT_DEBUG`, `DISALLOW_FILE_EDIT`, `DISALLOW_FILE_MODS`, `WP_MEMORY_LIMIT`, `DISABLE_WP_CRON`, `ALTERNATE_WP_CRON`, `WP_CRON_LOCK_TIMEOUT`, `AUTOSAVE_INTERVAL`, `WP_POST_REVISIONS`, constantes Multisite | Reconciliar catálogo; distinguir constantes reales de nombres abreviados y ajustes de plugins. |
| <a id="wp-c028"></a>WP-C028 | Core hooks y APIs | Actions/filters, Options/Settings/Metadata/HTTP/Filesystem APIs, WP_Query, wpdb, roles/caps, nonces, REST, cron y shortcodes | Ficha por función/hook público del alcance elegido; distinguir catálogo completo de APIs de tutoriales introductorios. |
| <a id="wp-c029"></a>WP-C029 | REST API | `/wp-json/`, namespaces, discovery/schema, posts/pages/media/users/comments/terms/settings/plugins/themes y rutas disponibles | Método, parámetros, context, _fields, paginación, autenticación y permission callback; no asumir rutas protegidas públicas. |
| <a id="wp-c030"></a>WP-C030 | Tema/plugin/bloque | Cabeceras, estructura, template hierarchy, `theme.json`, `block.json`, enqueue, hooks y build si corresponde | Compatibilidad, seguridad, assets y empaquetado; no cambiar tooling sin necesidad. |
| <a id="wp-c031"></a>WP-C031 | Compose imagen WordPress | Apache/FPM, variables WORDPRESS_*, `_FILE` admitidos, WORDPRESS_CONFIG_EXTRA y scripts del entrypoint | Configuración nueva frente a volumen existente; no guardar código/secretos sensibles en Git. |
| <a id="wp-c032"></a>WP-C032 | Compose WP-CLI y operación | Servicio/tarea CLI con acceso a archivos y SQL; todas las unidades CMP | Usuario/UID, working dir, red y bootstrap; CLI no sustituye servidor web. |

## Casos integradores que deben desarrollarse

- [ ] **WP-P01.** Instalar el mismo sitio en XAMPP/LAMP y Compose; comparar rutas, cuentas, URLs y permisos.
- [ ] **WP-P02.** Crear contenido, taxonomías y medios con interfaz y CLI, y comprobar revisiones, estados y accesibilidad.
- [ ] **WP-P03.** Definir roles mínimos, probar una operación permitida y otra denegada, y revocar una application password ficticia.
- [ ] **WP-P04.** Crear tema hijo o plugin mínimo con hook, capacidad y validación; actualizar el padre sin perder cambios.
- [ ] **WP-P05.** Cambiar de dominio/ruta con copia y search-replace --dry-run; verificar serialización, enlaces, medios y login.
- [ ] **WP-P06.** Crear/restaurar una copia completa de archivos y SQL en un proyecto Compose distinto.
- [ ] **WP-P07.** Diagnosticar un plugin que provoca fatal error, un 404 de permalink y un fallo de conexión SQL.
- [ ] **WP-P08.** Activar Multisite en laboratorio y distinguir usuarios/red/sitios, roles y plugins de red.
- [ ] **WP-P09.** Reconciliar todos los comandos/flags de WP-CLI y, según alcance, operaciones del admin, constantes y APIs públicas por versión.

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

- [XAMPP](xampp.md), [LAMP](lampp.md), [LEMP](lempp.md), [MySQL](mysql.md) y [Compose](comun-compose.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [WordPress documentation](https://wordpress.org/documentation/)
- [WordPress developer resources](https://developer.wordpress.org/)
- [WP-CLI command index](https://developer.wordpress.org/cli/commands/)
- [WordPress Code Reference](https://developer.wordpress.org/reference/)
- [WordPress REST API](https://developer.wordpress.org/rest-api/)
- [Docker Official Image: WordPress](https://hub.docker.com/_/wordpress)
