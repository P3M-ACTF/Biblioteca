# Chuleta: DHCP y DNS en Windows Server

En una red con Active Directory, DHCP y DNS no son servicios sueltos: son la forma en que un equipo recibe su dirección y encuentra a los controladores de dominio. Si el DNS apunta al sitio equivocado, el dominio entero parece caído aunque los controladores estén perfectamente. Esta chuleta explica qué hace cada rol, cómo se relacionan y qué mirar cuando un equipo no entra en el dominio.

---

## 1. Qué aporta cada rol

**DNS** traduce nombres a direcciones y, en un dominio, guarda los registros con los que los equipos localizan a los controladores: registros SRV que dicen «el servicio LDAP de este dominio está en este servidor, en este puerto». Sin esos registros no hay inicio de sesión en el dominio ni aplicación de directivas. Por eso el DNS del dominio vive en los controladores, o en servidores que replican esa zona, y los puestos usan esos servidores como sus únicos DNS.

**DHCP** reparte la configuración de red: dirección, máscara, puerta de enlace y, lo más importante aquí, qué DNS deben usar los equipos. Un ámbito DHCP que entrega un DNS público es la forma más habitual de romper un dominio sin tocar el dominio.

| Pieza | Para qué sirve |
|-------|----------------|
| **Ámbito** | El rango de direcciones que el servidor puede repartir dentro de una subred, con su máscara, puerta de enlace y opciones. |
| **Exclusión** | Direcciones del rango que no se reparten, porque están usadas por servidores, impresoras o la puerta de enlace. |
| **Reserva** | Una dirección fija para una MAC concreta. El equipo sigue siendo cliente DHCP, pero recibe siempre la misma IP. Mejor que una IP estática configurada a mano, porque la gestión queda en el servidor. |
| **Concesión** | La asignación actual, con su fecha de caducidad. El cliente renueva a la mitad del plazo. |
| **Opciones** | El resto de la configuración: DNS, dominio de búsqueda, puerta de enlace. Hay opciones de ámbito y de servidor; gana la más específica. |

---

## 2. Cómo encajan DHCP, DNS y el dominio

El flujo de un equipo al arrancar dentro de la red:

1. Pide dirección por DHCP.
2. El servidor le da IP, máscara, puerta de enlace y los DNS, que son los controladores de dominio.
3. El equipo registra su nombre en el DNS (actualización dinámica), si la política lo permite.
4. Para entrar en el dominio, pregunta al DNS por los registros SRV del dominio y localiza un controlador.

```powershell
Get-DhcpServerv4Scope -ComputerName dc01
Get-DhcpServerv4OptionValue -ScopeId 10.1.10.0 -ComputerName dc01
Get-DhcpServerv4Lease -ScopeId 10.1.10.0 -ComputerName dc01
Get-DnsServerZone -ComputerName dc01
Get-DnsServerResourceRecord -ZoneName empresa.local -RRType Srv -ComputerName dc01
```

Estos cmdlets están en los módulos `DhcpServer` y `DnsServer`, que vienen con los roles.

### Qué estás viendo

```text
$ Get-DhcpServerv4OptionValue -ScopeId 10.1.10.0

OptionId  Name            Value
--------  ----            -----
3         Router          {10.1.10.1}
6         DNS Servers     {10.1.10.11, 10.1.10.12}
15        DNS Domain Name {empresa.local}
```

La opción 6 es la que decide si el dominio funciona. Aquí apunta a dos controladores, que es lo correcto: si uno cae, el otro sigue resolviendo. La opción 15 es el dominio de búsqueda, gracias al cual `srv-ficheros` se completa a `srv-ficheros.empresa.local`. Si la opción 6 tuviera un `8.8.8.8`, los equipos navegarían por Internet y no encontrarían a los controladores.

En la zona DNS, los registros SRV bajo `_msdcs` los crean los propios controladores. Que falten, o que apunten a un controlador que ya no existe, explica un dominio donde «algunos equipos entran y otros no».

---

## 3. Reservas y actualizaciones dinámicas

Una reserva liga una MAC a una IP dentro del ámbito. Sirve para impresoras, cámaras y cualquier aparato que quieras localizar siempre en la misma dirección sin tener que configurar cada uno a mano ni correr el riesgo de que alguien ponga una IP que el DHCP también reparte.

La actualización dinámica es lo que hace que el DNS se entere de qué IP tiene hoy cada equipo. En una red con dominio se suele configurar para que sea el servidor DHCP quien actualice el DNS en nombre del cliente (con una cuenta dedicada, no con las credenciales de administrador), porque los clientes no siempre tienen permiso para escribir en la zona. El síntoma de que esto no está bien es un nombre que resuelve a una IP vieja: el equipo cambió de dirección y el registro no se actualizó.

Las zonas integradas en Active Directory replican con el propio directorio, así que todos los controladores sirven los mismos datos. Una zona primaria clásica con secundarias también funciona, pero añade un mecanismo de transferencia que hay que vigilar aparte.

---

## 4. Cuando un equipo no entra

| Síntoma | Lo primero que se mira |
|---------|------------------------|
| El equipo tiene una `169.254.x.x` | No recibió DHCP. ¿Está el servidor en marcha, hay ámbito para esa subred, y el relay (`ip helper`) está puesto en la VLAN? El DHCP no cruza routers sin relay. |
| Tiene IP pero no resuelve nombres internos | La opción 6 no apunta a los DNS del dominio. `Get-DnsClientServerAddress` en el cliente dice cuáles le llegaron. |
| Resuelve nombres pero no encuentra un controlador | Faltan los SRV, o el DNS que usa no es el del dominio. `nslookup -type=srv _ldap._tcp.dc._msdcs.empresa.local` lo enseña. |
| Entra, pero tarda minutos | Tiene un DNS público como secundario y prueba ese primero cuando el primario tarda. El NXDOMAIN del público se cachea. |
| Un nombre resuelve a una IP antigua | La actualización dinámica no se hizo, o la caché aún tiene el valor previo. |

---

## 5. Checklist

| Pregunta | Dónde se responde |
|----------|-------------------|
| ¿Qué ámbitos hay y qué rango cubren? | `Get-DhcpServerv4Scope` |
| ¿Qué DNS están recibiendo los clientes? | Opción 6 del ámbito, y `Get-DnsClientServerAddress` en un cliente para confirmar. |
| ¿Las reservas cubren lo que tiene IP fija de facto? | `Get-DhcpServerv4Reservation`. Una IP fija configurada a mano dentro del rango, sin reserva ni exclusión, acabará duplicada. |
| ¿La zona del dominio está sirviendo SRV? | `Get-DnsServerResourceRecord -RRType Srv` |
| ¿Hay dos servidores, no uno? | Dos controladores con DNS, y un DHCP en conmutación por error o con ámbitos partidos. Un único servidor de cualquiera de los dos es un único punto de fallo del dominio entero. |

---

## 6. Error típico

**Situación.** Añades una VLAN nueva para los puestos de una sede y configuras el ámbito DHCP. Los equipos reciben IP, navegan por Internet y no se unen al dominio: «no se puede contactar con un controlador de dominio». Desde uno de ellos haces ping a la IP del controlador y responde.

**Por qué ocurre.** Al crear el ámbito marcaste las opciones de router y poco más, y el servidor no tiene opciones globales, así que el ámbito no entrega DNS. El equipo se queda con los DNS que trae de otro sitio, o con ninguno útil, y resuelve Internet por casualidad (algunos sistemas prueban resolvers de respaldo) pero no pregunta nunca al DNS que conoce los registros SRV del dominio. El controlador está perfectamente alcanzable por IP, que es justo lo que comprueba el ping, y completamente ilocalizable por el mecanismo que el dominio usa de verdad.

**Cómo se ve.** `Get-DhcpServerv4OptionValue -ScopeId` de ese ámbito no tiene opción 6, o la tiene apuntando a un DNS público. En el cliente, `Get-DnsClientServerAddress` muestra ese DNS y no los controladores. `nslookup srv-dc01` falla mientras que `nslookup srv-dc01 10.1.10.11` (preguntando explícitamente al controlador) responde. La diferencia entre las dos consultas es el diagnóstico entero.

**Cómo se arregla.** Poner en la opción 6 del ámbito las IP de los controladores de dominio, y en la 15 el nombre del dominio. Renovar la concesión en el cliente (`ipconfig /renew`, o `Get-NetIPAddress` y una renovación) y comprobar que ya usa esos DNS. Entonces la unión al dominio funciona, porque por fin puede preguntar dónde están los controladores. Y de paso, revisar los demás ámbitos: un error de opciones se copia de ámbito en ámbito cuando se crean «igual que el otro».

---

Relacionado: [active-directory](active-directory.md) · [dns](../../Redes/chuletas/dns.md) · [direccionamiento](../../Redes/chuletas/direccionamiento.md) · [powershell-basico](powershell-basico.md) · guía [Inicio de sesión en un dominio](https://github.com/P3M-ACTF/Biblioteca/wiki/Inicio-de-sesion-en-un-dominio)

*Biblioteca — Sistemas Operativos · DHCP y DNS en Windows Server*
