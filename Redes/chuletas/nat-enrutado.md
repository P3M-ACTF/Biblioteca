# Chuleta: NAT y enrutado

Traducción de direcciones (NAT) y tablas de rutas: conceptos para administrar y diagnosticar.

---

## 1. Enrutado — idea

Un router (o host con IP forwarding) elige el **siguiente salto** según la tabla de rutas: prefijo más específico gana; si no hay match, **default route**.

```bash
ip route
ip -6 route
ip route get 1.1.1.1
sysctl net.ipv4.ip_forward          # 1 = este host puede reenviar
```

| Entrada típica | Significado |
|----------------|-------------|
| `default via 192.168.1.1 dev eth0` | Salida por defecto |
| `10.0.0.0/8 dev eth1` | Red conectada / vía interfaz |
| `172.16.0.0/12 via 10.0.0.1` | Red remota por un gateway |

---

## 2. NAT — qué es

**NAT** (Network Address Translation): reescribe IPs (y a menudo puertos) al atravesar un borde.

| Tipo | Qué hace | Uso habitual |
|------|----------|--------------|
| **SNAT / Masquerade** | Cambia origen (LAN → IP pública) | Salida a Internet desde privadas |
| **DNAT / Port forward** | Cambia destino (público:puerto → host interno) | Publicar un servicio interno |
| **1:1** | Mapeo fijo público ↔ privado | Servidores con IP dedicada |

**Masquerade** = SNAT dinámico a la IP de la interfaz de salida (útil en DHCP/WAN variable).

RFC 1918 (`10/8`, `172.16/12`, `192.168/16`) no se enrutan en Internet público → casi siempre hay NAT de salida en el borde.

---

## 3. Tabla mental del flujo

```
Host LAN ──(SNAT/MASQ)──> Internet
Internet ──(DNAT puerto)──> Host LAN
```

Conntrack (seguimiento de conexiones) asocia respuestas al mapeo correcto. Sin conntrack/reglas de estado, el NAT “rompe” el retorno.

---

## 4. Ver rutas y política

```bash
ip route show table main
ip rule list                     # policy routing (si hay)
ip route show table 100          # tablas alternativas
```

Varias defaults o `ip rule` → rutas por origen/marca (VPN, multi-WAN). Diagnosticar con `ip route get` desde la IP/interfaz implicada.

---

## 5. nftables / firewall — dónde vive el NAT (alto nivel)

En Linux el NAT suele configurarse en **nftables** (o wrappers: `firewalld`, `ufw` no cubre todos los casos) en cadenas tipo `prerouting` (DNAT) y `postrouting` (SNAT/masquerade).

```bash
sudo nft list ruleset | less
# Buscar: masquerade, snat, dnat, redirect
```

No hace falta memorizar la sintaxis aquí: sí saber **en qué sentido** falla (salida vs publicación de puerto).

---

## 6. Síntomas ↔ causa

| Síntoma | Mirar |
|---------|-------|
| LAN navega, pero no entra nada de fuera | DNAT/puertos / firewall WAN |
| No hay Internet desde LAN | default route, SNAT/masq, DNS |
| Solo falla un puerto publicado | DNAT al IP:puerto correcto, servicio en listen, firewall host |
| VPN OK pero se pierde LAN | rutas solapadas, order de tablas |
| Respuesta asimétrica | path de ida ≠ vuelta (conntrack/routing) |

```bash
ping -c 2 gateway_lan
ping -c 2 1.1.1.1
ip route get 1.1.1.1 from 192.168.1.10 iif eth0    # si aplica
ss -tlnp                                           # ¿quién escucha en el destino DNAT?
```

---

## 7. Checklist

| Pregunta | Comando / foco |
|----------|----------------|
| ¿Cuál es mi salida? | `ip route` → `default via …` |
| ¿Forwarding activo? | `ip_forward` / rol del equipo |
| ¿NAT de salida? | reglas masquerade/SNAT + conectividad LAN→WAN |
| ¿Puerto publicado? | DNAT + listen interno + firewall |
| ¿Ruta correcta a un destino? | `ip route get DEST` |

---

*Biblioteca — Redes · NAT / enrutado*
