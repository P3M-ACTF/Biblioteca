# Chuleta: copias de seguridad

Regla **3-2-1**, tipos de backup y conceptos para diseñar restauración. Enfoque de resiliencia, no de exfiltración.

---

## 1. Objetivo

Poder **restaurar** datos y servicio tras borrado, corrupción, ransomware o error humano. Un backup que no se ha restaurado nunca es una hipótesis.

---

## 2. Regla 3-2-1

| Nº | Regla |
|----|--------|
| **3** | Tres copias de los datos (producción + 2 backups) |
| **2** | Dos tipos de medio distintos (p. ej. disco e inmutable/nube/cinta) |
| **1** | Una copia **off-site** (otra ubicación / otra cuenta cloud) |

Ampliaciones habituales:

| Variante | Idea |
|----------|------|
| **3-2-1-1-0** | +1 copia offline/inmutable; 0 errores en la última prueba de restore |
| Aire gap / inmutable | WORM, object-lock, cinta offline frente a ransomware |

---

## 3. Tipos de copia

| Tipo | Qué guarda | Pros / contras |
|------|------------|----------------|
| **Completa** | Todo | Restore simple; más tiempo/espacio |
| **Incremental** | Cambios desde la última copia (cualquier tipo) | Rápida; restore = cadena completa |
| **Diferencial** | Cambios desde la última **completa** | Restore = completa + última diferencial |
| **Snapshot** | Punto en el tiempo (disco/VM/FS) | Rápido; no sustituye off-site solo |

---

## 4. Métricas: RPO y RTO

| Métrica | Pregunta |
|---------|----------|
| **RPO** (Recovery Point Objective) | ¿Cuántos datos (tiempo) puedo permitirme perder? |
| **RTO** (Recovery Time Objective) | ¿En cuánto tiempo debo estar de vuelta? |

La frecuencia de backup ≤ RPO. El procedimiento de restore debe cumplir el RTO (personas, hardware, DNS, secretos…).

---

## 5. Qué incluir (lista mental)

| Ámbito | Ejemplos |
|--------|----------|
| Datos de negocio | BBDD, ficheros, object storage |
| Config | `/etc`, IaC, secrets **por canal seguro** |
| Estado de app | volúmenes Docker/K8s, uploads |
| Identidad | no olvidar export/recuperación de IdP (según diseño) |
| Documentación de restore | runbook junto al backup |

Prioriza según criticidad; no todo requiere el mismo RPO.

---

## 6. Buenas prácticas

| Práctica | Motivo |
|----------|--------|
| Probar restore periódicamente | detectar backups vacíos/corruptos |
| Separar credenciales de backup | una cuenta admin comprometida no borra todo |
| Cifrado en tránsito y en reposo | medios perdidos / cloud |
| Retención documentada | legal + capacidad |
| Monitorizar fallos de job | silencio ≠ éxito |
| Versionado / inmutabilidad | ransomware que cifra también los backups conectados |

---

## 7. Checklist

| Pregunta | ☐ |
|----------|---|
| ¿Cumple 3-2-1? | |
| ¿RPO/RTO definidos por sistema crítico? | |
| ¿Última prueba de restore con fecha y resultado? | |
| ¿Copia off-site / inmutable? | |
| ¿Runbook de restauración accesible si cae el sistema principal? | |

---

*Biblioteca — Ciberseguridad · copias de seguridad*
