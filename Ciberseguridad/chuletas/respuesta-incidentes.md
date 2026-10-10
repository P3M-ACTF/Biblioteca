# Chuleta: respuesta a incidentes

Un incidente es un momento en el que se trabaja peor de lo normal: hay prisa, información a medias y gente preguntando. Tener el orden decidido de antemano es lo que evita los dos errores grandes: tocar cosas antes de apuntarlas, y ponerse a reparar sin haber parado el daño. Esta chuleta describe las fases, qué se anota en cada una y cómo se decide la gravedad. Es un marco de proceso; no contiene procedimientos de ataque.

---

## 1. Para qué sirve el proceso

Tres objetivos, en este orden cuando hay que elegir: **parar el daño**, **volver a dar el servicio con confianza** y **aprender**. Preservar evidencias no es un objetivo aparte: es lo que permite saber, durante y después, qué pasó de verdad. En un incidente menor se hace ligero; en uno grave es lo que diferencia una recuperación de una repetición.

Quien responde necesita saber de antemano tres cosas que no se improvisan: a quién se llama, qué sistemas son los importantes y dónde están las copias de seguridad. Eso es la fase de preparación, y se hace cuando no pasa nada.

---

## 2. Las fases

| Fase | La pregunta | Qué se hace |
|------|-------------|-------------|
| **1. Preparar** | ¿Estaríamos listos hoy? | Inventario de sistemas, contactos y escalado, copias que se han probado, relojes en hora, registros que se conservan, cuentas de administración separadas. |
| **2. Detectar e identificar** | ¿Qué está pasando y hasta dónde llega? | Recoger la alerta, confirmar que es real, ver qué sistemas están afectados y decidir la gravedad. |
| **3. Contener** | ¿Cómo se para esto? | Aislar lo afectado de la red, revocar sesiones, cambiar credenciales comprometidas. Primero se frena; luego se estudia con calma. |
| **4. Erradicar** | ¿Por dónde entró y qué dejó? | Quitar lo que no debería estar, cerrar la vía de entrada, parchear. Se hace cuando ya entiendes qué buscas, no antes. |
| **5. Recuperar** | ¿Podemos volver a confiar en el servicio? | Restaurar desde una copia limpia o reconstruir, vigilar de cerca durante un tiempo y comprobar que la vía de entrada sigue cerrada. |
| **6. Aprender** | ¿Qué cambiamos para que no se repita? | Reunión corta, sin buscar culpables, con acciones concretas y un responsable para cada una. |

Algunos marcos separan el análisis como fase propia entre detectar y contener. El nombre importa poco. Lo que importa es no saltarse la contención para ponerse a curiosear, y no borrar nada antes de haber apuntado qué había.

La guía [De la alerta al informe](https://github.com/P3M-ACTF/Biblioteca/wiki/De-la-alerta-al-informe) recorre las mismas fases con el hilo de la evidencia.

---

## 3. Decidir la gravedad

La gravedad decide a quién despiertas y cuánto puedes interrumpir. Se valora por el impacto, no por lo aparatoso de la alerta.

| Gravedad | Ejemplos | Respuesta |
|----------|----------|-----------|
| **Crítica** | Cifrado en curso, salida masiva de datos, dominio comprometido. | Todo el mundo. Se para lo que haga falta parar, dirección incluida en la decisión. |
| **Alta** | Cuenta de administración comprometida, malware en un servidor que da servicio. | Contención inmediata, aunque corte ese servicio. |
| **Media** | Un puesto con malware que no se ha movido, un phishing en el que alguien escribió la contraseña. | Se trata el mismo día, con el procedimiento, sin movilizar a toda la organización. |
| **Baja** | Un escaneo desde Internet, una alerta que resulta ser legítima. | Se documenta y se ajusta la alerta para que no vuelva a gastar tiempo. |

Dos preguntas ayudan a no quedarse corto: ¿hay credenciales de administrador en el sistema afectado? y ¿ese sistema puede llegar a los demás? Un puesto cualquiera con un malware contenido es media; el mismo malware en el equipo de quien administra el dominio es alta, porque desde ahí se llega a todo.

---

## 4. Qué se anota

La nota se empieza en el minuto uno, no al escribir el informe. Quien toma una decisión a las tres de la mañana no se acuerda el viernes de por qué la tomó.

| Qué | Por qué |
|-----|---------|
| Hora en UTC, qué se observó y quién lo vio. | Correlacionar con registros de otros sistemas, que pueden estar en otra zona horaria. |
| Qué sistemas están afectados y cómo se supo. | El alcance cambia durante el incidente; la nota enseña cuándo cambió. |
| Cada acción de contención, con su hora. | Saber qué síntoma es del ataque y cuál lo provocaste tú al aislar. |
| Qué registros se consultaron y dónde se copiaron. | Poder volver a mirar, y demostrar que no se alteró el original. |
| Estado de las copias: de qué fecha son y si se ha probado a restaurar. | La decisión de reconstruir depende de esto, y es mejor saberlo antes de necesitarlo. |

En la práctica basta un documento compartido con líneas de una frase. Lo importante es que sea un único sitio y que se escriba en el momento.

### Dónde están los registros

| Sistema | Dónde mirar |
|---------|-------------|
| Linux | `journalctl` de la unidad y del arranque anterior; `/var/log/auth.log` o `/var/log/secure` para accesos; `audit.log` si auditd está activo. |
| Windows | Visor de eventos: Seguridad (inicios de sesión, cambios de cuenta), Sistema (servicios) y Aplicación. Se exporta con `Get-WinEvent`, no con capturas de pantalla. |
| Red | Registros del cortafuegos de perímetro y del proxy, si existen. Dicen quién habló con quién cuando el equipo ya no es fiable. |

Si el sistema va a investigarse de verdad, no se trabaja sobre el original: se copia y se anota la integridad de la copia. Apagar un equipo borra la memoria, que a veces es donde está lo único interesante; aislarlo de la red conserva la memoria y corta el daño. Cuando dudes, aísla antes de apagar.

---

## 5. Contener sin empeorar

La contención tiene un coste: corta servicio. Por eso se elige la medida más pequeña que pare el daño, y se anota.

| Situación | Contención proporcionada |
|-----------|--------------------------|
| Un puesto comprometido | Se desconecta de la red, no se borra. Se cambia la contraseña de esa cuenta en el dominio. |
| Una cuenta robada | Se deshabilita o se le cambia la contraseña, y se cierran sus sesiones abiertas. Se mira qué hizo con ella antes de volver a abrirla. |
| Un servidor expuesto | Se corta el acceso desde fuera en el perímetro, se mantiene el acceso de administración por la vía interna, y se investiga con el servicio aún en pie. |
| Cifrado en marcha | Se aísla el segmento entero. Cada minuto de red es un equipo más cifrado. Aquí la contención va por delante de todo. |

Lo que no es contención: borrar el malware y seguir, cambiar la contraseña sin mirar si hay otra vía de entrada, o reinstalar sin saber cómo entraron. Eso garantiza el segundo incidente.

---

## 6. Checklist

| Momento | Qué comprobar |
|---------|----------------|
| Antes de que pase nada | Contactos escritos, copias probadas, relojes sincronizados, registros que duran más que el ataque. |
| Al recibir la alerta | ¿Es real? ¿Qué sistemas? ¿Qué gravedad? Primera línea en la nota. |
| Antes de tocar | Copia o nota de lo que hay. Aislar antes que apagar si importa la memoria. |
| Al contener | La medida más pequeña que pare el daño, anotada con su hora. |
| Al recuperar | El sistema vuelve desde algo limpio, la vía de entrada está cerrada y alguien vigila durante unos días. |
| Al cerrar | Reunión breve, acciones con responsable, y la alerta afinada para la próxima vez. |

---

## 7. Error típico

**Situación.** Salta la alerta de un antivirus en un servidor de ficheros un viernes a las siete. Alguien entra por escritorio remoto, borra el fichero que señala la alerta, pasa un análisis completo, ve que sale limpio y se va tranquilo. El lunes el mismo servidor ha cifrado tres carpetas compartidas.

**Por qué ocurre.** Borrar el fichero no respondió a ninguna de las preguntas. No se supo cómo llegó, así que la vía de entrada seguía abierta y volvió a entrar. No se supo qué hizo entre la llegada y el borrado, así que una tarea programada que dejó atrás siguió en su sitio. No se anotó nada, así que el lunes nadie podía reconstruir a qué hora pasó qué. Y el análisis salió limpio porque lo que quedó no era un fichero malicioso reconocible: era una tarea legítima del sistema apuntando a algo que se descargaba después. Se trató un incidente de gravedad alta como una limpieza.

**Cómo se ve.** No hay nada que ver, y ese es el problema: ni nota, ni exportación de eventos, ni copia de lo borrado. El lunes, el registro de Seguridad muestra inicios de sesión de una cuenta de servicio a horas raras, y el Programador de tareas tiene una tarea creada el viernes que nadie reconoce. Las copias de seguridad nocturnas del sábado y el domingo ya contienen ficheros cifrados; la del viernes, anterior a la alerta, está bien. Esa es la que salva, y se encuentra por suerte.

**Cómo se arregla.** Desde la alerta: anotar, aislar el servidor de la red, exportar los registros de Seguridad y Sistema, y solo entonces mirar qué hay. La tarea programada y la cuenta de servicio habrían aparecido el viernes con el registro delante. La recuperación se hace desde la copia del viernes, no desde las posteriores, y la cuenta de servicio se queda deshabilitada hasta entender por qué tenía permisos para lanzar tareas. El incidente se cierra con esa acción escrita: las cuentas de servicio no deberían poder crear tareas programadas.

---

Relacionado: [auditoria-eventos](auditoria-eventos.md) · [copias-seguridad](copias-seguridad.md) · [logs-clasicos](../../Sistemas%20Operativos/chuletas/logs-clasicos.md) · [windows-servicios-eventos](../../Sistemas%20Operativos/chuletas/windows-servicios-eventos.md) · guía [De la alerta al informe](https://github.com/P3M-ACTF/Biblioteca/wiki/De-la-alerta-al-informe) · guía [Dónde mira un admin cuando algo falla](https://github.com/P3M-ACTF/Biblioteca/wiki/Donde-mira-un-admin-cuando-algo-falla)

*Biblioteca — Ciberseguridad · respuesta a incidentes*
