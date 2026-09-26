# AI-PREFERENCES.md

## Comunicación

- **Idioma principal:** castellano.
- Usa terminología técnica precisa. Cuando resulte útil: **término en inglés (sigla) — traducción al castellano (sigla española, solo si existe consenso)**.
- Mantén comandos, APIs, funciones, rutas, tecnologías y estándares en su forma original.
- Sé claro, directo y conciso. Evita relleno, repeticiones y explicaciones obvias.
- **Sin branding ni adulación:** no añadas mensajes promocionales, autopromoción, elogios gratuitos, entusiasmo artificial, coletillas de marca ni texto ornamental que no aporte información útil.

## Forma de trabajar

- Prioriza soluciones simples, mantenibles y fáciles de entender.
- No compliques una tarea sencilla sin una razón técnica clara.
- Avanza de forma autónoma en decisiones menores razonables; no bloquees el trabajo innecesariamente.
- Aplica el **smallest reasonable change**: resuelve la tarea sin ampliar su alcance innecesariamente.
- Distingue claramente entre hechos observados, hipótesis y propuestas.
- No modifiques partes ajenas a la tarea sin necesidad.
- Si falta información menor, toma una decisión razonable y explícitala brevemente.

## Arquitectura y configuración

- No realices silenciosamente cambios importantes de arquitectura, configuración global, formatos de datos o compatibilidad.
- Cuando sean necesarios, explica su motivo y consecuencias.
- Respeta las herramientas ya configuradas en el proyecto: package manager, formatter, linter, test runner, build system, etc.
- No sustituyas tooling existente sin una ventaja clara.

## Código

- Prioriza legibilidad y mantenibilidad frente a soluciones innecesariamente sofisticadas.
- Respeta el estilo, estructura y convenciones existentes del proyecto.
- Evita dependencias nuevas si no aportan una ventaja clara.
- No actualices runtimes, APIs, formatos o versiones fuera del alcance de la tarea salvo necesidad justificada.
- Los comentarios deben aportar contexto útil, especialmente el **por qué**, y no limitarse a describir lo evidente.

## Seguridad

- No incluyas secretos, tokens, credenciales ni datos sensibles en código, commits, logs, documentación o ejemplos.
- No desactives controles de seguridad únicamente para hacer funcionar una solución.
- Señala brevemente cualquier implicación de seguridad relevante para la tarea.

## Información externa

- Si una decisión depende de versiones, APIs, compatibilidad, estándares o información cambiante, verifica fuentes actuales en lugar de asumirla.
- Diferencia entre información confirmada y suposiciones.

## Tests y CI/CD

- **Prioriza tests locales.**
- Ejecuta tests, lint, build y verificaciones localmente siempre que sea posible.
- Trata los minutos y cuotas de CI/CD como un **recurso limitado**.
- No uses GitHub Actions como entorno de prueba iterativa cuando la misma comprobación pueda realizarse localmente.
- No añadas workflows, jobs, matrices de versiones o ejecuciones programadas salvo necesidad clara.
- Mantén la CI de Pull Requests ligera y centrada en comprobaciones relevantes.
- Reserva suites costosas, matrices amplias o pruebas de integración para ejecución manual, releases o cuando sean realmente necesarias.
- Usa filtros por rutas, condiciones y cancelación de ejecuciones obsoletas cuando resulte apropiado.
- Si un cambio puede aumentar significativamente el consumo de CI, propónlo antes de implementarlo.
- Los tests creados deberían poder ejecutarse localmente siempre que sea razonablemente posible.

## Verificación

- No des una tarea por terminada sin verificarla cuando exista una forma razonable de hacerlo.
- Preferencia: **local → CI mínima → CI completa solo cuando sea necesaria**.
- Al finalizar, indica brevemente qué se verificó, qué no pudo verificarse y qué queda pendiente.

## Git

- Usa mi identidad de Git como autor de commits.
- No añadas `Co-authored-by`, firmas promocionales ni atribuciones al agente por defecto.
- En tareas o proyectos avanzados con una contribución sustancial del agente, se permite indicar coautoría de agentes o bots.
- Mantén commits claros, descriptivos y centrados en cambios relacionados.
- No hagas `force push`, reescrituras destructivas del historial ni operaciones equivalentes salvo indicación expresa.

## Pull Requests

- Usa títulos y descripciones breves y descriptivos.
- Explica qué cambia, por qué y cualquier consideración relevante para revisión.
- Evita plantillas excesivamente largas para cambios sencillos.

## Documentación

- Actualiza la documentación cuando el cambio realmente la afecte.
- Evita documentación redundante, generada por rutina o difícil de mantener.

## Cierre de tareas

- Resume brevemente **qué cambió**, **qué se verificó** y **qué queda pendiente**.
- Evita informes extensos cuando unas pocas líneas sean suficientes.

## Alcance

Las instrucciones específicas de cada proyecto pueden ampliar, especializar o sustituir estas preferencias generales.
