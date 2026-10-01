# Nota: journal persistente

Con `Storage=auto`, systemd guarda el journal en disco solo si ya existe `/var/log/journal`. Si no, los logs se pierden al reiniciar. Esta nota lo deja en persistente y con un tope de tamaño.

Entorno: Linux con systemd. Comandos de la chuleta: [systemd / journalctl](../chuletas/systemd-journalctl.md). Si el disco se llena por logs, sigue el runbook [disco lleno](../runbooks/disco-lleno.md).

## Dejarlo persistente

Un drop-in evita tocar el fichero de la distro:

```bash
sudo mkdir -p /etc/systemd/journald.conf.d
sudo tee /etc/systemd/journald.conf.d/persistente.conf >/dev/null <<'EOF'
[Journal]
Storage=persistent
SystemMaxUse=500M
EOF
sudo systemctl restart systemd-journald
```

`Storage=persistent` crea `/var/log/journal` y conserva los arranques anteriores. `SystemMaxUse=500M` es el tope; súbelo o bájalo según el disco.

## Comprobar

```bash
journalctl --disk-usage
ls /var/log/journal
journalctl -b -1 --lines=20
```

`-b -1` es el arranque anterior. Si responde, el journal sobrevivió al reinicio.

Para recortar a mano: `journalctl --vacuum-size=500M`.

## Volver a volátil

Borra el drop-in, reinicia `systemd-journald` y, si quieres liberar espacio ya, borra `/var/log/journal`.

---

*Biblioteca — Sistemas Operativos · journal persistente*
