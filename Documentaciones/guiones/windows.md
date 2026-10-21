# Guion de contenidos · Windows: consulta y administración

[Catálogo y criterios de cobertura](README.md) · [Plantilla](PLANTILLA.md)

## Alcance y estado

Windows cliente y Windows Server: terminal, sistema, red, identidad, almacenamiento, procesos, servicios y automatización. Distinguir Windows PowerShell 5.1, PowerShell 7, CMD, ejecutables externos y herramientas gráficas. Registrar edición/build/arquitectura, módulos disponibles y roles instalados. Active Directory/RSAT, Hyper-V, IIS y otros roles son bloques opcionales explícitos; no presuponerlos en un equipo cliente. Todos los ejemplos administrativos se desarrollarán en laboratorio, con comprobación y reversión.

**Estado:** guion inicial; desarrollo, contraste exhaustivo de opciones y pruebas pendientes. Las variantes de las tablas son puntos de trabajo, no instrucciones listas para ejecutar. No se afirma cobertura exhaustiva de todas las versiones. Aplicar el [criterio de cierre](README.md#cuándo-se-puede-decir-completo) antes de marcar una familia como completa.

## Temario

### WIN-T01 · Entorno y terminal

- [ ] Versiones, ediciones, arquitectura, cliente/Server/Core, actualizaciones y ciclo de soporte.
- [ ] Windows Terminal, consolas, perfiles, PATH, variables, codificación, redirección y pipelines.
- [ ] Objetos PowerShell frente a texto CMD, aliases y resolución de ejecutables; powershell.exe frente a pwsh.exe.
- [ ] Ayuda, módulos, parámetros comunes, parameter sets, tipos, arrays, pipeline binding y errores.
- [ ] UAC, elevación, otra identidad, runas y persistencia del entorno; otra cuenta no implica elevación.

### WIN-T02 · Archivos y datos

- [ ] Rutas, unidades/volúmenes, proveedores PowerShell, enlaces, atributos y streams NTFS.
- [ ] Crear, copiar, mover, renombrar, buscar, comparar, comprimir y calcular hashes.
- [ ] CSV/JSON/XML/CLIXML, registros de texto, encoding, locale y expresiones regulares.
- [ ] Registro de Windows, variables persistentes, exportación y restauración.

### WIN-T03 · Usuarios y grupos

- [ ] SAM local frente a AD/Entra ID; SID, cuenta, perfil, token, grupos y privilegios.
- [ ] Crear, consultar, modificar, habilitar/deshabilitar y retirar cuentas y grupos.
- [ ] Contraseñas, expiración, bloqueo, derechos de inicio de sesión, credenciales y cuentas de servicio.
- [ ] Operaciones con otra identidad, sesiones locales/RDP y auditoría.

### WIN-T04 · Permisos, ACL e herencia

- [ ] NTFS: owner, DACL/SACL, ACE allow/deny, derechos básicos/avanzados y orden canónico.
- [ ] Herencia, propagación a archivos/carpetas, protección, permisos explícitos y efectivos.
- [ ] Permisos de recurso compartido frente a NTFS; acceso remoto y evaluación del token.
- [ ] Consultar, guardar, conceder, denegar, retirar, restablecer y restaurar ACL; tomar posesión no concede automáticamente acceso.
- [ ] Auditoría de acceso, privilegios, integridad obligatoria, EFS y diferencias con BitLocker.

### WIN-T05 · Procesos y rendimiento

- [ ] Proceso, hilo, PID/PPID, usuario, sesión, línea de comandos, prioridad, handles y memoria.
- [ ] Consultar/filtrar, relacionar PID con servicio/puerto, iniciar/esperar/detener y árbol de procesos.
- [ ] CPU, RAM, disco/red, contadores, eventos, dumps y herramientas de diagnóstico.
- [ ] Herramientas Sysinternals opcionales: procedencia y diferencias con componentes integrados.

### WIN-T06 · Servicios y tareas

- [ ] Servicio frente a proceso; tipo de inicio, estado, dependencias, triggers y recuperación.
- [ ] Consultar, crear, configurar, iniciar/parar/reiniciar y retirar un servicio real de laboratorio.
- [ ] Identidad LocalSystem/LocalService/NetworkService/cuenta dedicada, logon as a service, ACL de servicio y mínimo privilegio.
- [ ] Tareas programadas: acciones, triggers, principal, logon type, elevación, condiciones, historial y códigos de resultado.
- [ ] Equivalencias PowerShell, sc.exe/schtasks.exe y MMC; quoting de binPath y rutas con espacios.

### WIN-T07 · Red y acceso remoto

- [ ] Adaptadores, IPv4/IPv6, DHCP, DNS, rutas, ARP/neighbor, conexiones y listeners.
- [ ] Consulta frente a cambios de IP/DNS/ruta; persistencia y recuperación de acceso.
- [ ] Windows Defender Firewall, perfiles, reglas, puertos, programas, servicios y logs.
- [ ] SMB, WinRM/PowerShell Remoting, SSH, RDP, TLS y certificados.

### WIN-T08 · Almacenamiento, hardware y recuperación

- [ ] Discos/particiones/volúmenes, GPT/MBR, NTFS/ReFS/FAT/exFAT, mount points y Storage Spaces.
- [ ] Drivers, dispositivos, firmware, arranque UEFI, BCD, Secure Boot, BitLocker y recuperación.
- [ ] Integridad, SFC/DISM/CHKDSK, imágenes, copias, restauración y WinRE.
- [ ] Instalación/retirada de software, winget, MSI, features/capabilities y políticas.

### WIN-T09 · Administración de dominio y roles

- [ ] AD DS/DNS, OU, usuarios/grupos/equipos, delegación, GPO y replicación; RSAT separado.
- [ ] DHCP/DNS/IIS/Hyper-V/WSL: inventarios por rol/módulo, instalación y ámbitos.
- [ ] Entra ID, unión/registro, certificados y autenticación; distinguir módulos locales de APIs cloud.
- [ ] Gestión remota, cuentas administradas, LAPS y Just Enough Administration según entorno.

### WIN-T10 · Automatización, seguridad y auditoría

- [ ] Scripts, funciones, módulos, parámetros, validación, errores, logs, jobs y runspaces.
- [ ] Políticas de ejecución y firma; no confundir execution policy con frontera de seguridad.
- [ ] Defender, políticas locales/GPO, auditoría, eventos, credenciales y mínimos privilegios.
- [ ] Inventario completo por build/módulo/rol y catálogo CMD; diferencias deprecadas como WMIC frente a CIM.

## Inventario de comandos, opciones y configuración

Cada fila identifica una unidad estable para enlazarla desde guías y chuletas. Desglosar **cada** subcomando, opción, argumento, directiva, valor admitido y caso en la ficha de la plantilla; conservar el ID de esta unidad como padre. Las opciones aquí recogidas son el inventario inicial, pendiente de reconciliar con el manual de la versión elegida. No trasladar opciones entre comandos de una misma fila sin consultar su sintaxis.

| ID | Comando, operación o directiva | Variantes que hay que desglosar | Casos y lectura de resultados |
| --- | --- | --- | --- |
| <a id="win-c001"></a>WIN-C001 | `Get-Help`, `Get-Command`, `Get-Module` | `-Full`, `-Examples`, `-Parameter`, `-Syntax`, `-Module`, `-ListAvailable` según cmdlet | Descubrir cmdlets/funciones/aliases, versión y parameter sets sin instalar módulos. |
| <a id="win-c002"></a>WIN-C002 | Identidad del entorno | `$PSVersionTable`, `Get-ComputerInfo`, `Get-CimInstance Win32_OperatingSystem`, `systeminfo`, `ver`, `winver` | Build, edición, arquitectura, shell y disponibilidad real. |
| <a id="win-c003"></a>WIN-C003 | Parámetros comunes PowerShell | `-Verbose`, `-Debug`, `-ErrorAction`, `-WarningAction`, `-InformationAction`, variables de streams, `-WhatIf`, `-Confirm` cuando estén soportados | No todos los cmdlets aceptan ShouldProcess; preferencia de errores frente a código nativo. |
| <a id="win-c004"></a>WIN-C004 | Objetos y salida | `Get-Member`, `Select-Object`, `Where-Object`, `Sort-Object`, `Group-Object`, `Measure-Object`, `ForEach-Object`, `Format-Table`, `Format-List`, `Out-String` | Propiedades, objetos perdidos por formatear demasiado pronto y campos calculados. |
| <a id="win-c005"></a>WIN-C005 | Comparación y datos | `Compare-Object`, `Tee-Object`, `Export-Csv`, `Import-Csv`, `ConvertTo-Json`, `ConvertFrom-Json`, `Export-Clixml`, `Import-Clixml` | Propiedades, depth, delimitador, encoding y límites de secretos serializados. |
| <a id="win-c006"></a>WIN-C006 | Archivos y proveedores | `Get-Location`, `Set-Location`, `Get-PSDrive`, `Get-ChildItem`, `Get-Item`, `New-Item`, `Copy-Item`, `Move-Item`, `Rename-Item`, `Remove-Item`, `Test-Path`, `Resolve-Path` | `-LiteralPath` frente a patrones, `-Recurse`, `-Force`, `-Filter`, proveedores y enlaces. |
| <a id="win-c007"></a>WIN-C007 | Contenido y búsqueda | `Get-Content`, `Set-Content`, `Add-Content`, `Clear-Content`, `Select-String`, `Get-FileHash`, `Compress-Archive`, `Expand-Archive` | `-Raw`, `-Tail`, `-Wait`, `-Encoding`, regex, algoritmo y sobrescritura donde proceda. |
| <a id="win-c008"></a>WIN-C008 | CMD archivos y texto | `dir`, `cd`, `md`, `rd`, `copy`, `xcopy`, `move`, `ren`, `del`, `type`, `more`, `find`, `findstr`, `fc`, `attrib`, `mklink` | Inventariar cada switch desde ayuda; rutas, recursión, atributos y códigos de salida. |
| <a id="win-c009"></a>WIN-C009 | `robocopy` | `/E`, `/MIR`, `/COPY`, `/DCOPY`, `/SEC`, `/SECFIX`, `/B`, `/Z`, `/R`, `/W`, `/MT`, `/L`, `/LOG`, `/TEE`, `/XJ` | Metadatos/ACL, enlaces, espejo destructivo y códigos de salida distintos de 0=fallo. |
| <a id="win-c010"></a>WIN-C010 | Entorno y registro | `Get/Set/New/Remove-ItemProperty`, `Get-ItemPropertyValue`, `reg.exe query/add/delete/export/import/save/restore`, `set`, `setx`, `[Environment]` | Proceso/usuario/máquina, tipo de dato, precedencia y consola ya abierta. |
| <a id="win-c011"></a>WIN-C011 | `Start-Process`, `runas.exe` | `-Verb RunAs`, `-Credential`, `-ArgumentList`, `-WorkingDirectory`, `-Wait`, `-PassThru`; runas `/user`, `/netonly`, `/profile` | Elevación frente a otra identidad, quoting y credenciales sin texto plano. |
| <a id="win-c012"></a>WIN-C012 | Usuarios locales PowerShell | `Get/New/Set/Remove-LocalUser`, `Enable/Disable-LocalUser`; `-Name`, `-SID`, `-Password`, expiración y estado según cmdlet | Existencia, Enabled, SID y password policies; disponibilidad del módulo/arquitectura. |
| <a id="win-c013"></a>WIN-C013 | Grupos locales PowerShell | `Get/New/Set/Remove-LocalGroup`, `Get/Add/Remove-LocalGroupMember` | Nombre/SID, miembros locales/dominio, duplicados y nombres localizados. |
| <a id="win-c014"></a>WIN-C014 | `net user`, `net localgroup`, `net group`, `net accounts` | Consulta, `/add`, `/delete`, `/active`, `/expires`, `/domain`, políticas y argumentos por orden | Cuenta local/dominio, membresía y políticas; no poner contraseñas en historial. |
| <a id="win-c015"></a>WIN-C015 | Sesión e identidad | `whoami /user /groups /priv /all`, `query user`, `quser`, `qwinsta`, `logoff`, `klist`, `cmdkey` | SID, grupos habilitados/deny-only, privilegios, sesiones y caché de tickets/credenciales. |
| <a id="win-c016"></a>WIN-C016 | `Get-Acl`, `Set-Acl` | `-Path`, `-LiteralPath`, `-Audit`; owner, Access, Audit, Sddl y objetos FileSystemAccessRule | DACL/SACL, herencia, propagación y permisos efectivos frente a entradas listadas. |
| <a id="win-c017"></a>WIN-C017 | `icacls` | `/grant`, `/grant:r`, `/deny`, `/remove`, `/remove:g`, `/remove:d`, `/inheritance:e`, `/inheritance:d`, `/inheritance:r`, `/reset`, `/save`, `/restore`, `/verify`, `/findsid`, `/setowner`, `/T`, `/C`, `/L` | Sintaxis ACE, OI/CI/IO/NP, permisos básicos/avanzados, backup y recuperación. |
| <a id="win-c018"></a>WIN-C018 | `takeown`, auditoría y owner | `/F`, `/R`, `/A`, `/D` según takeown; `auditpol /get /set /list /backup /restore` | Cambiar owner frente a conceder permiso; políticas y eventos de acceso. |
| <a id="win-c019"></a>WIN-C019 | SMB recursos y sesiones | `Get/New/Set/Remove-SmbShare`, `Get-SmbShareAccess`, `Grant/Revoke/Block/Unblock-SmbShareAccess`, `Get-SmbSession`, `Get-SmbOpenFile`, `Close-SmbSession`, `Close-SmbOpenFile` | Permisos share+NTFS, archivos abiertos y operaciones que interrumpen sesiones. |
| <a id="win-c020"></a>WIN-C020 | SMB cliente y CMD | `Get/New/Remove-SmbMapping`, `Get-SmbConnection`, `net use`, `net share`, `net session`, `net file` | Mapeos por usuario/sesión, credenciales y conexiones persistentes. |
| <a id="win-c021"></a>WIN-C021 | ACL e interfaces gráficas | Propiedades → Seguridad/Avanzadas, acceso efectivo, auditoría; secpol.msc y Computer Management | Inventariar campos, owner, herencia, objetos y diferencias según edición. |
| <a id="win-c022"></a>WIN-C022 | Consulta de procesos | `Get-Process`, `Get-CimInstance Win32_Process`, `tasklist`; `-Id`, `-Name`, `-IncludeUserName`, `-Filter`, `/FI`, `/V`, `/SVC` según herramienta | PID/PPID, usuario, ejecutable, commandline, CPU acumulada y memoria. |
| <a id="win-c023"></a>WIN-C023 | Operación de procesos | `Start-Process`, `Stop-Process`, `Wait-Process`, `Debug-Process`, `taskkill`; PID/nombre, `-Force`, `/PID`, `/IM`, `/T`, `/F` según orden | Salida normal frente a terminación forzada, árbol y permisos. |
| <a id="win-c024"></a>WIN-C024 | Rendimiento y diagnóstico | `Get-Counter`, `Get-WinEvent`, Task Manager, Resource Monitor, Performance Monitor, `typeperf`, `logman` | Contador, intervalo, muestras, localización de nombres y diferencias CPU/RAM/I/O. |
| <a id="win-c025"></a>WIN-C025 | Sysinternals opcional | Process Explorer, Process Monitor, Autoruns, TCPView, AccessChk, PsList, PsService y ProcDump | Procedencia y licencia; inventario separado de flags de cada herramienta añadida. |
| <a id="win-c026"></a>WIN-C026 | Consulta y control de servicios | `Get-Service`, `Start/Stop/Restart/Suspend/Resume-Service`, `Set-Service`; nombre/display name, estado, dependencias e inicio | Servicio frente a proceso; dependencia, pausa soportada y reinicio. |
| <a id="win-c027"></a>WIN-C027 | Alta/baja de servicios | `New-Service`, `Remove-Service` si existe; `-BinaryPathName`, `-StartupType`, `-Credential`, `-DependsOn` según cmdlet | Crear entrada no convierte cualquier script en un servicio; binario compatible y rollback. |
| <a id="win-c028"></a>WIN-C028 | CIM servicios | `Get-CimInstance Win32_Service`, `Invoke-CimMethod` con `Change`, `StartService`, `StopService`, `Delete` | StartName, StartMode, PathName, ProcessId y ReturnValue; valores de retorno específicos. |
| <a id="win-c029"></a>WIN-C029 | `sc.exe` | `query`, `queryex`, `qc`, `qdescription`, `qfailure`, `qtriggerinfo`, `qprivs`, `qsidtype`, `enumdepend`, `start`, `stop`, `pause`, `continue`, `create`, `config`, `description`, `failure`, `triggerinfo`, `privs`, `sidtype`, `sdshow`, `sdset`, `delete` | Inventariar flags por subcomando, espacios tras `=`, binPath, cuenta, DACL y errores. |
| <a id="win-c030"></a>WIN-C030 | Servicios e identidad | LocalSystem, LocalService, NetworkService, usuario dedicado, gMSA cuando aplique, derecho SeServiceLogonRight | Cambiar cuenta y verificar ejecución/privilegios; no justificar SYSTEM por comodidad del laboratorio. |
| <a id="win-c031"></a>WIN-C031 | `services.msc` | Inicio, cuenta, recuperación, dependencias, parámetros y estado | Equivalencias con comandos; operación bloqueada y cambios pendientes. |
| <a id="win-c032"></a>WIN-C032 | Consulta de tareas | `Get-ScheduledTask`, `Get-ScheduledTaskInfo`, `Export-ScheduledTask` | TaskPath/TaskName, State, LastRunTime, NextRunTime, LastTaskResult e historial. |
| <a id="win-c033"></a>WIN-C033 | Definición de tareas | `New-ScheduledTask`, `New-ScheduledTaskAction`, `New-ScheduledTaskTrigger`, `New-ScheduledTaskPrincipal`, `New-ScheduledTaskSettingsSet` | Acción, argumentos, working directory, cronología, LogonType, RunLevel y condiciones. |
| <a id="win-c034"></a>WIN-C034 | Operación de tareas | `Register/Set/Unregister/Start/Stop/Enable/Disable-ScheduledTask` | Nombre/ruta/XML, identidad, credenciales, persistencia y resultado. |
| <a id="win-c035"></a>WIN-C035 | `schtasks.exe` | `/Query`, `/Create`, `/Change`, `/Run`, `/End`, `/Delete`; `/TN`, `/TR`, `/SC`, `/MO`, `/ST`, `/SD`, `/RU`, `/RL`, `/IT`, `/XML`, `/V`, `/FO`, `/F` según operación | Cuenta, interactiva/no interactiva, schedule y quoting de argumentos. |
| <a id="win-c036"></a>WIN-C036 | Task Scheduler GUI | Carpeta, General, Triggers, Actions, Conditions, Settings, History y XML | Inventariar todos los campos; ejecución manual frente a trigger real. |
| <a id="win-c037"></a>WIN-C037 | Adaptadores e IP consulta | `Get-NetAdapter`, `Get-NetIPConfiguration`, `Get-NetIPAddress`, `Get-NetIPInterface`, `Get-DnsClientServerAddress`, `Get-NetConnectionProfile` | Interfaz, índice, estado, dirección/prefijo, origen DHCP y perfil. |
| <a id="win-c038"></a>WIN-C038 | IP/DNS administración | `New/Set/Remove-NetIPAddress`, `Set-NetIPInterface`, `Set-DnsClientServerAddress`, `Enable/Disable/Restart-NetAdapter`, `Set-NetConnectionProfile` | Configuración persistente, DHCP/estática, gateway y recuperación tras perder acceso. |
| <a id="win-c039"></a>WIN-C039 | DNS y pruebas | `Resolve-DnsName`, `Test-NetConnection`, `Test-Connection`, `Get-DnsClientCache`, `Clear-DnsClientCache`, `ipconfig`, `nslookup`, `ping`, `tracert`, `pathping` | DNS frente a conectividad, protocolo/puerto, caché y salto sin respuesta. |
| <a id="win-c040"></a>WIN-C040 | Rutas y vecinos | `Get/New/Set/Remove-NetRoute`, `Find-NetRoute`, `Get/New/Remove-NetNeighbor`, `route`, `arp` | Prefijo, next hop, métricas, scope, persistencia y vecinos IPv4/IPv6. |
| <a id="win-c041"></a>WIN-C041 | Conexiones y listeners | `Get-NetTCPConnection`, `Get-NetUDPEndpoint`, `netstat -ano`, `Get-CimInstance Win32_Service` | LocalAddress/Port, State, PID, proceso y servicio; loopback frente a todas las interfaces. |
| <a id="win-c042"></a>WIN-C042 | Firewall | `Get/New/Set/Remove/Enable/Disable-NetFirewallRule`, filtros Address/Port/Application/Service, `Get/Set-NetFirewallProfile`, `netsh advfirewall` | Dirección, acción, perfiles, puertos, programa/servicio, rule store y política efectiva. |
| <a id="win-c043"></a>WIN-C043 | SMB/WinRM/SSH/RDP remoto | `Test-WSMan`, `Enter-PSSession`, `New/Get/Remove-PSSession`, `Invoke-Command`, `Enable-PSRemoting`, `winrm`, `mstsc`, `ssh` | Transporte, autenticación, sesión, delegación y firewall; habilitar solo el servicio necesario. |
| <a id="win-c044"></a>WIN-C044 | Discos y volúmenes consulta | `Get-Disk`, `Get-PhysicalDisk`, `Get-Partition`, `Get-Volume`, `Get-StoragePool`, `Get-VirtualDisk`, `mountvol` | Disco físico/lógico, salud, bus, particiones, filesystem, capacidad y puntos de montaje. |
| <a id="win-c045"></a>WIN-C045 | Discos y volúmenes administración | `Initialize-Disk`, `New/Resize/Remove-Partition`, `Format-Volume`, `Set-Disk`, `Set-Partition`, Storage Spaces | Número/UniqueId validado, GPT/MBR, formato y riesgo destructivo en disco de laboratorio. |
| <a id="win-c046"></a>WIN-C046 | `diskpart` | `list`, `select`, `detail`, `create`, `delete`, `clean`, `convert`, `format`, `assign`, `extend`, `shrink`, `active` | Contexto seleccionado, comandos por objeto y consecuencias para datos/arranque. |
| <a id="win-c047"></a>WIN-C047 | Integridad y recuperación | `sfc /scannow`, DISM `/Online /Cleanup-Image /CheckHealth /ScanHealth /RestoreHealth`, `chkdsk`, `reagentc`, `wbadmin`, `bcdedit`, `bcdboot` | Consulta frente a reparación offline/online; logs, origen de reparación y BCD. |
| <a id="win-c048"></a>WIN-C048 | Software y componentes | `winget search/show/list/install/upgrade/uninstall/export/import/source`, `msiexec`, `Get-Package`, `Get/Enable/Disable-WindowsOptionalFeature`, `Get/Add/Remove-WindowsCapability` | Origen, alcance, silent, reinicio, dependencias y estado de instalación. |
| <a id="win-c049"></a>WIN-C049 | Windows Server roles | `Get/Install/Uninstall-WindowsFeature`, Server Manager, RSAT y módulos de rol | Disponibilidad por edición y herramientas de administración frente al rol de servidor. |
| <a id="win-c050"></a>WIN-C050 | Dispositivos y drivers | `Get-PnpDevice`, `Get-PnpDeviceProperty`, `pnputil`, `driverquery`, CIM hardware | Estado, instance ID, paquete, firma y reversión del controlador. |
| <a id="win-c051"></a>WIN-C051 | Actualización, energía y arranque | Windows Update e inventario soportado por versión; `Get-HotFix`, `powercfg`, `shutdown`, `Restart-Computer`, `Stop-Computer`, `Confirm-SecureBootUEFI` | Reinicio pendiente, soporte real de cmdlets y estado firmware. |
| <a id="win-c052"></a>WIN-C052 | Cifrado y certificados | `Get/Enable/Disable-BitLocker`, `manage-bde`, `cipher`, `Get-ChildItem Cert:`, `certutil`, `certreq`, `Import/Export-Certificate`, `Import/Export-PfxCertificate` | BitLocker/EFS, almacén/clave privada, thumbprint, cadena y recuperación sin exponer claves. |
| <a id="win-c053"></a>WIN-C053 | Defender y política local | `Get-MpComputerStatus`, `Get/Set-MpPreference`, `Start-MpScan`, `Get-MpThreatDetection`, `secedit`, `auditpol`, secpol.msc | Estado, firmas, detecciones y política efectiva; no desactivar protección para corregir errores. |
| <a id="win-c054"></a>WIN-C054 | Eventos y logs | `Get-WinEvent`, `wevtutil el/ep/qe/epl/sl/cl`, Event Viewer, `Start/Stop-Transcript` | Proveedor, canal, nivel, Event ID, tiempo, filtro y exportación; limpiar destruye evidencia. |
| <a id="win-c055"></a>WIN-C055 | GPO y dominio | `gpupdate`, `gpresult`, `Get-GPO`, `Get-GPResultantSetOfPolicy`, `Get-GPInheritance`, `Get/Set-GPRegistryValue` | Usuario/equipo, ámbito, precedencia, herencia y política resultante. |
| <a id="win-c056"></a>WIN-C056 | AD usuarios/grupos/equipos | `Get/New/Set/Remove-ADUser`, ADGroup, ADComputer; `Add/Remove/Get-ADGroupMember`, `Get-ADPrincipalGroupMembership` | Filtro LDAP/PowerShell, SearchBase, OU/DN, scope, categorías y propiedades no cargadas. |
| <a id="win-c057"></a>WIN-C057 | AD cuentas y delegación | `Enable/Disable-ADAccount`, `Unlock-ADAccount`, `Set-ADAccountPassword`, `Search-ADAccount`, `Move-ADObject`, OU y ACL AD | Expiración/bloqueo, mínimos privilegios y diferencia entre ACL AD y NTFS. |
| <a id="win-c058"></a>WIN-C058 | AD diagnóstico | `Get-ADDomain`, `Get-ADForest`, `Get-ADDomainController`, `Get-ADReplication*`, `repadmin`, `dcdiag`, `nltest`, `Test-ComputerSecureChannel` | DC, DNS, trusts, replicación y canal seguro; catálogo por rol. |
| <a id="win-c059"></a>WIN-C059 | DNS/DHCP Server | Módulos `DnsServer`, `DhcpServer`: inventariar todos los Get/Add/Set/Remove y operaciones de scopes, leases, reservas, zonas/registros | Servidor/ámbito, consulta frente a cambio, autorización, copia y validación cliente. |
| <a id="win-c060"></a>WIN-C060 | Virtualización y web | Módulos Hyper-V, IIS/WebAdministration; `wsl --help`, `Get-VM`, `Get-Website` si existen | Inventario completo por rol y exclusiones justificadas; redes/almacenamiento e impacto del host. |
| <a id="win-c061"></a>WIN-C061 | Identidad cloud | `dsregcmd /status`, estado de unión/registro; Microsoft Graph y módulos específicos si se incluyen | No mezclar cuentas AD, Entra y locales ni asumir disponibilidad de módulos cloud. |
| <a id="win-c062"></a>WIN-C062 | Scripts y jobs | `about_*`, funciones, param, Validate*, try/catch/finally, ShouldProcess, `Start/Get/Receive/Wait/Stop/Remove-Job`, `Start-ThreadJob` si instalado | Scopes, tipos, errores terminantes, objetos serializados y concurrencia. |
| <a id="win-c063"></a>WIN-C063 | Remoting restringido y credenciales | `Get-Credential`, SecureString/PSCredential, JEA, sesiones endpoint y SecretManagement si instalado | Modelo de protección por usuario/host, delegación y extensiones opcionales. |
| <a id="win-c064"></a>WIN-C064 | Execution policy y firma | `Get/Set-ExecutionPolicy`, `Get/Set-AuthenticodeSignature`, `Unblock-File` | Scope, precedencia, procedencia y autorización; no aplicar Bypass global por comodidad. |
| <a id="win-c065"></a>WIN-C065 | Catálogo restante Windows/CMD | Índice Windows commands, `help`, `comando /?`, `Get-Command` por módulo/rol, GUI y CIM classes/methods incluidos | Crear ficha para cada elemento no listado; distinguir alias, binario, API y herramienta opcional. |

## Casos integradores que deben desarrollarse

- [ ] **WIN-P01.** Crear usuarios/grupos locales, probar inicio con otra identidad y distinguirlo de una terminal elevada.
- [ ] **WIN-P02.** Construir árbol NTFS con permisos explícitos/heredados, allow/deny y owner; guardar ACL, cambiar, verificar acceso efectivo y restaurar.
- [ ] **WIN-P03.** Combinar permisos de share y NTFS, probar con dos usuarios y diagnosticar una denegación por token o sesión SMB previa.
- [ ] **WIN-P04.** Relacionar un puerto en escucha con PID, ejecutable, usuario y servicio; distinguir loopback, IP concreta y wildcard.
- [ ] **WIN-P05.** Administrar un servicio ficticio compatible con SCM: consulta, inicio, cuenta dedicada, recuperación, dependencias y retirada.
- [ ] **WIN-P06.** Crear una tarea con acción/ruta/identidad explícitas, probar el trigger y leer LastTaskResult e historial.
- [ ] **WIN-P07.** Configurar IP/DNS y una regla de firewall en VM con consola de recuperación; validar persistencia tras reiniciar.
- [ ] **WIN-P08.** Preparar un disco virtual de laboratorio, copiar datos/ACL con robocopy y demostrar restauración.
- [ ] **WIN-P09.** Consultar eventos, filtrar un fallo y exportar evidencia sin credenciales ni datos personales innecesarios.
- [ ] **WIN-P10.** Aplicar GPO/AD solo en dominio de laboratorio y comprobar la política resultante y mínimo privilegio.
- [ ] **WIN-P11.** Reconciliar catálogo CMD/PowerShell/GUI y roles incluidos para cada edición/build, sin dar por universales los módulos opcionales.

## Captura de catálogo para el cierre

Comandos de consulta que deberán ejecutarse en cada entorno objetivo y guardar como evidencia de versión. No afirman por sí solos que todo el contenido esté documentado:

```powershell
$PSVersionTable
Get-Module -ListAvailable | Select-Object Name, Version, Path
Get-Command -CommandType Cmdlet, Function, Application |
    Select-Object Name, CommandType, Source, Version
Get-Command -Module Microsoft.PowerShell.LocalAccounts -Syntax
Get-Command -Module ScheduledTasks -Syntax
Get-Help icacls.exe
icacls.exe /?
sc.exe /?
schtasks.exe /?
```

La ayuda de ejecutables nativos se obtiene del propio binario; `Get-Help` puede no disponer de documentación para él. Repetir `Get-Command -Syntax` y `Get-Help -Full` para cada cmdlet del alcance, incluidos todos sus parameter sets. Los roles ausentes se registran como «No aplicable» para ese equipo, no como inexistentes en Windows.

## Materiales derivados y relaciones

Los materiales nuevos siguen pendientes. Registrar sus enlaces reales y los IDs cubiertos en la ficha de cada unidad; una mención en este guion no acredita que un recurso existente cubra todas sus variantes.

| Formato | Contenido que debe extraerse | Estado |
| --- | --- | --- |
| Guía divulgativa | Modelo mental, conceptos y decisiones de uso. | Pendiente |
| Guía técnica | Sintaxis completa por versión, configuración y laboratorios. | Pendiente |
| Cheatsheet Markdown | Consultas y operaciones con interpretación de salida. | Pendiente |
| Cheatsheet visual | Relaciones, flujos y decisiones; enlazar al detalle técnico. | Pendiente |
| Referencia | Fichas de todas las opciones, argumentos y casos inventariados. | Pendiente |

### Recursos existentes o guiones relacionados

- [Chuletas de Sistemas Operativos](../../Sistemas%20Operativos/chuletas/README.md).
- [Runbooks existentes](../../Sistemas%20Operativos/runbooks/README.md).
- [SSH](ssh.md) y [GNU/Linux](gnu-linux.md) para comparar operaciones equivalentes.

## Fuentes y reconciliación del inventario

Referencias oficiales para delimitar familias y contrastar el desarrollo. La consulta de sus índices no equivale a haber validado todas las opciones. Anotar en cada ficha la URL específica, versión, fecha de consulta y evidencia de laboratorio. Si una función pertenece a una edición, paquete o extensión opcional, registrarlo expresamente.

- [Windows commands](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/windows-commands)
- [PowerShell](https://learn.microsoft.com/en-us/powershell/)
- [Windows PowerShell module reference](https://learn.microsoft.com/en-us/powershell/windows/)
- [Windows Server](https://learn.microsoft.com/en-us/windows-server/)
- [Sysinternals](https://learn.microsoft.com/en-us/sysinternals/)
