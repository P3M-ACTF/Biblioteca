# Nota: claves SSH la primera vez

Entras en un servidor con una clave en lugar de una contraseña. La clave son dos ficheros: la **privada**, que se queda en tu equipo y equivale a tu contraseña, y la **pública**, que copias al servidor. El servidor comprueba que tienes la privada sin que la privada salga nunca de tu equipo. Por eso la privada no se copia, no se manda por correo y no se mete en un recurso compartido: quien la tiene, es tú.

## Generarla

En tu equipo, no en el servidor:

```bash
ssh-keygen -t ed25519 -C "ana@empresa"
```

Ed25519 es el tipo que se usa hoy: claves cortas y rápidas. El comentario `-C` solo sirve para reconocerla dentro de un fichero lleno de claves. Te pide una ruta (entra vale la de por defecto, `~/.ssh/id_ed25519`) y una **frase de paso**. Ponla. Es lo que protege la clave si alguien copia el fichero de tu portátil; sin ella, el fichero basta para entrar.

Se crean dos ficheros. El que acaba en `.pub` es el público y se puede enseñar. El otro es el privado: permisos `600` y en tu home.

## Copiarla al servidor

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub ana@servidor
```

Esto añade tu clave pública a `~/.ssh/authorized_keys` de ana en el servidor, y deja los permisos bien puestos. Esa será la última vez que te pida la contraseña de la cuenta.

### Qué estás viendo

```text
$ ssh -v ana@servidor
debug1: Offering public key: ED25519 SHA256:abCd...
debug1: Server accepts key: ED25519 SHA256:abCd...
debug1: Authentication succeeded (publickey).
```

`Server accepts key` confirma que el servidor encontró tu clave pública y tu equipo demostró tener la privada. Si dice `Offering public key` y luego `we did not send a packet`, la rechazó: casi siempre son los permisos de `~/.ssh` o de `authorized_keys` en el servidor, que tienen que ser legibles solo por la cuenta (el directorio `700`, el fichero `600`). SSH se niega a usarlos si otros usuarios pueden escribir en ellos, y el mensaje no lo explica.

## El agente, para no escribir la frase cada vez

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

El agente guarda la clave descifrada en memoria durante la sesión, así que la frase se escribe una vez. En un escritorio suele estar ya integrado y no hace falta lanzarlo a mano.

## Qué no hacer

No reutilices la misma clave privada para todo sin pensarlo: una clave por equipo (portátil, sobremesa) permite revocar uno sin quedarte fuera de todos. Para revocar, se borra la línea correspondiente de `authorized_keys`; la frase de paso no hace falta para eso, porque lo que el servidor guarda es la pública.

Chuleta: [ssh-admin](../chuletas/ssh-admin.md). Plantilla: [sshd_config.ejemplo](../plantillas/sshd_config.ejemplo).

*Biblioteca — Sistemas Operativos · claves SSH*
