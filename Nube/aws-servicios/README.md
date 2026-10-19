# Guía visual de servicios AWS

[Abrir la infografía interactiva](https://p3m-actf.github.io/Biblioteca/Nube/aws-servicios/) · [Consultar el HTML](index.html)

La página reúne servicios de AWS por categorías y una ruta de aprendizaje de 16 pasos. Permite buscar, filtrar, alternar vistas y consultar ejemplos de AWS CLI. Los comandos son ilustrativos: revisa su coste y sus parámetros antes de ejecutarlos en una cuenta.

El CSS se publica ya generado en `styles.css`. Para actualizarlo tras cambiar las clases de la página:

```sh
npm ci
npm run build:css
```

La tipografía Inter se carga desde Google Fonts; si no está disponible, se usa una fuente sans-serif local. La revisión editorial de esta incorporación retiró Amazon QLDB, cuyo soporte terminó en 2025; no supone una validación exhaustiva de los demás servicios y comandos.
