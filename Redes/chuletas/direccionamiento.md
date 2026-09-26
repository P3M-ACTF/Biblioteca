# Chuleta: direccionamiento IPv4/IPv6 y CIDR

IPv4/IPv6, máscaras, CIDR, gateway y ejemplos de cálculo de redes.

---

## 1. IPv4 — piezas

| Pieza | Rol |
|-------|-----|
| Dirección | 32 bits; p. ej. `192.168.1.10` |
| Máscara | Separa red / host |
| CIDR | `/n` = bits de red (p. ej. `/24`) |
| Gateway | Siguiente salto hacia otras redes |
| Broadcast | Todos los hosts de la subred (IPv4) |

---

## 2. Máscaras ↔ CIDR (IPv4)

| CIDR | Máscara | Hosts útiles* |
|------|---------|---------------|
| `/8` | `255.0.0.0` | ~16 M |
| `/16` | `255.255.0.0` | ~65 k |
| `/24` | `255.255.255.0` | 254 |
| `/25` | `255.255.255.128` | 126 |
| `/26` | `255.255.255.192` | 62 |
| `/27` | `255.255.255.224` | 30 |
| `/28` | `255.255.255.240` | 14 |
| `/30` | `255.255.255.252` | 2 (enlaces) |
| `/32` | `255.255.255.255` | host único |

\*En redes clásicas: resta red y broadcast. En `/31` punto a punto (RFC 3021) el cálculo cambia.

---

## 3. Cálculo rápido de subred

Ejemplo: host `192.168.10.37/26`

1. Máscara `/26` → bloques de **64** direcciones (2^(32-26)).
2. Redes: `.0`, `.64`, `.128`, `.192`.
3. `37` cae en el bloque `.0`–`.63`.
4. **Red:** `192.168.10.0/26`
5. **Primer host:** `.1` · **Último:** `.62` · **Broadcast:** `.63`
6. Gateway habitual: `.1` (convención, no obligación).

Otro: `10.0.5.100/24` → red `10.0.5.0/24`, hosts `.1`–`.254`, broadcast `.255`.

```bash
# Herramientas útiles si están instaladas
ipcalc 192.168.10.37/26
sipcalc 192.168.10.37/26
```

---

## 4. Rangos privados (RFC 1918)

| Bloque | CIDR |
|--------|------|
| `10.0.0.0` | `/8` |
| `172.16.0.0` | `/12` (`172.16`–`172.31`) |
| `192.168.0.0` | `/16` |

Otros especiales: `127.0.0.0/8` (loopback), `169.254.0.0/16` (link-local), `224.0.0.0/4` (multicast).

---

## 5. IPv6 — lo esencial

| Concepto | Detalle |
|----------|---------|
| Longitud | 128 bits; notación hex con `:` |
| CIDR | Igual idea: `/64` típico en LAN |
| Compresión | `2001:db8::1` (ceros omitidos) |
| Loopback | `::1` |
| Link-local | `fe80::/10` (obligatoria en interfaz) |
| ULA | `fc00::/7` (privado) |
| Documentación | `2001:db8::/32` |

No hay broadcast; hay multicast (`ff00::/8`).

```bash
ip -6 addr
ip -6 route
```

---

## 6. Gateway y rutas

```bash
ip route                     # tabla IPv4
ip -6 route
ip route get 1.1.1.1         # qué ruta usaría
```

| Ruta | Significado |
|------|-------------|
| `default via 192.168.1.1` | Salida por defecto |
| `10.0.0.0/8 dev eth0` | Directamente conectada / vía iface |

Sin gateway correcto: LAN sí, Internet no (o al revés si faltan rutas internas).

---

## 7. Checklist

| Pregunta | Respuesta con |
|----------|----------------|
| ¿Mis IP y CIDR? | `ip -br addr` / `ip addr` |
| ¿Gateway? | `ip route` |
| ¿Cuántos hosts? | 2^(32-prefijo) − 2 (IPv4 clásico) |
| ¿Misma L2/L3? | mismo prefijo de red → misma subred |

---

*Biblioteca — Redes · direccionamiento*
