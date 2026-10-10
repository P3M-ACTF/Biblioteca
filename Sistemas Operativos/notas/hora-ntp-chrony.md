# Nota: hora correcta con chrony o timesyncd

Un reloj mal puesto rompe cosas que no parecen tener que ver con la hora: los certificados TLS se ven como caducados o como «aún no válidos», Kerberos rechaza los inicios de sesión si la diferencia pasa de unos minutos, y los registros de dos máquinas no se pueden correlacionar porque cada una cuenta una hora distinta. La hora se sincroniza sola con NTP; esta nota deja eso funcionando y comprobado.

Mira primero qué hay:

```bash
timedatectl
```

### Qué estás viendo

```text
$ timedatectl
               Local time: sáb 2026-10-10 13:05:22 CEST
           Universal time: sáb 2026-10-10 11:05:22 UTC
                 RTC time: sáb 2026-10-10 11:05:22
                Time zone: Europe/Madrid (CEST, +0200)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

`System clock synchronized: yes` es el objetivo. `NTP service: active` dice que hay un servicio de sincronización corriendo. `RTC in local TZ: no` significa que el reloj del hardware guarda la hora en UTC, que es lo correcto en un servidor y en un Linux que convive con Windows (si Windows también se configura para ello; nota [windows-hora-dual-boot](windows-hora-dual-boot.md)).

La zona horaria se fija con `timedatectl set-timezone Europe/Madrid`. Cambiar la zona no cambia el instante que marca el reloj: cambia cómo se muestra. Los registros en UTC siguen siendo la referencia para correlacionar.

## Qué servicio usa la máquina

Ubuntu y Debian de escritorio suelen traer `systemd-timesyncd`, que vale para un cliente: una sola configuración sencilla y suficiente. Los servidores, y cualquier RHEL, suelen usar **chrony**, que aguanta mejor las interrupciones y permite servir hora a otros equipos.

```bash
systemctl is-active systemd-timesyncd chronyd
```

Solo uno de los dos debería estar activo. Los dos a la vez compiten por ajustar el reloj.

### timesyncd

```bash
timedatectl show-timesync --all
```

Los servidores NTP salen en `FallbackNTP` o en la configuración de `/etc/systemd/timesyncd.conf`. Tras cambiarlo, `systemctl restart systemd-timesyncd`.

### chrony

```bash
chronyc tracking
chronyc sources
```

`chronyc sources` lista los servidores y marca con `^*` el que se está usando ahora. Un `^?` en todos significa que no llega a ninguno: cortafuegos (el NTP sale por UDP/123) o servidores mal escritos. `chronyc tracking` dice cuánto se desvía el reloj; unos milisegundos es lo normal, segundos ya no.

La configuración está en `/etc/chrony/chrony.conf` o `/etc/chrony.conf`, con líneas `pool` o `server`. Hay una plantilla comentada en [chrony.conf.ejemplo](../plantillas/chrony.conf.ejemplo).

## Cuando la diferencia es enorme

Si el reloj está horas o días fuera (una máquina virtual que estuvo apagada mucho tiempo), el servicio puede negarse a corregirlo de golpe para no dar saltos. `sudo chronyc makestep` fuerza el ajuste inmediato. En timesyncd suele bastar con reiniciarlo. Después de un salto grande, los certificados y las sesiones que se quejaban empiezan a funcionar sin tocarlos: el problema era el reloj.

*Biblioteca — Sistemas Operativos · hora y NTP*
