# Descripción
**🏛️ Biblioteca de Libros, Documentación y Apuntes** relacionados con Informática, Redes Informáticas, Programación, Ciberseguridad y Tecnología en general.

En este repositorio puedes encontrar material útil para el aprendizaje y recursos de referencia para consulta.

> [!NOTE]
> Este es un repositorio colaborativo [^1]

## Contenido destacado

### Sistemas Operativos

| Recurso | Descripción |
|---------|-------------|
| [Aliases bash / zsh / sh](Sistemas%20Operativos/shell/README.md) | Aliases de admin + one-liner de instalación |
| [Índice de chuletas SO](Sistemas%20Operativos/chuletas/README.md) | Todas las chuletas de sistemas |
| [Runbooks SO](Sistemas%20Operativos/runbooks/README.md) | Máquina nueva, disco lleno, servicio caído |
| [Plantillas SO](Sistemas%20Operativos/plantillas/README.md) | sshd, sudoers.d, nftables base |
| [Permisos POSIX](Sistemas%20Operativos/chuletas/permisos-posix.md) | rwx, octal, bits especiales, ACLs |
| [Permisos NTFS](Sistemas%20Operativos/chuletas/permisos-ntfs.md) | ACL Windows, herencia, `icacls` |
| [systemd / journalctl](Sistemas%20Operativos/chuletas/systemd-journalctl.md) | Unidades, timers, journal |
| [Usuarios, grupos y sudo](Sistemas%20Operativos/chuletas/usuarios-grupos-sudo.md) | Cuentas y privilegios |
| [FHS y montajes](Sistemas%20Operativos/chuletas/fhs-montajes.md) | Jerarquía, discos, espacio |
| [Procesos y señales](Sistemas%20Operativos/chuletas/procesos-senales.md) | ps, kill, nice, jobs |
| [SSH admin](Sistemas%20Operativos/chuletas/ssh-admin.md) | Cliente, claves, endurecimiento |
| [Paquetes (apt/dnf)](Sistemas%20Operativos/chuletas/paquetes.md) | Consulta, instalar, actualizar |
| [Logs clásicos](Sistemas%20Operativos/chuletas/logs-clasicos.md) | `/var/log` y rotación |
| [Disco y LVM](Sistemas%20Operativos/chuletas/disco-lvm.md) | Particiones y LVM |
| [Entorno y PATH](Sistemas%20Operativos/chuletas/entorno-path.md) | Variables de entorno |
| [Windows: usuarios y grupos](Sistemas%20Operativos/chuletas/windows-usuarios-grupos.md) | net user, UAC |
| [Windows: servicios y eventos](Sistemas%20Operativos/chuletas/windows-servicios-eventos.md) | Servicios y Event Viewer |
| [SELinux / AppArmor](Sistemas%20Operativos/chuletas/selinux-apparmor.md) | MAC: modos y denegados |
| [Git diario](Sistemas%20Operativos/chuletas/git-diario.md) | Flujo diario de Git |
| [Cron y timers](Sistemas%20Operativos/chuletas/cron-timers.md) | crontab vs systemd timers |

### Redes

| Recurso | Descripción |
|---------|-------------|
| [Índice de chuletas Redes](Redes/chuletas/README.md) | Todas las chuletas de redes |
| [Modelo y puertos](Redes/chuletas/modelo-puertos.md) | OSI/TCP-IP, puertos, estados TCP |
| [Direccionamiento](Redes/chuletas/direccionamiento.md) | IPv4/IPv6, CIDR, gateway |
| [DNS](Redes/chuletas/dns.md) | Registros, dig, caché |
| [Diagnóstico](Redes/chuletas/diagnostico.md) | ip, ping, mtr, curl |
| [HTTP](Redes/chuletas/http.md) | Métodos, códigos, cabeceras |
| [NAT y enrutado](Redes/chuletas/nat-enrutado.md) | NAT y tablas de rutas |
| [Captura (lectura)](Redes/chuletas/captura.md) | tcpdump/Wireshark (lectura) |

### Ciberseguridad

| Recurso | Descripción |
|---------|-------------|
| [Índice de chuletas Ciberseguridad](Ciberseguridad/chuletas/README.md) | Todas las chuletas de ciberseguridad |
| [Autenticación y autorización](Ciberseguridad/chuletas/autenticacion-autorizacion.md) | Factores, hashes, mínimo privilegio |
| [Cifrado, hash y firma](Ciberseguridad/chuletas/cifrado-hash-firma.md) | Cuándo usar cada mecanismo |
| [Bastionado Linux](Ciberseguridad/chuletas/bastionado-linux.md) | Endurecimiento de host |
| [Respuesta a incidentes](Ciberseguridad/chuletas/respuesta-incidentes.md) | Fases IR y registro |
| [TLS](Ciberseguridad/chuletas/tls.md) | Handshake y certificados |
| [OWASP Top 10](Ciberseguridad/chuletas/owasp-top10.md) | Nombre e impacto |
| [Copias de seguridad](Ciberseguridad/chuletas/copias-seguridad.md) | 3-2-1 y conceptos |
| [Secretos](Ciberseguridad/chuletas/secretos.md) | Gestión de secretos |

### Inteligencia Artificial

| Recurso | Descripción |
|---------|-------------|
| [Preferencias para agentes de IA (ES)](Inteligencia%20Artificial/AI-PREFERENCES.es.md) | Preferencias generales de trabajo en castellano |
| [Preferencias para agentes de IA (EN)](Inteligencia%20Artificial/AI-PREFERENCES.en.md) | Traducción equivalente al inglés |
| [Guía de uso y adaptación](Inteligencia%20Artificial/GUIA-DE-USO-AI-PREFERENCES.md) | Cómo aplicar las preferencias en Codex, Cursor, OpenCode y otros entornos |

### Wiki

Guías narrativas: [Biblioteca Wiki](https://github.com/P3M-ACTF/Biblioteca/wiki)

### Temas

- [Sistemas Operativos](Sistemas%20Operativos/)
- [Redes](Redes/)
- [Ciberseguridad](Ciberseguridad/)
- [Programación](Programación/)
- [Electrónica](Electrónica/)
- [Inteligencia Artificial](Inteligencia%20Artificial/)

[^1]: Puedes colaborar en la construcción del repositorio creando un [Issue](../issues) adjuntando la dirección __URL del archivo__ que quieres añadir o tus __sugerencias__ para mejorar el repositorio ❤️.

<!-- Referencia para Formato de Estilos:
https://www.freecodecamp.org/news/github-flavored-markdown-syntax-examples/
https://docs.github.com/es/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
--!>
