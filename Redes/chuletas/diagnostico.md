# Chuleta: diagnóstico de red

Herramientas (`ip`, `ping`, `traceroute`/`mtr`, `curl -v`) y qué mirar según el fallo. Enfoque de **comprobación**, no de ataque.

---

## 1. Orden de depuración

1. **Interfaz / enlace** — ¿UP? ¿IP?
2. **L3 local** — ¿ping a gateway?
3. **Ruta** — ¿default route?
4. **DNS** — ¿resuelve nombres?
5. **Transporte / app** — ¿puerto abierto? ¿HTTP/TLS?

No saltes al paso 5 si falla el 1.

---

## 2. ip — enlace y direcciones

```bash
ip -br link                  # estado de interfaces
ip -br addr                  # IP por interfaz
ip addr show eth0
ip route
ip -6 route
ip neigh                     # ARP / vecinos
```

| Síntoma | Mirar |
|---------|-------|
| `DOWN` / sin cable | físico, driver, `ip link set … up` |
| Sin IPv4/IPv6 | DHCP/estática, `ip addr` |
| `NO-CARRIER` | medio físico o virtualización |

---

## 3. ping — alcance IP

```bash
ping -c 4 192.168.1.1
ping -c 4 1.1.1.1
ping -c 4 ejemplo.org          # mezcla DNS + IP
ping -c 4 -I eth0 10.0.0.1     # salir por interfaz
```

| Resultado | Interpretación |
|-----------|----------------|
| Respuestas OK | L3 hacia ese destino (salvo filtrado asimétrico) |
| Fallo a nombre, OK a IP | DNS |
| Fallo a Internet, OK a gateway | ruta uplink / NAT / firewall |
| Fallo a gateway | VLAN, cable, IP/máscara, Wi-Fi |

Muchos hosts **filtran ICMP**: silencio ≠ “no existe”.

---

## 4. traceroute / mtr — camino

```bash
traceroute -n 1.1.1.1
traceroute -n -T -p 443 1.1.1.1   # TCP 443 si ICMP va filtrado
mtr -n 1.1.1.1                    # continuo (si instalado)
```

| Qué ves | Lectura |
|---------|---------|
| `* * *` al inicio | bloqueo local / primer salto |
| `* * *` a mitad | router que no responde ICMP (puede ser normal) |
| Último salto OK | path completo a destino |
| Se corta siempre en el mismo hop | sospecha de filtro o enlace |

---

## 5. curl -v — aplicación HTTP/TLS

```bash
curl -vI https://ejemplo.org       # cabeceras + handshake visible
curl -v https://ejemplo.org/ruta
curl -v --connect-timeout 5 https://…
curl -v http://192.0.2.10:8080/    # por IP y puerto
```

| Fase en `-v` | Si falla aquí |
|--------------|---------------|
| `Trying IP…` / `Connected` | red / firewall / listen |
| `SSL/TLS` / certificado | TLS, hora del sistema, CA, SNI |
| `HTTP/1.1 …` código | aplicación / proxy / auth |

Códigos útiles: `401` auth, `403` permiso, `404` path, `502`/`503` backend.

---

## 6. Matriz síntoma → herramienta

| Fallo percibido | Linux | Windows |
|-----------------|-------|---------|
| “No hay red” | `ip -br link/addr`, `ip route` | `Get-NetIPAddress`, `Get-NetRoute` |
| “No hay Internet” | ping gateway / `1.1.1.1` | `Test-NetConnection 1.1.1.1` |
| “No carga la web” (nombre) | `dig`, `curl -vI` | `Resolve-DnsName`, `Test-NetConnection -Port 443` |
| “Va lento / a ratos” | `mtr`, `ss -s` | `Test-NetConnection` + contadores / ruta |
| “Puerto inaccesible” | `ss -tlnp`, cliente al puerto | `Get-NetTCPConnection -State Listen` |
| DNS dudoso | `resolvectl` / `dig @…` | `Resolve-DnsName` / DNS del cliente |

---

## 7. Equivalentes en Windows (PowerShell)

Mismo orden mental: interfaz → gateway → DNS → puerto/app.

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-NetRoute -DestinationPrefix '0.0.0.0/0'
Get-DnsClientServerAddress
Resolve-DnsName ejemplo.org
Test-NetConnection -ComputerName 1.1.1.1 -InformationLevel Detailed
Test-NetConnection -ComputerName ejemplo.org -Port 443
# Ping clásico:
Test-Connection -ComputerName 192.168.1.1 -Count 4
```

| Linux | Windows (orientativo) |
|-------|------------------------|
| `ip -br addr` | `Get-NetIPAddress` |
| `ip route` | `Get-NetRoute` |
| `dig` / `resolvectl` | `Resolve-DnsName` |
| `ping` | `Test-Connection` / `Test-NetConnection` |
| `curl` a un puerto | `Test-NetConnection -Port` |
| `ss -tlnp` | `Get-NetTCPConnection -State Listen` |

`Test-NetConnection` resume ping, DNS y puerto TCP en un solo comando útil para triage.

---

## 8. Checklist corto

**Linux**

```bash
ip -br link && ip -br addr && ip route
ping -c 3 "$(ip route | awk '/default/ {print $3; exit}')"
ping -c 3 1.1.1.1
dig +short ejemplo.org
curl -vI https://ejemplo.org
```

**Windows**

```powershell
Get-NetIPAddress -AddressFamily IPv4
Get-NetRoute -DestinationPrefix '0.0.0.0/0'
Resolve-DnsName ejemplo.org
Test-NetConnection ejemplo.org -Port 443
```

---

*Biblioteca — Redes · diagnóstico*
