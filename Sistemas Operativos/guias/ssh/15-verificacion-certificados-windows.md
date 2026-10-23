# SSH · Evidencia local de certificados y KRL en Windows

[Índice](README.md) · [Práctica](13-certificados-ca-krl.md) · [Referencia](14-referencia-certificados.md)

Registro del **23 de octubre de 2026**. Se ejecutaron **71 operaciones/comprobaciones locales de ssh-keygen** (incluida la preparación de claves y certificados), todas con resultado esperado. Además, el perfil cliente de la práctica se validó mediante ssh -G sin conexión. No representa 71 laboratorios de autenticación ni una certificación de compatibilidad de todas las opciones.

| Campo | Entorno observado |
| --- | --- |
| Sistema | Windows 11, build 26200. |
| Herramientas | OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2; ssh-keygen de C:\Windows\System32\OpenSSH. |
| Ejecución | Argumentos enviados directamente al proceso con subprocess de Python; sin shell intermedio para las órdenes de ssh-keygen. |
| Datos | Claves Ed25519 efímeras para tres CA de control, usuarios y host; sin identidades reales. |
| Protección | Fixtures descartables sin frase de paso, exclusivamente para automatizar estas comprobaciones; retiradas al finalizar. La práctica utiliza privadas protegidas con frase de paso. |
| Alcance | Sin conexiones de red, modificación de sshd/servicios, instalación de confianza ni autenticadores FIDO. |

La referencia documental del bloque es **Portable 10.6p1**; la versión realmente ejecutada es **Windows 9.5p2**. No se extrapolan resultados de una a la otra. El intento de utilizar WSL devolvió acceso denegado; no se ejecutó laboratorio Linux mediante esa vía. Bash tampoco pudo arrancar por restricciones del entorno, por lo que no se verificó la sintaxis de sus fragmentos con bash -n.

## Resultados agrupados

| Grupo de órdenes ejecutadas | Resultado observado | Lo que sigue pendiente |
| --- | --- | --- |
| Generación Ed25519 y firma de usuario con -s/-I/-n/-V/-z | Emisión correcta y campos esperados con -L. | Autenticación y validación de firma por un servidor. |
| Firma de host con -h y otra CA | Type host certificate y nombre esperado. | Presentación desde sshd y verificación desde C. |
| Certificado sin -O frente a -O clear | Defaults incluyen cinco permisos; clear deja Extensions: (none). | Efecto sobre PTY, rc y forwarding en sesión real. |
| -O clear seguido de -O permit-pty | Aparece permit-pty; no permit-port-forwarding ni permit-agent-forwarding. | Petición de PTY admitida/rechazada por política efectiva. |
| -O force-command=hostname seguido de -O clear | force-command sigue presente y extensiones quedan vacías. | Ejecución efectiva y combinación con ForceCommand/authorized_keys. |
| -L sobre certificado expirado / pública ordinaria | Lee el certificado pasado; la pública ordinaria falla como certificado. | Rechazo temporal al autenticar; -L no verifica aceptación. |
| Intervalo invertido y fecha absoluta aislada | Retorno no cero. | Repetición en Portable 10.6p1; su parser se contrastó documentalmente. |
| Serial máximo / desbordamiento / hexadecimal CLI | Máximo uint64 se emite; desbordamiento y 0x10 en -z se rechazan. | Gestión persistente de seriales, que no proporciona esta CLI. |
| -z +3001 con dos públicas | Seriales 3001 y 3002 inspeccionados. | Emisiones concurrentes y control administrativo de unicidad. |
| -n primero -n segundo | Solo aparece segundo. | Autorización con principal correcto/incorrecto en B. |
| KRL vacía desde especificación vacía | Consulta de certificado devuelve ok y 0. | Archivo legible y aplicado en contexto real. |
| KRL serial: 1001 con CA pública | Revoca serial 1001 de esa CA; no serial 1002 ni serial 1001 de otra CA. | Rechazo de conexión nueva tras distribuirla. |
| -k -u añade id: usuario-lab-1002 | Conserva revocación anterior y añade la del ID; versión 2 visible con -Q -l. | Sustitución atómica y verificación posterior en B. |
| KRL de pública subyacente o pública de CA | Certificados correspondientes consultados como REVOKED; otra CA queda no revocada. | Alcance sobre usuarios activos y recuperación real. |
| KRL de certificado de host | Consulta de ese certificado devuelve REVOKED. | Rechazo del host antes de autenticar usuario. |
| key:, sha1:, sha256:, hash: y serial: 1001-1002 | Consultas del material correspondiente revocadas y extremos de rango incluidos. | Compatibilidad con versiones antiguas y distribución íntegra. |
| serial: 0 o serial sin -s CA | Generación rechazada. | Política de serial/ID en una emisión real. |
| -Q con KRL ausente/corrupta | Error con retorno no cero. | Comportamiento del cliente/servidor ante rutas inaccesibles en un entorno dedicado. |
| source-address inválida | Emisión rechazada. | Comparación de origen admitido/excluido observada por B. |
| Crítica arbitraria prueba@lab.example | Se serializa y aparece al inspeccionar. | Rechazo por el verificador si no conoce esa crítica. |

Las operaciones de preparación, firma e inspección necesarias para esos grupos están incluidas en el total 71. Las salidas se comprobaron mediante retorno y fragmentos esperados; no se publican claves privadas ni volcados de fixtures.

El perfil cliente de la práctica pasó adicionalmente la inspección con ssh -G: destino/puerto/cuenta, HostKeyAlias, algoritmos de certificado para host y usuario, autenticación por pública, ForwardAgent no y StrictHostKeyChecking activo coincidieron con lo previsto. Esta lectura de configuración no acredita conexión ni carga de las credenciales.

## Órdenes representativas y lectura de salida

Con archivos nuevos de laboratorio preparados según la práctica:

```sh
ssh-keygen -L -f ./usuario_v1-cert.pub
ssh-keygen -Q -f ./usuarios-v2.krl ./usuario_v1-cert.pub
ssh-keygen -Q -l -f ./usuarios-v2.krl
```

**Qué estás viendo.** -L enumera campos sin probar aceptación. La consulta de un certificado revocado produjo retorno **1** con REVOKED; los controles no revocados produjeron **0** con ok. El listado mostró la versión KRL esperada. Los errores de fichero/formato produjeron un no cero y se clasificaron como error, no como prueba de revocación.

En PowerShell, registrar inmediatamente:

```powershell
ssh-keygen -Q -f ./usuarios-v2.krl ./usuario_v1-cert.pub
$LASTEXITCODE
```

**Qué estás viendo.** El valor pertenece a la orden externa inmediatamente anterior. No ejecutar otra orden externa antes de capturarlo. Una KRL que responde ok no acredita CA confiable, principal autorizado, reloj correcto o privada disponible.

## Cómo completar la verificación

Repetir la práctica con C y B reales de laboratorio, registrando versión/build de ambos, política efectiva, cada conexión nueva y logs correlacionados. Completar casos positivos y negativos de principal, CA, nombre, tiempo, revocación y recuperación; mantener abiertas las casillas mientras falte esa evidencia.

No se ensayaron firmas/validación con hardware FIDO, PKCS#11, emisión por agente, múltiples archivos de revocación de 10.6p1, revocación masiva ni despliegue de producción. La automatización local de comprobación no se incorpora como dependencia ni como workflow de Biblioteca.
