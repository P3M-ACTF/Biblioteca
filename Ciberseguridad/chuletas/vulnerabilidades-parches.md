# Chuleta: vulnerabilidades y parches

Una vulnerabilidad es un fallo en un programa que permite que haga algo que no debería. Un parche es la corrección que publica quien lo mantiene. Entre las dos cosas hay una carrera: desde que el fallo se conoce hasta que lo aplicas, quien sea puede usarlo contra tus sistemas. Esta chuleta explica cómo se nombran y se miden las vulnerabilidades, cómo se organiza el parcheo para que ocurra de verdad, y qué hacer con las que no se pueden parchear todavía.

---

## 1. Cómo se nombra una vulnerabilidad

| Término | Qué es |
|---------|--------|
| **CVE** | El identificador público de una vulnerabilidad: `CVE-2026-12345`. Sirve para que todo el mundo hable de la misma, porque el nombre comercial cambia según el fabricante. Lleva una descripción, el producto afectado y las versiones. |
| **CVSS** | Una puntuación de 0 a 10 que estima la gravedad a partir de datos objetivos: si se puede explotar desde la red, si hace falta estar autenticado, si el impacto es total. No dice nada de tu entorno. |
| **Aviso del fabricante** | Lo que de verdad te dice qué hacer: qué versiones están afectadas, qué parche lo corrige y si hay algún paliativo mientras tanto. La fuente de referencia para decidir. |
| **PoC pública** | Una prueba de concepto publicada. Cuando existe, el tiempo importa más, porque usarla ya no exige conocimientos especiales. |

El CVSS se lee con calma. Una vulnerabilidad con un 9,8 que solo afecta a un componente que no tienes instalado no es tu urgencia; una con un 7,5 en el servidor web expuesto a Internet sí lo es. La puntuación ordena; el contexto decide. Por eso «parcheamos todo lo que sea crítico» sin mirar si aplica es tanto un desperdicio como un riesgo: se gasta el tiempo de la ventana en lo que no duele.

---

## 2. El ciclo, no el parche suelto

El parcheo que funciona es un ciclo repetido, no una reacción a cada noticia.

| Paso | Qué se hace | Por qué si falta |
|------|-------------|------------------|
| **Saber qué tienes** | Inventario de sistemas, versiones y qué está expuesto a la red. | Sin inventario no puedes saber si un CVE te afecta. Se acaba parcheando «lo que se recuerda». |
| **Enterarte** | Suscripción a los avisos de los fabricantes que realmente usas, no a un feed genérico de todo Internet. | Te enteras por la prensa, cuando ya lleva días circulando. |
| **Decidir** | ¿Aplica? ¿Está expuesto? ¿Hay parche? ¿Cuál es el paliativo si el parche tiene que esperar? | Todo llega marcado urgente y nada se prioriza. |
| **Probar** | El parche entra primero en un equipo que no es el crítico, cuando el cambio es gordo (kernel, motor de base de datos, framework). | El parche rompe producción y el siguiente se retrasa por miedo. |
| **Aplicar** | Dentro de la ventana acordada, con forma de volver atrás. | Se aplica un martes cualquiera, a mediodía, sobre el sistema de facturación. |
| **Comprobar** | La versión de después es la esperada, el servicio funciona y el aviso desaparece del escaneo. | Crees que está aplicado porque la tarea terminó sin error, y no lo está. |

Los plazos los marca la política de la organización, y suelen distinguir entre lo expuesto a Internet y lo interno. Lo único que no funciona es no tener plazo: «lo antes posible» significa «cuando alguien se acuerde».

---

## 3. Ventanas y cómo se aplica

Una ventana de mantenimiento es el momento acordado en el que se acepta interrumpir o arriesgar un servicio. Existe para que el parcheo no sea una negociación cada vez.

En Linux, el gestor de paquetes es quien aplica: las actualizaciones de seguridad vienen marcadas y se pueden instalar solas en los equipos donde un reinicio ocasional no importa, y de forma controlada donde sí importa. El kernel nuevo no entra en vigor hasta reiniciar, así que «paquete instalado» y «fallo corregido» no son lo mismo hasta el reinicio. Conviene saber qué máquinas llevan un reinicio pendiente.

```bash
apt list --upgradable
dnf updateinfo list security
needs-restarting -r 2>/dev/null || true
```

En Windows, Windows Update y, en una red con dominio, WSUS o las directivas de actualización deciden qué se aprueba y cuándo se reinicia. La pieza que se olvida es el reinicio: una actualización descargada y pendiente de reinicio no corrige nada todavía, y un servidor que lleva seis semanas pendiente de reinicio lleva seis semanas con el fallo corregido solo en el disco.

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
```

### Qué estás viendo

`Get-HotFix` lista las actualizaciones instaladas con su fecha. Si el aviso del fabricante dice que la corrección viene en `KB5040123` y esa KB no aparece, el servidor no la tiene, por mucho que Windows Update diga que está al día: puede estar al día respecto a lo que tu servidor WSUS le ofrece, y tu WSUS no haberla aprobado. La diferencia entre «el cliente está actualizado» y «el parche está aprobado e instalado» es la causa de muchas ventanas que aparentemente se cumplieron.

---

## 4. Cuando no se puede parchear

A veces el parche rompe una aplicación que el fabricante dejó de mantener, a veces no existe todavía, y a veces el sistema no se puede reiniciar hasta el mes que viene. Dejarlo «así hasta que se pueda» sin más es aceptar el riesgo sin decirlo. Las alternativas, de mejor a peor:

| Medida | Qué consigue |
|--------|--------------|
| **Aislar** | El sistema solo es alcanzable desde donde lo necesita. Un fallo explotable por red deja de serlo si la red no llega. Es la medida más efectiva mientras tanto. |
| **Paliativo del fabricante** | A veces hay una configuración que neutraliza el fallo sin el parche: desactivar el componente afectado, cambiar una opción. Viene en el aviso y tiene fecha de retirada, que es cuando salga el parche. |
| **Compensar** | Vigilancia adicional sobre ese sistema: alertas específicas, revisión más frecuente de sus registros. No cierra el fallo; acorta el tiempo hasta que te enteres. |
| **Aceptar por escrito** | Alguien con autoridad asume el riesgo, con fecha de revisión. No es lo deseable, pero es infinitamente mejor que aceptarlo en silencio, porque queda una fecha en la que se vuelve a preguntar. |

Lo que no es una medida: apagar el antivirus porque ralentiza, ni retrasar el parche sine die porque «ese servidor es delicado». Lo delicado es precisamente lo que más merece estar corregido, con la prueba previa que haga falta.

---

## 5. Checklist

| Pregunta | Respuesta que deberías tener |
|----------|------------------------------|
| ¿Nos afecta este CVE? | Lo dice el inventario: versión instalada contra versiones afectadas del aviso. |
| ¿Está expuesto? | Alcanzable desde Internet, desde toda la red interna, o solo desde un segmento. Cambia la prisa. |
| ¿Hay parche y de qué fecha? | El aviso del fabricante, no el titular. |
| ¿Cuándo se aplica y quién lo hace? | Una ventana, un responsable, una forma de volver atrás. |
| ¿Cómo se comprueba que quedó aplicado? | Versión o número de KB de después, más el servicio funcionando. |
| ¿Qué hacemos si no se puede? | Aislar, paliar o aceptar por escrito, con fecha. |

---

## 6. Error típico

**Situación.** Sale un aviso grave sobre el servidor web que usas, explotable desde la red, y hay parche el mismo día. En los servidores de producción lo aplicas esa tarde, reinicias y compruebas. Tres semanas después, un escaneo interno lo sigue marcando en el servidor de desarrollo, que resulta estar publicado al exterior porque alguien abrió el puerto para una demo y no se cerró.

**Por qué ocurre.** El ciclo se aplicó a lo que se considera producción y el inventario mental no incluía el servidor de desarrollo. Nadie lo parchea porque «no es de producción», pero está expuesto igual que si lo fuera: el fallo no distingue para qué se usa el servidor, solo si puede llegar a él. El escaneo lo encuentra porque el escaneo mira puertos, no organigramas.

**Cómo se ve.** El aviso del fabricante indica las versiones afectadas y el servidor de desarrollo está en una de ellas. Desde fuera, el puerto responde. En el inventario, ese servidor figura como baja prioridad y su último parche es de hace cuatro meses. Los de producción, comprobados, están bien: el proceso funcionó donde se aplicó.

**Cómo se arregla.** Parchear ese servidor hoy, cerrar el puerto que ya no necesita la demo, y corregir el inventario para que «expuesto a Internet» pese más que «es de desarrollo» a la hora de priorizar. La regla que sale del susto: lo que decide la prisa es la exposición y el impacto, no el nombre del entorno. Un servidor de pruebas alcanzable desde fuera es un servidor de producción a efectos de un fallo explotable por red.

---

Relacionado: [bastionado-linux](bastionado-linux.md) · [bastionado-windows](bastionado-windows.md) · [paquetes](../../Sistemas%20Operativos/chuletas/paquetes.md) · [windows-roles-actualizaciones](../../Sistemas%20Operativos/chuletas/windows-roles-actualizaciones.md) · [respuesta-incidentes](respuesta-incidentes.md)

*Biblioteca — Ciberseguridad · vulnerabilidades y parches*
