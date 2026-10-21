# SSH · Referencia de claves y agente

[Índice](README.md) · [Práctica de claves](04-claves-y-agente.md) · [Referencia de conexión](03-referencia-conexion.md)

Esta entrega desarrolla **21 opciones de cuatro herramientas y tres directivas de cliente** para el ciclo básico de claves de usuario. Es una selección por tarea: los otros modos de estas herramientas permanecen en el [inventario](../../../Documentaciones/guiones/ssh/README.md).

## Referencia, entorno y estado

| Campo | Alcance |
| --- | --- |
| Producto | OpenSSH Portable 10.6p1, commit a8c72b842423f0774f542d3c2197247c3dd28d74. |
| Consulta | 21 de octubre de 2026. |
| Entorno | Semántica upstream; ejemplos POSIX/Bash salvo indicación. Cliente Windows se contrasta con su build; servidor de la práctica Linux. |
| Requisitos | Herramientas instaladas, carpeta privada de laboratorio, cuenta autorizada, confianza de host verificada y acceso de recuperación. |
| Privilegios | Usuario ordinario sobre sus archivos/agente y autorizaciones de su cuenta; cambios gestionados requieren el administrador correspondiente. |
| Estado | Documentado mediante manuales/código; todos los casos funcionales pendientes. |
| Persistencia | Generación/cambio de frase y autorización modifican archivos; carga/retirada afectan el agente. Las consultas no prueban acceso remoto. |
| Relación | Familias SSH-C007, C012/C013 y C016/C017/C018; introducción a C023/C026. |

Las fichas cubren generación ordinaria, huellas, derivación de pública, protección de privada y operaciones básicas del agente/provisión. **No declaran agotadas las opciones reutilizadas en otros modos**: firma de certificados/datos, KRL, conversión, FIDO/PKCS#11, modos SFTP y todas las restricciones de authorized_keys siguen pendientes. El desarrollo completo de tamaños mediante `ssh-keygen -b` también queda para el bloque criptográfico.

## Formas de invocación de este bloque

```text
ssh-keygen -t tipo [-a rondas] [-C comentario] -f privada
ssh-keygen -l [-E hash] -f publica
ssh-keygen -y -f privada
ssh-keygen -p [-a rondas] -f privada

ssh-agent -s [-t vida]
ssh-agent -k
ssh-add [-t vida] privada ...
ssh-add -l
ssh-add -L
ssh-add -T publica ...
ssh-add -d [publica ... | -]

ssh-copy-id [-n] [-F config] [-o directiva]... [-p puerto]
            [-i [publica]] [usuario@]host
```

**Qué estás viendo.** Son las formas seleccionadas; no una sinopsis de todos los modos. `tipo`, `rondas`, `vida` y las rutas son marcadores. Los corchetes indican opcionales; `...` admite varios argumentos donde lo indica la herramienta. Una bandera mayúscula tiene significado distinto de su minúscula y entre programas no hay equivalencia universal.

| Argumento posicional | Significado y condición |
| --- | --- |
| `ssh-add privada ...` | Carga cada privada; sin rutas busca los nombres predeterminados de su versión. Puede pedir frases y cargar certificados asociados. |
| `ssh-add -T publica ...` | Exige al menos una pública; consulta si el agente puede utilizar su privada correspondiente. |
| `ssh-add -d [publica ...]` | Selecciona identidades a retirar, no archivos a borrar; sin rutas recorre los nombres predeterminados. `-` lee públicas desde stdin. |
| `ssh-copy-id [usuario@]host` | Un destino, obligatorio; puede ser alias del archivo seleccionado. Si falta el usuario, rige la selección del cliente. |
| Forma `ssh-agent comando [argumentos]` | Variante del manual: proporciona entorno al comando y vincula la vida del agente a él. Su desarrollo y pruebas quedan pendientes; no mezclarla con -s/-k. |

Los ejemplos de generación son **alternativas**, no una secuencia para ejecutar repetidamente sobre el mismo nombre. Sustituir `id_ed25519_nueva_lab` por un nombre libre, como se comprueba en la práctica. Introducir frases mediante prompts; las opciones `-N`/`-P` de ssh-keygen existen, pero la gestión segura de secretos en automatización requiere un bloque propio y no se utiliza aquí.

## Reglas comunes para verificar y revertir

Antes de cada caso registrar precondición, versión/build, ruta, identidad y agente seleccionados. Después guardar stdout, stderr y retorno; en Bash `$?`, en PowerShell `$LASTEXITCODE` para ejecutables nativos. Una salida vacía no acredita éxito.

Para `ssh-add` upstream, `0` es éxito, `1` fallo de la operación y `2` imposibilidad de contactar con el agente. La lista vacía puede devolver `1`. En operaciones con múltiples claves hay que comprobar cada una: un fallo parcial no implica que no se haya añadido o retirado ninguna. El resto de herramientas tiene sus propios retornos: conservarlos junto al mensaje en vez de aplicar esta tabla a todas.

| Cambio | Reversión o cierre |
| --- | --- |
| Generar par de laboratorio | Retirar antes cualquier autorización/carga que dependa de él; conservar o eliminar solo sus archivos según el registro. |
| Cambiar protección de privada | Copia previa protegida y recuperable; si hace falta, restaurarla verificando que no reintroduce una protección comprometida. |
| Cargar identidad | Retirarla selectivamente con -d; no vaciar agentes compartidos. |
| Arrancar agente dedicado | Cerrar ese proceso identificado; no usar PID heredado sin comprobarlo. |
| Añadir pública | Retirar sus entradas concretas en todas las fuentes del alcance; conservar el acceso de recuperación y probar conexiones nuevas. |
| Cambiar configuración cliente | Guardar archivo propio o copia previa; comprobar -G antes de conectar. |

La [práctica](04-claves-y-agente.md) desarrolla comparación de huellas, archivos, diagnóstico, rotación y prueba negativa de la clave anterior. Los casos de cada ficha amplían ese recorrido y permanecen sin marcar como ejecutados.

## ssh-keygen

<a id="ssh-k-ssh-keygen-74"></a>

### ssh-keygen -t

Unidad: [SSH-I-SSH-KEYGEN-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-74). Fuente: [ssh-keygen.1:611](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L611).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Tipo obligatorio: ecdsa, ecdsa-sk, ed25519, ed25519-sk, mldsa44-ed25519 o rsa en el manual 10.6p1. |
| Predeterminado | ed25519 si se genera sin seleccionar tipo. |
| Repetición y selección | La última -t asigna el tipo en el parser; usar una selección. |
| Efecto y límites | Genera un par. Los tipos -sk requieren autenticador/proveedor y el híbrido requiere soporte de ambos extremos. No confundir tipo de clave con algoritmo de firma; su uso al firmar certificados RSA queda pendiente del bloque CA. |

```sh
ssh-keygen -t ed25519 -f ./id_ed25519_nueva_lab
```

**Qué estás viendo.** Debe crear privada y pública en una ruta libre y pedir frase de paso. Un tipo desconocido o no disponible requiere revisar el build y política.

Casos pendientes:

- [ ] Tipo admitido: obtener par y huella; tipo desconocido: error sin par útil.
- [ ] Compatibilidad de cada tipo, dispositivo y política: pendiente; no extrapolar éxito de Ed25519.

<a id="ssh-k-ssh-keygen-61"></a>

### ssh-keygen -a

Unidad: [SSH-I-SSH-KEYGEN-OPT-61](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-61). Fuente: [ssh-keygen.1:285](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L285).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Entero obligatorio de rondas del KDF; parser 1…INT_MAX. |
| Predeterminado | 32 rondas al guardar una privada en el formato de referencia. |
| Repetición y selección | La última -a asigna rounds; el coste real impide usar los extremos como valores operativos. |
| Efecto y límites | Aumenta el coste de derivar protección desde la frase en una privada cifrada. No alarga la clave pública. Se usa al generar o con -p; el formato/cifrado puede condicionar su aplicación. |

```sh
ssh-keygen -p -a 32 -f ./id_ed25519_lab
```

**Qué estás viendo.** Reescribe protección de la privada tras los prompts; la pública conserva identidad. Guardar sin frase no proporciona protección KDF útil.

Casos pendientes:

- [ ] 32 en copia de laboratorio cifrada: nuevo desbloqueo correcto y huella estable.
- [ ] 0, negativo, texto, overflow o ausencia: error local; no ensayar valores enormes.

<a id="ssh-k-ssh-keygen-43"></a>

### ssh-keygen -C

Unidad: [SSH-I-SSH-KEYGEN-OPT-43](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-43). Fuente: [ssh-keygen.1:308](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L308).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Comentario obligatorio; citarlo si contiene espacios. |
| Predeterminado | En generación ordinaria se construye un comentario usuario@host cuando no se proporciona. |
| Repetición y selección | La última -C selecciona el comentario; no acumula etiquetas. |
| Efecto y límites | Etiqueta la clave y puede revelar nombres/equipos. -C durante generación no equivale por sí sola a editar un par existente: para ese modo existe -c, todavía pendiente. |

```sh
ssh-keygen -t ed25519 -C "lab-cliente-02" -f ./id_ed25519_nueva_lab
```

**Qué estás viendo.** La pública generada puede incluir la etiqueta. Comparar huella y datos públicos para identificarla; el comentario no autoriza ni revoca.

Casos pendientes:

- [ ] Comentario con espacios: una etiqueta, sin alterar la selección de archivo.
- [ ] Ausencia de argumento: error; cambio de comentario en existente: desarrollar -c por separado.

<a id="ssh-k-ssh-keygen-66"></a>

### ssh-keygen -f

Unidad: [SSH-I-SSH-KEYGEN-OPT-66](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-66). Fuente: [ssh-keygen.1:350](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L350).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria al archivo; su rol depende del modo. |
| Predeterminado | Generación: ruta/prompt del tipo; consulta/modificación: selección o prompt correspondiente. |
| Repetición y selección | La última -f selecciona un archivo; no procesa una lista de ficheros por repetirla. |
| Efecto y límites | Aquí se cubre salida de generación y entrada en -l/-y/-p. En generación se añade .pub para la pública; no crea automáticamente cualquier directorio padre. KRL, known_hosts, firmas y conversiones tienen roles de -f propios pendientes. |

```sh
ssh-keygen -l -E sha256 -f ./id_ed25519_lab.pub
```

**Qué estás viendo.** Consulta la pública indicada. Para generar, usar un nombre libre: confirmar sobrescritura puede destruir una identidad anterior.

Casos pendientes:

- [ ] Ruta relativa/absoluta y con espacios citada: mismo archivo seleccionado según cwd.
- [ ] Padre inexistente, entrada ilegible o nombre ocupado: diagnosticar y cancelar sobrescritura.

<a id="ssh-k-ssh-keygen-6c"></a>

### ssh-keygen -l

Unidad: [SSH-I-SSH-KEYGEN-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-6c). Fuente: [ssh-keygen.1:414](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L414).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; seleccionar archivo mediante -f. |
| Predeterminado | Sin -l no se solicita el modo de mostrar huellas. |
| Repetición y selección | Repetir -l mantiene el indicador en este parser; no combinar modos para deducir prioridad. |
| Efecto y límites | Muestra fingerprints públicas. Puede localizar la pública asociada; en un archivo con varias entradas puede mostrar varias huellas. Con -v añade representación visual, que no sustituye el canal independiente. |

```sh
ssh-keygen -l -E sha256 -f ./id_ed25519_lab.pub
```

**Qué estás viendo.** Tamaño, huella, comentario y tipo. No hay contacto con el servidor ni prueba de que autorice esa pública.

Casos pendientes:

- [ ] Pública válida y archivo con varias entradas: identificar la huella concreta.
- [ ] Archivo inválido/ausente: error de lectura/formato; no interpretar una etiqueta como huella.

<a id="ssh-k-ssh-keygen-45"></a>

### ssh-keygen -E

Unidad: [SSH-I-SSH-KEYGEN-OPT-45](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-45). Fuente: [ssh-keygen.1:322](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L322).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Hash obligatorio; interfaz documentada: sha256 o md5. |
| Predeterminado | sha256 para fingerprints. |
| Repetición y selección | La última -E fija el algoritmo de huella; el parser lo valida con el registro de hashes del build. |
| Efecto y límites | Cambia la representación de la huella, no la clave ni su algoritmo de firma. La lista pública del manual es el contrato descrito aquí; no prometer otros nombres solo porque un build los reconozca. |

```sh
ssh-keygen -l -E sha256 -f ./id_ed25519_lab.pub
```

**Qué estás viendo.** Comparar referencias con el mismo hash. MD5 y SHA256 de la misma pública tienen textos diferentes.

Casos pendientes:

- [ ] sha256 y md5 sobre la misma pública: conservar la misma identidad, representaciones distintas.
- [ ] Nombre desconocido o argumento ausente: error local; preferir SHA256 en la práctica.

<a id="ssh-k-ssh-keygen-79"></a>

### ssh-keygen -y

Unidad: [SSH-I-SSH-KEYGEN-OPT-79](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-79). Fuente: [ssh-keygen.1:820](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L820).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; privada seleccionada mediante -f. |
| Predeterminado | Sin -y no se solicita la derivación de pública. |
| Repetición y selección | Indicador repetido sin acumulación; no mezclar modos. |
| Efecto y límites | Lee una privada OpenSSH y escribe la pública en stdout. Puede pedir frase de paso; no reconstruye la privada desde la pública ni instala nada. |

```sh
ssh-keygen -y -f ./id_ed25519_lab
```

**Qué estás viendo.** Tipo y base64 deben corresponder a la .pub. La ausencia/diferencia de comentario no implica otra clave.

Casos pendientes:

- [ ] Privada cifrada y frase correcta: pública derivada coincidente.
- [ ] Frase errónea, archivo público como entrada o formato no admitido: fallo; no sobrescribir la privada al redirigir stdout.

<a id="ssh-k-ssh-keygen-70"></a>

### ssh-keygen -p

Unidad: [SSH-I-SSH-KEYGEN-OPT-70](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-keygen-opt-70). Fuente: [ssh-keygen.1:544](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1#L544).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; -f selecciona la privada, -a puede fijar rondas. |
| Predeterminado | Sin -p no se solicita el cambio de protección de una privada existente. |
| Repetición y selección | Indicador idempotente en el parser; una sola operación sobre la ruta elegida. |
| Efecto y límites | Solicita frase anterior y dos nuevas, y reescribe la privada; admite cambiar cifrado/KDF en modos compatibles. Su uso para requisitos FIDO mediante -O se mantiene pendiente. No rota la pública ni retira copias previas. |

```sh
ssh-keygen -p -a 32 -f ./id_ed25519_lab
```

**Qué estás viendo.** La huella pública queda igual; comprobar nueva carga sin una identidad antigua ya desbloqueada en el agente.

Casos pendientes:

- [ ] Cambio correcto en copia recuperable: nueva frase funciona y pública conserva huella.
- [ ] Frase previa incorrecta, escritura impedida o cancelación: registrar fallo y revisar archivo antes de reintentar.

## ssh-add

<a id="ssh-k-ssh-add-6c"></a>

### ssh-add -l

Unidad: [SSH-I-SSH-ADD-OPT-6C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-add-opt-6c). Fuente: [ssh-add.1:232](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L232).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; consulta el agente accesible. |
| Predeterminado | Sin un modo, ssh-add carga identidades de sus archivos predeterminados o los indicados. |
| Repetición y selección | Repetir -l o combinarla con -L se rechaza en el parser 10.6p1; elegir una consulta. |
| Efecto y límites | Lista huellas de identidades del agente, no de todos los archivos del disco. No autentica contra el servidor. |

```sh
ssh-add -l
```

**Qué estás viendo.** Lista de huellas con identidad cargada; lista vacía y agente inaccesible son resultados diferentes. Upstream: vacío puede devolver 1, sin contacto 2.

Casos pendientes:

- [ ] Agente dedicado vacío y con una identidad: distinguir lista/retorno.
- [ ] -l -l y -l -L: error local de selección, distinto de ausencia de agente.

<a id="ssh-k-ssh-add-4c"></a>

### ssh-add -L

Unidad: [SSH-I-SSH-ADD-OPT-4C](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-add-opt-4c). Fuente: [ssh-add.1:224](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L224).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | Sin modo de lista, la operación ordinaria es carga de identidades. |
| Repetición y selección | Una sola -L; repetición o mezcla con -l se rechaza. |
| Efecto y límites | Lista públicas completas representadas por el agente. Puede exponer comentarios/asociaciones; no exporta las privadas ni garantiza que un host las acepte. |

```sh
ssh-add -L
```

**Qué estás viendo.** Tipo, base64 y comentario públicos por entrada. Comparar con pública/huella del ejercicio; no instalar todas por defecto.

Casos pendientes:

- [ ] Varias identidades: identificar una sin confundir su comentario con confianza.
- [ ] Vacío/inaccesible y repetición de modo: registrar salida y retorno por separado.

<a id="ssh-k-ssh-add-74"></a>

### ssh-add -t

Unidad: [SSH-I-SSH-ADD-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-add-opt-74). Fuente: [ssh-add.1:260](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L260).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Tiempo obligatorio: segundos o unidades/composición de sshd_config, por ejemplo 10m; convtime produce segundos enteros no negativos, hasta INT_MAX. |
| Predeterminado | Sin restricción de vida positiva de ssh-add se aplica la política/default del agente. |
| Repetición y selección | La última -t selecciona la vida solicitada para las cargas de esa invocación. |
| Efecto y límites | Pide caducidad al agente al cargar identidades. En este código 0 no codifica una restricción de vida: no significa borrar inmediatamente ni garantiza superar el default del agente. No es el TTL del proceso ni la validez en authorized_keys. |

```sh
ssh-add -t 10m ./id_ed25519_lab
```

**Qué estás viendo.** Debe cargar la identidad y anunciar el límite cuando sea aceptado. Comprobar consulta/firma tras el plazo; no deducirlo solo del mensaje.

Casos pendientes:

- [ ] Vida corta deliberada en agente dedicado: identidad deja de estar disponible tras el plazo.
- [ ] 0, negativo, tiempo inválido y límite de conversión: distinguir semántica/errores; contrastar agente no upstream.

<a id="ssh-k-ssh-add-64"></a>

### ssh-add -d

Unidad: [SSH-I-SSH-ADD-OPT-64](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-add-opt-64). Fuente: [ssh-add.1:112](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L112).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; admite rutas públicas posicionales, o - para públicas por stdin. |
| Predeterminado | Sin -d, las rutas posicionales se usan para cargar privadas. |
| Repetición y selección | Repetir -d mantiene el modo; varias identidades se expresan mediante varias rutas. |
| Efecto y límites | Retira claves/certificados seleccionados del agente. Sin rutas intenta las identidades predeterminadas; si no encuentra pública en una ruta, prueba añadiendo .pub. No borra archivos ni autorizaciones remotas. |

```sh
ssh-add -d ./id_ed25519_lab.pub
```

**Qué estás viendo.** Comprobar que desaparece esa huella y permanecen las demás. Evitar -D en un agente compartido: retira todas las identidades.

Casos pendientes:

- [ ] Dos identidades en agente: retirar una y conservar la otra.
- [ ] Identidad ausente, archivo inválido y entrada - controlada: registrar error/resultado sin inferir revocación.

<a id="ssh-k-ssh-add-54"></a>

### ssh-add -T

Unidad: [SSH-I-SSH-ADD-OPT-54](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-add-opt-54). Fuente: [ssh-add.1:256](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1#L256).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento de opción; requiere una o más rutas de públicas posicionales. |
| Predeterminado | Sin -T no se solicita la prueba de firma/verificación. |
| Repetición y selección | Indicador; usar una -T y varias rutas para probar varias claves. |
| Efecto y límites | Solicita operaciones de firma y verifica si son utilizables las privadas correspondientes en el agente. Puede activar restricciones de confirmación/dispositivo. No prueba una cuenta ni se conecta a un servidor. |

```sh
ssh-add -T ./id_ed25519_lab.pub
```

**Qué estás viendo.** Puede no haber salida en éxito; leer retorno. Upstream: 0 éxito, 1 fallo de operación, 2 agente inaccesible.

Casos pendientes:

- [ ] Pública correspondiente cargada: firma/verificación satisfactoria.
- [ ] Sin ruta, pública no cargada, archivo inválido o agente bloqueado: fallo con causa diferenciada.

## ssh-agent

<a id="ssh-k-ssh-agent-73"></a>

### ssh-agent -s

Unidad: [SSH-I-SSH-AGENT-OPT-73](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-agent-opt-73). Fuente: [ssh-agent.1:199](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L199).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; modo de salida para shell Bourne. |
| Predeterminado | Sin comando, el estilo de salida se elige según SHELL; -s lo fija explícitamente. |
| Repetición y selección | Repetir -s conserva el estilo en el parser; incompatible con -c y con la forma comando en este código. |
| Efecto y límites | Arranca un agente POSIX y emite asignaciones de entorno; ejecutarlo sin evaluar/capturar no actualiza por sí solo la terminal padre. Las rutas de socket del default 10.6p1 no se extrapolan a versiones anteriores. |

```sh
ssh-agent -s -t 15m
```

**Qué estás viendo.** Salida con SSH_AUTH_SOCK/SSH_AGENT_PID y mensaje. Usar el bloque aislado de la práctica para interpretar únicamente salida de un ejecutable local de confianza.

Casos pendientes:

- [ ] Captura/evaluación en subshell: agente propio accesible, entorno exterior conservado.
- [ ] -s -c, forma con comando o arranque fallido: detener el flujo sin operar sobre el agente previo.

<a id="ssh-k-ssh-agent-6b"></a>

### ssh-agent -k

Unidad: [SSH-I-SSH-AGENT-OPT-6B](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-agent-opt-6b). Fuente: [ssh-agent.1:130](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L130).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento; necesita SSH_AGENT_PID válido. |
| Predeterminado | Sin -k se usa la forma de arranque seleccionada. |
| Repetición y selección | Repetir -k no elige varios agentes; el objetivo viene del entorno. |
| Efecto y límites | En POSIX envía terminación al PID indicado y emite órdenes de limpieza del entorno. No es una orden para parar el servicio Windows ni para terminar todos los agentes del usuario. |

```sh
ssh-agent -k
```

**Qué estás viendo.** Solo ejecutar para un agente propio identificado. Evaluar su salida local si también se quiere limpiar las variables de esa shell; el subshell del laboratorio desaparece al terminar.

Casos pendientes:

- [ ] Agente dedicado identificado: proceso terminado y socket ya no utilizable.
- [ ] PID ausente/inválido, ya terminado o de otro proceso: no lanzar señales a ciegas; revisar entorno.

<a id="ssh-k-ssh-agent-74"></a>

### ssh-agent -t

Unidad: [SSH-I-SSH-AGENT-OPT-74](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-agent-opt-74). Fuente: [ssh-agent.1:209](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1#L209).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Vida predeterminada obligatoria, en segundos o formato temporal; parser convtime, 0…INT_MAX segundos. |
| Predeterminado | Sin límite positivo, vida máxima predeterminada ilimitada para identidades ordinarias en upstream. |
| Repetición y selección | La última -t fija el default del agente. |
| Efecto y límites | Asigna vida a identidades cargadas sin restricción propia. Una vida de ssh-add la sustituye. Cero corresponde a sin caducidad predeterminada; no apaga el agente al pasar ese tiempo. |

```sh
ssh-agent -s -t 15m
```

**Qué estás viendo.** Se inicia el proceso; comprobar caducidad con una carga sin -t y compararla con otra que sí lo tenga.

Casos pendientes:

- [ ] Default corto y carga con vida explícita distinta: comprobar ambos plazos.
- [ ] 0 y argumento inválido/negativo: separar ausencia de límite de error del parser.

## ssh-copy-id

<a id="ssh-k-ssh-copy-id-69"></a>

### ssh-copy-id -i

Unidad: [SSH-I-SSH-COPY-ID-OPT-69](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-copy-id-opt-69). Fuente: [contrib/ssh-copy-id.1:71](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L71).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta opcional a pública; si no acaba en .pub el script la añade; con -i sin ruta selecciona default_ID_file. |
| Predeterminado | Sin -i usa públicas listadas por ssh-add -L si existen; si no, la id*.pub más reciente bajo ~/.ssh, excluyendo *-cert.pub. |
| Repetición y selección | Repetir -i se rechaza en el script fijado. Un archivo puede contener varias públicas. |
| Efecto y límites | Selecciona qué públicas se autorizarán, no qué privada autoriza el acceso inicial. Puede necesitar la privada correspondiente para detectar presencia; -f cambia ese comportamiento y queda fuera del recorrido. |

```sh
ssh-copy-id -n -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** Identificar exactamente las públicas y destino. Pasar siempre la ruta evita la ambigüedad del argumento opcional y selección desde el agente.

Casos pendientes:

- [ ] Ruta pública explícita y nombre sin .pub: misma selección prevista; privada ausente afecta comprobación.
- [ ] -i repetida, ruta ilegible, pública vacía y -i sin ruta: comprobar error/selección, sin instalar otra identidad por accidente.

<a id="ssh-k-ssh-copy-id-6e"></a>

### ssh-copy-id -n

Unidad: [SSH-I-SSH-COPY-ID-OPT-6E](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-copy-id-opt-6e). Fuente: [contrib/ssh-copy-id.1:93](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L93).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | No consume argumento. |
| Predeterminado | Sin -n se instala la lista pendiente por el mecanismo elegido. |
| Repetición y selección | Repetición mantiene dry-run en el script. |
| Efecto y límites | Imprime qué públicas añadiría sin escribir authorized_keys. Sigue pudiendo conectar, ejecutar comprobaciones y pedir autenticación; no es análisis offline ni garantía de ausencia de registros remotos. |

```sh
ssh-copy-id -n -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** Revisar lista y mensajes de detección; si todas ya permiten entrar puede indicar que no queda ninguna por instalar.

Casos pendientes:

- [ ] Pública nueva frente a ya autorizada: cambia la lista pendiente sin escritura de autorizaciones.
- [ ] Host no confiable, acceso inicial fallido o red ausente: dry-run también puede fallar.

<a id="ssh-k-ssh-copy-id-46"></a>

### ssh-copy-id -F

Unidad: [SSH-I-SSH-COPY-ID-OPT-46](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-copy-id-opt-46). Fuente: [contrib/ssh-copy-id.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L110).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Ruta obligatoria de configuración cliente, transmitida a ssh/sftp. |
| Predeterminado | Sin -F rige la configuración normal de las herramientas invocadas. |
| Repetición y selección | El script conserva las ocurrencias para pasarlas; el parser de ssh decide la selección efectiva de -F, la última en la referencia fijada. |
| Efecto y límites | Permite usar alias/destino/archivo de confianza de laboratorio. No selecciona la ruta de authorized_keys ni valida que el servidor la consulte. |

```sh
ssh-copy-id -n -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** Archivo y alias deben resolver el destino ya verificado. Revisar con ssh -F archivo -G antes de instalar.

Casos pendientes:

- [ ] Alias en archivo propio y configuración sin ese alias: resolución/destino distintos.
- [ ] Archivo inaccesible, argumento ausente y ruta con espacios citada: diagnóstico local.

<a id="ssh-k-ssh-copy-id-70"></a>

### ssh-copy-id -p

Unidad: [SSH-I-SSH-COPY-ID-OPT-70](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-copy-id-opt-70). Fuente: [contrib/ssh-copy-id.1:108](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L108).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Puerto obligatorio, enviado a la herramienta de conexión. |
| Predeterminado | El puerto resultante de ssh_config o 22 sin otra selección. |
| Repetición y selección | En este script la última -p asigna SSH_PORT; no trasladar esa regla a ssh -p, que conserva la primera asignación efectiva. |
| Efecto y límites | Selecciona el puerto de destino; no cambia escucha/firewall. La validación final corresponde al cliente invocado. |

```sh
ssh-copy-id -n -p 2222 -F ./ssh-lab.conf -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** Se comprueba el servidor correcto en ese puerto. Un rechazo/timeout no se corrige instalando más públicas.

Casos pendientes:

- [ ] Puerto correcto y otro sin escucha: diferenciar transporte de autenticación.
- [ ] Dos -p: inspeccionar el script y contrastar en laboratorio; valor inválido: rechazo del cliente.

<a id="ssh-k-ssh-copy-id-6f"></a>

### ssh-copy-id -o

Unidad: [SSH-I-SSH-COPY-ID-OPT-6F](../../../Documentaciones/guiones/ssh/cli.md#ssh-i-ssh-copy-id-opt-6f). Fuente: [contrib/ssh-copy-id.1:110](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1#L110).

| Propiedad | Comportamiento |
| --- | --- |
| Argumento y valores | Asignación obligatoria de directiva cliente, correctamente citada si incluye espacios. |
| Predeterminado | Sin -o rige la configuración de los clientes invocados y opciones internas del script. |
| Repetición y selección | Puede repetirse; se transmite la secuencia y la directiva decide si acumula o conserva la primera asignación. |
| Efecto y límites | Configura ssh/sftp; no es una directiva de sshd. El script añade opciones para comprobar identidades, por lo que no deducir toda precedencia solo de la línea visible. |

```sh
ssh-copy-id -n -F ./ssh-lab.conf -o ConnectTimeout=5 -i ./id_ed25519_lab.pub ssh-lab
```

**Qué estás viendo.** Revisar el efecto de la directiva, no solo el éxito del script. No utilizar opciones para omitir confianza del host.

Casos pendientes:

- [ ] Dos directivas distintas: ambas se transmiten; repetición escalar/acumulativa: reglas diferentes.
- [ ] Directiva desconocida, valor no válido o quoting incorrecto: error antes de completar la instalación.

## Directivas de cliente

<a id="ssh-k-cfg-identityfile"></a>

### IdentityFile

Unidad: [SSH-I-CLIENT-IDENTITYFILE](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-identityfile). Fuente: [ssh_config.5:1200](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1200).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Ruta a privada o pública cuya privada correspondiente esté en el agente; valor especial none. Admite tilde y tokens del manual. |
| Predeterminado upstream | Sin rutas explícitas: ~/.ssh/id_rsa, id_ecdsa, id_ecdsa_sk, id_ed25519, id_ed25519_sk e id_mldsa44_ed25519. |
| Repetición y selección | Acumulativa, con detección de duplicados; límite de 100 identidades en upstream. No sustituye una lista ya existente por añadir -o IdentityFile. |
| Efecto y límites | Selecciona candidatas. Con ninguna CertificateFile explícita puede asociar el archivo -cert.pub. none no desactiva por sí solo el agente. El orden de oferta puede depender del agente y certificados. |

```sh
ssh -F none -G -o IdentityFile=./id_ed25519_lab alumno@192.0.2.10
```

**Qué estás viendo.** La consulta debe mostrar la identidad elegida, pero no acredita que el archivo exista ni esté autorizado. Relacionar con -i e IdentitiesOnly del bloque anterior.

Casos pendientes:

- [ ] Dos rutas distintas: ambas candidatas, incluso si una procede de CLI y otra del archivo.
- [ ] none con agente y pública seleccionada cuya privada esté en agente: separar selección de archivo y uso del agente.

<a id="ssh-k-cfg-identityagent"></a>

### IdentityAgent

Unidad: [SSH-I-CLIENT-IDENTITYAGENT](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-identityagent). Fuente: [ssh_config.5:1171](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L1171).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | Ruta al socket Unix, none, literal SSH_AUTH_SOCK o referencia de variable admitida por el manual; tilde, tokens y expansión permitida. |
| Predeterminado upstream | La localización habitual del agente procede de SSH_AUTH_SOCK en POSIX si no se sustituye. |
| Repetición y selección | Primera asignación efectiva; no acumula agentes. |
| Efecto y límites | Sustituye el socket seleccionado; none desactiva uso del agente en esa conexión. No termina su proceso, retira identidades ni cambia su autorización remota. Transporte del agente Windows requiere contraste propio. |

```sh
ssh -F ./ssh-claves.conf -G -o IdentityAgent=none ssh-lab-key
```

**Qué estás viendo.** Se espera identityagent none. La forma IdentityAgent=SSH_AUTH_SOCK de la práctica pide leer esa variable al cliente, sin expansión accidental por el shell.

Casos pendientes:

- [ ] none frente a SSH_AUTH_SOCK en el agente dedicado: acceso a privada directa frente a firma del agente.
- [ ] Variable ausente, nombre inválido y socket inaccesible: distinguir parser, selección y fallo de comunicación.

<a id="ssh-k-cfg-addkeystoagent"></a>

### AddKeysToAgent

Unidad: [SSH-I-CLIENT-ADDKEYSTOAGENT](../../../Documentaciones/guiones/ssh/configuracion.md#ssh-i-client-addkeystoagent). Fuente: [ssh_config.5:313](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5#L313).

| Propiedad | Comportamiento |
| --- | --- |
| Valores y argumentos | no, yes, ask, confirm [tiempo] o tiempo; parser también acepta false/true para no/yes. Tiempo con gramática sshd_config; no añadir un segundo argumento a yes/ask/no. |
| Predeterminado upstream | no. |
| Repetición y selección | Primera asignación efectiva, incluida su vida asociada; no acumula políticas. |
| Efecto y límites | Añade automáticamente una privada cargada desde archivo a un agente ya operativo. yes usa su vida predeterminada; tiempo solicita vida concreta; ask pide confirmación con SSH_ASKPASS para añadir; confirm exige confirmación al utilizar, opcionalmente limitada en tiempo. No arranca el agente. |

```sh
ssh -F ./ssh-claves.conf -G -o AddKeysToAgent=no ssh-lab-key
```

**Qué estás viendo.** En la práctica se evita la carga implícita para controlar el experimento. Configuración impresa no demuestra carga; comprobar el agente antes/después de una conexión real que lea la privada.

Casos pendientes:

- [ ] no frente a yes/tiempo con agente dedicado: comprobar si aparece la identidad y cuándo caduca.
- [ ] ask/confirm con interfaz disponible y ausente: registrar interacción/error; valor inválido o segundo argumento no permitido: error de configuración.

## Compatibilidad y cuestiones que siguen abiertas

- `ssh-keygen -t` selecciona tipos; `ssh -i` selecciona identidades. `-i` de ssh-keygen importa formatos y `-i` de ssh-copy-id selecciona públicas: no intercambiar sintaxis.
- El tiempo de `ssh-agent -t` es un default para identidades; `ssh-add -t` fija una restricción para una carga. Ninguno es el tiempo de conexión ni el período de validez de un certificado.
- Las reglas de repetición se contrastaron con los parsers fijados. Por ejemplo, `ssh-add -l -l` se rechaza y `ssh-copy-id -p` no sigue la misma regla que `ssh -p`. Son conclusiones de lectura de código, pendientes de ensayo.
- En Windows, usar herramientas del mismo entorno y verificar agente/ACL con build identificado. WSL, Git for Windows y el servicio nativo no constituyen automáticamente un mismo agente.
- Confirmación, restricciones por destino, bloqueo del agente y providers tienen fichas inventariadas aún pendientes. El agente facilita operaciones con claves; no autoriza una cuenta en el servidor.
- Retirar una pública de authorized_keys no equivale a revocar un certificado ni a finalizar conexiones existentes. Revisar otras fuentes de autorización.

## Cobertura y fuentes

Estas 24 fichas corresponden a 21 opciones y tres directivas; los enlaces de unidad llevan a su inventario y este enlaza de vuelta. Todas están documentadas para el alcance indicado, con **pruebas funcionales pendientes**. Las casillas de familias del guion general permanecen abiertas.

Fuentes fijadas del mismo commit upstream:

- [ssh-keygen.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.1) y [ssh-keygen.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-keygen.c).
- [ssh-add.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.1) y [ssh-add.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-add.c).
- [ssh-agent.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.1) y [ssh-agent.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh-agent.c).
- [authfd.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/authfd.c): codificación de restricciones de vida solicitadas al agente.
- [contrib/ssh-copy-id.1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id.1) y [script](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/contrib/ssh-copy-id).
- [ssh_config.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/ssh_config.5) y [readconf.c](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/readconf.c).
- [sshd_config.5](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshd_config.5): gramática temporal y fuentes de autorización.

Para ampliar el bloque, añadir los modos faltantes a estas unidades sin cambiar sus IDs, conservar la separación entre fuente y ensayo y registrar las diferencias del binario utilizado.
