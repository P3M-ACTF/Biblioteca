# Cómo colaborar

Puedes participar compartiendo un recurso, proponiendo una idea o corrigiendo un documento. Una sugerencia o un enlace también son una aportación útil.

## Compartir un recurso o una sugerencia

Abre una [issue](https://github.com/P3M-ACTF/Biblioteca/issues) con la URL del recurso que te gustaría añadir o una breve explicación de tu propuesta. Si has encontrado un error, indica el documento para que podamos localizarlo.

## Proponer un cambio en los documentos

Si prefieres editar el contenido, puedes hacerlo en una rama de tu copia o fork y abrir una [pull request](https://github.com/P3M-ACTF/Biblioteca/pulls). Basta con explicar qué cambia y por qué.

Estas orientaciones pueden ayudarte a preparar el cambio:

- Usa como referencia el estilo de los documentos de la misma categoría, principalmente en castellano.
- Añade la fuente del material y conserva sus atribuciones. Para recursos de terceros, puedes compartir el enlace de origen; si incorporas el archivo, comprueba que se permite redistribuirlo.
- Revisa los enlaces y la vista previa Markdown. Si aportas comandos o configuraciones, indica el entorno en el que los has probado, cuando sea posible.

## Páginas interactivas

Guarda cada página HTML en una carpeta temática propia con un `index.html` y sus recursos referenciados mediante rutas relativas. Añade desde el índice un enlace a su URL de GitHub Pages y otro al código fuente. Comprueba localmente la página y sus enlaces antes de proponerla; si necesita generar CSS o JavaScript, incluye el comando de generación y los archivos finales para que Pages pueda servirlos directamente.

## Cómo se escribe una chuleta

Una chuleta sirve para recordar, pero también tiene que servir para entender. Quien la abre por primera vez no conoce el tema; quien la abre por décima vez busca el comando. Las dos lecturas tienen que funcionar.

- Cada sección empieza con un párrafo que explica qué es la cosa, para qué sirve y cuándo se usa. La tabla o el bloque de comandos viene después, no en lugar del párrafo.
- En las tablas, la columna de explicación lleva una frase completa, no una palabra. «Cambia origen» no explica nada; «Reescribe la dirección de origen del paquete para que la respuesta vuelva al router y no al host privado» sí.
- Cada bloque de comandos va seguido de un apartado «Qué estás viendo» que lee la salida típica línea a línea: qué significa cada campo y cuál es el valor que indica un problema.
- Cada chuleta termina con un apartado «Error típico»: una situación real, por qué ocurre, cómo se ve en pantalla y cómo se arregla, escrito en prosa.
- La estructura sigue siendo escaneable: cabeceras numeradas, tablas, comandos en bloques. Pero la longitud habitual de una chuleta está entre 7 y 10 KB, no en 3.

Los runbooks siguen la misma idea: cada paso explica por qué se hace y qué salida se espera. Las notas sueltas son más cortas porque resuelven una sola tarea, pero también explican el porqué de cada comando.

Si tienes dudas sobre dónde encaja una aportación, puedes plantearlas en la propia issue o pull request.

[Volver a Biblioteca](README.md)
