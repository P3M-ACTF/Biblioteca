# Chuleta: captura de tráfico (lectura)

`tcpdump` y Wireshark/tshark para **inspeccionar** capturas y aplicar filtros de visualización. No incluye técnicas de explotación ni ataques activos.

---

## 1. Cuándo usarlo

| Objetivo | Herramienta |
|----------|-------------|
| Ver tráfico en un host (CLI) | `tcpdump` |
| Analizar captura con UI | Wireshark |
| Filtrar/exportar en script | `tshark` / `tcpdump -r` |

Permisos: capturar en interfaz suele requerir capacidades/`sudo`. Respeta política legal y de privacidad (PII, credenciales en claro).

---

## 2. tcpdump — captura y lectura

```bash
# Listar interfaces
tcpdump -D

# Capturar (escribir a fichero pcap)
sudo tcpdump -i eth0 -n -w /tmp/captura.pcap

# Leer fichero
tcpdump -n -r /tmp/captura.pcap
tcpdump -n -r /tmp/captura.pcap 'port 53'
```

Opciones útiles:

| Opción | Efecto |
|--------|--------|
| `-i` | Interfaz (`any` si existe) |
| `-n` | No resolver nombres (más rápido/claro) |
| `-nn` | No resolver hosts ni puertos |
| `-w` | Escribir pcap |
| `-r` | Leer pcap |
| `-c N` | Parar tras N paquetes |
| `-v` / `-vv` | Más detalle |
| `-A` / `-X` | ASCII / hex+ASCII del contenido del paquete |

### Filtros de captura (BPF) — ejemplos de lectura

```bash
tcpdump -n -i eth0 host 192.0.2.10
tcpdump -n -i eth0 net 10.0.0.0/8
tcpdump -n -i eth0 port 443
tcpdump -n -i eth0 tcp port 22
tcpdump -n -i eth0 icmp
tcpdump -n -i eth0 'tcp[tcpflags] & tcp-syn != 0'
tcpdump -n -r captura.pcap 'src net 192.168.0.0/16 and not port 22'
```

| Quark | Significado |
|-------|-------------|
| `host` / `net` / `port` | Criterios básicos |
| `src` / `dst` | Dirección |
| `and` / `or` / `not` | Combinar |
| `tcp` / `udp` / `icmp` | Protocolo |

---

## 3. Wireshark — filtros de **visualización**

Distinción importante:

| Tipo | Cuándo | Ejemplo |
|------|--------|---------|
| **Filtro de captura (BPF)** | Al capturar (menos volumen) | `port 53` |
| **Filtro de visualización** | Sobre lo ya capturado | `dns` / `http.request` |

### Filtros de visualización frecuentes

| Filtro | Qué muestra |
|--------|-------------|
| `ip.addr == 192.0.2.10` | Tráfico de/desde esa IP |
| `ip.src == 10.0.0.5` | Origen |
| `tcp.port == 443` | Puerto TCP |
| `tcp.flags.syn == 1 && tcp.flags.ack == 0` | SYN iniciales |
| `dns` | Tráfico DNS |
| `dns.qry.name contains "ejemplo"` | Consultas por nombre |
| `http` / `http.request` / `http.response.code == 404` | HTTP en claro |
| `tls.handshake.type == 1` | Client Hello |
| `tcp.analysis.retransmission` | Retransmisiones |
| `frame.time_relative > 1` | Frames tardíos (ajuste según caso) |

Combinar: `&&`, `\|\|`, `!`.

---

## 4. tshark (CLI tipo Wireshark)

```bash
tshark -r captura.pcap -Y 'dns'
tshark -r captura.pcap -Y 'ip.addr==192.0.2.10' -T fields -e ip.src -e ip.dst -e tcp.port
```

`-Y` = filtro de visualización; `-f` = BPF al capturar.

---

## 5. Lectura de una conversación TCP

En Wireshark: menú contextual → **Follow → TCP Stream** (o HTTP/TLS según caso).

| Qué mirar | Interpretación |
|-----------|----------------|
| Handshake SYN / SYN-ACK / ACK | Conexión establecida |
| Retransmisiones / dup ACK | pérdida o congestión |
| RST | cierre abrupto / rechazo |
| TLS Client Hello + certs | inicio HTTPS (aplicación cifrada después) |

Tráfico TLS: ver metadatos (SNI, certs en handshake); el cuerpo de aplicación va cifrado.

---

## 6. Buenas prácticas

| Práctica | Motivo |
|----------|--------|
| Capturar a fichero (`-w`) | no saturar la terminal |
| Empezar con filtro BPF acotado | menos ruido y disco |
| `-n` en CLI | salida predecible |
| Minimizar datos sensibles | cookies, auth en HTTP claro |
| Cadena de custodia si es incidente | hash SHA-256 del pcap |

---

## 7. Checklist

| Objetivo | Acción |
|----------|--------|
| Captura puntual | `tcpdump -i … -w fichero.pcap` |
| Ver DNS en pcap | Wireshark `dns` o `tcpdump -r … port 53` |
| Aislar un host | `host IP` / `ip.addr == …` |
| Ver retransmisiones | `tcp.analysis.retransmission` |
| Exportar campos | `tshark -T fields -e …` |

---

*Biblioteca — Redes · captura (lectura)*
