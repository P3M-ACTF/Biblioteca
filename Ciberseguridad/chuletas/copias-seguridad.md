# Chuleta: copias de seguridad

Una copia de seguridad sirve para una sola cosa: volver a tener los datos cuando se pierden, se corrompen, se cifran o alguien los borra sin querer. Todo lo demás (el software de copias, la ventana nocturna, el disco lleno de ficheros) es el medio. Esta chuleta explica cómo se piensa una copia para que ese día funcione: cuántas copias, de qué tipos, qué no es una copia aunque se le parezca, y por qué la prueba de restauración es parte de la copia y no un extra.

---

## 1. Diseñar desde la restauración

La pregunta útil no es «¿hacemos copias?». Es «¿cuánto podemos perder?». Hay dos números, y conviene tenerlos dichos en voz alta antes de elegir herramienta.

**Cuánto tiempo de datos puedes permitirte perder** (RPO). Si las copias son nocturnas, la respuesta es «hasta un día». Si el negocio no puede perder más de una hora de facturas, la copia nocturna no sirve por muy bien hecha que esté, y hace falta algo que copie con más frecuencia o un sistema que replique.

**Cuánto tiempo puedes tardar en volver** (RTO). Una copia de cuatro terabytes en un disco USB que está en otra oficina restaura perfectamente y tarda dos días en llegar. Si el servicio tiene que estar arriba en cuatro horas, esa copia no cumple aunque los datos estén impecables.

Con esos dos números, el diseño se cae solo: frecuencia, tecnología y dónde vive la copia. Sin ellos se compra herramienta a ciegas.

---

## 2. La regla 3-2-1

| Número | Qué exige | Por qué |
|--------|-----------|---------|
| **3 copias** | Los datos de producción más dos copias. | Una copia sola no es copia: el día que falle (disco estropeado, copia a medias, fichero corrupto) te quedas con nada. |
| **2 soportes distintos** | Las copias no viven en el mismo tipo de medio. | Un fallo que afecta a todos los discos del mismo almacenamiento afecta a la vez a la producción y a la copia si conviven ahí. |
| **1 fuera** | Una copia en otra ubicación, o en otra cuenta si estás en la nube. | Un incendio, un robo o un cifrado que alcanza todo el edificio no puede alcanzarlas todas. |

La variante que se cita hoy es **3-2-1-1-0**: se añade una copia **sin conexión o inmutable** (una cinta fuera del dispositivo, un almacén de objetos con bloqueo que impide borrar durante un plazo) y se exige **cero errores en la última prueba de restauración**. La copia inmutable existe por el cifrado: si el ataque consigue las credenciales de quien administra las copias, borrará o cifrará también las copias que estén en línea. La que no se puede modificar ni estando autenticado es la que queda.

---

## 3. Tipos de copia

| Tipo | Qué guarda | Cómo se restaura | El compromiso |
|------|------------|------------------|---------------|
| **Completa** | Todo, cada vez. | Se restaura esa copia y nada más. | Simple y lenta. Ocupa mucho. Es la base sobre la que se apoyan las demás. |
| **Incremental** | Solo lo cambiado desde la última copia, sea cual sea. | Hacen falta la última completa y **todas** las incrementales posteriores, en orden. | Rápida y pequeña. Si una de la cadena está mal, se pierde de ahí en adelante. |
| **Diferencial** | Lo cambiado desde la última completa. | La completa más la última diferencial. | Crece cada día hasta la siguiente completa. El punto medio entre las dos. |
| **Instantánea** | El estado de un disco o volumen en un instante. | Se revierte a ese instante, casi al momento. | Rapidísima, pero vive en el mismo almacenamiento que los datos. No es la copia de fuera. |

La instantánea es la que más se malentiende. Es perfecta para «se borró un fichero hace una hora»: se recupera en minutos. No sirve de nada si el almacenamiento se rompe o se cifra, porque la instantánea se va con él. Por eso cuenta como comodidad operativa, no como una de las copias de la regla.

---

## 4. Qué tiene que cumplir la copia para valer

| Requisito | Qué significa en la práctica |
|-----------|------------------------------|
| **Cubre lo que importa** | Lista escrita de qué se copia: datos, configuración, bases de datos con su método (una base de datos se copia con sus herramientas, no copiando los ficheros en caliente). Y lista de qué no se copia, para que nadie se lleve sorpresas. |
| **Se puede leer sin el sistema original** | Si para restaurar necesitas el mismo servidor, el mismo dominio o la misma clave que acaba de desaparecer, no puedes restaurar. Las credenciales de la copia se guardan aparte. |
| **Está cifrada donde viaja y donde descansa** | Una copia contiene todos los datos. Una copia sin cifrar en un disco portátil es una filtración esperando sitio. |
| **Alguien se entera si falla** | Una copia que lleva tres semanas fallando en silencio es peor que no tenerla, porque crees que la tienes. El fallo avisa; el acierto se puede comprobar. |
| **Se ha restaurado de verdad** | Restaurar un fichero suelto prueba poco. Recuperar un servicio entero en un sitio distinto prueba que sirve. Se hace con fecha en el calendario, no «cuando se pueda». |

---

## 5. El día que hace falta

El orden importa tanto como tener la copia.

1. **Para el daño antes de restaurar.** Restaurar un servidor que sigue expuesto a lo que lo cifró es cifrar la copia también. Primero se aísla y se cierra la vía de entrada.
2. **Elige la copia anterior al problema.** La copia de anoche puede contener ya el daño si el problema empezó ayer por la mañana. La nota del incidente y las fechas de modificación dicen cuál es la última copia limpia.
3. **Restaura en otro sitio si puedes.** Un directorio paralelo o una máquina aparte permite comprobar que los datos están bien antes de sustituir lo que hay. Restaurar encima no tiene marcha atrás.
4. **Comprueba que funciona**, no solo que los ficheros están. Una base de datos restaurada se abre y se consulta; un servidor web se arranca y se pide una página.
5. **Apunta qué copia era y cuánto se tardó.** Es el dato que ajusta el RTO la próxima vez, y el que demuestra que el procedimiento existe.

---

## 6. Checklist

| Pregunta | Respuesta que deberías poder dar |
|----------|-----------------------------------|
| ¿Cuánto dato podemos perder? | Un número, en horas. La frecuencia de copia tiene que ser menor. |
| ¿En cuánto tiempo tenemos que volver? | Un número, en horas. El medio elegido tiene que poder restaurar en ese tiempo. |
| ¿Dónde está la copia de fuera? | Otra ubicación u otra cuenta, y sabes cómo llegar a ella sin el sistema caído. |
| ¿Hay una copia que no se pueda borrar aunque roben las credenciales? | Cinta fuera, o almacenamiento inmutable con plazo. |
| ¿Cuándo se restauró por última vez un servicio entero? | Una fecha reciente. Si nadie se acuerda, no se ha hecho. |
| ¿Quién recibe el aviso de fallo? | Una persona concreta, no una bandeja que nadie lee. |

---

## 7. Error típico

**Situación.** El servidor de ficheros hace su copia cada noche a un segundo disco del mismo servidor, y una vez por semana copia ese disco a un NAS de la misma sala. Lleva un año así, con el indicador en verde. Un viernes el servidor se cifra, y de paso se cifran el segundo disco (está montado) y el NAS (la cuenta que hace la copia tiene permiso de escritura, y el cifrado recorrió las unidades de red). La copia existe y no se puede usar.

**Por qué ocurre.** Se cumplía la parte fácil de la regla y se ignoraba la difícil. Había tres copias, pero las tres estaban en línea, en la misma sala, accesibles con credenciales que vivían en el equipo comprometido. Para el cifrado fueron un disco más. Nadie lo había visto porque la prueba de restauración consistía en comprobar que los ficheros se habían creado, no en intentar recuperar el servicio desde cero y desde fuera.

**Cómo se ve.** El software de copias muestra historial perfecto hasta el viernes. El disco secundario tiene los mismos ficheros con la extensión cambiada. El NAS también, porque la tarea del viernes por la noche copió diligentemente los ficheros ya cifrados encima de los buenos, y la retención era de una semana: para el lunes solo quedan copias cifradas. No hay cinta, no hay cuenta de nube separada, no hay nada desconectado.

**Cómo se arregla.** En el momento, poco: se reconstruye desde lo que haya fuera de ese alcance y se asume la pérdida. Para el diseño nuevo hace falta la pieza que faltaba: una copia a la que el servidor de producción no pueda llegar con sus propias credenciales. Puede ser un almacenamiento de objetos con bloqueo de retención, donde ni el administrador puede borrar lo escrito durante el plazo, o una copia externa cuya contraseña está en otro sitio. Y la prueba pasa a ser real: una vez por trimestre se restaura un servicio completo en una máquina vacía, con el reloj en marcha, usando solo la documentación. Lo que falle en esa prueba es lo que habría fallado el viernes.

---

Relacionado: [respuesta-incidentes](respuesta-incidentes.md) · [secretos](secretos.md) · [disco-lvm](../../Sistemas%20Operativos/chuletas/disco-lvm.md) · runbook [disco-lleno](../../Sistemas%20Operativos/runbooks/disco-lleno.md) · guía [De la alerta al informe](https://github.com/P3M-ACTF/Biblioteca/wiki/De-la-alerta-al-informe)

*Biblioteca — Ciberseguridad · copias de seguridad*
