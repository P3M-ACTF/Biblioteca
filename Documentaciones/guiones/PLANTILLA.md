# Plantilla de unidad de contenido

[Criterios y catálogo](README.md)

Copiar esta estructura al desarrollar una unidad. Sustituir los campos entre corchetes; no considerar completos los ejemplos ni las fuentes mientras sigan vacíos. La ficha puede vivir en la guía técnica o en un archivo propio si su tamaño lo justifica. El guion conserva el ID y un enlace a esa ficha.

## Identificación

| Campo | Valor |
| --- | --- |
| ID y unidad padre | [ID estable] |
| Nombre y tipo | [Concepto / comando / opción / argumento / directiva / GUI / API / caso] |
| Objetivo | [Problema que resuelve y cuándo usarlo] |
| Producto y versión | [Versión exacta o corte del servicio; edición y arquitectura] |
| Entorno | [SO, distribución, shell, paquete, módulo, host/contenedor] |
| Requisitos y privilegios | [Dependencias, permisos y alcance] |
| Efecto | [Consulta/modificación; sesión/persistente; recursos afectados] |
| Estado | [Inventariado / Documentado / Verificado / No aplicable / Retirado] |
| Fuente y consulta | [URL específica, versión de la referencia, fecha] |

## Concepto y sintaxis

[Explicación breve y sintaxis completa de la unidad. Distinguir literales, marcadores, opcionales y alternativas. Indicar precedencia de configuración y de opciones. En una operación GUI: ruta de menús y campos; en una API: método, ruta y autenticación.]

## Inventario de opciones, argumentos y valores

Una fila por opción, argumento o clave; añadir su ancla estable cuando exista contenido enlazable. No sustituir esta tabla por «ver ayuda».

| ID | Elemento | Tipo y valores | Predeterminado | Repetición/requisitos/exclusiones | Versión/estado |
| --- | --- | --- | --- | --- | --- |
| [ID-O001] | [Opción o parámetro] | [Tipo, rango, unidades y valores especiales] | [Valor o ausencia] | [Reglas] | [Versión y estado] |
| [ID-A001] | [Argumento posicional] | [Tipo y posición] | [Obligatorio/opcional] | [Reglas] | [Versión y estado] |

Para APIs, inventariar path/query/header/body, paginación, límites, permisos, códigos HTTP y schema de respuesta. Para SQL, cláusulas, tipos, funciones, modos y motor. Para GUI, cada operación, campo y efecto. Registrar alias sin contarlos como comandos independientes.

## Casos y combinaciones

| ID | Objetivo y precondiciones | Entrada o acción | Resultado y campos que observar | Error/límite | Reversión | Evidencia |
| --- | --- | --- | --- | --- | --- | --- |
| [ID-K001] | [Caso mínimo] | [Comando/acción] | [Cómo confirmar éxito] | [Fallo esperado] | [Si procede] | [Entorno, resultado, fecha] |

Cubrir caso mínimo, variantes, consulta frente a cambio, privilegios insuficientes, entrada inválida, elemento inexistente, duplicado, valores límite, configuración previa y persistencia. Incluir idempotencia, concurrencia, desconexión, reinicio y restauración cuando sean relevantes.

## Interpretación de salida y diagnóstico

[Explicar cada campo relevante, unidades, estados, salida normal, códigos de retorno y mensajes de error. Separar stdout/stderr, objetos y texto. Anotar qué dato confirma la hipótesis y qué dato la refuta.]

## Compatibilidad y cambios

[Diferencias entre versiones, ediciones, distribuciones, shells y arquitecturas. Elementos obsoletos/retirados y alternativa. No extrapolar comportamiento sin evidencia.]

## Materiales derivados

| Recurso | Ruta o enlace real | IDs cubiertos | Alcance y estado |
| --- | --- | --- | --- |
| Guía divulgativa | Pendiente | [IDs] | [Estado] |
| Guía técnica / referencia | Pendiente | [IDs] | [Estado] |
| Cheatsheet Markdown | Pendiente | [IDs] | [Estado] |
| Cheatsheet visual | Pendiente | [IDs] | [Estado] |

## Cierre de cobertura

- [ ] Se ha comparado el inventario con la fuente de la versión elegida y no quedan elementos sin ficha ni exclusión justificada.
- [ ] Las opciones, argumentos, valores, efectos y combinaciones relevantes tienen desarrollo.
- [ ] Los casos publicados como verificados tienen evidencia y entorno identificados.
- [ ] Los enlaces y los IDs de los materiales derivados son correctos.
