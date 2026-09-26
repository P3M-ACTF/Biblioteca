# Chuleta: cortafuegos en Linux

Perímetro (appliance / security group) frente a **firewall en el host**. Un solo frontal de administración en el host; no apilar UFW e iptables a mano.

---

## 1. Dos planos

| Plano | Ejemplos | Rol |
|-------|----------|-----|
| **Perímetro** | Firewall dedicado, NGFW, security group cloud | Filtra antes de llegar al host |
| **Host** | netfilter vía firewalld / nftables / ufw | Última línea en la máquina |

Ambos pueden (y suelen) coexistir: el security group no sustituye un host endurecido, ni al revés.

---

## 2. netfilter y frontales

```
Política admin → frontal (firewalld | ufw | nft) → netfilter (kernel)
```

| Frontal | Dónde suele verse | Notas |
|---------|-------------------|-------|
| **firewalld** | RHEL y derivados | Zonas; backend nftables en versiones modernas |
| **nftables** | Imágenes/distros modernas | `nft` directo; plantilla de ejemplo en el repo |
| **ufw** | Ubuntu (simple) | Frontal amigable; no mezclar con reglas iptables manuales |
| **iptables** | Legado / compat | A menudo `iptables-nft` (misma API, backend nft) |

La plantilla [`nftables-base.nft`](../plantillas/nftables-base.nft) es el ejemplo del **camino nftables**, no el único válido.

---

## 3. ¿Cuál está activo?

```bash
# firewalld
sudo firewall-cmd --state
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --list-all

# ufw
sudo ufw status verbose

# nftables (reglaset cargado)
sudo nft list ruleset

# iptables legado / compat (puede mostrar reglas vía iptables-nft)
sudo iptables -L -n -v
sudo iptables -V          # indica nft o legacy
```

| Señales | Interpretación |
|---------|----------------|
| `firewall-cmd --state` → running | Gestiona firewalld; no edites nft a espaldas |
| `ufw status` → active | Usa ufw; no apiles iptables manual |
| Solo `nft list ruleset` con reglas | Camino nft “a pelo” o backend sin otro frontal |
| Varios frontales “activos” | Conflicto — elige **uno** y documenta |

---

## 4. Política base (host)

Idea habitual: **input drop** por defecto, allow established/related, allow admin (SSH acotado), allow servicios del rol, output según necesidad.

No abras “todo a any” para salir del paso. Tras cambios, comprueba con sesión alternativa.

---

## 5. Relación con el perímetro

| Security group / NACL | Firewall host |
|-----------------------|---------------|
| Puerto 22 desde bastión | SSH solo en el host |
| 443 público | nginx/apache listen + allow 443 |
| Denegar resto | `policy drop` en input |

Si el SG cierra el puerto, el host no lo verá; si el SG abre y el host dropea, tampoco entra.

---

## 6. Checklist

| Objetivo | Comando / acción |
|----------|------------------|
| ¿Qué frontal hay? | `firewall-cmd --state` / `ufw status` / `nft list ruleset` |
| Un solo gestor | no mezclar ufw + iptables manual |
| SSH acotado | origen admin + fail2ban/política según org |
| Tras cambiar | probar desde otra sesión; revisar `ss -tulpn` |

Relacionado: plantilla [nftables-base.nft](../plantillas/nftables-base.nft) · [bastionado-linux](../../Ciberseguridad/chuletas/bastionado-linux.md) · runbook [máquina nueva](../runbooks/maquina-nueva.md)

---

*Biblioteca — Sistemas Operativos · firewall Linux*
