# Chuleta: roles y actualizaciones en Windows Server

Windows Update, Server Manager, roles y características. Vista de administración, no de ataque.

---

## 1. Server Manager — roles y características

| Concepto | Significado |
|----------|-------------|
| **Rol** | Función mayor del servidor (AD DS, DNS, IIS, File Services…) |
| **Característica** | Capacidad transversal (Failover Clustering, .NET, SNMP…) |
| **Server Manager** | Consola para instalar/ver roles y el estado del servidor |

```powershell
Get-WindowsFeature
Get-WindowsFeature | Where-Object InstallState -eq 'Installed'
# Instalación (ejemplo; requiere privilegios y planificación):
# Install-WindowsFeature -Name DNS -IncludeManagementTools
```

En UI: **Server Manager → Manage → Add Roles and Features**.

> [!NOTE]
> Instalar un rol cambia la superficie del servidor. Documenta el motivo y reinicia si el asistente lo pide.

---

## 2. Windows Update (admin)

| Herramienta | Uso |
|-------------|-----|
| Settings → Windows Update | Cliente / Server con UI moderna |
| `sconfig` | Menú texto en Server Core |
| WSUS / Intune / SCCM | Gestión centralizada (según org) |

```powershell
# Estado / historial (módulo según versión)
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15

# Windows Update (PSWindowsUpdate u otros módulos — si están aprobados en tu org)
# Get-WindowsUpdate
```

Buenas prácticas: anillo de prueba → producción; ventanas de mantenimiento; reinicios planificados tras updates de calidad/feature.

---

## 3. Qué mirar tras un rol o un parche

| Pregunta | Dónde |
|----------|-------|
| ¿El servicio del rol corre? | `Get-Service` / [servicios-eventos](windows-servicios-eventos.md) |
| ¿Errores de instalación? | Visor de eventos → Setup / System |
| ¿Queda reinicio pendiente? | banner Server Manager / `shutdown /r` planificado |
| ¿Puerto en listen esperado? | `Get-NetTCPConnection -State Listen` |

---

## 4. Checklist

| Objetivo | Acción |
|----------|--------|
| Ver roles instalados | `Get-WindowsFeature` (Installed) |
| Añadir rol | Server Manager / `Install-WindowsFeature` con plan |
| Parches recientes | `Get-HotFix` + consola Update |
| Post-cambio | servicios + eventos System |

Relacionado: [windows-servicios-eventos](windows-servicios-eventos.md) · [bastionado-windows](../../Ciberseguridad/chuletas/bastionado-windows.md)

---

*Biblioteca — Sistemas Operativos · Windows roles / actualizaciones*
