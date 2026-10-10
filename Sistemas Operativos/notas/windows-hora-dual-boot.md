# Nota: hora de Windows en arranque dual

Cuando Windows y Linux comparten un equipo, el reloj se desfasa dos horas (una, en invierno) cada vez que arrancas el otro sistema. No es que se rompa: es que no se ponen de acuerdo sobre qué guarda el reloj del hardware.

Linux asume que el reloj de la placa está en **UTC** y le suma el huso al mostrar la hora. Windows asume que está en **hora local** y lo lee tal cual. Cada vez que uno ajusta el reloj, se lo deja al otro mal puesto. La solución limpia es que Windows también use UTC, que es además lo que conviene en cualquier máquina que vaya a correlacionar registros.

El valor está en el Registro:

```text
HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
    RealTimeIsUniversal = 1
```

Con ese valor a 1, Windows interpreta el reloj de hardware como UTC, igual que Linux. El fichero [windows-hora-dual-boot.reg](windows-hora-dual-boot.reg) lo escribe. Importarlo pide administrador y hace falta reiniciar para que valga.

Después del reinicio, entra en Linux, sincroniza la hora (nota [hora-ntp-chrony](hora-ntp-chrony.md)) y vuelve a Windows: la hora tiene que coincidir. Si Windows está unido a un dominio, el dominio también le empuja la hora; con `RealTimeIsUniversal` las dos cosas conviven en lugar de deshacerse la una a la otra.

Para volver atrás, el mismo valor a `0`, que es lo que Windows trae de fábrica.

*Biblioteca — Sistemas Operativos · hora en arranque dual*
