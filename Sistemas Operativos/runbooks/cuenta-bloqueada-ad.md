# Runbook: cuenta bloqueada en Active Directory

Úsalo cuando alguien no puede iniciar sesión y Windows le dice que la cuenta está bloqueada, o cuando salta el mismo aviso para varias cuentas a la vez. Desbloquear es lo rápido; averiguar **qué** la bloqueó es lo que evita que se vuelva a bloquear cinco minutos después. Casi nunca es un ataque: es un teléfono, una sesión guardada o una tarea con la contraseña antigua.

Chuleta de referencia: [active-directory](../chuletas/active-directory.md). El evento que lo explica está en [auditoria-eventos](../../Ciberseguridad/chuletas/auditoria-eventos.md).

## 1. Confirmar que está bloqueada, y solo eso

**Por qué este paso.** El mensaje del usuario puede ser una contraseña mal puesta, una cuenta deshabilitada o un problema de conectividad con el controlador, y el remedio es distinto en cada caso. La cuenta bloqueada tiene un estado concreto que se puede mirar.

```powershell
Get-ADUser -Identity ana -Properties LockedOut, LockoutTime, BadLogonCount, Enabled
```

Hace falta el módulo ActiveDirectory, desde un controlador o una máquina con RSAT.

### Qué estás viendo

```text
LockedOut     : True
LockoutTime   : 10/10/2026 9:42:11
BadLogonCount : 0
Enabled       : True
```

`LockedOut: True` confirma el bloqueo, y `LockoutTime` dice cuándo ocurrió. `Enabled: True` descarta que alguien la deshabilitara: eso no se arregla desbloqueando. `BadLogonCount` en cero despista: el contador se reinicia al bloquear, así que no contradice nada.

Si `LockedOut` es `False` y la persona sigue sin entrar, no sigas este runbook: es la contraseña, la conectividad o el hecho de que esté mirando a un controlador que todavía no recibió la réplica.

## 2. Averiguar desde dónde se bloqueó

**Por qué este paso.** Desbloquear sin más devuelve a la persona a la sesión, y el dispositivo que tiene guardada la contraseña vieja vuelve a fallar hasta bloquearla otra vez. El evento 4740 dice qué equipo provocó los intentos.

```powershell
Get-WinEvent -ComputerName dc01 -FilterHashtable @{
  LogName = 'Security'; Id = 4740; StartTime = (Get-Date).AddHours(-4)
} | ForEach-Object { $_.Properties[1].Value; $_.Properties[0].Value; $_.TimeCreated }
```

### Qué estás viendo

El evento trae el nombre de la cuenta y el nombre del equipo que hizo las llamadas (`Caller Computer Name`). Un portátil concreto señala un dispositivo suyo con la contraseña antigua guardada: el cliente de correo del móvil es el campeón. Un servidor señala una tarea programada o un servicio que arranca con esa cuenta. Muchos equipos distintos señalan algo peor, y entonces esto deja de ser un desbloqueo rutinario y pasa a mirarse como incidente.

Si no aparece ningún 4740, la auditoría de gestión de cuentas no está activa en el controlador o estás preguntando al controlador equivocado: el evento lo registra el controlador que procesó el intento, que puede no ser el que tienes delante. `nltest` o el propio `LockoutTime` ayudan a localizarlo; en último caso se repite la consulta en cada controlador.

## 3. Parar la causa y después desbloquear

**Por qué este paso.** El orden importa. Si desbloqueas mientras el móvil sigue intentando cada treinta segundos, la cuenta vuelve a caer antes de que la persona termine de entrar. Primero se corta el origen, luego se abre la cuenta.

Según lo que dijera el 4740: pedirle que quite la cuenta del correo del móvil, parar la tarea programada, o desconectar ese equipo de la red. Cuando el origen es un servicio con la contraseña antigua, la solución buena es cambiar la cuenta de servicio a una contraseña nueva (o a una cuenta gestionada) y actualizar el servicio, no subir el umbral de bloqueo para que quepa el problema.

```powershell
Unlock-ADAccount -Identity ana
Get-ADUser -Identity ana -Properties LockedOut | Select-Object LockedOut
```

### Qué estás viendo

`LockedOut: False` confirma el desbloqueo en el controlador al que preguntaste. La réplica tarda un poco en llegar al resto; si la persona autentica contra otro controlador en ese minuto, puede seguir viéndose bloqueada. Esperar un momento y reintentar, no volver a desbloquear en bucle.

## 4. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| La cuenta está desbloqueada en los controladores | `LockedOut` es `False` y la persona ha entrado, no solo tú has ejecutado el comando. |
| Se sabe qué la bloqueó | Una frase: «el móvil con la contraseña anterior», «la tarea del servidor de informes». «Se desbloqueó» no vale, porque va a repetirse. |
| El origen está parado | La tarea actualizada, el móvil reconfigurado, el servicio con la contraseña nueva. Si no se pudo localizar, queda anotado para vigilar si se repite hoy. |
| No se tocó la política para esconderlo | El umbral de bloqueo sigue donde estaba. Subirlo evita la llamada y también el aviso que te da un ataque de contraseñas. |

---

*Biblioteca — runbook · cuenta bloqueada en AD*
