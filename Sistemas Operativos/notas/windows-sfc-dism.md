# Nota: reparar el sistema con SFC y DISM

Cuando Windows se comporta raro —un componente que no abre, un servicio que falla al arrancar, actualizaciones que no terminan— y no hay un culpable claro, el propio sistema trae dos herramientas que comprueban sus ficheros contra la copia buena que guarda. Se usan en este orden, y en una consola de administrador.

## Primero la imagen, después los ficheros

SFC compara los ficheros del sistema con la imagen local que Windows guarda como referencia. Si esa imagen también está dañada, SFC no tiene contra qué reparar y termina diciendo que encontró errores que no pudo corregir. Por eso se arregla primero la imagen con DISM y luego se pasan los ficheros con SFC.

```powershell
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
```

`/Online` significa «el sistema que está corriendo», no una imagen apagada. `/RestoreHealth` repara, no solo informa; DISM descarga lo que le falte desde Windows Update, así que necesita salida a Internet o un origen alternativo. Tarda un rato y el porcentaje se queda quieto durante minutos: es normal.

### Qué estás viendo

```text
sfc /scannow

Verificación 100 % completada.
Protección de recursos de Windows encontró archivos dañados y los reparó correctamente.
```

Esa frase es el buen resultado: había daño y lo corrigió. «No encontró ninguna infracción de integridad» significa que los ficheros están bien y el problema está en otro sitio (configuración, perfil de usuario, un programa concreto). «Encontró archivos dañados pero no pudo reparar algunos» significa que la imagen de referencia no bastó: se vuelve a correr DISM y se repite SFC, y si insiste, el informe está en `C:\Windows\Logs\CBS\CBS.log`.

## Qué no hacen

No desinstalan programas, no limpian malware y no arreglan el Registro. Si el sistema no arranca lo bastante como para ejecutarlos, se lanzan desde el entorno de recuperación, sin `/Online` y apuntando a la instalación. Y si el daño vino de un corte de luz a media actualización, conviene mirar antes el historial de actualizaciones: a veces lo que toca es completar o revertir esa actualización, no reparar ficheros.

*Biblioteca — Sistemas Operativos · SFC y DISM*
