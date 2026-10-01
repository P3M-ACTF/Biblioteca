# Nota: menú contextual clásico en Windows 11

Windows 11 acorta el clic derecho y deja el menú completo detrás de **Mostrar más opciones**. [windows-menu-contextual-clasico.reg](windows-menu-contextual-clasico.reg) restaura el menú de Windows 10 para el usuario actual.

Entorno: Windows 11. Clave de `HKCU`; no hace falta administrador. En Windows 10 el menú ya es el clásico y este archivo no cambia nada útil.

Sin registro, Mayús+clic derecho abre el menú completo en esa ocasión.

## Importar

```bat
regedit /s windows-menu-contextual-clasico.reg
taskkill /f /im explorer.exe
start explorer.exe
```

El `.reg` crea `HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32` con el valor predeterminado vacío. El Explorador, al ver esa clave, usa el menú antiguo.

## Volver al menú de Windows 11

```bat
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe
start explorer.exe
```

Si una actualización ignora la clave, el menú nuevo reaparece y la clave queda sin efecto; bórrala con el comando de arriba.

---

*Biblioteca — Sistemas Operativos · menú contextual*
