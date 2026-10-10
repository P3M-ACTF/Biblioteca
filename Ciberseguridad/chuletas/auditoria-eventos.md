# Chuleta: auditoría de eventos

Los registros dicen que algo ocurrió; la auditoría dice **quién** hizo **qué** sobre **qué cosa**. En Linux eso lo cubre `auditd`, que vigila llamadas del sistema según unas reglas. En Windows lo cubre el registro de Seguridad, donde cada tipo de hecho tiene un identificador numérico. Esta chuleta enseña a leer los dos: las reglas básicas de uno y los identificadores que un administrador reconoce del otro. Sirve para investigar y para cumplir; no explica cómo borrar el rastro.

---

## 1. Para qué sirve y qué cuesta

Auditar lo es todo sería inútil: el volumen taparía lo importante y llenaría el disco. Se audita lo que responde a una pregunta concreta. Las preguntas que de verdad se hacen después de un incidente son pocas: quién inició sesión, quién no pudo, quién creó una cuenta, quién la metió en un grupo de administración, qué proceso apareció y quién cambió la directiva.

Cada una de esas preguntas tiene su evento, y el trabajo de preparación es asegurarse de que ese evento se está registrando **antes** de necesitarlo. Activar la auditoría el día del incidente solo sirve para lo que pase a partir de ese momento.

---

## 2. Linux: auditd

`auditd` es un servicio que recibe eventos del kernel según las reglas cargadas, y los escribe en `/var/log/audit/audit.log`. Las reglas viven en `/etc/audit/rules.d/` y se cargan al arrancar. Se consultan con `ausearch` y `aureport`, que filtran mucho mejor que leer el fichero a mano.

```bash
sudo auditctl -l
sudo aureport -au --start today
sudo ausearch -m USER_LOGIN --start today
sudo ausearch -k identidad --start recent
```

`auditctl -l` muestra las reglas activas ahora mismo. Si no sale nada, no se está auditando nada, por muy instalado que esté el servicio.

Una regla tiene un sitio donde engancharse y una clave (`-k`) que luego sirve para buscar. Tres reglas que cubren las preguntas más frecuentes:

```text
-w /etc/passwd -p wa -k identidad
-w /etc/group -p wa -k identidad
-w /etc/sudoers -p wa -k identidad
-w /etc/sudoers.d/ -p wa -k identidad
```

`-w` vigila un fichero o directorio, `-p wa` solo las escrituras y los cambios de atributos (no cada lectura, que sería ruido), y `-k identidad` etiqueta el evento para encontrarlo después con `ausearch -k identidad`. Vigilar `/etc/passwd` y `/etc/group` registra la creación de cuentas y los cambios de grupo; vigilar sudoers registra quién amplió sus privilegios.

Para vigilar ejecuciones se engancha a la llamada del sistema en lugar de a un fichero, por ejemplo `execve` con filtros. Eso genera mucho más volumen, así que se hace con una pregunta concreta en mente y no «por si acaso».

### Qué estás viendo

```text
$ sudo ausearch -k identidad --start today
time->Sat Oct 10 09:40:12 2026
type=SYSCALL exe="/usr/sbin/useradd" success=yes key="identidad"
type=PATH name="/etc/passwd"
auid=1000 uid=0
```

`exe` dice qué programa hizo el cambio: `useradd`. `success=yes` dice que lo consiguió. `name` dice sobre qué fichero. Los dos identificadores son la parte que más importa y se confunden: `uid=0` es la identidad **efectiva** con la que se ejecutó (root, como toda llamada a través de sudo), y `auid=1000` es la identidad de **auditoría**, la de quien inició la sesión originalmente. La `auid` no cambia al hacer sudo. Por eso la auditoría responde «fue ana» donde el log normal solo dice «fue root». Sin ese campo, todo cambio administrativo parecería hecho por la misma persona.

---

## 3. Windows: los identificadores que hay que reconocer

El registro de Seguridad numera cada tipo de evento. Memorizar media docena cubre la mayoría de las preguntas, y se filtran por ese número.

| ID | Qué registra | Por qué te importa |
|----|--------------|--------------------|
| **4624** | Un inicio de sesión correcto. | Saber quién entró, desde qué equipo y con qué tipo de inicio. El tipo 3 es por red, el 10 por escritorio remoto. |
| **4625** | Un intento de inicio fallido. | Muchos seguidos sobre una cuenta son un intento de adivinar la contraseña; sobre muchas cuentas, un barrido. |
| **4740** | Una cuenta bloqueada por demasiados fallos. | El evento dice además desde qué equipo se produjeron los fallos, que es lo que necesitas para desbloquear con criterio. |
| **4720** | Se creó una cuenta. | Una cuenta que nadie recuerda haber creado es de las primeras cosas que se buscan. |
| **4732** | Se añadió un miembro a un grupo local. | Junto con 4728 (grupo global) y 4756 (grupo universal), responde quién ganó privilegios. |
| **7045** | Se instaló un servicio nuevo. | Vive en el registro de Sistema, no en el de Seguridad. Un servicio instalado a una hora rara es una forma clásica de persistencia. |

```powershell
Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4740; StartTime = (Get-Date).AddDays(-1) }
Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 7045; StartTime = (Get-Date).AddDays(-7) }
```

El filtrado por `-FilterHashtable` lo hace el propio registro, así que es rápido aunque el registro sea enorme. Filtrar después, trayendo todo y pasando por `Where-Object`, es lento y da igual de resultado.

### Qué estás viendo

En un 4624, los campos que se leen son el nombre de cuenta, el dominio, la dirección de origen y el tipo de inicio de sesión. Un 4624 de tipo 10 (escritorio remoto) desde una IP que no es de la oficina, con una cuenta de administración, a las tres de la mañana, es el evento que justifica abrir un incidente. El mismo 4624 de tipo 3 desde un servidor conocido, de día, es ruido.

En un 4740 aparece la cuenta bloqueada y el equipo que causó el bloqueo (`Caller Computer Name`). Ese equipo es el dato que el runbook de cuenta bloqueada necesita: casi siempre es un teléfono con la contraseña antigua guardada, o una tarea programada, y no un ataque. Distinguirlos es justamente para lo que está el evento.

La auditoría avanzada tiene que estar activa para que estos eventos existan. Una GPO de línea de base suele activar el inicio de sesión, la gestión de cuentas y los cambios de directiva. Si buscas 4740 en un controlador y no hay ninguno en la historia, puede que nadie se haya bloqueado nunca, o puede que esa categoría no se esté auditando: se comprueba en la directiva de auditoría avanzada antes de concluir que no pasa nada.

---

## 4. Conservarlo

Un registro que se borra a los dos días no cubre un incidente que se descubre a la semana. En Linux, el tamaño de `audit.log` se controla con la rotación propia de auditd (`max_log_file` y `num_logs` en `/etc/audit/auditd.conf`), no con logrotate. En Windows, el tamaño máximo del registro de Seguridad y la política de retención se configuran en el Visor de eventos o por GPO: cuando se llena, o se sobrescribe (pierdes lo viejo) o se para de registrar (pierdes lo nuevo). Para un servidor importante, lo sano es que una copia de los registros salga a otro sistema, porque quien controla un equipo puede limpiar sus registros.

---

## 5. Checklist

| Pregunta | Linux | Windows |
|----------|-------|---------|
| ¿Se está registrando algo? | `auditctl -l` muestra reglas | La directiva de auditoría avanzada tiene categorías en éxito y error |
| ¿Quién cambió las cuentas? | `ausearch -k identidad` | 4720, 4732, 4728, 4756 |
| ¿Quién entró o lo intentó? | `aureport -au` | 4624 y 4625, mirando el tipo de inicio |
| ¿Desde dónde se bloqueó una cuenta? | Fallos de `USER_AUTH` repetidos | 4740, campo del equipo de origen |
| ¿Apareció un servicio nuevo? | Regla sobre `systemctl` o unidades en `/etc/systemd/system` | 7045 en el registro de Sistema |
| ¿Cuánto tiempo se conserva? | `num_logs` y el tamaño en `auditd.conf` | Tamaño y retención del registro de Seguridad |

---

## 6. Error típico

**Situación.** Tras un susto, quieres saber quién añadió a un usuario al grupo `sudo` la semana pasada en un servidor Linux. Miras `/var/log/auth.log`, ves varias líneas de sudo de varios administradores y no puedes decir cuál de ellas tocó el grupo. En el journal de systemd tampoco queda, porque nadie usó `systemctl` para eso.

**Por qué ocurre.** El log de autenticación registra que alguien usó sudo, y a veces el comando, pero depende de cómo se hizo el cambio: `gpasswd`, `usermod -aG`, editar el fichero. Cada uno deja un rastro distinto y ninguno está pensado para responder esta pregunta dentro de un mes. `auditd` sí lo está, porque vigila el fichero `/etc/group` directamente y guarda la `auid` de quien lo hizo, pero en ese servidor las reglas por defecto están vacías: el servicio corre y no vigila nada. Activarlo ahora registrará el próximo cambio, no el de la semana pasada.

**Cómo se ve.** `systemctl is-active auditd` dice `active`, lo que da una confianza equivocada. `auditctl -l` no muestra ninguna regla, o solo las de un perfil a medias. `ausearch -k identidad` responde que no hay coincidencias. `/var/log/auth.log` tiene líneas `sudo` sin el detalle del fichero tocado, y la rotación se llevó las de la semana pasada.

**Cómo se arregla.** Para el incidente concreto, reconstruir con lo que haya: `last`, el historial de cada administrador, las fechas de modificación. Quedará la duda. Para que no se repita, dejar escritas las reglas sobre `/etc/passwd`, `/etc/group` y sudoers con su clave de búsqueda, comprobar con `auditctl -l` que cargan tras un reinicio, y provocar un cambio de prueba para verificar que `ausearch -k identidad` lo encuentra y que la `auid` es la de la persona y no la de root. La auditoría que no se ha probado tiene el mismo problema que la copia de seguridad que no se ha restaurado.

---

Relacionado: [respuesta-incidentes](respuesta-incidentes.md) · [logs-clasicos](../../Sistemas%20Operativos/chuletas/logs-clasicos.md) · [windows-servicios-eventos](../../Sistemas%20Operativos/chuletas/windows-servicios-eventos.md) · [selinux-apparmor](../../Sistemas%20Operativos/chuletas/selinux-apparmor.md) · [usuarios-grupos-sudo](../../Sistemas%20Operativos/chuletas/usuarios-grupos-sudo.md) · runbook [cuenta-bloqueada-ad](../../Sistemas%20Operativos/runbooks/cuenta-bloqueada-ad.md)

*Biblioteca — Ciberseguridad · auditoría de eventos*
