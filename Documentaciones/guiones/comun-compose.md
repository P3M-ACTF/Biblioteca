# Guion transversal · Docker Compose

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Base compartida de los guiones XAMPP, LAMP, LEMP y WordPress. Cubrir Docker Engine o Docker Desktop según el host, el plugin `docker compose`, la Compose Specification y las imágenes realmente utilizadas. Separar Compose del antiguo ejecutable `docker-compose`; las opciones dependen de la versión del plugin. No se fija ni instala aquí ninguna imagen o versión.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### CMP-T01 · Modelo y entorno

- [ ] Host, daemon, contexto, imagen, contenedor, capa escribible, registro, red y volumen.
- [ ] Linux nativo frente a Docker Desktop/WSL2; permisos, arquitectura y puertos.
- [ ] Instalación, versiones, procedencia de imágenes, tags, digests y licencias.

### CMP-T02 · Definición declarativa

- [ ] YAML, tipos, comillas, rutas relativas y directorio de proyecto.
- [ ] Servicios, build, redes, volúmenes, configs, secrets, profiles, include y fusión de archivos.
- [ ] Interpolación, precedencia de variables y diferencia entre .env, env_file y entorno del contenedor.
- [ ] Dependencias, healthchecks y disponibilidad real; no confundir orden de inicio con servicio listo.

### CMP-T03 · Operación y datos

- [ ] Construir, validar, descargar, iniciar, consultar, entrar, detener, recrear y retirar.
- [ ] Bind mounts frente a volúmenes; UID/GID, permisos y etiquetado SELinux cuando corresponda.
- [ ] Copias coherentes de aplicación y base de datos; restauración probada.
- [ ] Actualización con rollback, recursos, señales, logs, rotación y recuperación.

### CMP-T04 · Seguridad y diagnóstico

- [ ] Publicación en loopback y separación frontend/backend; DNS de servicios y localhost.
- [ ] Usuarios, capacidades, filesystem de solo lectura, secretos y archivos fuera del repositorio.
- [ ] Conflictos de puertos, errores de build, healthcheck fallido, permisos y volumen inicializado.
- [ ] Distinguir desarrollo, pruebas y despliegue persistente; evitar asumir que un ejemplo local es apto para Internet.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="cmp-c001"></a>CMP-C001 | `docker version`, `docker info`, `docker context` | `ls`, `show`, `use`, `inspect`; cliente/servidor/contexto | Identificar daemon y host antes de modificar recursos. |
| <a id="cmp-c002"></a>CMP-C002 | `docker compose` | `--help`, `version`, `-f`, `-p`, `--project-directory`, `--profile`, `--env-file`, `--parallel`, `--progress`, `--dry-run` según versión | Proyecto, mezcla de archivos y soporte real de cada opción. |
| <a id="cmp-c003"></a>CMP-C003 | `docker compose config` | `--quiet`, `--services`, `--images`, `--profiles`, `--environment`, `--no-interpolate`, `--format` según versión | Configuración efectiva y validación; evitar registrar valores sensibles. |
| <a id="cmp-c004"></a>CMP-C004 | `docker compose build` | `--pull`, `--no-cache`, `--build-arg`, `--progress` si la versión lo admite | Caché, reconstrucción, plataforma y fallo de extensión PHP. |
| <a id="cmp-c005"></a>CMP-C005 | `docker compose pull`, `push` | Servicio, política de descarga, `--ignore-pull-failures`; revisar opciones por subcomando | Imágenes disponibles y credenciales del registro. |
| <a id="cmp-c006"></a>CMP-C006 | `docker compose up` | `-d`, `--build`, `--wait`, `--wait-timeout`, `--no-deps`, `--force-recreate`, `--remove-orphans`, `--scale`, `--watch` según versión | Recrear frente a reiniciar; estado saludable y código de salida. |
| <a id="cmp-c007"></a>CMP-C007 | `docker compose create`, `start`, `stop`, `restart` | Servicios, `--timeout`; consultar sintaxis individual | Ciclo de vida y señales; restart no aplica cambios de definición. |
| <a id="cmp-c008"></a>CMP-C008 | `docker compose down`, `rm` | `--volumes`, `--remove-orphans`, `--rmi`; `rm -f -s -v` según subcomando | Diferenciar borrar contenedores, volúmenes y datos; caso destructivo aislado. |
| <a id="cmp-c009"></a>CMP-C009 | `docker compose ps`, `ls`, `top`, `images` | `--all`, `--format`, `--status` donde proceda | Proyecto, contenedores, estado, procesos e imagen efectiva. |
| <a id="cmp-c010"></a>CMP-C010 | `docker compose logs` | `-f`, `--tail`, `--since`, `--timestamps`, `--no-color` | Identificar servicio, arranque, fallo de conexión y reinicios. |
| <a id="cmp-c011"></a>CMP-C011 | `docker compose exec` | `-T`, `--user`, `--workdir`, `--env`, servicio y comando | Terminal interactiva, redirección de SQL y usuario efectivo. |
| <a id="cmp-c012"></a>CMP-C012 | `docker compose run` | `--rm`, `--no-deps`, `--entrypoint`, `--user`, `--service-ports` | Tareas puntuales, WP-CLI e inicialización sin confundirlas con exec. |
| <a id="cmp-c013"></a>CMP-C013 | `docker compose cp`, `port`, `events`, `wait` | Origen/destino; servicio/puerto; `--json`, `--timeout` solo donde existan | Copias, mapeos efectivos y eventos del ciclo de vida. |
| <a id="cmp-c014"></a>CMP-C014 | `docker compose watch`, `publish`, `bridge` | Inventariar disponibilidad y ayuda del plugin elegido | Funciones opcionales o dependientes de versión; justificar inclusión. |
| <a id="cmp-c015"></a>CMP-C015 | `docker image`, `container`, `network`, `volume` | `ls`, `inspect`, `rm`, `prune` por familia; filtros y formato | Recursos externos/huérfanos; alcance destructivo de limpieza. |
| <a id="cmp-c016"></a>CMP-C016 | `docker inspect`, `stats`, `system df` | `--format`, `--no-stream`, `-v` según comando | Mounts, redes, consumo y uso de disco sin exponer secretos. |
| <a id="cmp-c017"></a>CMP-C017 | Compose: identidad y construcción | `name`, `services`, `image`, `build`, `context`, `dockerfile`, `args`, `target`, `platform`, `pull_policy` | Rutas de build, múltiples etapas y selección de arquitectura. |
| <a id="cmp-c018"></a>CMP-C018 | Compose: ejecución | `command`, `entrypoint`, `working_dir`, `user`, `init`, `restart`, `stop_signal`, `stop_grace_period` | PID 1, señales, usuario y política de reinicio. |
| <a id="cmp-c019"></a>CMP-C019 | Compose: configuración | `environment`, `env_file`, `configs`, `secrets`, `profiles`, `extends`, `include` | Precedencia, permisos y diferencias entre secretos de Compose local y otros orquestadores. |
| <a id="cmp-c020"></a>CMP-C020 | Compose: conectividad | `ports`, `expose`, `networks`, `aliases`, `internal`, `external`, `ipam`, `extra_hosts` | Host frente a red interna; la base de datos no necesita puerto publicado para otros servicios. |
| <a id="cmp-c021"></a>CMP-C021 | Compose: almacenamiento | `volumes`, `type`, `source`, `target`, `read_only`, `bind`, `volume`, `tmpfs` | Persistencia, propagación, permisos y datos preexistentes. |
| <a id="cmp-c022"></a>CMP-C022 | Compose: salud y recursos | `depends_on`, `condition`, `healthcheck`, `test`, `interval`, `timeout`, `retries`, `start_period`, `cpus`, `mem_limit`, `deploy` | Disponibilidad, límites y compatibilidad con el modo de ejecución. |
| <a id="cmp-c023"></a>CMP-C023 | Compose: endurecimiento y desarrollo | `cap_drop`, `security_opt`, `read_only`, `pids_limit`, `logging`, `develop`, `watch` | Privilegios mínimos, logs acotados y sincronización local. |
| <a id="cmp-c024"></a>CMP-C024 | Dockerfile | `FROM`, `ARG`, `ENV`, `RUN`, `COPY`, `ADD`, `WORKDIR`, `USER`, `EXPOSE`, `VOLUME`, `HEALTHCHECK`, `ENTRYPOINT`, `CMD`, `STOPSIGNAL`, `LABEL`, `.dockerignore` | Inventariar opciones de cada instrucción; capas, caché, contexto y secretos de build. |

## Casos integradores que deben desarrollarse

- [ ] **CMP-P01.** Validar el archivo, levantar el stack, comprobar HTTP y consulta SQL, reiniciar y demostrar persistencia.
- [ ] **CMP-P02.** Provocar por separado puerto ocupado, contraseña incorrecta, permiso de volumen y dependencia no disponible; explicar los logs.
- [ ] **CMP-P03.** Guardar copia consistente, recrear el despliegue y restaurar en un proyecto distinto; verificar datos y archivos.
- [ ] **CMP-P04.** Cambiar una versión fijada y volver atrás usando la copia y la política de compatibilidad; no suponer downgrade de datos.
- [ ] **CMP-P05.** Contrastar todas las claves de Compose y opciones del plugin elegido, incluidas las no listadas en este inventario inicial.

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

- [Compose Specification](https://docs.docker.com/reference/compose-file/)
- [Docker Compose CLI](https://docs.docker.com/reference/cli/docker/compose/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker CLI](https://docs.docker.com/reference/cli/docker/)
