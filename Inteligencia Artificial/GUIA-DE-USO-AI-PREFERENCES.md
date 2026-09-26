# Cómo usar y adaptar AI-PREFERENCES.md

El archivo `AI-PREFERENCES.md` recoge preferencias personales para trabajar con agentes de IA: comunicación, autonomía, código, seguridad, tests, CI y Git. Sirve como base reutilizable; las instrucciones de cada proyecto pueden ampliarlo, especializarlo o sustituirlo.

## 1. Mantener una referencia común

- Usa [AI-PREFERENCES.es.md](AI-PREFERENCES.es.md) como archivo maestro y [AI-PREFERENCES.en.md](AI-PREFERENCES.en.md) como traducción equivalente.
- Ambos mantienen castellano como idioma principal de comunicación. La versión inglesa traduce las instrucciones, pero no cambia esa preferencia.
- Instala una sola versión por entorno para evitar duplicar el contenido.
- Conserva las 13 secciones y las 51 reglas al adaptar el formato. Cambia únicamente el nombre, la ubicación y los metadatos necesarios. Si decides modificar una preferencia, hazlo primero en el maestro y actualiza su traducción.

El nombre `AI-PREFERENCES.md` identifica nuestra referencia. Para que una herramienta la cargue, hay que instalar su contenido mediante uno de los mecanismos que admite.

## 2. Elegir dónde aplicarlo

Las preferencias personales encajan en la configuración global de cada herramienta. En los repositorios compartidos, añade las reglas acordadas para el proyecto: comandos de instalación y verificación, arquitectura, convenciones y excepciones concretas.

| Entorno | Preferencias personales | Reglas del proyecto |
| --- | --- | --- |
| **Codex** | Copia el contenido en `~/.codex/AGENTS.md`. Si has definido `CODEX_HOME`, usa su directorio. | `AGENTS.md` en la raíz; pueden existir instrucciones más específicas en subdirectorios. Un `AGENTS.override.md` puede desplazar al archivo normal del mismo directorio. [Documentación](https://learn.chatgpt.com/docs/agent-configuration/agents-md). |
| **Cursor** | Pega el contenido en **User Rules**, dentro de Customize → Rules. Estas reglas se aplican a Agent, no a todas las funciones del editor. | Usa `AGENTS.md` o una regla `.mdc` dentro de `.cursor/rules/`. [Documentación](https://cursor.com/docs/rules). |
| **OpenCode** | Copia el contenido en `~/.config/opencode/AGENTS.md`. | Usa `AGENTS.md`. En V2, el campo `instructions` de la configuración todavía no carga los archivos que enumera. [Documentación](https://opencode.ai/v2/docs/instructions). |
| **Claude Code** | Copia el contenido en `~/.claude/CLAUDE.md`. | Usa `CLAUDE.md`. Las versiones recientes también admiten `AGENTS.md`, según la versión, la configuración y los demás archivos presentes. [Documentación](https://code.claude.com/docs/en/memory). |

`~` representa la carpeta personal del entorno donde se ejecuta el agente. En Windows nativo suele corresponder a `C:\Users\<usuario>`; WSL o una máquina remota tienen sus propias carpetas y configuración.

Antes de copiar, revisa el archivo de destino: si ya contiene instrucciones útiles, integra las preferencias conservando ese contenido. Evita instalar el mismo bloque globalmente y repetirlo también en el proyecto.

### Adaptación para Cursor

Para una regla de proyecto que se aplique siempre, crea `.cursor/rules/ai-preferences.mdc` con esta cabecera y, a continuación, el contenido íntegro del archivo elegido:

```yaml
---
alwaysApply: true
---
```

Esta es una alternativa a cargar las mismas preferencias mediante User Rules o `AGENTS.md`. `.cursorrules` es un formato heredado; para nuevas adaptaciones usa los formatos actuales. [Formato de reglas](https://cursor.com/docs/rules) y [migración de .cursorrules](https://cursor.com/help/customization/rules).

## 3. Añadir el contexto del proyecto

Un `AGENTS.md` compartido puede recoger las instrucciones del repositorio para Codex, Cursor y OpenCode. Incluye información concreta que ayude a trabajar: cómo ejecutar los tests, qué herramientas se usan y qué restricciones tiene el proyecto.

Si una regla del proyecto modifica una preferencia general, explicita su alcance. Por ejemplo: «Para releases, ejecuta la suite completa de integración; en PR, conserva las comprobaciones rápidas».

La combinación de instrucciones depende de cada herramienta. Codex aplica una precedencia entre archivos; OpenCode V2 combina las fuentes sin resolver automáticamente sus contradicciones. Revisa los posibles conflictos al instalar las preferencias. [Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md) y [OpenCode](https://opencode.ai/v2/docs/instructions).

## 4. Actualizar y comprobar

1. Modifica el archivo maestro y sincroniza la traducción.
2. Actualiza las variantes instaladas conservando las reglas específicas que ya existan en sus destinos.
3. Revisa las diferencias y comprueba que las 51 reglas siguen presentes y mantienen su significado.
4. Abre una sesión nueva y comprueba qué fuentes de instrucciones se han cargado, usando los mecanismos de diagnóstico de la herramienta. Pedir al agente que explique las pautas que va a seguir puede servir como comprobación adicional.

Si el mantenimiento se vuelve repetitivo, un script local puede copiar el contenido y añadir las cabeceras necesarias. No hace falta usar CI para esta tarea. Un generador debería mostrar las diferencias y preservar el contenido ajeno a las preferencias.

Para añadir otra herramienta, consulta su documentación y verifica el nombre del archivo, su ubicación, el ámbito y cómo se combina con otras instrucciones. No presupongas que basta con cambiar la extensión o mencionar el archivo maestro.

Documentación consultada el 26 de septiembre de 2026. Comprueba la versión instalada cuando una función dependa de ella.
