# Nota: claves SSH la primera vez

Entras en un servidor con una clave en lugar de una contraseña. La clave son dos ficheros: la **privada**, que se queda en tu equipo y equivale a tu contraseña, y la **pública**, que copias al servidor. El servidor comprueba que tienes la privada sin que la privada salga nunca de tu equipo. Por eso la privada no se copia, no se manda por correo y no se mete en un recurso compartido: quien la tiene, es tú.

## Generarla

En tu equipo, no en el servidor:

```bash
ssh-keygen -t ed25519 -C "ana@empresa"
```

Ed25519 es una opción habitual cuando cliente, servidor y política del entorno la admiten. El comentario `-C` solo sirve para reconocerla dentro de un fichero lleno de claves. Te pide una ruta (entra vale la de por defecto, `~/.ssh/id_ed25519`) y una **frase de paso**. Ponla. Es lo que protege la clave si alguien copia el fichero de tu portátil; sin ella, el fichero basta para entrar.

Se crean dos ficheros. El que acaba en `.pub` es el público y se puede enseñar. El otro es el privado: permisos `600` y en tu home.

## Copiarla al servidor

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub ana@servidor
```

Esto instala tu pública en el archivo de claves autorizadas de esa cuenta. Si el servidor permite y acepta la autenticación con esa clave, podrás utilizarla en conexiones posteriores; todavía puede pedir la frase de paso o un factor adicional. Verifica el acceso antes de cambiar otros métodos de autenticación.

### Qué estás viendo

```text
$ ssh -v ana@servidor
debug1: Offering public key: ED25519 SHA256:abCd...
debug1: Server accepts key: ED25519 SHA256:abCd...
debug1: Authentication succeeded (publickey).
```

`Offering public key` indica qué pública se ofrece. `Server accepts key` confirma que el servidor la considera aceptable en la consulta, pero todavía falta que se complete la firma y la autenticación. Si después no se envía un paquete, hay que investigar por qué no se realizó esa firma o cómo continúa el método; no demuestra por sí solo un rechazo por permisos. Busca la confirmación final de autenticación y contrasta el intento con el servidor.

Como valores habituales se utilizan `700` para `~/.ssh` y `600` para `authorized_keys`, con propietario correcto y sin escritura por otros usuarios. El diagnóstico también debe contemplar cuenta, archivo efectivo, algoritmo y política. Los archivos públicos no necesitan ser legibles exclusivamente por el titular para que esa sea, por sí sola, una condición universal de aceptación.

Esta distinción aparece en el [código de autenticación de OpenSSH Portable 10.6p1](https://github.com/openssh/openssh-portable/blob/a8c72b842423f0774f542d3c2197247c3dd28d74/sshconnect2.c), donde el mensaje de aceptación de pública precede a la firma.

## El agente, para no escribir la frase cada vez

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

El agente guarda la clave descifrada en memoria durante la sesión, así que la frase se escribe una vez. En un escritorio suele estar ya integrado y no hace falta lanzarlo a mano.

## Qué no hacer

No reutilices la misma clave privada para todo sin pensarlo: una clave por equipo (portátil, sobremesa) permite revocar uno sin quedarte fuera de todos. Para revocar, se borra la línea correspondiente de `authorized_keys`; la frase de paso no hace falta para eso, porque lo que el servidor guarda es la pública.

Guía: [fundamentos y conexión básica](../guias/ssh/README.md).

Chuleta: [ssh-admin](../chuletas/ssh-admin.md). Plantilla: [sshd_config.ejemplo](../plantillas/sshd_config.ejemplo).

*Biblioteca — Sistemas Operativos · claves SSH*
