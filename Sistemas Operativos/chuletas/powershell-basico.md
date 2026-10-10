# Chuleta: PowerShell básico

PowerShell no es una línea de comandos que devuelve texto: es un shell donde los comandos devuelven **objetos**, y el siguiente comando trabaja con esos objetos en lugar de recortar columnas con `awk`. Casi todos los cmdlets de administración de Windows que aparecen en las otras chuletas se entienden mejor con esa idea. Esta chuleta explica el modelo, cómo descubrir qué puede hacer un comando y cómo filtrar y sacar los datos.

---

## 1. Cmdlets y objetos

Un cmdlet se nombra con un verbo y un sustantivo: `Get-Service`, `Restart-Service`, `Get-NetIPAddress`. El verbo dice la acción y el sustantivo sobre qué. `Get-Command` lista los que hay; `Get-Verb` los verbos admitidos, que son una lista cerrada a propósito para que se puedan adivinar.

Lo que devuelve no es una cadena. `Get-Service sshd` devuelve un objeto con propiedades (`Name`, `Status`, `StartType`) y métodos. La consola lo pinta como una tabla porque hay que pintarlo de alguna forma, pero el objeto sigue ahí hasta que lo conviertes en texto. Esa diferencia lo es todo: mientras sea un objeto puedes pedir una propiedad; en cuanto es texto, solo puedes recortar caracteres.

```powershell
Get-Service sshd
Get-Service sshd | Get-Member
(Get-Service sshd).Status
```

### Qué estás viendo en `Get-Member`

```text
TypeName: System.ServiceProcess.ServiceController

Name        MemberType   Definition
----        ----------   ----------
Start       Method       void Start()
Stop        Method       void Stop()
Name        Property     string Name {get;}
Status      Property     ServiceControllerStatus Status {get;}
StartType   Property     ServiceStartMode StartType {get;set;}
```

`TypeName` dice qué clase de objeto es. Todo lo que pone `Property` se puede leer (y a veces escribir); lo que pone `Method` se puede ejecutar. Cuando un comando saca diez columnas y tú necesitas una que no se ve, `Get-Member` enseña las que existen de verdad, que suelen ser muchas más de las que la tabla pinta.

---

## 2. La tubería filtra objetos, no texto

El `|` pasa objetos de un comando al siguiente. `Where-Object` se queda con los que cumplen una condición, `Select-Object` se queda con algunas propiedades, `Sort-Object` ordena por una propiedad de verdad (no alfabéticamente como texto, salvo que lo sea).

```powershell
Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, StartType
Get-Service | Where-Object Status -eq Running | Sort-Object Name
Get-Process | Sort-Object WS -Descending | Select-Object -First 5 Name, WS
```

`$_` es el objeto que está pasando en ese momento. `-eq` compara; los operadores van con guion (`-eq`, `-ne`, `-gt`, `-like`, `-match`) en lugar de símbolos. `-like` usa comodines de shell (`*sql*`) y `-match` usa expresiones regulares.

La forma corta `Where-Object Status -eq Running` vale cuando la condición es una sola propiedad; el bloque con llaves vale para todo lo demás.

### Qué estás viendo

```text
$ Get-Process | Sort-Object WS -Descending | Select-Object -First 3 Name, WS

Name       WS
----       --
sqlservr   734003200
w3wp       251658240
MsMpEng    188743680
```

`WS` es la memoria de trabajo en bytes, y el orden es numérico: 734 millones va delante de 251 millones. Ordenar eso como texto habría puesto delante cualquier proceso cuyo número empezara por 9. `Select-Object -First 3` corta después de ordenar, que es lo que quieres; filtrar antes de ordenar te dejaría los tres primeros que aparezcan, no los tres mayores.

---

## 3. Pedir ayuda

La ayuda de PowerShell se actualiza aparte del sistema. Con `Update-Help` (en una sesión con privilegios y salida a Internet) se descargan los manuales completos; sin eso, `Get-Help` da una versión resumida.

```powershell
Get-Help Get-NetIPAddress
Get-Help Get-NetIPAddress -Examples
Get-Help Get-NetIPAddress -Parameter AddressFamily
Get-Command *NetIP*
```

`-Examples` enseña usos reales, que suele ser lo más útil. `-Parameter` explica uno concreto. `Get-Command *NetIP*` descubre cmdlets cuyo nombre no recuerdas: el comodín busca en verbo y sustantivo.

Los parámetros comunes están en casi todos los cmdlets: `-ErrorAction Stop` convierte un error que se saltaría en uno que para el script, y `-WhatIf` dice qué haría un comando que cambia algo, sin hacerlo. En cualquier cmdlet que borre o modifique, `-WhatIf` antes de lanzarlo en serio.

---

## 4. Sacar los datos fuera

Mientras los datos son objetos, puedes convertirlos al formato que necesites al final. Convertir a texto a mitad de la tubería es tirar la estructura.

```powershell
Get-Service | Where-Object Status -eq Running |
  Select-Object Name, StartType |
  Export-Csv -Path C:\Temp\servicios.csv -NoTypeInformation

Get-NetIPAddress -AddressFamily IPv4 |
  ConvertTo-Json | Out-File C:\Temp\ips.json
```

`Export-Csv` escribe propiedades como columnas, y `-NoTypeInformation` evita una primera línea con el nombre del tipo que estorba al abrirlo. `ConvertTo-Json` sirve para pasarlo a otra herramienta. `Out-File` y la redirección escriben texto ya formateado: bien para un informe, mal para seguir procesando.

Para leer de vuelta, `Import-Csv` devuelve objetos otra vez, con las columnas como propiedades.

---

## 5. Errores que confunden al principio

| Lo que pasa | Por qué |
|-------------|---------|
| La comparación no cuela nunca | PowerShell compara con `-eq`, no con `=`. El `=` es para asignar. |
| `Where-Object` no filtra nada y tampoco se queja | Las propiedades van con su nombre exacto. `$_.status` y `$_.Status` no son lo mismo cuando el objeto distingue mayúsculas, y una propiedad que no existe simplemente sale vacía. `Get-Member` lo aclara. |
| Un comando dice que no existe | El módulo no está cargado. `Get-Module -ListAvailable` enseña los instalados; `Import-Module ActiveDirectory` lo carga. Muchos módulos de administración se instalan con las RSAT y no están en un Windows normal. |
| La ejecución de scripts está bloqueada | La política por defecto impide scripts. `Get-ExecutionPolicy` la muestra; cambiarla es una decisión de seguridad, no un paso de un tutorial. Para probar, puedes ejecutar comando a comando sin cambiar nada. |

---

## 6. Checklist

| Quiero | Comando |
|--------|---------|
| Saber qué propiedades tiene esto | `... \| Get-Member` |
| Quedarme con las filas que cumplen | `Where-Object { $_.Propiedad -eq 'valor' }` |
| Quedarme con algunas columnas | `Select-Object Propiedad1, Propiedad2` |
| Ver los más grandes | `Sort-Object Propiedad -Descending \| Select-Object -First 10` |
| Aprender un cmdlet | `Get-Help Cmdlet -Examples` |
| Llevarlo a una hoja de cálculo | `Export-Csv -NoTypeInformation` |
| Probar sin romper | `-WhatIf` en el cmdlet que modifica |

---

## 7. Error típico

**Situación.** Quieres los servicios parados cuyo tipo de arranque sea automático: son los que deberían estar corriendo y no lo están. Escribes `Get-Service | Where-Object { $_.Status = 'Stopped' }` y la salida es todos los servicios, o un error de asignación. Lo intentas con comillas distintas. Nada cambia.

**Por qué ocurre.** El operador `=` asigna. Dentro del bloque has asignado `Stopped` a la propiedad de cada objeto que pasaba, y el resultado de una asignación es el propio valor, que es siempre verdadero, así que el filtro deja pasar todo. No estabas filtrando: estabas escribiendo la misma propiedad en cada objeto que recorrías. (En objetos de solo lectura fallará con un error por objeto, que es igual de confuso.)

**Cómo se ve.** O sale la lista completa sin filtrar, o una retahíla de errores «Property is read-only». `Get-Member` muestra que `Status` existe y se llama exactamente así. La ayuda de `Where-Object`, en los ejemplos, usa `-eq`.

**Cómo se arregla.** Comparar con `-eq` y encadenar condiciones con `-and`:

```powershell
Get-Service | Where-Object { $_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic' }
```

La salida ahora solo tiene los servicios que están parados debiendo arrancar, que son los que ibas a buscar. El reflejo útil es que en cuanto un filtro devuelve todo o nada, el fallo está en la comparación, y `Get-Member` más `-eq` lo resuelven casi siempre.

---

Relacionado: [windows-servicios-eventos](windows-servicios-eventos.md) · [windows-usuarios-grupos](windows-usuarios-grupos.md) · [active-directory](active-directory.md) · [diagnostico](../../Redes/chuletas/diagnostico.md)

*Biblioteca — Sistemas Operativos · PowerShell básico*
