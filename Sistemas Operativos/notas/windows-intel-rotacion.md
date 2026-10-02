# Nota: desactivar la rotación de pantalla (Intel)

En portátiles con gráfica integrada Intel, Ctrl+Alt+flecha gira el escritorio. El atajo lo registra el controlador, no el menú de Windows. El archivo [windows-intel-rotacion.reg](windows-intel-rotacion.reg) apaga ese comportamiento en los dos sitios donde ha vivido el ajuste.

Entorno: Windows 10 u 11 con gráfica Intel. Importar claves de `HKLM` pide una cuenta de administrador.

## Importar

1. Copia `windows-intel-rotacion.reg` al equipo.
2. Doble clic, o en un símbolo del sistema elevado:

```bat
regedit /s windows-intel-rotacion.reg
```

3. Reinicia.

El `.reg` hace dos cosas:

- `Enable=0` en `igfxcui\HotKeys` (panel clásico de Intel), en `HKLM` y en `HKCU`.
- `EnableRotation=0` en la clase de adaptadores de vídeo `{4d36e968-e325-11ce-bfc1-08002be10318}`, entradas `0000` y `0001`.

## Qué entrada es la Intel

```bat
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v DriverDesc
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v DriverDesc
```

`DriverDesc` debe mencionar Intel. Si el adaptador está en `0002` u otra entrada, copia el bloque `EnableRotation` de esa entrada en el `.reg` y vuelve a importarlo.

## Si el giro sigue

Los controladores DCH nuevos (Intel Graphics Command Center) a veces ignoran `igfxcui`. En esa aplicación: **Sistema → Teclas de acceso rápido** y desactívalas. Un update del controlador puede recrear los valores; vuelve a importar el `.reg` si el atajo regresa.

La opción **Bloqueo de rotación** de Configuración → Sistema → Pantalla es el giro automático de una tableta. Es independiente de este atajo.

## Volver a activarlo

Pon los `dword` a `00000001` y reimporta, o borra los valores `Enable` y `EnableRotation` que creó el archivo. Reinicia.

---

*Biblioteca — Sistemas Operativos · rotación Intel*
