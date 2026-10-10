# Runbook: servicio que no arranca

Úsalo cuando `systemctl start` falla, cuando un servicio queda en `failed` después de un reinicio, o cuando algo que debería escuchar en un puerto no responde. El objetivo es leer lo que systemd ya sabe antes de cambiar nada: casi siempre el journal dice el motivo en las últimas líneas, y se pierde en cuanto empiezas a editar a ciegas.

## 1. Ver en qué estado quedó

**Por qué este paso.** «No arranca» cubre situaciones distintas: no pudo arrancar y se rindió (`failed`), está intentándolo en bucle (`activating` con `auto-restart`), arrancó y terminó enseguida (`inactive` con código de salida), o ni siquiera está habilitado para arrancar. Cada una se investiga distinto, y `status` las distingue en cinco líneas.

```bash
systemctl status NOMBRE.service
systemctl is-enabled NOMBRE
systemctl cat NOMBRE
```

### Qué estás viendo

```text
$ systemctl status nginx.service
× nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: failed (Result: exit-code) since Sat 2026-10-10 09:14:02 UTC; 3min ago
    Process: 1204 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=1/FAILURE)
   Main PID: 1204 (code=exited, status=1/FAILURE)
        CPU: 42ms

oct 10 09:14:02 web01 nginx[1204]: nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
oct 10 09:14:02 web01 systemd[1]: nginx.service: Failed with result 'exit-code'.
```

`Loaded` con la ruta dice qué fichero de unidad se está usando, y `enabled` dice que el fallo no es que nadie lo arranque: está habilitado y falló al ejecutarse. `Active: failed (Result: exit-code)` descarta el bucle de reinicios. `status=1/FAILURE` es el código con el que terminó el proceso. Y la línea del journal, que `status` ya incluye, da el motivo literal: no pudo enlazar el puerto 80 porque alguien lo ocupa. Con eso puedes ir al paso 3 directamente. Si las líneas no bastan, el paso 2 saca el resto.

Anota antes de seguir: estado, código de salida y ruta de la unidad. Chuleta: [systemd-journalctl](../chuletas/systemd-journalctl.md).

## 2. Leer el journal del servicio

**Por qué este paso.** `status` enseña las últimas líneas; el journal tiene el arranque completo, los intentos anteriores y lo que escribió el propio servicio. Filtrar por unidad quita el ruido del resto del sistema.

```bash
journalctl -u NOMBRE.service -b --no-pager
journalctl -u NOMBRE.service -b -1 --no-pager
```

`-b` es este arranque; `-b -1` es el anterior, que es donde está la respuesta cuando el servicio murió justo antes de un reinicio. Hace falta journal persistente para que el arranque anterior exista (nota [journal-persistente](../notas/journal-persistente.md)).

### Qué estás viendo

Los mensajes que más se repiten, y lo que significan:

| Mensaje | Qué está diciendo |
|---------|-------------------|
| `Address already in use` | El puerto que quiere usar lo tiene otro proceso. No es un fallo del servicio: es un conflicto. |
| `Permission denied` al abrir un fichero | El `User=` de la unidad no puede leer su configuración, su certificado o su directorio de trabajo. |
| `No such file or directory` en el `ExecStart` | La ruta del binario o de un fichero que necesita no existe en esta máquina. |
| `Failed to locate executable` | Igual, dicho por systemd antes siquiera de ejecutar nada. |
| `Dependency failed` | Otra unidad de la que esta depende no está activa. El fallo real está en la dependencia, no aquí. |
| Una denegación AVC o de AppArmor | La política de acceso obligatorio bloqueó algo. Se lee, no se desactiva. |

## 3. Comprobar el puerto y el proceso

**Por qué este paso.** Si el journal dice que el puerto está ocupado, hay que ver por quién. Si dice que el binario no existe, hay que confirmar la ruta. Son dos comprobaciones mecánicas que evitan reinstalar un servicio que está perfectamente instalado.

```bash
ss -tulpn
ps aux | grep NOMBRE
```

### Qué estás viendo

```text
$ ss -tulpn | grep ':80'
tcp  LISTEN  0  511  0.0.0.0:80  0.0.0.0:*  users:(("apache2",pid=998,fd=4))
```

El puerto 80 lo tiene `apache2` con PID 998. nginx no arranca porque en esta máquina ya hay un servidor web sirviendo ese puerto: quedó de una instalación anterior, o los dos están habilitados. La decisión es de administración (cuál de los dos debe estar), no de reparación. Arrancar los dos a la vez es imposible mientras quieran el mismo puerto.

Si `ss` no muestra a nadie en el puerto y el servicio aun así dice que está ocupado, mira IPv6: muchas veces el que escucha es otro proceso en `:::80`.

Chuleta: [procesos-senales](../chuletas/procesos-senales.md).

## 4. Comprobar permisos y rutas de la unidad

**Por qué este paso.** Cuando el journal habla de permisos o de ficheros inexistentes, la causa está en la diferencia entre quién eres tú (que puedes leer todo, porque usas sudo) y quién es el servicio (el `User=` de la unidad, que puede muy poco). Probar a mano con sudo esconde exactamente el problema.

| Pieza de la unidad | Qué comprobar |
|--------------------|----------------|
| `ExecStart=` | La ruta existe y tiene permiso de ejecución. Una ruta relativa aquí es un error: systemd no garantiza el directorio desde el que arranca. |
| `User=` y `Group=` | La cuenta existe (`getent passwd`) y puede leer la configuración y escribir donde el servicio lo necesite. |
| `WorkingDirectory=` | El directorio existe. Si no existe, el servicio ni siquiera llega a ejecutarse. |
| SELinux o AppArmor | Denegaciones recientes en el audit o en el journal del kernel. Se corrige la etiqueta o el perfil; no se pasa la máquina a permissive para siempre. |

```bash
systemctl cat NOMBRE
namei -l /ruta/del/binario
sudo -u USUARIO_DEL_SERVICIO ls -l /ruta/de/la/config
```

`namei -l` recorre cada componente de la ruta y enseña los permisos de todos los directorios, que es donde se esconde un `750` de un home que impide al servicio atravesarlo. `systemctl cat` muestra la unidad resultante con sus drop-ins, que es lo que systemd usa de verdad; mirar solo el fichero de `/lib` se deja fuera precisamente las modificaciones locales.

Chuletas: [permisos-posix](../chuletas/permisos-posix.md) y [selinux-apparmor](../chuletas/selinux-apparmor.md).

## 5. Aplicar el cambio

**Por qué este paso.** Si has editado la unidad, systemd sigue teniendo en memoria la versión anterior hasta que se lo digas. Reiniciar el servicio sin recargar la unidad ejecuta otra vez lo mismo que acaba de fallar.

```bash
sudo systemctl daemon-reload
sudo systemctl restart NOMBRE
systemctl status NOMBRE
```

`daemon-reload` solo cuando cambió la unidad o un drop-in. Si el arreglo fue en la configuración propia del servicio, en un fichero o en un puerto, no hace falta: basta el `restart`. Después, `status` tiene que mostrar `active (running)` y el journal del nuevo arranque no debe repetir el error anterior.

## 6. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| El servicio está activo, o sabes por qué no | `systemctl is-active` devuelve `active`. Si decidiste dejarlo parado, hay una frase escrita que dice por qué (conflicto con otro servicio, pendiente de configuración) y está `disabled` para que el próximo reinicio no lo vuelva a intentar. |
| La causa está anotada | Una de estas: configuración, puerto ocupado, permiso, dependencia o política MAC. «Reinicié y funcionó» no es una causa; el próximo fallo empezará de cero. |
| No quedó un atajo permanente | El arreglo no consiste en permisos `777`, ni en `User=root` donde antes había un usuario propio, ni en SELinux en permissive, ni en un cortafuegos abierto. Esos cambios hacen que arranque y eliminan el control que lo impedía. |

---

*Biblioteca — runbook · servicio no arranca*
