# Plantillas — Sistemas Operativos

Ejemplos **copiables** para administración. No son instaladores ni one-liners: revisa, adapta y valida en tu entorno.

| Plantilla | Uso |
|-----------|-----|
| [sshd_config.ejemplo](sshd_config.ejemplo) | Opciones habituales de endurecimiento SSH |
| [sudoers.d-ejemplo](sudoers.d-ejemplo) | Fragmento para `/etc/sudoers.d/` |
| [nftables-base.nft](nftables-base.nft) | Política base nftables (input restrictivo) |
| [unit-systemd.ejemplo](unit-systemd.ejemplo) | Esqueleto comentado de `.service` y `.timer` |
| [logrotate.d-ejemplo](logrotate.d-ejemplo) | Rotación de un log propio |
| [chrony.conf.ejemplo](chrony.conf.ejemplo) | Servidores NTP y opciones habituales de chrony |

> [!NOTE]
> Prueba cambios de SSH y firewall con una sesión alternativa abierta. Usa `visudo` / `sshd -t` / `nft -c` según corresponda.

Los `.reg` de Windows (rotación Intel, inicio rápido, Explorador y menú contextual) viven junto a su receta en [notas](../notas/README.md).
