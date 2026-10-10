# Nota: un certificado autofirmado para el laboratorio

Para probar HTTPS en una máquina de laboratorio no hace falta una autoridad de verdad: generas un certificado firmado por su propia clave y le dices al equipo de pruebas que confíe en él. Cualquier otro equipo seguirá avisando, que es exactamente lo que quieres. Esto no sirve para nada expuesto a usuarios reales; para eso está una autoridad reconocida (chuleta [tls](../../Ciberseguridad/chuletas/tls.md)).

El certificado tiene que llevar el nombre por el que vas a conectar dentro del **SAN**. Los clientes ya no miran el nombre común: si entras por `lab.local` y el SAN no lo contiene, el aviso de nombre no coincidente seguirá ahí por muy confiable que sea la autoridad.

## Generarlo

```bash
openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
  -keyout lab.key -out lab.crt \
  -subj "/CN=lab.local" \
  -addext "subjectAltName=DNS:lab.local,DNS:localhost,IP:127.0.0.1"
```

`-x509` lo autofirma en lugar de generar una petición. `-nodes` deja la clave privada sin cifra, cómodo en un laboratorio y mala idea en cualquier otro sitio. `-days 365` es su caducidad: apúntala, porque el año que viene el fallo será un certificado caducado y no te acordarás. `-addext` mete el SAN.

### Qué estás viendo

```bash
openssl x509 -in lab.crt -noout -subject -dates -ext subjectAltName
```

```text
subject=CN = lab.local
notBefore=Oct 10 11:00:00 2026 GMT
notAfter=Oct 10 11:00:00 2027 GMT
X509v3 Subject Alternative Name:
    DNS:lab.local, DNS:localhost, IP:127.0.0.1
```

Si el SAN no aparece, el `-addext` no se aplicó (OpenSSL viejo) y los clientes lo rechazarán. Vuelve a generarlo con una versión actual.

El servidor usa los dos ficheros: `lab.crt` y `lab.key`. La clave no se copia a ningún otro sitio.

## Hacer que el equipo de pruebas confíe

En Linux, copiar `lab.crt` (solo el certificado, nunca la clave) a `/usr/local/share/ca-certificates/lab.crt` y ejecutar `update-ca-certificates`. A partir de ahí, las herramientas que usan el almacén del sistema (`curl`, los navegadores que leen ese almacén) lo aceptan.

En Windows, el certificado se importa en el almacén de **entidades de certificación raíz de confianza** de la máquina, desde una consola de administrador:

```powershell
Import-Certificate -FilePath lab.crt -CertStoreLocation Cert:\LocalMachine\Root
```

Importarlo en el almacén del usuario solo vale para ese usuario, y los servicios no lo verán. Importar la clave privada en el almacén de confianza no hace falta para nada y es un error.

Comprueba con `curl -vI https://lab.local` que la verificación termina en `SSL certificate verify ok`. Si el navegador sigue avisando, suele estar usando su propio almacén: Firefox trae uno distinto del sistema.

Cuando acabes el laboratorio, borra el certificado de los almacenes donde lo instalaste. Una raíz de confianza que ya no recuerdas es una puerta que dejaste abierta.

*Biblioteca — Sistemas Operativos · certificado de laboratorio*
