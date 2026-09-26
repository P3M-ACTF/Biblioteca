# Chuleta: servicios y eventos en Windows

`services.msc`, Visor de eventos y equivalentes PowerShell (`Get-Service`, `Get-WinEvent`).

---

## 1. Servicios

| Herramienta | Uso |
|-------------|-----|
| `services.msc` | Consola gráfica |
| `Get-Service` | Listar / filtrar en PowerShell |
| `sc.exe` | Consulta/control clásico |

```powershell
Get-Service
Get-Service -Name spooler
Get-Service | Where-Object Status -eq 'Running'
Start-Service -Name nombre
Stop-Service -Name nombre
Restart-Service -Name nombre
Get-Service nombre | Format-List *
```

```cmd
sc query
sc query nombre
sc qc nombre
```

| Campo útil | Significado |
|------------|-------------|
| Status | Running / Stopped… |
| StartType | Automatic / Manual / Disabled |
| BinaryPathName | Binario y argumentos |

---

## 2. Visor de eventos (Event Viewer)

Ruta UI: `eventvwr.msc`

| Registro habitual | Contenido |
|-------------------|-----------|
| **Windows Logs → System** | Kernel, servicios, drivers |
| **Windows Logs → Security** | Auditoría (logon, privilegios…) |
| **Windows Logs → Application** | Apps que usan el log de aplicación |
| **Applications and Services Logs** | Canales específicos (p. ej. PowerShell) |

IDs frecuentes (orientativos): logon correcto/fallido, reinicio inesperado, servicio no pudo iniciar — consultar documentación del ID concreto.

---

## 3. Get-WinEvent

```powershell
Get-WinEvent -ListLog * | Where-Object RecordCount -gt 0

Get-WinEvent -LogName System -MaxEvents 50
Get-WinEvent -LogName Security -MaxEvents 20

Get-WinEvent -FilterHashtable @{
  LogName = 'System'
  Level = 2          # Error
  StartTime = (Get-Date).AddHours(-6)
} -MaxEvents 30

Get-WinEvent -FilterHashtable @{
  LogName = 'System'
  ProviderName = 'Service Control Manager'
} -MaxEvents 20
```

Niveles: 1 Critical, 2 Error, 3 Warning, 4 Information…

---

## 4. Relación servicio ↔ eventos

1. `Get-Service` → estado y nombre.  
2. System log / SCM → por qué no arrancó.  
3. Application log → error de la app.  
4. Dependencias del servicio en `services.msc` (pestaña Dependencias).

---

## 5. Checklist

| Objetivo | Acción |
|----------|--------|
| ¿Está en ejecución? | `Get-Service nombre` |
| Tipo de arranque | propiedades en `services.msc` / `sc qc` |
| Errores recientes | `Get-WinEvent -LogName System` (Level 2) |
| Auditoría de acceso | Security (si la política audita) |

---

*Biblioteca — Sistemas Operativos · Windows servicios/eventos*
