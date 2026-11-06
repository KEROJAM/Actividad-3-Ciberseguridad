# Práctica: Bucket S3 seguro con Terraform y LocalStack

> **Fase 1 · Infraestructura como Código (IaC)**
>
> Construye un bucket simulado, declara su cifrado y bloqueo de acceso público,
> y comprueba qué está realmente configurado.

**Contexto:** práctica para estudiantes · Ciberseguridad
**Stack:** Terraform · LocalStack · S3 + AES-256 · AWS CLI · GitHub

---

## Datos clave del laboratorio

| Elemento | Valor |
|---|---|
| Bucket | `actividad3-seguro-local` |
| Región | `us-east-1` |
| Endpoint | `http://localhost:4566` |
| Cifrado | `SSE-S3 · AES256` |
| Recursos en el plan de Terraform | **3** |
| Controles de bloqueo de acceso público | **4** |

### Arquitectura

```text
Terraform  →  LocalStack :4566  →  Bucket S3
(código)      (contenedor Docker)   ├─ bucket
                                    ├─ cifrado AES256
                                    └─ bloqueo público ×4
```

> ⚠️ **Nada de esto debe apuntar a AWS real. No se requiere cuenta AWS.**

---

## Propósito

Construir un bucket S3 simulado mediante Terraform, declarar cifrado AES-256 y
controles de bloqueo de acceso público, y **verificar la configuración y el
comportamiento** del servicio.

---

## 1. Registro gratuito en LocalStack

- [ ] Ingresar a [localstack.cloud/pricing](https://localstack.cloud/pricing) y seleccionar **LocalStack for AWS**.
- [ ] Elegir el plan **Hobby — Free**.
  - No seleccionar `Base`, `Ultimate` ni una prueba de pago.
- [ ] Crear una cuenta personal, iniciar sesión y localizar el **token de autenticación** para el entorno local.
- [ ] Conservar el token de forma privada.
  - No incluirlo en capturas, repositorios ni entregables.

> 🔑 **El token es un secreto.** Si aparece en una captura o en GitHub, queda
> comprometido. En Docker/Compose se pasa como `LOCALSTACK_AUTH_TOKEN` y es
> obligatorio para iniciar el contenedor.

---

## 2. Herramientas y plataformas

| Herramienta | Uso | Comprobación |
|---|---|---|
| Docker Engine / Desktop | Ejecutar contenedores | `docker --version` |
| Docker Compose v2 | Levantar LocalStack | `docker compose version` |
| Terraform | Definir y aplicar IaC | `terraform version` |
| AWS CLI v2 | Consultar el S3 simulado | `aws --version` |
| LocalStack (Hobby) | Emular S3 localmente | contenedor saludable · puerto `4566` |

---

## 3. Instalación según tu sistema

> Investiga el procedimiento. **Usa únicamente fuentes oficiales.**

### 🪟 Windows 10/11

Docker Desktop y WSL2 (recomendado). Descarga los instaladores oficiales de
Terraform y AWS CLI. Verifica desde PowerShell, Windows Terminal o WSL.

### 🍎 macOS

Docker Desktop (Intel o Apple Silicon). Usa `brew` (Homebrew) para Terraform y
AWS CLI, o las descargas oficiales.

### 🐧 Linux

Ubuntu / Mint / Debian: APT para Docker Engine y Compose; repositorio oficial de
HashiCorp para Terraform; AWS CLI por descarga oficial (`curl`/`wget`).

> 📘 Investiga también: requisitos de **virtualización**, **permisos** y
> **compatibilidad** de tu equipo.

---

## 4. Verificar instalación y servicios

- [ ] Comprobar la versión de **Docker, Compose, Terraform y AWS CLI**.
- [ ] Verificar que el **servicio Docker esté activo**.
  - Linux: `systemctl` y `ps`
  - macOS: Docker Desktop y procesos
  - Windows: Docker Desktop y PowerShell/Terminal
- [ ] Listar contenedores **sin errores de permisos**.
  - En Linux, investiga el grupo `docker` y el efecto de cerrar y abrir sesión.
- [ ] Confirmar que **no hay conflicto con el puerto 4566**.

---

## 5. Desarrollo del laboratorio

### Fase A · Levantar LocalStack

- [ ] **1.** Crear un **directorio de trabajo exclusivo** para el laboratorio.
- [ ] **2.** Escribir un **Docker Compose** que:
  - ejecute LocalStack,
  - exponga `4566` **solo en localhost**,
  - habilite S3,
  - reciba el token por **variable de entorno**.
  - _Evita publicar secretos._
- [ ] **3.** Iniciar en segundo plano y comprobar el **estado saludable** del contenedor y su **endpoint de salud**.

### Fase B · Definir con Terraform

- [ ] **4.** Configurar el **provider AWS**:
  - región `us-east-1`,
  - credenciales ficticias,
  - endpoint S3 `http://localhost:4566`.
  - _Impide que las pruebas apunten por error a AWS real._
- [ ] **5.** Definir:
  - el bucket `actividad3-seguro-local`,
  - el cifrado **SSE-S3 AES256**,
  - los **cuatro controles** de bloqueo de acceso público.
- [ ] **6.** **Inicializar, validar y revisar el plan**. Confirma que se crearán **3 recursos**.
- [ ] **7.** **Aplicar** tras revisar los cambios y verificar los recursos creados.

### Fase C · Comprobar con AWS CLI

- [ ] **8.** Consultar **listado de buckets, cifrado y los cuatro controles** indicando **explícitamente el endpoint local**.
- [ ] **9.** Crear un **archivo de texto de prueba**, subirlo al bucket y comprobar que aparece en el listado.
- [ ] **10.** Intentar **descargarlo sin firmar la solicitud** (acceso anónimo).
  - Registra el resultado real, sea permitido o denegado.
  - Explica por qué LocalStack no replica necesariamente todas las reglas de autorización de AWS.
- [ ] **11.** Consultar el **estado de la política** del bucket e interpretar `NoSuchBucketPolicy`.
  - _No es una confirmación de exposición pública._

---

## Complementos

### Repositorio de GitHub

- [ ] Crear un repo **público** con:
  - `compose.yaml`
  - `providers.tf`
  - `main.tf`
  - lo necesario para reproducir el laboratorio.
- [ ] Incluir un `README.md` con descripción, requisitos e instrucciones de ejecución.
- [ ] Verificar que la URL sea accesible antes de entregarla.

> 🚫 **Nunca subir al repositorio:** tokens · contraseñas · `.env` · `*.tfstate`
>
> Usa `.gitignore` para excluirlos.

### Dashboard de LocalStack

- [ ] Abrirlo en el navegador de la misma computadora donde corre Docker.
- [ ] Configurar el endpoint `http://localhost:4566`.
- [ ] Entrar al explorador S3 y localizar tu bucket.
- [ ] Verificar su existencia, los archivos y las configuraciones de seguridad disponibles.
- [ ] **Evidencia:** captura donde se vea el bucket.

---

## 6. Evidencias de entrega

- [ ] 📸 Captura del **plan Hobby** seleccionado, sin datos de cuenta ni token.
- [ ] 💻 **Versiones** de las herramientas y contenedor LocalStack en estado saludable.
- [ ] 📄 **Archivos de configuración** redactados por ti, sin credenciales reales.
- [ ] 💻 Resultado de **validación, plan y aplicación** de Terraform.
- [ ] 🔒 Consultas de **cifrado AES256** y de los **cuatro controles** de bloqueo público.
- [ ] ⬆️ **Carga del archivo** y resultado del **acceso anónimo**.
- [ ] 🐙 **URL del repositorio público** de GitHub (verificada).
- [ ] 📸 Captura del **Dashboard** con el bucket creado.
- [ ] 📘 **Conclusión breve:** diferencia entre _infraestructura declarada_, _configuración consultada_ y _seguridad efectivamente aplicada_.

---

## 7. Criterios de seguridad

- 🚫 **No publicar tokens.**
- 🚫 **No usar información confidencial real.**
- 🚫 **No apuntar los comandos a AWS de producción.**

> ⚠️ Si LocalStack **acepta una solicitud anónima**, trátalo como una
> **limitación o comportamiento del simulador** hasta contar con una validación
> independiente.

---

## Fuentes oficiales

- [LocalStack · Precios](https://localstack.cloud/pricing)
- [LocalStack · Docs](https://docs.localstack.cloud)
- [LocalStack · Auth Token](https://docs.localstack.cloud/aws/getting-started/auth-token/)
- [Docker · Docs](https://docs.docker.com)
- [Terraform · Instalación](https://developer.hashicorp.com/terraform/install)
- [AWS CLI · Docs](https://docs.aws.amazon.com/cli/)

---

## Notas de verificación

Contrastado contra las fuentes oficiales el **6 de noviembre de 2026**:

1. **El plan Hobby — Free existe** y es el gratuito de LocalStack for AWS.
   `Base` (39 USD/licencia/mes) y `Ultimate` (89 USD/licencia/mes) son de pago,
   por lo que la indicación de no seleccionarlos es correcta.
2. **El token de autenticación es obligatorio** para iniciar el contenedor de
   LocalStack, incluso en Hobby. Se configura con `LOCALSTACK_AUTH_TOKEN`.
3. **Los 3 recursos de Terraform** corresponden, con el provider AWS moderno, a:
   - `aws_s3_bucket`
   - `aws_s3_bucket_server_side_encryption_configuration`
   - `aws_s3_bucket_public_access_block`
4. **Los 4 controles** de bloqueo público son:
   - `block_public_acls`
   - `ignore_public_acls`
   - `block_public_policy`
   - `restrict_public_buckets`
5. **El plan Hobby no aplica IAM policy enforcement** (según la tabla oficial de
   precios). Esto explica en parte por qué el acceso anónimo puede comportarse
   distinto que en AWS real; el punto 10 pide justamente documentarlo.
6. **`NoSuchBucketPolicy`** solo indica que el bucket no tiene una política
   adjunta; no demuestra por sí solo que sea privado ni público.

### Precisión sobre el alcance

- El proveedor AWS requiere además `s3_use_path_style = true` para hablar con
  LocalStack, y conviene desactivar las comprobaciones de credenciales reales
  (`skip_credentials_validation`, `skip_metadata_api_check`,
  `skip_requesting_account_id`). No está escrito en el enunciado porque pide
  investigarlo.
- El enunciado no incluye comandos exactos: la intención es que se consulten
  las fuentes oficiales y se documente el procedimiento propio.
