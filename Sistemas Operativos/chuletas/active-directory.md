# Chuleta: Active Directory (alto nivel)

Dominio, controlador, usuarios/grupos, OU y GPO: **qué son y qué aplican**. Sin procedimientos de ataque ni elusión de políticas.

---

## 1. Piezas básicas

| Concepto | Significado |
|----------|-------------|
| **Dominio** | Contenedor de seguridad AD (cuentas, políticas, recursos) |
| **Bosque / árbol** | Jerarquía de dominios (confianza entre ellos) |
| **Controlador de dominio (DC)** | Servidor que autentica y sirve el directorio (AD DS) |
| **Objeto** | Usuario, equipo, grupo, OU… |
| **SID** | Identificador de seguridad del objeto |

El cliente **unido al dominio** usa cuentas de dominio y recibe políticas (GPO) según ubicación y filtrado.

---

## 2. Usuarios y grupos de dominio

| Tipo de grupo | Ámbito típico |
|---------------|---------------|
| Seguridad | Permisos y derechos |
| Distribución | Correo (no ACL) |
| Global / Universal / Domain Local | Ámbito de uso en bosques (diseño clásico AGDLP) |

```powershell
# En un DC o con RSAT / módulo AD (si está disponible)
Get-ADDomain
Get-ADUser -Identity ana -Properties MemberOf
Get-ADGroup Member -Properties Members
whoami /groups
```

Buenas prácticas: grupos por rol; evitar usuarios sueltos en ACL de ficheros; cuentas de servicio con privilegio mínimo.

---

## 3. Unidades organizativas (OU)

| Idea | Notas |
|------|-------|
| OU | Contenedor lógico para delegar admin y enlazar GPO |
| No es un grupo de seguridad | No da permisos por sí sola |
| Diseño | Por departamento, geografía o función — estable y documentado |

Mover un objeto de OU puede cambiar las GPO que le aplican.

---

## 4. GPO — qué aplican (no cómo atacarlas)

**Group Policy Object**: conjunto de valores de configuración aplicados a usuarios y/o equipos.

| Ámbito | Ejemplos de efecto |
|--------|-------------------|
| Equipo | firewall, scripts de arranque, restricciones locales |
| Usuario | redirección de carpetas, políticas de IE/Edge, scripts de logon |

```powershell
gpresult /r
gpresult /h reporte.html
# En DC:
Get-GPO -All
```

Orden mental (simplificado): políticas locales → sitio → dominio → OU (la más específica suele ganar en conflictos, con excepciones de herencia/enforcement).

> [!NOTE]
> Diagnosticar “no se aplica la GPO”: membresía, OU correcta, filtrado de seguridad/WMI, replicación, `gpresult`. No desactives políticas de seguridad para “probar” en producción sin cambio controlado.

---

## 5. Relación con el host

| En el cliente | En el directorio |
|---------------|------------------|
| `whoami` / grupos | objetos de usuario/grupo |
| Firewall perfil Domain | GPO de firewall |
| RDP/WinRM | grupos + GPO de derechos |
| NTFS con grupos de dominio | ACE con SID de dominio |

Chuletas: [windows-firewall-acceso](windows-firewall-acceso.md) · [permisos-ntfs](permisos-ntfs.md) · [windows-usuarios-grupos](windows-usuarios-grupos.md)

---

## 6. Checklist de lectura

| Pregunta | Herramienta / foco |
|----------|---------------------|
| ¿Estoy en dominio? | `echo %USERDOMAIN%` / `Get-ADDomain` |
| ¿Qué grupos tengo? | `whoami /groups` |
| ¿Qué GPO aplican? | `gpresult /r` |
| ¿Dónde está el objeto? | OU del usuario/equipo en ADUC |

---

*Biblioteca — Sistemas Operativos · Active Directory*
