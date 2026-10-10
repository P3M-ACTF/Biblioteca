# Notas — Sistemas Operativos

Recetas cortas e independientes. Cada una resuelve una tarea concreta; el detalle de un tema entero sigue en las [chuletas](../chuletas/README.md).

| Nota | Contenido |
|------|-----------|
| [Guest Additions (VirtualBox)](guest-additions-virtualbox.md) | `linux-headers`, DKMS e instalador de la ISO |
| [Nano: sintaxis y atajos](nano-sintaxis-atajos.md) | Resaltado en `~/.nanorc` y Ctrl+S / Ctrl+Z |
| [Rotación de pantalla Intel](windows-intel-rotacion.md) | Desactivar el giro con Ctrl+Alt+flechas (`.reg`) |
| [Carpetas compartidas (VirtualBox)](carpetas-compartidas-virtualbox.md) | Grupo `vboxsf`, montaje y `fstab` |
| [Inicio rápido de Windows](windows-inicio-rapido.md) | `HiberbootEnabled` y dual boot |
| [Extensiones y archivos ocultos](windows-explorador-extensiones.md) | Explorador de archivos (`.reg`) |
| [Menú contextual clásico (Windows 11)](windows-menu-contextual-clasico.md) | Volver al menú de Windows 10 (`.reg`) |
| [Journal persistente](journal-persistente.md) | `Storage=persistent` en journald |
| [Swap en fichero](swap-fichero.md) | `mkswap`, `swapon` y `fstab` |
| [Claves SSH la primera vez](ssh-claves-primer-uso.md) | generar una Ed25519, copiarla y usar el agente |
| [Hora con chrony o timesyncd](hora-ntp-chrony.md) | dejar el reloj sincronizado y comprobarlo |
| [Hora de Windows en arranque dual](windows-hora-dual-boot.md) | `RealTimeIsUniversal` para que el reloj no se desfase (`.reg`) |
| [winget](windows-winget.md) | instalar y actualizar software desde la línea de comandos |
| [SFC y DISM](windows-sfc-dism.md) | reparar los ficheros de sistema antes de reinstalar |
| [Certificado autofirmado de laboratorio](certificado-autofirmado-lab.md) | generarlo con SAN e importarlo como confiable |

Los `.reg` están junto a su nota. Ábrelos con el Editor del Registro o impórtalos con `regedit`.

Relacionado: [chuletas](../chuletas/README.md) · [runbooks](../runbooks/README.md) · [plantillas](../plantillas/README.md) · [aliases de shell](../shell/README.md).
