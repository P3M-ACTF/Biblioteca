# SSH · Introducción a rsync sobre SSH

[Índice](README.md) · [Laboratorio de transferencias](08-transferencias.md) · [Familia SSH-C033](../../../Documentaciones/guiones/ssh.md#ssh-c033) · [Guion GNU/Linux](../../../Documentaciones/guiones/gnu-linux.md)

Rsync actualiza archivos y árboles utilizando su propio protocolo. Con `host:ruta` y transporte SSH necesita un ejecutable rsync accesible **en ambos extremos**, además de una cuenta que pueda ejecutar el proceso remoto. Tener un subsistema SFTP no satisface ese requisito.

**Referencia:** rsync 3.5.1, tag `v3.5.1`, commit `04355d27b7386d7de0e6bd5e79c556223210f700`. Es una referencia documental, no una versión que se haya instalado aquí. Este documento es introductorio: no desarrolla todo el catálogo de rsync, que corresponde a GNU/Linux. Todos los ensayos funcionales permanecen pendientes.

## 1. Entorno y versiones

Usar cliente y servidor Linux del laboratorio anterior, su cuenta ordinaria y datos propios. Revisar que `ssh-claves.conf` y `ssh-lab-key` siguen seleccionando destino, identidad y host verificado.

```sh
rsync --version
ssh -T -F ./ssh-claves.conf ssh-lab-key 'rsync --version'
```

**Qué estás viendo.** La primera versión es local; la segunda corresponde al ejecutable que resuelve la shell remota. Registrar ambas y sus capacidades. Ejecutar y anotar el retorno de cada orden por separado. Una cuenta SFTP-only, una shell restringida o una ruta sin rsync pueden impedir este transporte.

No es una sesión del daemon rsync: `host::módulo` y `rsync://` tienen otro modo de conexión y autenticación. No cambiar sintaxis pensando que conservan automáticamente SSH.

## 2. Preparar origen y destino

El [laboratorio SFTP/SCP](08-transferencias.md#2-crear-datos-propios-de-laboratorio) crea dos archivos de origen y `xfer-lab-20261022/rsync` bajo el home remoto. Usar exclusivamente esa raíz nueva y conservar el origen inmutable durante las comprobaciones.

La sintaxis de subida seleccionada es:

```text
rsync [opciones] -e "ssh [opciones-ssh]" origen/ [usuario@]host:destino/
```

**Qué estás viendo.** `-e` selecciona el transporte remoto, no un archivo de configuración SSH por sí mismo. En los ejemplos, `ssh -F ./ssh-claves.conf` conserva la política de host/identidad y rsync usa el alias. Las rutas relativas remotas parten del contexto de la cuenta; confirmar ese contexto antes de sincronizar.

No construir el argumento de `-e` concatenando valores no confiables. Los ejemplos usan una ruta de configuración sin espacios y un alias propio; los nombres de archivos con espacios se transmiten dentro de la lista de transferencia.

## 3. Revisar qué se propone copiar

```bash
rsync -av -s --partial-dir=.rsync-partial --itemize-changes --dry-run -e "ssh -F ./ssh-claves.conf" ./xfer-lab-20261022/origen/ ssh-lab-key:xfer-lab-20261022/rsync/
```

**Qué estás viendo.** Se calcula una propuesta sin aplicar cambios de archivos. Puede abrir SSH, autenticar y ejecutar rsync remoto; no es una operación offline ni una medición de velocidad de copia. Deben aparecer las rutas del origen esperado y el destino de este ejercicio.

Antes de quitar `--dry-run` comprobar identidad/destino, barra final, conjunto de archivos y cualquier operación indicada. Un cambio entre ensayo y ejecución puede modificar el resultado: la propuesta no bloquea ambos árboles.

| Elemento utilizado | Argumento/default y efecto limitado a este recorrido |
| --- | --- |
| `-a` / `--archive` | Sin argumento; equivale a `-rlptgoD` en este caso. Recursión, enlaces, permisos, mtime, grupo, propietario y dispositivos/especiales según privilegios. No incluye por sí sola ACL, xattrs, atime/crtime ni conservación de hard links. |
| `-v` / `--verbose` | Sin argumento; aumenta información frente al modo ordinario. Puede repetirse para mayor detalle; no verifica contenido por sí mismo. |
| `-s` / `--secluded-args` | Sin argumento; envía nombres y muchas opciones mediante protocolo. `--protect-args` es el nombre anterior. Requiere compatibilidad y puede ser rechazado por shells restringidas que inspeccionan argumentos. |
| `-e` / `--rsh` | Cadena de transporte, aquí `ssh -F ./ssh-claves.conf`. Sin selección explícita intervienen build/entorno, incluida `RSYNC_RSH`. No es `ssh -e`, que configura escapes. |
| `--dry-run` / `-n` | Sin argumento; propone cambios sin ejecutarlos. No elimina el contacto/autenticación ni garantiza el resultado de una ejecución posterior. |
| `--itemize-changes` / `-i` | Sin argumento; identifica tipo de cambio. No es `ssh -i`, que selecciona identidad, ni un checksum por sí solo. |
| `--partial-dir=DIR` | Directorio para parciales, aquí relativo al destino de cada archivo. Implica `--partial`; si no se pide conservación, los temporales incompletos normalmente se eliminan. No es un temporizador de reanudación. |
| `--checksum` / `-c` | Sin argumento; cambia la selección de actualización desde tamaño/mtime a tamaño/contenido mediante checksums para archivos comparables. Aumenta lectura de disco; no equivale a pedir cifrado ni a producir un manifiesto SHA256. |
| `--delete` | Sin argumento; permite borrar entradas sobrantes en los directorios sincronizados del receptor. No está activo en las copias ordinarias de esta práctica; solo se muestra con dry-run más abajo. |

Los defaults y efectos de rsync pueden depender de otras opciones, del entorno y de ambos builds. Esta tabla explica la invocación seleccionada; rangos y combinaciones de todo su catálogo siguen pendientes del desarrollo GNU/Linux.

## 4. Aplicar la copia revisada

Si la propuesta es la esperada, ejecutar la misma orden retirando únicamente `--dry-run`:

```bash
rsync -av -s --partial-dir=.rsync-partial --itemize-changes -e "ssh -F ./ssh-claves.conf" ./xfer-lab-20261022/origen/ ssh-lab-key:xfer-lab-20261022/rsync/
```

**Qué estás viendo.** Se escriben datos y metadatos en el destino. Leer el retorno inmediatamente con `$?`. El prefijo de `--itemize-changes` describe dirección/tipo y atributos: por ejemplo, una línea de archivo nuevo y una actualización de tiempo no representan la misma operación.

Los campos se interpretan con el esquema `YXcstpoguax` del manual de esta versión. Entre otros: `f` identifica archivo regular, `d` directorio, `L` enlace; `s` se relaciona con tamaño y `t` con tiempo. `+` puede indicar entrada nueva; `.` o un espacio pueden indicar ausencia de cambio según campo/formato. No interpretar una sola letra fuera de su posición ni exigir un prefijo idéntico en todos los escenarios.

La estadística de bytes transferidos no mide cuántos bytes de usuario cambiaron ni demuestra integridad. Un retorno no cero puede corresponder a una transferencia parcial con algunos archivos ya actualizados.

## 5. Barra final y nuevas ejecuciones

Con destino `rsync/` **ya existente**:

| Origen | Forma esperada |
| --- | --- |
| `./origen/` | Copia el contenido directamente a `rsync/`. |
| `./origen` | Copia el directorio por nombre dentro de `rsync/origen/`. |

Comparar primero mediante dry-run. No generalizar estas reglas a scp/SFTP ni confundir la barra final con un filtro de borrado.

Repetir la orden ordinaria sobre los datos estables. Se espera que no haya actualizaciones de contenido innecesarias; pueden seguir existiendo estadísticas y diferencias de metadatos. El quick check normal considera principalmente tamaño y mtime, así que “no propone transferir” no es una prueba criptográfica de identidad.

Para inspección por contenido:

```bash
rsync -av -s --checksum --itemize-changes --dry-run -e "ssh -F ./ssh-claves.conf" ./xfer-lab-20261022/origen/ ssh-lab-key:xfer-lab-20261022/rsync/
```

**Qué estás viendo.** Se recalculan checksums para decidir actualizaciones con coste de lectura en ambos lados. No confundir esa selección previa con la comprobación interna que rsync hace de archivos efectivamente transferidos. Tampoco representa una comprobación externa de todos los metadatos o de entradas extra en destino.

Comparar además hashes SHA256 de los dos archivos conocidos por el procedimiento del [laboratorio](08-transferencias.md#5-comprobar-integridad-y-metadatos), sustituyendo la ruta remota por `rsync/nota con espacios.txt` y `rsync/sub/informe.txt`.

## 6. Parciales y reanudación

`--partial-dir=.rsync-partial` guarda datos incompletos aparte del nombre final y puede reutilizarlos en una ejecución posterior. El directorio debe estar bajo control de la cuenta, sin escritura por terceros. No usar una ubicación pública compartida para esos datos.

Repetir la misma invocación tras una interrupción controlada del proceso concreto puede reutilizar información y completar la copia. No presupone que simplemente se añadan bytes después del tamaño del parcial, como en SFTP reget/reput; la estrategia real depende del modo de rsync, el estado y las opciones. Con `--whole-file` la reutilización de parciales cambia.

No fabricar una interrupción deteniendo sshd o la red del servidor. Para probarla, usar un archivo propio suficientemente grande, registrar ambos procesos/estado y detener solo el intento identificado. El origen debe permanecer estable para interpretar el resultado. Después, repetir, comprobar retornos y verificar el archivo completo.

`-P` en rsync combina `--partial` y `--progress`; no es el puerto `-P` de scp/sftp. Guardar un parcial no crea una copia de seguridad del destino ni garantiza un rollback.

## 7. Revisar borrados sin aplicarlos

La siguiente orden añade **--delete junto con --dry-run**:

```bash
rsync -av -s --delete --itemize-changes --dry-run -e "ssh -F ./ssh-claves.conf" ./xfer-lab-20261022/origen/ ssh-lab-key:xfer-lab-20261022/rsync/
```

**Qué estás viendo.** Solo propone qué sobrantes borraría del destino de laboratorio. Una entrada `*deleting` corresponde a una retirada propuesta, no a una subida. Si no hay sobrantes, puede no aparecer ninguna.

No retirar `--dry-run` de esta demostración. Un sincronizado con borrado exige delimitar raíz, origen completo, filtros, respaldo y recuperación. `--delete` no es una forma de “limpiar errores” y una barra o ruta equivocada puede ampliar sus efectos. Los filtros y variantes de borrado se desarrollarán por separado.

## 8. Retornos, efectos y evidencia

| Retorno de la referencia | Significado |
| --- | --- |
| `0` | Éxito de la operación; comprobar también el resultado esperado. |
| `23` | Transferencia parcial por error; revisar qué se completó y qué no. |
| `24` | Archivos de origen desaparecieron; investigar cambios concurrentes antes de aceptarlo. |
| `12` | Error en el flujo de protocolo; puede requerir revisar proceso remoto y salida inesperada de la shell. |
| `30` | Timeout de envío/recepción. |

Son retornos de rsync, no una tabla para ssh/scp/sftp. Otras causas tienen otros códigos; registrar stderr y fase. Un SSH que autentica pero una shell que imprime texto inesperado por stdout puede impedir el protocolo.

El archivo temporal, el reemplazo por archivo y los metadatos no equivalen a una transacción del árbol completo. Una copia fallida puede haber actualizado parte del conjunto. Para revertir cambios sobre datos previos hace falta su respaldo/snapshot; este laboratorio usa un destino propio nuevo.

- [ ] Versiones/capacidades de ambos rsync y transporte SSH documentados.
- [ ] Dry-run y ejecución coinciden bajo precondiciones estables; barra final y rutas verificadas.
- [ ] Contenido/metadatos y nueva ejecución sin cambios innecesarios comprobados.
- [ ] Parcial, retorno y reanudación controlada comprobados; borrados solo inspeccionados mediante dry-run.

## Fuentes y alcance

- [Manual rsync 3.5.1 fijado](https://github.com/RsyncProject/rsync/blob/04355d27b7386d7de0e6bd5e79c556223210f700/rsync.1.md).
- [Notas de la misma versión](https://github.com/RsyncProject/rsync/blob/04355d27b7386d7de0e6bd5e79c556223210f700/NEWS.md).
- [Proyecto upstream](https://rsync.samba.org/).
- [Familia SSH-C033](../../../Documentaciones/guiones/ssh.md#ssh-c033) y [guion GNU/Linux](../../../Documentaciones/guiones/gnu-linux.md).

Consulta: 22 de octubre de 2026. No se declara completo rsync ni se extrapolan permisos/ACL a un cliente nativo Windows. Su disponibilidad no forma parte de instalar OpenSSH. Quedan pendientes el catálogo íntegro, privilegios/metadatos, filtros, hard links, ACL/xattrs, daemons, estrategias de borrado y todas las pruebas del entorno.
