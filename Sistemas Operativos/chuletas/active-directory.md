# Chuleta: Active Directory

Active Directory es el servicio de directorio de Microsoft: la base de datos central donde una empresa guarda las cuentas de las personas, las cuentas de los equipos, los grupos y las políticas que se les aplican. En lugar de crear a cada usuario en cada servidor, se crea una vez en el dominio y esa identidad vale en todas las máquinas unidas a él. Esta chuleta explica las piezas (dominio, controlador, OU, grupo, GPO) y cómo comprobar desde un equipo qué le está llegando. No entra en cómo saltarse políticas.

---

## 1. Las piezas

| Concepto | Qué es |
|----------|--------|
| **Dominio** | El contenedor de seguridad: un nombre DNS (`empresa.local`, `ad.empresa.es`) dentro del cual las cuentas, los equipos y las políticas forman un conjunto. Una cuenta del dominio se autentica contra el dominio, no contra cada máquina. |
| **Bosque** | El conjunto de dominios que comparten el mismo catálogo y la misma raíz de confianza. La mayoría de organizaciones pequeñas y medianas tienen un solo dominio y por tanto un bosque de un dominio. |
| **Controlador de dominio (DC)** | Un Windows Server con el rol AD DS que guarda una copia del directorio y autentica. Se instalan al menos dos: si el único controlador se cae, nadie inicia sesión. Los controladores se replican entre sí. |
| **Objeto** | Cualquier cosa guardada en el directorio: un usuario, un equipo, un grupo, una OU, una impresora. |
| **SID** | El identificador de seguridad del objeto, un número largo que no cambia aunque renombres la cuenta. Los permisos NTFS y los derechos se guardan con SIDs, no con nombres. |
| **Equipo unido al dominio** | Un Windows que tiene cuenta de equipo en el directorio y, gracias a eso, acepta cuentas del dominio y recibe directivas de grupo. |

Unir un equipo al dominio no «mete a los usuarios dentro». Crea una cuenta de equipo, establece una relación de confianza y, a partir de ahí, el equipo pregunta a un controlador cada vez que alguien quiere iniciar sesión.

---

## 2. Usuarios y grupos

Igual que en Linux, los permisos no se dan a personas sueltas sino a grupos, y las personas se meten y se sacan de los grupos. En AD el matiz es que hay grupos de distintos alcances.

| Tipo | Para qué sirve |
|------|----------------|
| **Seguridad** | Se usa en permisos y derechos. Es el que quieres casi siempre. |
| **Distribución** | Solo para listas de correo. No se puede poner en una ACL de NTFS; si lo intentas, no aparece. |
| **Global** | Contiene usuarios del propio dominio y se usa en cualquier dominio del bosque. Es donde agrupas a las personas por rol: `GG-Contabilidad`. |
| **Dominio local** | Se usa para dar permisos sobre recursos del propio dominio. Entra en las ACL. Según el modelo clásico (AGDLP), los grupos globales se meten dentro de grupos de dominio local, y estos son los que aparecen en los permisos. |
| **Universal** | Como el global pero puede contener objetos de cualquier dominio del bosque. Tiene coste de replicación; se usa cuando de verdad hay varios dominios. |

La disciplina que evita el caos: **ningún usuario suelto en una ACL de una carpeta**. Si María necesita acceso a Facturas, María entra en el grupo del rol y el grupo está en la ACL. Cuando María se va, sale del grupo y no queda un SID suelto que dentro de seis meses nadie sepa qué hace ahí.

```powershell
Get-ADDomain
Get-ADUser -Identity ana -Properties MemberOf, Enabled, PasswordLastSet, LockedOut
Get-ADGroupMember "GG-Contabilidad"
whoami /groups
```

Estos cmdlets necesitan el módulo ActiveDirectory, que está en los controladores y en cualquier máquina con las RSAT instaladas. `whoami /groups` funciona en cualquier Windows y enseña los grupos del usuario de la sesión actual, que es lo que de verdad se está usando para evaluar permisos.

### Qué estás viendo en `whoami /groups`

```text
Grupo                                  Tipo                                  SID
====================================== ===================================== ============
EMPRESA\GG-Contabilidad                Grupo                                 S-1-5-21-...-1142
EMPRESA\Usuarios del dominio           Grupo                                 S-1-5-21-...-513
NT AUTHORITY\INTERACTIVE               Grupo conocido                        S-1-5-4
NT AUTHORITY\Se autentificó            Grupo conocido                        S-1-5-11
```

Cada línea es una identidad con la que esta sesión cumple. Si el grupo que esperabas no está, el usuario no es miembro (o lo acabas de añadir y hace falta un nuevo inicio de sesión, porque la lista de grupos viaja dentro del token que se crea al autenticarse). `Se autentificó` aparece en cualquier sesión autenticada; es el grupo al que apunta el permiso genérico «usuarios autenticados».

---

## 3. Unidades organizativas

Una OU es una carpeta dentro del directorio. Sirve para dos cosas: **delegar** (el responsable de una sede puede resetear contraseñas solo de su OU) y **enlazar directivas de grupo** (una GPO vinculada a la OU de portátiles se aplica a los portátiles y no a los servidores).

Una OU no es un grupo. Meter un equipo en una OU no le da ningún permiso sobre nada; solo cambia qué políticas recibe y quién lo administra. Al revés también: un grupo no decide qué GPO se aplica.

El diseño de las OU conviene decidirlo pronto y tocarlo poco, porque mover objetos de OU cambia las políticas que reciben. Los criterios habituales son geografía (sede), función (servidores, puestos, cuentas de servicio) o departamento. Mezclar los tres a la vez, anidando sin criterio, produce un árbol que nadie se atreve a reorganizar.

Mover un objeto es fácil y sus consecuencias no: un servidor movido a la OU de puestos puede recibir una GPO que le instala software de puesto o le reconfigura el cortafuegos. Antes de mover, mira qué GPO tiene la OU de destino.

---

## 4. Directivas de grupo (GPO)

Una GPO es un conjunto de valores de configuración que el dominio aplica solo. Hay dos mitades, y se evalúan en momentos distintos:

| Mitad | Cuándo se aplica | Qué suele contener |
|-------|------------------|--------------------|
| **Equipo** | Al arrancar el equipo y en cada ciclo de fondo (unos 90 minutos, con retraso aleatorio). | Cortafuegos, servicios que deben existir, scripts de arranque, políticas de contraseña locales, restricciones de software. |
| **Usuario** | Al iniciar sesión y en cada ciclo de fondo. | Redirección de carpetas, unidades de red, scripts de inicio de sesión, configuración de aplicaciones, certificados. |

El orden en que se aplican, de menos a más prioritario: política local del equipo, GPO de sitio, GPO de dominio, GPO de OU. Si hay OU anidadas, se aplica primero la de más arriba. Cuando dos GPO tocan el mismo valor, gana la última en aplicarse, es decir la de la OU más específica. Dos excepciones rompen esa lógica: **Aplicar** (*enforced*) hace que una GPO de arriba no pueda ser pisada por las de abajo, y **Bloquear herencia** hace que una OU no reciba las de arriba (salvo las marcadas como Aplicar).

```powershell
gpresult /r
gpresult /h C:\Temp\gp.html
Get-GPO -All
Get-GPResultantSetOfPolicy -ReportType Html -Path C:\Temp\rsop.html
```

### Qué estás viendo en `gpresult /r`

```text
Datos del equipo
    Nombre de equipo:          PORT12
    Configuración del equipo
        CN=PORT12,OU=Portatiles,OU=Sede-Madrid,DC=empresa,DC=local
    Última vez que se aplicó la directiva de grupo: 10/10/2026 a las 9:40:12

    Directivas de grupo aplicadas
        Default Domain Policy
        Cortafuegos-Puestos
        Certificados-Internos

    Las siguientes GPO no se aplicaron porque se filtraron
        Config-Servidores        Filtro de seguridad
```

La línea `CN=PORT12,OU=...` es la posición del equipo en el directorio: de ahí salen las GPO que le tocan. «Directivas aplicadas» son las que de verdad entraron. «No se aplicaron porque se filtraron» es oro para diagnosticar: `Filtro de seguridad` significa que la GPO está vinculada a la OU pero el equipo no está en el grupo al que la GPO se aplica; `Denegado (vínculo)` significa que el vínculo está deshabilitado; un filtrado WMI significa que una consulta (por ejemplo «es portátil») no se cumplió.

`gpresult /h` genera un informe HTML con cada valor efectivo y qué GPO lo puso. Es la forma de responder «¿por qué este equipo tiene el cortafuegos así?».

Cuando una GPO no llega, las causas, en orden de frecuencia: el objeto no está en la OU que crees, el vínculo está deshabilitado, el filtrado de seguridad excluye al equipo, un filtro WMI no cuadra, o los controladores no se han replicado y estás preguntando a uno que aún no tiene el cambio. `gpupdate /force` adelanta el ciclo, pero no arregla ninguna de esas causas; solo evita la espera.

---

## 5. Cómo se relaciona con lo que ves en el equipo

| Lo que observas en el puesto | De dónde sale en el directorio |
|------------------------------|--------------------------------|
| El usuario entra con `EMPRESA\ana` | Objeto de usuario en AD, contraseña validada por un controlador. |
| `whoami /groups` lista grupos del dominio | Pertenencia a grupos, metida en el token al iniciar sesión. |
| El cortafuegos cambia al conectar la VPN de la oficina | El perfil de red pasa a «Dominio» y se aplican las reglas de ese perfil, a menudo definidas por GPO. |
| RDP permitido para un grupo y no para otro | Grupo de dominio en la directiva de derechos de usuario, o en el grupo local «Usuarios de escritorio remoto». |
| Permisos de una carpeta concedidos a `EMPRESA\GG-Contabilidad` | Una ACE en la DACL con el SID de ese grupo. |

Por eso diagnosticar un permiso en una máquina de dominio sin mirar el directorio es quedarse a medias: el grupo local puede estar vacío porque el grupo de dominio que debería contener no se ha resuelto, o la GPO que lo rellena no se ha aplicado.

---

## 6. Checklist

| Pregunta | Cómo responderla |
|----------|------------------|
| ¿Este equipo está en el dominio, y en cuál? | `systeminfo` (línea «Dominio») o `(Get-WmiObject Win32_ComputerSystem).Domain`. |
| ¿Dónde está el objeto? | La ruta `CN=...,OU=...` que muestra `gpresult /r`, o Usuarios y equipos de Active Directory. |
| ¿A qué grupos pertenece esta sesión? | `whoami /groups`. Recuerda que es la sesión, no el estado actual del directorio. |
| ¿Qué directivas le están llegando? | `gpresult /r` y, para el detalle, `gpresult /h`. |
| ¿Por qué no le llega una GPO? | Sección «no se aplicaron» de `gpresult`: filtrado de seguridad, vínculo deshabilitado, filtro WMI. |
| ¿Cuándo se aplicó por última vez? | La marca de tiempo de `gpresult`. Si es de hace días, el equipo no está contactando con un controlador. |

---

## 7. Error típico

**Situación.** Creas la GPO «Proxy-Contabilidad», la vinculas a la OU de Contabilidad y la configuras en la mitad de **usuario** para que ponga el proxy del navegador. María, de contabilidad, reinicia su equipo, entra, y el navegador sigue saliendo directo. Sus compañeros tampoco lo tienen. La GPO aparece como aplicada... en ningún sitio.

**Por qué ocurre.** La mitad de usuario de una GPO se aplica a los **usuarios** que están bajo el vínculo, no a los equipos. Los usuarios de contabilidad viven en la OU «Usuarios / Contabilidad»; sus equipos están en «Equipos / Puestos», que es donde vinculaste la GPO. Como en esa OU no hay objetos de usuario, la mitad de usuario no tiene a quién aplicarse, y la mitad de equipo está vacía porque no configuraste nada en ella. La GPO está perfecta y no hace nada. (El caso inverso, configurar algo de equipo y vincularlo a la OU de usuarios, es igual de frecuente.)

**Cómo se ve.** En el equipo de María, `gpresult /r` lista las GPO aplicadas al usuario y «Proxy-Contabilidad» no está. En la sección del equipo tampoco. En Administración de directivas de grupo, el vínculo apunta a la OU de equipos. El informe de resultados de directiva para el usuario María, ejecutado desde el servidor, confirma que esa GPO no entra en su conjunto.

**Cómo se arregla.** Vincular la GPO a la OU donde están los usuarios de contabilidad, o mover la configuración a la mitad que corresponde a la OU que ya tienes. Después, `gpupdate /force` y un nuevo `gpresult /r` para comprobar que aparece en «Directivas aplicadas» antes de darla por buena. Si necesitas que una configuración de usuario se aplique según el equipo en el que se sienta la persona (aulas, mostradores), eso es el modo de bucle invertido (*loopback*), que existe precisamente para este caso y conviene usar a conciencia porque invierte la lógica que todo el mundo espera.

---

Relacionado: [windows-usuarios-grupos](windows-usuarios-grupos.md) · [windows-firewall-acceso](windows-firewall-acceso.md) · [permisos-ntfs](permisos-ntfs.md) · [windows-roles-actualizaciones](windows-roles-actualizaciones.md) · [dhcp-dns-windows-server](dhcp-dns-windows-server.md) · runbook [cuenta-bloqueada-ad](../runbooks/cuenta-bloqueada-ad.md) · guía [Inicio de sesión en un dominio](https://github.com/P3M-ACTF/Biblioteca/wiki/Inicio-de-sesion-en-un-dominio)

*Biblioteca — Sistemas Operativos · Active Directory*
