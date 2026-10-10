# Nota: instalar y actualizar con winget

winget es el gestor de paquetes de línea de comandos de Windows. Sirve para instalar un programa por su nombre, ver qué hay pendiente de actualizar y actualizarlo, sin recorrer páginas de descarga. Está en Windows 10 y 11 actuales como «App Installer»; si `winget` no existe, se instala desde la Microsoft Store con ese nombre.

## Buscar e instalar

```powershell
winget search firefox
winget show Mozilla.Firefox
winget install Mozilla.Firefox
```

`search` busca por texto libre y enseña varios resultados parecidos. `show` enseña uno concreto: versión, editor y dirección de origen. Se instala con el **identificador** (`Mozilla.Firefox`), no con el nombre bonito, porque el nombre se repite entre editores distintos y el identificador no.

### Qué estás viendo

```text
$ winget search 7zip

Nombre       Id                 Versión
-----------------------------------------
7-Zip        7zip.7zip          24.08
7-Zip ZS     mcmilk.7zip-zstd   24.08
```

La columna `Id` es la que vas a usar. Cuando hay varias filas, lee el editor antes de instalar: el primer resultado no siempre es el oficial.

`winget install` pide confirmación y elevación si el instalador la necesita. `--accept-package-agreements` y `--accept-source-agreements` sirven para dejarlo no interactivo en un script, y conviene saber qué estás aceptando la primera vez que usas una fuente.

## Actualizar

```powershell
winget upgrade
winget upgrade --all
```

Sin más argumentos, `upgrade` lista lo que tiene versión nueva y no toca nada: es el informe. `--all` aplica todo lo de la lista. Los paquetes que winget no gestiona (porque se instalaron a mano y no los reconoce) simplemente no aparecen; no es que estén al día.

Para dejar una máquina nueva con lo de siempre, un fichero de texto con un `winget install` por línea se puede volver a ejecutar: si el programa ya está, lo dice y sigue.

*Biblioteca — Sistemas Operativos · winget*
