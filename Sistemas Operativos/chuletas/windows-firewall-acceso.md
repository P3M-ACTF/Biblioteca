# Chuleta: Firewall de Windows, RDP y WinRM

Acceso remoto y cortafuegos del host a nivel de administración. Sin técnicas de elusión.

---

## 1. Firewall de Windows (con seguridad avanzada)

| Vista | Uso |
|-------|-----|
| `wf.msc` | Reglas entrantes/salientes, conexión de seguridad |
| Panel de control / Settings | Perfiles Dominio / Privado / Público |
| PowerShell | `Get-NetFirewallRule`, perfiles |

```powershell
Get-NetFirewallProfile
Get-NetFirewallRule -Enabled True | Select-Object Name, Direction, Action, Profile
Get-NetFirewallPortFilter | Where-Object LocalPort -in 3389,5985,5986
```

Perfiles: **Domain** (unido a dominio), **Private**, **Public** (más restrictivo por defecto).

Política sensata: denegar entrante no necesario; RDP/WinRM solo desde redes de administración.

---

## 2. RDP (Escritorio remoto)

| Tema | Notas de admin |
|------|----------------|
| Puerto por defecto | TCP **3389** (cambiar puerto ≠ seguridad fuerte por sí solo) |
| Quién puede | grupo **Remote Desktop Users** (+ derechos) |
| Red | Preferir VPN/bastión; no exponer 3389 a Internet sin controles |
| NLA | Network Level Authentication recomendado |
| Certificado | TLS del servicio RDP; evitar “aceptar siempre” a ciegas |

```powershell
# ¿Escucha RDP?
Get-NetTCPConnection -LocalPort 3389 -State Listen -ErrorAction SilentlyContinue
# Miembros con derecho a RDP (local)
net localgroup "Remote Desktop Users"
```

---

## 3. WinRM (administración remota)

| Tema | Notas |
|------|-------|
| HTTP | puerto **5985** (por defecto) |
| HTTPS | puerto **5986** |
| Uso | PowerShell Remoting (`Enter-PSSession`, `Invoke-Command`) |
| Auth | Kerberos en dominio; certificados/HTTPS fuera de dominio |
| Firewall | reglas “Windows Remote Management” |

```powershell
winrm quickconfig          # solo si tu política lo permite; revisa impacto
Test-WSMan -ComputerName nombre
Get-Service WinRM
```

No habilites WinRM en hosts que no deban administrarse en remoto. Acota orígenes.

---

## 4. Matriz de acceso

| Necesitas… | Canal | Control típico |
|------------|-------|----------------|
| Escritorio | RDP | grupo + firewall + MFA/VPN |
| Shell/admin script | WinRM / PS Remoting | HTTPS o dominio + firewall |
| Archivos | SMB (445) | no exponer a Internet; NTFS + share ACL |

---

## 5. Checklist

| Objetivo | Acción |
|----------|--------|
| Ver perfiles firewall | `Get-NetFirewallProfile` |
| Reglas RDP/WinRM | `wf.msc` / `Get-NetFirewallRule` |
| ¿Quién tiene RDP? | `Remote Desktop Users` |
| WinRM activo | `Get-Service WinRM` + `Test-WSMan` |
| Exposición | confirmar que no hay 3389/5985 abiertos a `Any` sin necesidad |

Relacionado: [windows-usuarios-grupos](windows-usuarios-grupos.md) · [bastionado-windows](../../Ciberseguridad/chuletas/bastionado-windows.md)

---

*Biblioteca — Sistemas Operativos · Windows firewall / acceso*
