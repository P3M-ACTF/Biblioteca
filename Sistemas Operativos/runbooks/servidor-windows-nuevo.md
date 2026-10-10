# Runbook: servidor Windows nuevo

Úsalo al recibir un Windows Server recién instalado, antes de darle un rol. Es el equivalente del runbook de máquina nueva de Linux: primero un acceso de administración que no dependa de la cuenta por defecto, después los parches, después el cortafuegos, y la unión al dominio cuando toque. El orden evita quedarte fuera y evita que un servidor sin parchear pase días expuesto.

No sustituye al estándar de tu organización. Si hay una imagen corporativa o una directiva que ya configura todo esto, eso gana, y este runbook sirve para comprobar que lo hizo.

## 1. Anotar qué va a ser

**Por qué este paso.** El rol decide qué se instala y qué puertos se abren. Un servidor «ya veremos» acaba con el Escritorio remoto abierto a toda la red y tres roles a medias.

| Dato | Por qué hace falta |
|------|--------------------|
| Nombre definitivo | Cambiarlo después de unirlo al dominio es posible y es un lío. Se decide ahora. |
| IP, máscara, puerta de enlace y DNS | Los DNS serán los controladores de dominio si va a estar en el dominio. Un DNS público aquí hace que la unión falle o vaya a trompicones (chuleta [dhcp-dns-windows-server](../chuletas/dhcp-dns-windows-server.md)). |
| Rol previsto | AD DS, ficheros, web, aplicación. Uno, dicho en voz alta. |
| Quién lo administra | Cuentas con nombre, no la cuenta Administrator compartida. |

## 2. Nombre, red y acceso de administración

**Por qué este paso.** Mientras el acceso depende de una contraseña que vino en la imagen o que conoce media empresa, el servidor no es administrable con responsabilidad. Primero se asegura un acceso tuyo, y luego se cierra el genérico.

1. Fija el nombre con `Rename-Computer -NewName srv-app01 -Restart` y la IP en el adaptador, estática si es un servidor.
2. Crea (o usa) una cuenta de administración nominativa, local de momento, y comprueba que entra por Escritorio remoto o por PowerShell remoto.
3. La cuenta `Administrator` local se queda con una contraseña larga guardada en el canal de emergencia, o deshabilitada si vuestra política lo dice. No se usa en el día a día.

Chuleta: [windows-usuarios-grupos](../chuletas/windows-usuarios-grupos.md).

### Qué estás viendo

```text
$ Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4
IPAddress    : 10.1.20.15
PrefixLength : 24

$ Get-DnsClientServerAddress -InterfaceAlias Ethernet -AddressFamily IPv4
ServerAddresses : {10.1.10.11, 10.1.10.12}
```

La IP es la prevista y los DNS son los controladores, no los del DHCP de la red de instalación. Si aquí aparece un DNS público, la unión al dominio del paso 5 va a dar problemas que parecerán del dominio.

## 3. Actualizar antes de nada

**Por qué este paso.** La imagen puede llevar meses. Instalar el rol encima de un sistema sin parchear obliga a reiniciar igual, pero con el rol ya configurado y más cosas que se pueden romper. Se parchea con el servidor todavía vacío.

```powershell
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot
```

Si no tienes el módulo, la interfaz de Windows Update hace lo mismo; lo importante es el reinicio y la comprobación de después. En una red con WSUS, el servidor recibe lo que esté aprobado, así que «sin actualizaciones pendientes» significa «al día de lo aprobado», no «al día de lo publicado».

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID, InstalledOn
```

Chuleta: [windows-roles-actualizaciones](../chuletas/windows-roles-actualizaciones.md) y [vulnerabilidades-parches](../../Ciberseguridad/chuletas/vulnerabilidades-parches.md).

## 4. Cortafuegos según el rol

**Por qué este paso.** Windows Server trae el cortafuegos activo, y los roles abren sus puertos al instalarse. Conviene mirar qué quedó abierto en lugar de darlo por bueno, y el Escritorio remoto se limita a la red de administración en vez de a cualquier origen.

```powershell
Get-NetFirewallRule -Direction Inbound -Enabled True |
  Where-Object { $_.Profile -match 'Domain' } |
  Select-Object DisplayName, Profile |
  Sort-Object DisplayName
```

### Qué estás viendo

La lista son las reglas de entrada activas en el perfil de dominio. Tienen que corresponder al rol: compartición de ficheros si es un servidor de ficheros, 443 si es web, Administración remota de Windows si vais a usar PowerShell remoto. Una regla con un nombre que no reconoces, habilitada, se investiga antes de seguir: puede venir de la imagen. El Escritorio remoto, si hace falta, con el origen acotado.

Chuleta: [windows-firewall-acceso](../chuletas/windows-firewall-acceso.md).

## 5. Unirlo al dominio, si toca

**Por qué este paso.** Va después de los parches y del cortafuegos porque la unión dispara la aplicación de directivas, y es mejor que las directivas lleguen a un servidor ya al día. Va con los DNS correctos, que se comprobaron en el paso 2.

```powershell
Add-Computer -DomainName empresa.local -Credential EMPRESA\ana -Restart
```

Tras el reinicio, el servidor tiene cuenta de equipo en el directorio y recibe las GPO de la OU donde cayó. Muévelo a la OU que le corresponde **antes** de dar nada por terminado: la OU de «equipos recién unidos» suele tener las directivas de puestos, no las de servidores.

```powershell
gpresult /r
```

La salida tiene que mostrar la OU correcta y las GPO de servidores aplicadas. Si no aparece ninguna, mira la conectividad con el controlador y los DNS antes de tocar directivas. Chuleta: [active-directory](../chuletas/active-directory.md).

## 6. Criterio de cierre

| Casilla | Qué significa que esté cumplida |
|---------|----------------------------------|
| Entras con una cuenta nominativa | Tu cuenta de administración entra, y la cuenta genérica de la instalación ya no sirve o tiene una contraseña que solo está en el depósito de emergencia. |
| Está al día y reiniciado | `Get-HotFix` muestra las actualizaciones de esta ventana y no hay reinicio pendiente. |
| Solo escucha lo del rol | La lista de reglas activas cuadra con el rol, y lo comprobaste desde otro equipo, no solo leyendo la configuración. |
| Está en su OU y con sus directivas | `gpresult /r` muestra la OU de servidores y las GPO esperadas, no las de puestos. |
| Alguien más sabría qué es | Nombre, IP, rol y responsable están donde el equipo guarda el inventario. |

---

*Biblioteca — runbook · servidor Windows nuevo*
