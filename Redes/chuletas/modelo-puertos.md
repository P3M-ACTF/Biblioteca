# Chuleta: modelo de red y puertos

TCP/IP frente a OSI, puertos bien conocidos y estados TCP visibles con `ss`.

---

## 1. OSI frente a TCP/IP (mapa mental)

| OSI (7) | TCP/IP (4) | Ejemplos |
|---------|------------|----------|
| 7 Aplicación | Aplicación | HTTP, DNS, SSH, SMTP |
| 6 Presentación | (en aplicación) | TLS, encoding |
| 5 Sesión | (en aplicación) | sesiones de app |
| 4 Transporte | Transporte | TCP, UDP, ICMP* |
| 3 Red | Internet | IPv4/IPv6, ICMP |
| 2 Enlace | Acceso a red | Ethernet, Wi-Fi, ARP |
| 1 Física | Acceso a red | cable, radio, señal |

\*ICMP no es transporte estricto; se asocia a la capa de red/internet.

Flujo típico al diagnosticar: **físico/enlace → IP → transporte (puerto) → aplicación**.

---

## 2. TCP frente a UDP

| | **TCP** | **UDP** |
|--|---------|---------|
| Conexión | Orientado a conexión | Datagramas |
| Fiabilidad | Reenvío, orden | Sin garantías |
| Uso típico | SSH, HTTP(S), SMTP | DNS (a menudo), DHCP, VoIP, QUIC* |

\*QUIC va sobre UDP pero aporta fiabilidad en la capa de aplicación.

---

## 3. Puertos bien conocidos (muestra)

| Puerto | Proto | Servicio |
|--------|-------|----------|
| 22 | TCP | SSH |
| 53 | UDP/TCP | DNS |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 25 / 587 | TCP | SMTP / submission |
| 110 / 995 | TCP | POP3 / POP3S |
| 143 / 993 | TCP | IMAP / IMAPS |
| 123 | UDP | NTP |
| 389 / 636 | TCP | LDAP / LDAPS |
| 3306 | TCP | MySQL/MariaDB |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 8080 | TCP | HTTP alt. / proxies |

Rangos:

| Rango | Nombre |
|-------|--------|
| 0–1023 | Bien conocidos (privilegiados al bind) |
| 1024–49151 | Registrados |
| 49152–65535 | Efímeros / dinámicos (cliente) |

```bash
# /etc/services tiene muchos nombres
getent services ssh
```

---

## 4. Estados TCP (ss)

```bash
ss -tulpn                  # listening TCP/UDP + proceso
ss -tan                    # TCP todas
ss -tan state established
ss -tan state time-wait
ss -tpn dst 192.0.2.10
```

| Estado | Significado breve |
|--------|-------------------|
| `LISTEN` | Esperando conexiones |
| `ESTABLISHED` | Conexión activa |
| `SYN-SENT` | Cliente ha enviado SYN |
| `SYN-RECV` | Servidor recibió SYN (handshake a medias) |
| `FIN-WAIT-1/2` | Cierre iniciado por este extremo |
| `TIME-WAIT` | Espera tras cierre (reutilización segura del tuple) |
| `CLOSE-WAIT` | El remoto cerró; la app local aún no cerró |
| `LAST-ACK` | Último ACK de cierre pendiente |

Muchos `TIME-WAIT` tras carga alta suele ser normal. Muchos `CLOSE-WAIT` → la aplicación no cierra sockets.

---

## 5. Lectura rápida de ss

```bash
ss -tlnp                   # solo listening TCP
ss -ulnp                   # listening UDP
ss -s                      # resumen de sockets
```

Columnas útiles: `Local Address:Port`, `Peer Address:Port`, `Process`.

---

## 6. Checklist

| Pregunta | Comando / foco |
|----------|----------------|
| ¿Qué escucha aquí? | `ss -tulpn` |
| ¿Hay sesión con X? | `ss -tan dst X` |
| ¿Capa correcta? | enlace → IP → puerto → app |
| ¿TCP o UDP? | mirar columna / flag `-t` / `-u` |

---

*Biblioteca — Redes · modelo / puertos*
