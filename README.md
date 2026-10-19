# Biblioteca

**Biblioteca de Libros, Documentación y Apuntes** relacionados con Informática, Redes Informáticas, Programación, Ciberseguridad y Tecnología en general.

En este repositorio puedes encontrar material útil para el aprendizaje y recursos de referencia para consulta.

- **Chuletas** para consultas rápidas.
- **Documentos y apuntes** para estudiar y repasar conceptos.
- **Procedimientos** para resolver tareas paso a paso.
- **Ejemplos y plantillas reutilizables** para adaptar a otros entornos y proyectos.

Este repositorio forma parte de [**Tecnoteca**](https://github.com/users/P3M-ACTF/projects/3), el proyecto paraguas que organiza ambos recursos. **Biblioteca** reúne material de consulta y aprendizaje, documentación, apuntes, guías, chuletas y recursos propios; para un catálogo curado de recursos, plataformas, proyectos y referencias externas, consulta [Awesome-ASIR](https://github.com/P3M-ACTF/Awesome-ASIR).

> [!NOTE]
> Este es un repositorio colaborativo

[Explorar temas](#temas) · [Contenido destacado](#contenido-destacado) · [Cómo usarla](#cómo-usar-esta-biblioteca) · [Colaborar](CONTRIBUTING.md) · [Licencia](#licencia)

## Temas

| Área | Qué encontrarás |
| --- | --- |
| [Sistemas Operativos](Sistemas%20Operativos/) | Referencias de Linux y Windows, notas sueltas, aliases de shell, procedimientos de diagnóstico y plantillas de configuración. |
| [Redes](Redes/) | Protocolos, direccionamiento, DNS, enrutamiento, diagnóstico, captura de tráfico y un [mapa de protocolos](Redes/mapa-protocolos/README.md). |
| [Computación en la nube](Nube/aws-servicios/README.md) | Infografía interactiva de servicios AWS y ruta de aprendizaje. |
| [Ciberseguridad](Ciberseguridad/) | Referencias con enfoque defensivo: autenticación, cifrado, bastionado y respuesta a incidentes. |
| [Inteligencia Artificial](Inteligencia%20Artificial/) | Preferencias de trabajo para agentes de IA y una guía para adaptarlas a distintos entornos. |
| [Documentaciones](Documentaciones/plantillas/readme/README.md) | Plantilla reutilizable de README y guía para adaptarla a otros proyectos. |
| [Programación](Programaci%C3%B3n/) | Previsto: todavía sin apuntes. |
| [Electrónica](Electr%C3%B3nica/) | Previsto: todavía sin apuntes. |

## Contenido destacado

Los índices de cada área reúnen el catálogo completo de chuletas. Estos son los principales puntos de entrada:

| Recurso | Para qué sirve |
| --- | --- |
| [Chuletas de Sistemas Operativos](Sistemas%20Operativos/chuletas/README.md) | Consultar permisos POSIX y NTFS, servicios, discos, SSH, firewall, Active Directory y otras tareas habituales. |
| [Aliases de bash, zsh y sh](Sistemas%20Operativos/shell/README.md) | Revisar y utilizar atajos para tareas de administración desde la terminal. |
| [Runbooks de Sistemas Operativos](Sistemas%20Operativos/runbooks/README.md) | Seguir procedimientos: máquina nueva, disco lleno, servicio caído, certificado caducado, cuenta bloqueada y servidor Windows nuevo. |
| [Plantillas de Sistemas Operativos](Sistemas%20Operativos/plantillas/README.md) | Adaptar ejemplos de `sshd_config`, `sudoers.d`, `nftables`, unidades systemd, logrotate y chrony. |
| [Notas de Sistemas Operativos](Sistemas%20Operativos/notas/README.md) | Seguir recetas sueltas: claves SSH, hora y NTP, winget, SFC, certificado de laboratorio, VirtualBox y ajustes de Windows en `.reg`. |
| [Chuletas de Redes](Redes/chuletas/README.md) | Repasar TCP/IP, puertos, IPv4/IPv6, DNS, HTTP, NAT, enrutamiento, VLAN, VPN y herramientas de diagnóstico. |
| [Mapa de protocolos](https://p3m-actf.github.io/Biblioteca/Redes/mapa-protocolos/) ([fuente](Redes/mapa-protocolos/README.md)) | Ver en qué capa vive cada familia de protocolos y abrir el grafo Mermaid. |
| [Servicios AWS](https://p3m-actf.github.io/Biblioteca/Nube/aws-servicios/) ([fuente](Nube/aws-servicios/README.md)) | Explorar servicios por categorías y seguir una ruta de aprendizaje interactiva. |
| [Chuletas de Ciberseguridad](Ciberseguridad/chuletas/README.md) | Consultar autenticación, TLS, bastionado, auditoría, parches, copias de seguridad y respuesta a incidentes. |
| [Preferencias para agentes de IA](Inteligencia%20Artificial/AI-PREFERENCES.es.md) | Reutilizar criterios de comunicación, código, seguridad y verificación. También disponibles [en inglés](Inteligencia%20Artificial/AI-PREFERENCES.en.md), con [guía de uso](Inteligencia%20Artificial/GUIA-DE-USO-AI-PREFERENCES.md). |
| [Plantilla de README](Documentaciones/plantillas/readme/README.md) | Preparar la presentación y documentación inicial de un proyecto con secciones adaptables. |

## Cómo usar esta biblioteca

1. **Elige un tema** en la tabla anterior o abre uno de los índices destacados.
2. **Consulta el formato que necesites:** las chuletas son referencias rápidas; las notas sueltas resuelven una tarea concreta; los runbooks describen procedimientos; las plantillas ofrecen ejemplos para adaptar.
3. **Busca un concepto o comando** con la búsqueda del repositorio en GitHub o con la búsqueda de tu editor en una copia local.

Puedes leer los documentos en GitHub y abrir las infografías interactivas mediante los enlaces anteriores, sin descargarlas. Para disponer de una copia local, utiliza **Code → Download ZIP** o clona el repositorio si tienes Git instalado:

```sh
git clone https://github.com/P3M-ACTF/Biblioteca.git
cd Biblioteca
```

> [!NOTE]
> Antes de utilizar comandos, aliases o configuraciones, revisa las indicaciones del documento y adapta los ejemplos a tu sistema y versión.

Las guías narrativas enlazadas desde el proyecto se encuentran en la [Wiki de Biblioteca](https://github.com/P3M-ACTF/Biblioteca/wiki).

## Licencia

El repositorio incluye la licencia **GNU GPL v3**, disponible en [LICENSE](LICENSE). Consulta también los avisos de autoría y licencia que acompañen a cada recurso o material externo.
