# Guion de contenidos · GitHub

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

GitHub como plataforma: uso personal, colaboración, organizaciones, automatización y administración. Incluir Git como fundamento diferenciado, GitHub CLI (`gh`), interfaz web, GitHub Desktop, REST, GraphQL, webhooks e integraciones. Delimitar GitHub.com, Enterprise Cloud y Enterprise Server; registrar plan, permisos y fecha de corte de las funciones. No confundir Git, GitHub ni GitHub Actions.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### GH-T01 · Fundamentos e instalación

- [ ] Control de versiones distribuido; working tree, index, objetos, referencias, HEAD y remotos.
- [ ] Instalación de Git, gh y Desktop en Windows/Linux; terminal, editor, finales de línea y Unicode.
- [ ] Identidad de autor/committer, configuración local/global/system, firmas y credenciales.

### GH-T02 · Cuenta, autenticación y perfil

- [ ] Cuenta, correos, privacidad, notificaciones, búsqueda, Markdown, archivos adjuntos y accesibilidad.
- [ ] Contraseña, passkeys, 2FA, recuperación, claves SSH, firma, PAT fine-grained/classic, OAuth y GitHub Apps.
- [ ] Alcance, expiración, rotación y revocación; SSO, cuentas administradas y políticas cuando correspondan.

### GH-T03 · Repositorios y trabajo Git

- [ ] Crear, clonar, importar, hacer fork, usar plantillas, archivar, transferir y eliminar repositorios.
- [ ] Commits, staging parcial, ramas, tags, remotos, sincronización y upstream.
- [ ] Merge, rebase, conflictos, revert, reset, reflog, bisect, stash, worktrees y recuperación.
- [ ] Atributos, ignores, hooks, Git LFS, submódulos, sparse checkout, partial/shallow clone y rendimiento.

### GH-T04 · Colaboración

- [ ] Issues, sub-issues y dependencias según disponibilidad; etiquetas, hitos, plantillas y formularios.
- [ ] Pull requests: borrador, revisión, comentarios, sugerencias, checks, conflictos y estrategias de integración.
- [ ] CODEOWNERS, rulesets, protecciones, merge queue y ramas protegidas según plan.
- [ ] Discussions, Wiki, Projects, vistas, campos, iteraciones, filtros y automatizaciones.

### GH-T05 · Distribución y entornos

- [ ] Releases, assets, tags, notas y versionado semántico.
- [ ] Packages, Container Registry, permisos, publicación, limpieza y procedencia.
- [ ] Pages, dominios, DNS, HTTPS, rutas relativas, artefactos y visibilidad.
- [ ] Codespaces, devcontainers, ciclo de vida, secretos, recursos y costes; Desktop y editor web.

### GH-T06 · Actions

- [ ] Workflows, eventos, filtros, expresiones, contextos, variables, jobs, steps y acciones.
- [ ] Runners alojados/autogestionados; permisos, environments y aprobaciones; OIDC.
- [ ] Caché, artefactos, matrices, concurrency, cancelación, reusable workflows y composite actions.
- [ ] Forks y código no confiable; pull_request_target, inyección de expresiones, pinning y supply chain.
- [ ] Minutos, almacenamiento, retención y presupuestos; validar localmente y mantener PR ligeras.

### GH-T07 · Seguridad, gobierno y administración

- [ ] Security policy, advisories, Dependabot, dependencias, code scanning, secret scanning y push protection según disponibilidad.
- [ ] Organizaciones, equipos, roles, colaboradores externos, acceso base, auditoría y políticas.
- [ ] Planes, facturación, cuotas, límites, licencias y derechos de redistribución.
- [ ] Enterprise: identidad, aprovisionamiento, políticas, auditoría, migraciones, copias y recuperación según edición.

### GH-T08 · APIs, aplicaciones y asistencia

- [ ] REST: recursos, verbos, parámetros, permisos, versiones, paginación, rate limits y errores.
- [ ] GraphQL: schema, tipos, queries, mutations, variables, conexiones y coste.
- [ ] Webhooks: eventos, entregas, firma, reintentos e idempotencia; OAuth y GitHub Apps.
- [ ] Copilot y agentes disponibles: permisos, contexto, revisión, privacidad y costes; separar cliente/extensión de gh.
- [ ] Catálogo de gh y extensiones instaladas; comandos añadidos o retirados entre versiones.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="gh-c001"></a>GH-C001 | `git`, `git help`, `git version` | `--version`, `--help`, `help -a`, `help -g`, `--list-cmds` según versión | Capturar catálogo completo; distinguir built-ins, aliases y comandos externos. |
| <a id="gh-c002"></a>GH-C002 | `git config` | `get`, `set`, `list`, `unset` o sintaxis antigua según versión; `--local`, `--global`, `--system`, `--show-origin`, `--show-scope` | Precedencia, identidad, editor, defaults y secretos fuera de logs. |
| <a id="gh-c003"></a>GH-C003 | `git init`, `git clone` | `--bare`, `--initial-branch`; clone `--branch`, `--depth`, `--filter`, `--sparse`, `--recurse-submodules` | Repositorio vacío, clon completo/parcial y remoto inicial. |
| <a id="gh-c004"></a>GH-C004 | `git status`, `git add` | status `--short`, `--branch`, `--porcelain`; add `-A`, `-u`, `-p`, `-N`, `--` | Staging, rutas y cambios nuevos/modificados/borrados. |
| <a id="gh-c005"></a>GH-C005 | `git diff`, `git show` | `--staged`, `--stat`, `--name-only`, `--check`, revisiones, rangos, rutas | Index frente a working tree; contexto y errores de espacios. |
| <a id="gh-c006"></a>GH-C006 | `git commit` | `-m`, `-a`, `--amend`, `--no-edit`, `--fixup`, `--squash`, `-S`, `--author` | Autoría, firma, commits parciales y efectos de reescritura. |
| <a id="gh-c007"></a>GH-C007 | `git log`, `git shortlog`, `git blame` | `--oneline`, `--graph`, `--all`, `--decorate`, `--follow`, `--format`; blame `-L` | Historia, autoría, rangos y movimientos de archivos. |
| <a id="gh-c008"></a>GH-C008 | `git branch`, `git switch`, `git checkout` | branch `-a`, `-r`, `-d`, `-D`, `-m`, `--set-upstream-to`; switch `-c`, `--detach` | Crear/cambiar/retirar ramas; separar checkout de rutas y de referencias. |
| <a id="gh-c009"></a>GH-C009 | `git restore`, `git reset`, `git revert` | restore `--source`, `--staged`, `--worktree`; reset `--soft`, `--mixed`, `--hard`; revert `--no-commit`, `-m` | Deshacer con distinto alcance y recuperar cambios sin perder trabajo. |
| <a id="gh-c010"></a>GH-C010 | `git remote`, `git fetch` | remote `-v`, `add`, `remove`, `rename`, `set-url`, `show`, `prune`; fetch `--all`, `--prune`, `--tags`, `--depth` | URLs, seguimiento, tags y referencias retiradas. |
| <a id="gh-c011"></a>GH-C011 | `git pull`, `git push` | pull `--ff-only`, `--rebase`, `--no-rebase`; push `-u`, `--tags`, `--delete`, `--dry-run`, `--force-with-lease` | Upstream, divergencia y protección del trabajo ajeno; reescritura solo en laboratorio autorizado. |
| <a id="gh-c012"></a>GH-C012 | `git merge`, `git rebase` | merge `--ff-only`, `--no-ff`, `--squash`, `--abort`; rebase `-i`, `--onto`, `--autosquash`, `--continue`, `--abort` | Conflictos, resolución y consecuencias sobre IDs de commit. |
| <a id="gh-c013"></a>GH-C013 | `git cherry-pick`, `git am`, `git apply`, `git format-patch` | Rangos, `--continue`, `--abort`, `--check`, `--3way` donde proceda | Trasladar cambios y series de parches. |
| <a id="gh-c014"></a>GH-C014 | `git stash`, `git clean` | stash `push`, `list`, `show`, `apply`, `pop`, `drop`, `-u`, `-p`; clean `-n`, `-d`, `-f`, `-x` | Guardado temporal y limpieza destructiva con previsualización. |
| <a id="gh-c015"></a>GH-C015 | `git tag`, `git describe`, `git archive` | tag `-a`, `-s`, `-d`, `-v`; archive `--format`, `--prefix`, `--output` | Versiones, firmas, exportación y diferencias con releases. |
| <a id="gh-c016"></a>GH-C016 | `git reflog`, `git bisect`, `git fsck` | reflog `show`, `expire`; bisect `start`, `good`, `bad`, `run`, `reset`; fsck `--full`, `--lost-found` | Recuperación, búsqueda de regresiones y objetos inaccesibles. |
| <a id="gh-c017"></a>GH-C017 | `git worktree`, `git sparse-checkout`, `git submodule` | worktree `add`, `list`, `remove`, `prune`; sparse `init`, `set`, `reapply`; submodule `add`, `update`, `sync`, `--recursive` | Checkouts múltiples, conjuntos parciales y dependencias fijadas. |
| <a id="gh-c018"></a>GH-C018 | `git grep`, `git ls-files`, `git check-ignore`, `git check-attr` | Patrones, `--cached`, `--others`, `--exclude-standard`, `-v`, `-z` según comando | Localizar contenido y diagnosticar reglas de atributos/ignore. |
| <a id="gh-c019"></a>GH-C019 | `git gc`, `git maintenance`, `git repack`, `git prune` | Ayuda de cada operación; automantenimiento y caducidad | Rendimiento, retención y riesgos para recuperación. |
| <a id="gh-c020"></a>GH-C020 | Git plumbing | `cat-file`, `hash-object`, `rev-parse`, `rev-list`, `update-index`, `write-tree`, `commit-tree`, `update-ref`, `symbolic-ref`, `for-each-ref`, `ls-tree`, `ls-remote` | Inventariar cada comando interno del catálogo oficial, opciones y formato de objetos. |
| <a id="gh-c021"></a>GH-C021 | Git configuración y extensiones | `.gitignore`, `.gitattributes`, `.gitmodules`, hooks; LFS `install`, `track`, `ls-files`, `pull`, `push`, `migrate` | Reglas, finales de línea, filtros, archivos grandes y procedencia de extensiones. |
| <a id="gh-c022"></a>GH-C022 | `gh`, `gh help`, `gh version` | `--help`, `--version`, variables `GH_HOST`, `GH_REPO`, `GH_TOKEN`; `--json`, `--jq`, `--template`, `--web` solo donde proceda | Catálogo real de la versión y formato de salida. |
| <a id="gh-c023"></a>GH-C023 | `gh auth` | `login`, `logout`, `status`, `refresh`, `switch`, `setup-git`, `token` | Hosts, scopes, almacenamiento de credenciales; token nunca en evidencias. |
| <a id="gh-c024"></a>GH-C024 | `gh repo` | `create`, `clone`, `fork`, `view`, `list`, `sync`, `edit`, `rename`, `archive`, `unarchive`, `transfer`, `delete`, `set-default`, `deploy-key`, `autolink` según versión | Visibilidad, permisos, ramas, forks y operaciones irreversibles. |
| <a id="gh-c025"></a>GH-C025 | `gh issue` | `create`, `list`, `view`, `edit`, `comment`, `close`, `reopen`, `delete`, `transfer`, `pin`, `unpin`, `lock`, `unlock`, `develop` | Filtros, etiquetas, asignación, hitos y relación con ramas. |
| <a id="gh-c026"></a>GH-C026 | `gh pr` | `create`, `list`, `view`, `checkout`, `diff`, `checks`, `review`, `comment`, `edit`, `ready`, `merge`, `close`, `reopen`, `revert`, `update-branch` según versión | Revisión, estrategias, draft y protecciones; no integrar sin autorización. |
| <a id="gh-c027"></a>GH-C027 | `gh release` | `create`, `list`, `view`, `edit`, `upload`, `download`, `delete`, `delete-asset`, `verify`, `verify-asset` si existen | Tags, assets, notas, prerelease y verificación. |
| <a id="gh-c028"></a>GH-C028 | `gh workflow`, `gh run` | workflow `list`, `view`, `run`, `enable`, `disable`; run `list`, `view`, `watch`, `cancel`, `rerun`, `download`, `delete` | Estado, logs, artefactos y coste de ejecutar o repetir workflows. |
| <a id="gh-c029"></a>GH-C029 | `gh project` | `create`, `list`, `view`, `copy`, `edit`, `close`, `delete`, `field-list`, `field-create`, `field-delete`, `item-list`, `item-add`, `item-create`, `item-edit`, `item-delete`, `item-archive`, `link`, `unlink` | IDs, propietario, campos tipados y automatización. |
| <a id="gh-c030"></a>GH-C030 | `gh api` | `--method`, `--field`, `--raw-field`, `--input`, `--header`, `--paginate`, `--slurp`, `--jq`, `--cache`, `graphql` | Parámetros, JSON, paginación, cuotas y errores; no registrar tokens. |
| <a id="gh-c031"></a>GH-C031 | `gh search` | `repos`, `code`, `commits`, `issues`, `prs`; qualifiers y límites | Búsqueda precisa y resultados incompletos por límites/indexación. |
| <a id="gh-c032"></a>GH-C032 | `gh secret`, `gh variable` | `list`, `set`, `delete`, `get` si existe; ámbitos repo/environment/org | Permisos y precedencia; lectura de nombres frente a revelación de secretos. |
| <a id="gh-c033"></a>GH-C033 | `gh codespace` | `create`, `list`, `view`, `code`, `ssh`, `ports`, `cp`, `logs`, `stop`, `delete`, `rebuild` según versión | Recursos remotos, coste, persistencia y puertos publicados. |
| <a id="gh-c034"></a>GH-C034 | `gh ssh-key`, `gh gpg-key` | `add`, `list`, `delete`; opciones por familia | Claves de autenticación frente a firma y revocación. |
| <a id="gh-c035"></a>GH-C035 | `gh label`, `gh ruleset`, `gh org`, `gh status`, `gh browse` | Catálogo de subcomandos, filtros y ámbitos de la versión | Configuración, políticas, membresía y navegación. |
| <a id="gh-c036"></a>GH-C036 | `gh config`, `gh alias`, `gh extension`, `gh completion` | `get`, `set`, `list`; alias `import`, `delete`; extension `install`, `list`, `upgrade`, `remove`, `exec` según familia | Configuración, aliases, confianza de extensiones y shell. |
| <a id="gh-c037"></a>GH-C037 | `gh attestation` y comandos emergentes | `verify`, `download`, `trusted-root`; `agent-task` y familias del catálogo actual | Procedencia, verificación y funciones dependientes de versión/plan. |
| <a id="gh-c038"></a>GH-C038 | GitHub web / Desktop | Inventariar operaciones de cada sección del temario y sus campos, permisos y confirmaciones | Equivalencias con CLI/API, límites y funciones exclusivas de interfaz. |
| <a id="gh-c039"></a>GH-C039 | REST y GraphQL | Método/ruta/schema, path/query/body, scopes, API version, cursor, ETag, códigos y rate limits | Crear matriz recurso-operación; endpoints de repos, PR, issues, Actions, Pages, paquetes, seguridad, org y enterprise. |
| <a id="gh-c040"></a>GH-C040 | Webhook y GitHub App | Evento/action, payload, firma, installation token, permisos, entrega y reintento | Validar autenticidad, idempotencia, rotación y fallo temporal. |
| <a id="gh-c041"></a>GH-C041 | Workflow YAML | `on`, `permissions`, `env`, `defaults`, `concurrency`, `jobs`, `runs-on`, `needs`, `if`, `strategy`, `matrix`, `steps`, `uses`, `run`, `with`, `secrets`, `outputs`, `environment`, `timeout-minutes` | Inventariar todas las claves y contextos por versión; procedencia de código y permisos efectivos. |

## Casos integradores que deben desarrollarse

- [ ] **GH-P01.** Crear un repositorio de laboratorio, configurar identidad y SSH, hacer primer commit y comprobar autoría.
- [ ] **GH-P02.** Trabajar con rama y PR; introducir y resolver un conflicto, revisar, integrar y retirar la rama.
- [ ] **GH-P03.** Recuperar un commit perdido con reflog; comparar revert, restore y reset en un repositorio descartable.
- [ ] **GH-P04.** Mantener un fork actualizado, mover un cambio con cherry-pick y trabajar con dos worktrees.
- [ ] **GH-P05.** Publicar una release y preparar Pages con rutas válidas; comprobar permisos, assets y HTTPS.
- [ ] **GH-P06.** Diseñar una CI mínima con filtros y cancelación; probar localmente antes de activar ejecuciones.
- [ ] **GH-P07.** Consultar REST y GraphQL con paginación y manejar rate limit, 403, 404 y conflicto concurrente.
- [ ] **GH-P08.** Rotar una credencial ficticia y comprobar acceso mínimo; revisar un flujo de PR de fork sin exponer secretos.
- [ ] **GH-P09.** Reconciliar todos los comandos de Git y gh, todos los endpoints/schema incluidos y operaciones web con fichas por versión.

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

- [SSH](ssh.md) para transporte, autenticación y claves.
- [Plantilla de README existente](../plantillas/readme/README.md).

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [Git reference y catálogo completo](https://git-scm.com/docs)
- [GitHub Docs](https://docs.github.com/en)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub GraphQL API](https://docs.github.com/en/graphql)
- [Actions workflow syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
