# Chuleta: autenticación y autorización

Que alguien demuestre quién es y decidir qué puede hacer son dos problemas distintos, y se resuelven con mecanismos distintos. Juntarlos («si ha entrado, puede hacer de todo») es el origen de la mayor parte de los excesos de privilegio. Esta chuleta separa las piezas: factores, contraseñas y sus hashes, sesiones y el principio de mínimo privilegio.

---

## 1. Tres preguntas distintas

| Concepto | La pregunta | Cuándo se responde |
|----------|-------------|--------------------|
| **Autenticación** | ¿Quién eres? | Al inicio de la sesión: contraseña, clave, certificado, segundo factor. |
| **Autorización** | ¿Qué puedes hacer? | En cada acción: permisos del fichero, rol en la aplicación, regla de sudo, ACE de NTFS. |
| **Registro** | ¿Qué hiciste? | Siempre: journal, registro de seguridad, auditoría. Sin esto, las otras dos no se pueden revisar. |

Un inicio de sesión correcto solo resuelve la primera. La segunda se responde con los permisos que tenga esa identidad, y debería responderse con los mínimos que necesite para su trabajo. La tercera es lo que permite, después de un incidente, saber hasta dónde llegó.

---

## 2. Factores

Un factor es un tipo de prueba. La seguridad de la autenticación depende de cuántos tipos distintos exiges, no de cuántas pruebas del mismo tipo.

| Factor | Qué demuestra | Ejemplos |
|--------|----------------|----------|
| Algo que **sabes** | Que conoces un secreto. | Contraseña, PIN. Se puede robar mirando, filtrando o adivinando. |
| Algo que **tienes** | Que posees un objeto. | Llave hardware (FIDO2), aplicación TOTP, tarjeta inteligente, certificado en el equipo. |
| Algo que **eres** | Que estás presente. | Huella, cara. Cómodo para desbloquear un dispositivo propio; poco práctico como factor remoto y difícil de revocar si se filtra. |

**MFA** es pedir al menos dos factores de tipo distinto. Dos contraseñas no son MFA: son dos cosas que se roban igual. Contraseña más un código TOTP sí lo es, porque robar la contraseña de una base de datos no da el código, que se genera en el momento. El SMS es mejor que nada y peor que el resto: el número de teléfono se puede secuestrar. Una llave hardware o WebAuthn/FIDO2 resiste además el phishing, porque la llave comprueba el sitio al que responde y no contesta en uno falso.

---

## 3. Contraseñas y hashes

Una contraseña no se guarda. Se guarda un **hash**: el resultado de una función que no se puede invertir. Para comprobar un inicio de sesión se calcula el hash de lo que el usuario escribió y se compara con lo guardado. Si la base de datos se filtra, el atacante obtiene hashes, no contraseñas... siempre que el hash sea del tipo adecuado.

| Algoritmo | Cuándo aparece | Qué debes saber |
|-----------|----------------|-----------------|
| **Argon2id** | Aplicaciones nuevas. | La elección actual. Permite fijar cuánta memoria y tiempo cuesta calcularlo, que es justo lo que encarece un ataque de diccionario. |
| **bcrypt** | Muchísimas aplicaciones existentes. | Sólido y probado. Tiene un factor de coste que hay que subir con los años, porque el hardware se abarata. |
| **scrypt** | Algunas aplicaciones. | También exige mucha memoria, lo que frena el hardware especializado. |
| **PBKDF2** | Estándares y sistemas antiguos. | Aceptable si el número de iteraciones es alto; se prefiere Argon2 en lo nuevo. |
| **SHA-256 o MD5 a secas** | Código propio mal hecho. | No sirven para contraseñas: son rápidos a propósito, así que probar millones de contraseñas por segundo es barato. Verlos en una base de usuarios es un fallo que hay que corregir. |

Dos ingredientes acompañan al algoritmo. La **sal** es un valor aleatorio distinto por usuario que se guarda junto al hash: hace que dos usuarios con la misma contraseña tengan hashes distintos, y que no sirva una tabla precalculada. El **coste** es el parámetro que hace el cálculo lento. Lento para un inicio de sesión (décimas de segundo) es invisible; lento para quien prueba mil millones de contraseñas es la diferencia entre horas y siglos.

Nada de esto sirve si la contraseña es `Empresa2024`. El hash protege contra el robo de la base de datos; una contraseña adivinable se adivina igual. De ahí las políticas de longitud (más útil que las de complejidad rara), la comprobación contra listas de contraseñas filtradas y, sobre todo, el segundo factor, que hace que la contraseña sola no baste.

---

## 4. Sesiones

Autenticar en cada clic sería inviable, así que tras el primer acierto el sistema crea una **sesión**: un identificador que el cliente presenta a partir de entonces. En la web es una cookie; en otras aplicaciones, un token.

El identificador de sesión tiene tres propiedades que importan. Es **aleatorio e impredecible**, porque quien lo copia es el usuario mientras dure la sesión. Se **caduca**: una sesión que vive para siempre convierte un robo puntual en un acceso permanente. Y se puede **revocar**: al cambiar la contraseña, al pulsar «cerrar todas las sesiones» o al dar de baja la cuenta, los identificadores emitidos dejan de valer. Un token que se valida solo con su firma y sin consultar ningún estado no se puede revocar; es cómodo y es un problema cuando hay que cerrar el acceso ya.

Por el lado del cliente, la cookie de sesión lleva las marcas que limitan su uso: `Secure` para que solo viaje por HTTPS, `HttpOnly` para que el código de la página no pueda leerla, y `SameSite` para acotar cuándo el navegador la envía.

---

## 5. Mínimo privilegio

El principio es corto: cada identidad tiene solo los permisos que necesita para su trabajo, y los temporales se devuelven al terminar. Aplicarlo bien es lo que separa un incidente contenido de uno que se lleva el dominio por delante.

| Ámbito | Cómo se concreta |
|--------|------------------|
| Cuentas de personas | Cada cual con su cuenta. Las tareas de administración se elevan con sudo o UAC en el momento, no se trabaja todo el día como root o como administrador del dominio. |
| Cuentas de servicio | Una por servicio, con permiso sobre lo suyo y sobre nada más. Sin inicio de sesión interactivo. |
| Permisos de ficheros | Grupos por rol, nunca usuarios sueltos en cada carpeta. Se revisa al cambiar de puesto y al irse. |
| Aplicaciones | Roles dentro de la aplicación. El rol de administrador de la aplicación no tiene por qué ser administrador del servidor. |
| Temporal | Un permiso concedido para una tarea tiene fecha de retirada. «Ya se lo quitaremos» no tiene fecha. |

El caso que más duele es la cuenta de servicio metida en el grupo de administradores «porque si no, no arrancaba». Arrancar no requiere ese grupo; requería permiso sobre una carpeta concreta. El exceso queda para siempre, y es la cuenta cuyas credenciales están en un fichero de configuración.

---

## 6. Checklist

| Pregunta | Dónde mirar |
|----------|-------------|
| ¿Esto autentica o autoriza? | Si comprueba identidad, autentica. Si decide una acción, autoriza. No los resuelve el mismo mecanismo. |
| ¿Hay un segundo factor de otro tipo? | TOTP, llave o certificado además de la contraseña. Dos contraseñas no cuentan. |
| ¿Cómo se guardan las contraseñas? | Hash lento con sal (Argon2id, bcrypt). Un SHA sin más es un hallazgo. |
| ¿Las sesiones caducan y se pueden revocar? | Tiempo de vida, y un sitio donde invalidarlas al cambiar la contraseña o dar de baja. |
| ¿Quién tiene privilegio de administración? | Grupos `sudo`/`wheel`, administradores del dominio, sudoers. Lista corta y revisada. |
| ¿Las cuentas de servicio pueden iniciar sesión? | No deberían. Shell `nologin`, o cuenta denegada para inicio interactivo. |

---

## 7. Error típico

**Situación.** Una aplicación propia guarda las contraseñas «cifradas» y el equipo está tranquilo porque no están en claro. Un día hay que migrar de servidor y descubres que para validar el inicio de sesión la aplicación descifra el valor guardado y lo compara con lo que escribió el usuario. La clave de cifrado está en el mismo fichero de configuración que la cadena de conexión a la base de datos.

**Por qué ocurre.** Se confundió cifrar con hacer hash. Cifrar es reversible a propósito: existe una clave que deshace la operación. Quien se lleva la base de datos y la clave (y la clave estaba al lado) se lleva todas las contraseñas. El hash no tiene marcha atrás; ni siquiera la aplicación puede recuperar la contraseña, y no le hace falta, porque le basta con comparar resultados.

**Cómo se ve.** En la tabla de usuarios hay una columna que se descifra a texto legible con una función del propio código. La clave está en `config.yml`, en el repositorio o en una variable del mismo servidor. No hay sal por usuario: dos personas con la misma contraseña tienen el mismo valor cifrado.

**Cómo se arregla.** Cambiar el almacenamiento a un hash de contraseñas (Argon2id o bcrypt) con sal aleatoria por usuario. Como no puedes convertir un cifrado en hash sin la contraseña original, la migración se hace en el siguiente inicio de sesión de cada usuario: se comprueba con el método viejo, se guarda el hash nuevo y se borra el valor cifrado. Se fija un plazo, pasado el cual las cuentas que no hayan entrado se marcan para restablecer contraseña. Y se da por hecho que las contraseñas actuales están comprometidas: el cifrado reversible con la clave al lado no fue nunca una protección, así que toca forzar el cambio.

---

Relacionado: [cifrado-hash-firma](cifrado-hash-firma.md) · [secretos](secretos.md) · [usuarios-grupos-sudo](../../Sistemas%20Operativos/chuletas/usuarios-grupos-sudo.md) · [active-directory](../../Sistemas%20Operativos/chuletas/active-directory.md) · [auditoria-eventos](auditoria-eventos.md) · guía [Qué pasa cuando ejecutas sudo](https://github.com/P3M-ACTF/Biblioteca/wiki/Que-pasa-cuando-ejecutas-sudo)

*Biblioteca — Ciberseguridad · autenticación y autorización*
