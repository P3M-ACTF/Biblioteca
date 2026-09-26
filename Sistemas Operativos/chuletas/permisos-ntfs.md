# Chuleta: permisos NTFS (Windows)

Referencia rápida del modelo de control de acceso en NTFS: DACLs, herencia, derechos básicos/avanzados y herramientas (`icacls`, interfaz, equivalencias conceptuales con POSIX).

---

## 1. Ideas clave (frente a POSIX)

| Concepto POSIX | Equivalente / análogo NTFS |
|----------------|----------------------------|
| `rwx` de u/g/o | ACE (Access Control Entries) en una DACL |
| Propietario (uid) | Owner (SID); puede ser usuario o grupo |
| Grupo dueño (gid) | No hay “grupo dueño” único; hay ACE de grupo |
| `chmod` | Cambiar ACE / mask de la DACL (`icacls`, Seguridad avanzada) |
| ACL POSIX (`setfacl`) | DACL NTFS (nativa; no es un “extra”) |
| setuid/setgid/sticky | No existen igual; hay *privileges*, ownership take, etc. |
| `root` | Administrators + SYSTEM + privilegios (Se*) |

NTFS usa **SID** (Security Identifiers), no nombres. Los nombres se resuelven vía SAM/AD.

Cada objeto (fichero, carpeta, registro, etc.) tiene un **security descriptor** con:

- **Owner**
- **Primary group** (poco usado en acceso diario)
- **DACL** — Discretionary ACL: quién puede qué
- **SACL** — System ACL: auditoría (quién se registra)

---

## 2. Anatomía de una ACE

Una entrada de la DACL típica incluye:

| Campo | Significado |
|-------|-------------|
| **Principal** | Usuario, grupo, equipo, SID bien conocido |
| **Tipo** | Allow (permitir) o Deny (denegar) |
| **Derechos** | Bitmask: lectura, escritura, modificar, Full control, etc. |
| **Herencia** | Si se aplica a este objeto, a hijos, solo a carpetas, etc. |

Orden de evaluación (simplificado):

1. Se recopilan ACE aplicables (explícitas + heredadas).
2. Un **Deny** explícito suele ganar sobre Allow (salvo matices de herencia y “deny heredado” vs “allow explícito”).
3. Si no hay Allow que cubra el acceso pedido → **denegado** (fail closed).

Regla práctica: evita Deny salvo excepciones; prefiere no conceder Allow.

---

## 3. Derechos básicos (UI “Seguridad”)

Vista simplificada del Explorador / propiedades:

| Nombre UI (ES) | Qué implica (resumen) |
|----------------|------------------------|
| **Control total** | Todo: cambiar permisos, tomar posesión, borrar, etc. |
| **Modificar** | Leer, escribir, ejecutar, borrar el objeto |
| **Lectura y ejecución** | Leer + ejecutar (o atravesar carpeta) |
| **Mostrar el contenido de la carpeta** | Listar (solo carpetas; alineado a lectura y ejecución) |
| **Lectura** | Leer datos / atributos / permisos |
| **Escritura** | Crear ficheros/dirs, escribir datos, atributos |

“Modificar” ≠ “Control total”: sin Control total normalmente **no** puedes cambiar la DACL ni el owner.

---

## 4. Derechos avanzados (bit a bit)

Ejemplos frecuentes en “Permisos especiales”:

| Derecho | Fichero | Carpeta |
|---------|---------|---------|
| Traverse folder / Execute file | Ejecutar | Atravesar |
| List folder / Read data | Leer datos | Listar |
| Read attributes / extended attributes | Metadatos | Idem |
| Create files / Write data | Escribir | Crear ficheros |
| Create folders / Append data | Append | Crear subcarpetas |
| Write attributes / EA | Cambiar attrs | Idem |
| Delete | Borrar objeto | Borrar objeto |
| Delete subfolders and files | — | Borrar hijos (aunque no seas owner del hijo) |
| Read permissions | Leer DACL | Idem |
| Change permissions | Cambiar DACL | Idem |
| Take ownership | Tomar posesión | Idem |

**Delete subfolders and files** en una carpeta es el análogo más cercano a poder limpiar contenidos ajenos (comparar mentalmente con sticky bit POSIX, pero invertido: aquí el permiso en el padre habilita el borrado).

---

## 5. Herencia

Las ACE pueden marcarse para propagarse:

| Flag (concepto) | Efecto |
|-----------------|--------|
| **This folder only** | Solo el contenedor |
| **This folder, subfolders and files** | Objeto + todo el árbol |
| **This folder and subfolders** | Carpetas, no ficheros |
| **This folder and files** | Carpeta + ficheros hijos directos / según flags |
| **Subfolders and files only** | No al contenedor (solo herederos) |
| **No propagate / one level** | Un nivel (CI/OI sin contenedor, etc.) |

En la UI: casilla **Heredar del objeto primario** y botón **Deshabilitar herencia**.

Al deshabilitar herencia puedes:

- **Convertir** ACE heredadas en explícitas (copia), o
- **Quitar** todas las heredadas (peligroso: puedes dejarte fuera).

Los objetos muestran iconos/estado: permisos **explícitos** vs **heredados**.

---

## 6. SID bien conocidos (atajos mentales)

| Nombre | Uso típico |
|--------|------------|
| `SYSTEM` | Servicio del sistema operativo |
| `Administrators` | Admins locales (grupo) |
| `Users` | Usuarios locales interactivos |
| `Authenticated Users` | Cualquiera autenticado (más amplio que Users) |
| `Everyone` | Incluye invitados en algunos contextos — úsalo con cuidado |
| `CREATOR OWNER` | Placeholder: se sustituye por el creador del objeto hijo |
| `INTERACTIVE` / `NETWORK` / `BATCH` | Logon types |

En dominio: `DOMAIN\Usuario`, grupos globales/universales, etc.

---

## 7. icacls — chuleta de comandos

`icacls` es la herramienta CLI moderna (sustituye en la práctica a `cacls` / `xcacls` antiguos).

### Ver permisos

```cmd
icacls C:\ruta\archivo
icacls C:\ruta\carpeta
icacls C:\ruta\carpeta /T          :: recursivo (listar)
icacls C:\ruta\* 
```

Salida típica:

```
archivo.txt BUILTIN\Administrators:(F)
            NT AUTHORITY\SYSTEM:(F)
            DOMINIO\ana:(M)
            ...
```

| Código | Significado |
|--------|-------------|
| `(F)` | Full access |
| `(M)` | Modify |
| `(RX)` | Read & execute |
| `(R)` | Read |
| `(W)` | Write |
| `(D)` | Delete |
| `(N)` | No access |
| `(OI)` | Object inherit (ficheros) |
| `(CI)` | Container inherit (carpetas) |
| `(IO)` | Inherit only (no aplica al objeto actual) |
| `(NP)` | No propagate |
| `(I)` | Inherited |

### Conceder / quitar

```cmd
:: Conceder Modify a un usuario
icacls C:\datos /grant DOMINIO\ana:(M)

:: Conceder con herencia a carpeta (OI)(CI)
icacls C:\datos /grant DOMINIO\devs:(OI)(CI)(M)

:: Denegar (preferible evitar)
icacls C:\datos\secreto.txt /deny DOMINIO\bob:(F)

:: Quitar ACE de un principal
icacls C:\datos /remove DOMINIO\bob

:: Sustituir (reset de grant para ese usuario)
icacls C:\datos /grant:r DOMINIO\ana:(RX)
```

### Herencia

```cmd
:: Activar herencia desde el padre
icacls C:\datos\hijo /inheritance:e

:: Deshabilitar herencia y COPIAR ACE heredadas a explícitas
icacls C:\datos\hijo /inheritance:d

:: Deshabilitar herencia y ELIMINAR heredadas
icacls C:\datos\hijo /inheritance:r
```

### Reset y propietario

```cmd
:: Restaurar ACL por defecto de sistema en carpeta (¡destructivo!)
icacls C:\datos /reset /T /C

:: Cambiar propietario
icacls C:\datos /setowner DOMINIO\ana /T

:: Tomar posesión (también: takeown)
takeown /F C:\datos /R /D Y
icacls C:\datos /grant Administrators:F /T
```

### Backup / restore de ACL

```cmd
icacls C:\datos /save C:\backup\acl.txt /T
icacls C:\datos /restore C:\backup\acl.txt
```

---

## 8. PowerShell (equivalentes modernos)

```powershell
# Ver ACL
Get-Acl C:\datos | Format-List
(Get-Acl C:\datos).Access

# Añadir regla Allow Modify
$acl = Get-Acl C:\datos
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
  "DOMINIO\ana", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.AddAccessRule($rule)
Set-Acl C:\datos $acl

# Deshabilitar herencia (copiar)
$acl = Get-Acl C:\datos\hijo
$acl.SetAccessRuleProtection($true, $true)   # protect, preserve
Set-Acl C:\datos\hijo $acl
```

---

## 9. UAC, elevación y “por qué no puedo borrar”

- Ser del grupo **Administrators** no implica token admin completo en sesión normal (UAC → *split token*).
- Carpetas de sistema / Program Files suelen requerir elevación.
- Si no eres **Owner** y no tienes Delete / Change permissions, puedes quedar bloqueado aunque seas admin hasta **Take ownership**.
- Flujos típicos de recuperación:
  1. `takeown /F ruta /R`
  2. `icacls ruta /grant Administrators:F /T`
  3. Ajustar DACL definitiva (principio de mínimo privilegio)

---

## 10. Recursos compartidos SMB vs NTFS

Al acceder por red se aplican **ambos**:

1. Permisos del **recurso compartido** (Share ACL) — a menudo Everyone:Change / Read
2. Permisos **NTFS** en disco

Efectivo ≈ intersección (el más restrictivo gana). Buena práctica: share permisivo + NTFS estricto (o ambos alineados y documentados).

---

## 11. Equivalencias mentales POSIX ↔ NTFS

| Quieres… | POSIX | NTFS |
|----------|-------|------|
| Solo yo leo/escribo | `chmod 600` / `700` | Quitar herencia; Allow solo a tu usuario (R/M); sin Users/Everyone |
| Equipo lee y escribe | `2775` + grupo | Allow al grupo `(OI)(CI)(M)`; Owner Administrators/SYSTEM |
| Público de solo lectura | `755` / `644` | Authenticated Users `(RX)` / `(R)` |
| /tmp con sticky | `chmod 1777` | Difícil de clonar 1:1; ACLs + quitar “Delete subfolders and files” a Users suele acercarse |
| Excepción a un usuario | `setfacl -m u:x:…` | `icacls /grant usuario:(…)` |
| Ver ACL | `getfacl` / `ls -l` | `icacls` / pestaña Seguridad |

No fuerces un mapeo exacto de `rwx` ↔ `(R)(W)(X)`: NTFS separa borrado, cambio de permisos y posesión de forma distinta.

---

## 12. Checklist operativo

| Tarea | Comando / acción |
|-------|------------------|
| Auditar carpeta | `icacls C:\ruta /T` |
| Dar acceso a un grupo | `icacls … /grant GRUPO:(OI)(CI)(M)` |
| Aislar carpeta sensible | `/inheritance:d` → quitar Users/Everyone → grant mínimo |
| Recuperar control | `takeown` + `icacls /grant Administrators:F` |
| Backup ACL antes de tocar | `icacls … /save acl.txt /T` |
| Compartido de red | Revisar Share ACL **y** NTFS |

### Errores frecuentes

- Dejar **Everyone:(F)** en datos sensibles.
- Desactivar herencia con `/inheritance:r` sin haber concedido Allow a tu cuenta admin.
- Confundir **Modify** (incluye Delete) con “solo editar contenido”.
- Arreglar solo el share y olvidar NTFS (o al revés).

---

## 13. Mapa rápido de códigos icacls

```
(F)  Full          (M)  Modify        (RX) Read & execute
(R)  Read          (W)  Write         (D)  Delete
(N)  No access

(OI) Object Inherit     (CI) Container Inherit
(IO) Inherit Only       (NP) No Propagate
(I)  Inherited
```

---

*Biblioteca — Sistemas Operativos · permisos NTFS*
