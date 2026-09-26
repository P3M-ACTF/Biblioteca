# Chuleta: usuarios y grupos en Windows

Cuentas locales, grupos y UAC a alto nivel (`net user`, administración clásica).

---

## 1. Conceptos

| Concepto | Notas |
|----------|-------|
| Usuario local | SAM del equipo |
| Usuario de dominio | AD (si el equipo está unido) |
| Grupo | Conjunto de SID con privilegios/derechos |
| UAC | Elevación: el token admin no va “completo” hasta consentir |
| SID | Identificador de seguridad (no el nombre) |

---

## 2. net user / net localgroup

```cmd
net user
net user ana
net user ana ContrasenaSegura /add
net user ana /active:yes
net user ana /delete

net localgroup
net localgroup Administrators
net localgroup Administrators ana /add
net localgroup Users ana /add
```

PowerShell (equivalente moderno):

```powershell
Get-LocalUser
Get-LocalGroup
Get-LocalGroupMember Administrators
```

---

## 3. Grupos locales habituales

| Grupo | Rol típico |
|-------|------------|
| Administrators | Admin local (sujeto a UAC) |
| Users | Usuarios estándar |
| Remote Desktop Users | Escritorio remoto |
| Power Users | Legado; poco uso en modernas |

En dominio: preferir grupos de AD + GPO frente a admins locales dispersos.

---

## 4. UAC (alto nivel)

| Idea | Práctica |
|------|----------|
| Consentimiento | La app pide elevación; el usuario acepta |
| Token filtrado | Miembro de Administrators sin elevación ≠ root permanente |
| “Ejecutar como administrador” | Eleva ese proceso |
| Desactivar UAC | No recomendable en bastionado |

---

## 5. Buenas prácticas

| Práctica | Motivo |
|----------|--------|
| Cuentas nominativas | Auditoría |
| Admin diario separado del usuario de trabajo | Mínimo privilegio |
| Menos membresías en Administrators | Menor impacto de malware |
| Contraseñas / MFA según política | AuthN |

Relacionado: [permisos-ntfs](permisos-ntfs.md) · [autenticacion-autorizacion](../../Ciberseguridad/chuletas/autenticacion-autorizacion.md)

---

## 6. Checklist

| Objetivo | Comando / acción |
|----------|------------------|
| Listar usuarios | `net user` / `Get-LocalUser` |
| Ver admins | `net localgroup Administrators` |
| Alta local | `net user … /add` + grupo |
| ¿Quién soy? | `whoami` / `whoami /groups` |

---

*Biblioteca — Sistemas Operativos · Windows usuarios/grupos*
