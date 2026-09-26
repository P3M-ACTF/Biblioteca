# Plantilla de README

Base reutilizable en castellano para presentar un proyecto, explicar cómo usarlo y facilitar las contribuciones. Incluye módulos para software, documentación y colecciones de recursos; conserva solo los que aporten información al proyecto de destino.

[Abrir la plantilla](PLANTILLA_README.md) · [Volver a Biblioteca](../../../README.md)

## Cómo utilizarla

1. Copia el contenido de [PLANTILLA_README.md](PLANTILLA_README.md) a un archivo `README.md` en la raíz del proyecto de destino. Revisa cualquier README existente antes de sustituirlo.
2. Sustituye todos los marcadores `{{NOMBRE_DEL_MARCADOR}}` por información comprobada. Son instrucciones de edición, no contenido listo para publicar.
3. Lee los comentarios HTML: señalan módulos opcionales y criterios de adaptación. Elimina las secciones que no correspondan y sus entradas del índice; retira también las instrucciones de edición.
4. Resuelve los enlaces desde la raíz del proyecto de destino. Los marcadores `{{RUTA_...}}` son rutas relativas a archivos reales; los marcadores `{{URL_...}}` son direcciones completas. No conserves enlaces a documentos o servicios inexistentes.
5. Sustituye los bloques de ejemplo por acciones o comandos reales y comprueba su resultado. Ajusta el lenguaje de cada bloque de código. No inventes dependencias, versiones, sistemas de CI ni comandos de prueba.
6. Revisa la vista previa Markdown, el índice y los enlaces antes de publicar.

## Qué conservar

| Tipo de proyecto | Contenido prioritario | Módulos que pueden sobrar |
|------------------|-----------------------|--------------------------|
| Aplicación o herramienta | Propósito, requisitos, instalación, uso y soporte | Los módulos que no tengan información real |
| Biblioteca de código | Integración, ejemplo mínimo, compatibilidad y documentación | Despliegue o interfaz visual, si no existen |
| Documentación o colección de recursos | Público, organización, acceso, ejemplo de consulta y contribución | Instalación, configuración y desarrollo, si no se ejecuta software |

La plantilla es un punto de partida, no una lista de secciones obligatorias. Una captura puede explicar una interfaz; una tabla suele ser más útil para organizar recursos. Añade imágenes, insignias o un estado del proyecto únicamente si transmiten información relevante y verificable.

## Antes de publicar

- [ ] La introducción explica qué es el proyecto, para quién es y qué permite hacer.
- [ ] No quedan marcadores `{{...}}`, instrucciones de edición ni secciones vacías.
- [ ] El ejemplo mínimo funciona y muestra un resultado esperado concreto.
- [ ] Los requisitos, versiones y comandos corresponden al proyecto real.
- [ ] El índice coincide con los encabezados y todos los enlaces tienen destino válido.
- [ ] Las imágenes tienen texto alternativo útil y las tablas se leen en la vista previa.
- [ ] No se incluyen secretos ni datos privados en ejemplos, capturas o configuración.
- [ ] La licencia y los créditos reflejan las condiciones reales del proyecto y de sus materiales externos.
- [ ] Los detalles extensos enlazan a documentación mantenida, sin duplicarla innecesariamente.

## Referencias

- [Best-README-Template](https://github.com/othneildrew/Best-README-Template): referencia para la organización general y las secciones de inicio, uso y contribución.
- [awesome-readme](https://github.com/matiassingers/awesome-readme): ejemplos de jerarquía visual, navegación y presentación de distintos tipos de proyectos.

Esta propuesta adapta esas ideas al castellano con Markdown sencillo y módulos que pueden eliminarse según el proyecto.
