# Nota: resaltado de sintaxis en nano y atajos que chocan

Nano ya sabe colorear lenguajes; en muchas instalaciones el `include` de las definiciones viene comentado en `/etc/nanorc`. Además, dos atajos no llegan al editor: Ctrl+S y Ctrl+Q se los queda el control de flujo del terminal, y Ctrl+Z suspende nano y te devuelve al shell.

Entorno: nano 4 o posterior (Debian, Ubuntu, Fedora). El fichero de usuario es `~/.nanorc`.

## 1. Resaltado y opciones de edición

```nanorc
include "/usr/share/nano/*.nanorc"

set linenumbers
set autoindent
set tabsize 4
set tabstospaces
set constantshow
set softwrap
```

Abre un `.sh` o un `.py`. Si el color no cambia, fuerza la sintaxis con `nano -Y sh archivo` y comprueba que existan ficheros en `/usr/share/nano/`.

Si al abrir nano aparece `Duplicate syntax name`, el `include` ya está activo en `/etc/nanorc`. Deja uno de los dos.

## 2. Ctrl+S y Ctrl+Q: control de flujo del terminal

Con `ixon` activo, Ctrl+S (XOFF) congela la salida del terminal y Ctrl+Q (XON) la reanuda. Nano no ve esas teclas: Ctrl+S es guardar y Ctrl+Q es buscar hacia atrás.

En `~/.bashrc` o `~/.zshrc`:

```bash
stty -ixon
```

Abre un terminal nuevo y comprueba:

```bash
stty -a | grep -o -- '-ixon'
```

Tiene que salir `-ixon`.

## 3. Ctrl+Z: dejar de suspender nano

En `~/.nanorc`, debajo de las opciones del paso 1:

```nanorc
unset suspend
unbind ^Z all
```

`unset suspend` apaga la suspensión. `unbind ^Z all` retira el atajo en todos los menús. Ctrl+Z pasa a no hacer nada, que es lo buscado cuando el atajo chocaba con la costumbre de otros editores.

Si quieres que Ctrl+Z deshaga, añade esta línea en lugar de dejar la tecla libre:

```nanorc
bind ^Z undo main
```

Deshacer sigue estando en Alt+U y rehacer en Alt+E.

## Comprobar

1. `nano archivo.sh` muestra color y números de línea.
2. Ctrl+G lista la ayuda: Ctrl+S figura como guardar.
3. Ctrl+S escribe el fichero y el terminal no se queda congelado.
4. Ctrl+Z ya no devuelve el prompt en medio de la edición.

---

*Biblioteca — Sistemas Operativos · nano*
