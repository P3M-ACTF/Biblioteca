# Chuleta: bastionado Windows

Lista de control defensiva: cuentas, actualizaciones, firewall, NTFS, eventos y copias. Alto nivel; sin eludir controles.

---

## 1. Principios

| Principio | Práctica |
|-----------|----------|
| Superficie mínima | Menos roles, menos puertos, menos admins locales |
| Mínimo privilegio | UAC on; admin separado del usuario diario |
| Parcheo | Windows Update / WSUS / anillo de prueba |
| Observabilidad | Security + System; retención |
| Resiliencia | Backups 3-2-1; restore probado |

---

## 2. Cuentas

| Control | Acción |
|---------|--------|
| Nominativas | Evitar cuentas compartidas “Admin” |
| Local Admins | Membresía mínima; LAPS / gestión de password local si aplica |
| UAC | Activo |
| Dominio | Grupos de AD + GPO frente a admins locales dispersos |
| Guest / cuentas huérfanas | Deshabilitar |

Chuleta: [windows-usuarios-grupos](../../Sistemas%20Operativos/chuletas/windows-usuarios-grupos.md) · [active-directory](../../Sistemas%20Operativos/chuletas/active-directory.md)

---

## 3. Actualizaciones y roles

- Parches de seguridad al día; reinicios planificados.  
- Solo roles necesarios (Server Manager).  
- Tras instalar rol: revisar servicios y firewall.

Chuleta: [windows-roles-actualizaciones](../../Sistemas%20Operativos/chuletas/windows-roles-actualizaciones.md)

---

## 4. Firewall y acceso remoto

- Perfiles Domain/Private/Public coherentes.  
- RDP/WinRM acotados a redes de admin (VPN/bastión).  
- No publicar 3389/5985 a Internet sin capas adicionales.

Chuleta: [windows-firewall-acceso](../../Sistemas%20Operativos/chuletas/windows-firewall-acceso.md)

---

## 5. NTFS y datos

- Herencia consciente; quitar Everyone/Users excesivos en datos sensibles.  
- Principio: share permisivo + NTFS estricto (o ambos alineados).  
- Take ownership solo como recuperación controlada.

Chuleta: [permisos-ntfs](../../Sistemas%20Operativos/chuletas/permisos-ntfs.md)

---

## 6. Eventos y servicios

| Área | Mirar |
|------|-------|
| System | fallos de servicio, reinicios |
| Security | logon, privilegios (si hay auditoría) |
| Servicios | StartType, cuentas de servicio con mínimo privilegio |

Chuleta: [windows-servicios-eventos](../../Sistemas%20Operativos/chuletas/windows-servicios-eventos.md)

---

## 7. Copias de seguridad

- Regla 3-2-1; probar restore.  
- Separar credenciales de backup del admin diario.  
- Volume Shadow Copy / agente corporativo según diseño.

Chuleta: [copias-seguridad](copias-seguridad.md)

---

## 8. Checklist rápido

| Área | ☐ |
|------|---|
| Parches al día / reinicio planificado | |
| Roles mínimos instalados | |
| Admins locales revisados + UAC | |
| Firewall: RDP/WinRM acotados | |
| NTFS en datos sensibles revisado | |
| Eventos Security/System retenidos | |
| Backup y restore verificados | |

---

*Biblioteca — Ciberseguridad · bastionado Windows*
