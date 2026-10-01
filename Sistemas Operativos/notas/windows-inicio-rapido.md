# Nota: desactivar el inicio rápido de Windows

El inicio rápido no apaga el sistema del todo: hiberna la sesión del kernel. En un dual boot el volumen NTFS queda montado en sucio y Linux se niega a montarlo.

Entorno: Windows 10 u 11. La clave es de `HKLM`; hace falta administrador.

## Solo el inicio rápido

Importa [windows-inicio-rapido.reg](windows-inicio-rapido.reg) (doble clic, o `regedit /s` en un símbolo elevado) y reinicia.

El archivo deja `HiberbootEnabled` a `0` en:

`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power`

La hibernación sigue disponible. El mismo ajuste está en **Opciones de energía → Elegir el comportamiento de los botones de inicio/apagado → Cambiar la configuración actualmente no disponible**, casilla **Activar inicio rápido**.

## Quitar también la hibernación

```bat
powercfg /hibernate off
```

Eso borra `hiberfil.sys` y, con él, el inicio rápido. Recuperas el espacio del fichero de hibernación. Para volver: `powercfg /hibernate on` y reimporta el `.reg` con el valor `1` si quieres el inicio rápido otra vez.

## Comprobar

```bat
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled
```

`0x0` es inicio rápido apagado.

> [!NOTE]
> El desfase de hora que queda después de esto suele ser el reloj de la BIOS en hora local (Windows) frente a UTC (Linux). Es un ajuste aparte: en Linux, `timedatectl set-local-rtc 1`.

---

*Biblioteca — Sistemas Operativos · inicio rápido*
