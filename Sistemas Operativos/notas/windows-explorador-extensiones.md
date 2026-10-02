# Nota: mostrar extensiones y archivos ocultos

El Explorador oculta la extensión de los tipos conocidos y los archivos con atributo oculto. [windows-explorador-extensiones.reg](windows-explorador-extensiones.reg) invierte esas dos casillas para el usuario actual.

Entorno: Windows 10 u 11. La clave es de `HKCU`; no hace falta administrador.

## Importar

Doble clic en el `.reg`, o:

```bat
regedit /s windows-explorador-extensiones.reg
taskkill /f /im explorer.exe
start explorer.exe
```

Valores que escribe en `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`:

| Valor | Dato | Efecto |
|-------|------|--------|
| `HideFileExt` | `0` | Muestra la extensión (`.txt`, `.exe`, …) |
| `Hidden` | `1` | Muestra archivos ocultos |

El mismo resultado está en el Explorador: **Ver → Mostrar → Extensiones de nombre de archivo** y **Elementos ocultos**.

Este archivo no enseña los archivos protegidos del sistema (la casilla aparte del cuadro Opciones de carpeta).

## Volver al comportamiento de fábrica

`HideFileExt=1` y `Hidden=2`, reimportar y reiniciar el Explorador.

---

*Biblioteca — Sistemas Operativos · Explorador*
