# Actividad 3 — Bucket S3 seguro con Terraform + LocalStack

Práctica de **Infraestructura como Código (IaC)**: se crea un bucket S3 simulado
en LocalStack, se declara cifrado **SSE-S3 AES-256** y los **cuatro controles**
de bloqueo de acceso público, y se verifica la configuración con Terraform y
AWS CLI.

> Nada de este laboratorio apunta a AWS real. No se necesita cuenta de AWS.

## Arquitectura

```text
Terraform  →  LocalStack :4566  →  Bucket S3
(código)      (contenedor local)    ├─ actividad3-seguro-local
                                    ├─ cifrado AES256
                                    └─ bloqueo público ×4
```

| Elemento | Valor |
|---|---|
| Bucket | `actividad3-seguro-local` |
| Región | `us-east-1` |
| Endpoint | `http://localhost:4566` |
| Cifrado | `SSE-S3` / `AES256` |
| Recursos Terraform | 3 |
| Controles de bloqueo público | 4 |

## Estructura

```text
.
├── compose.yaml        # LocalStack (solo S3, solo localhost)
├── providers.tf        # Provider AWS apuntando a LocalStack
├── main.tf             # Bucket + cifrado + public access block
├── verificar.sh        # Consultas de comprobación con AWS CLI
├── .env.example        # Plantilla del token (sin secreto)
├── .gitignore          # Excluye .env, tfstate y datos locales
└── README.md
```

## Requisitos

- Docker Engine/Desktop + Docker Compose v2 (o Podman + podman-compose)
- Terraform >= 1.5
- AWS CLI v2
- Cuenta gratuita de LocalStack (**plan Hobby**) y su **Auth Token**

```bash
docker --version
docker compose version
terraform version
aws --version
```

> En este equipo se ejecutó con **Podman 6.1.4** y `podman-compose 1.6.0`;
> el mismo `compose.yaml` funciona con Docker Compose.
>
> La imagen de LocalStack no incluye `curl`; por eso el healthcheck del
> contenedor usa el `python3` que sí trae la imagen.

## 1. Configurar el token

El token es un secreto. **No lo escribas en `compose.yaml`, en el README ni en
GitHub.**

```bash
cp .env.example .env
# Edita .env y pega tu token:
#   LOCALSTACK_AUTH_TOKEN=tu_token_aqui
```

Carga el token en la sesión actual:

```bash
set -a
source .env
set +a
```

Comprueba que está definido sin imprimirlo:

```bash
[ -n "$LOCALSTACK_AUTH_TOKEN" ] && echo "token definido"
```

## 2. Levantar LocalStack

```bash
docker compose up -d
docker compose ps
```

Espera a que el contenedor esté `healthy` y comprueba el endpoint:

```bash
curl -s http://localhost:4566/_localstack/health | python3 -m json.tool
```

Debe aparecer `"s3": "available"` (o `"running"`).

## 3. Terraform

```bash
terraform init
terraform validate
terraform plan
```

El plan debe indicar **3 recursos a crear**:

- `aws_s3_bucket.seguro`
- `aws_s3_bucket_server_side_encryption_configuration.seguro`
- `aws_s3_bucket_public_access_block.seguro`

Aplicar:

```bash
terraform apply
# revisar y escribir: yes
```

## 4. Verificar con AWS CLI

Exporta credenciales ficticias (LocalStack las acepta):

```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
EP=http://localhost:4566
```

Listado de buckets:

```bash
aws --endpoint-url $EP s3api list-buckets
```

Cifrado (debe mostrar `SSEAlgorithm: AES256`):

```bash
aws --endpoint-url $EP s3api get-bucket-encryption \
  --bucket actividad3-seguro-local
```

Los cuatro controles (todos en `true`):

```bash
aws --endpoint-url $EP s3api get-public-access-block \
  --bucket actividad3-seguro-local
```

Estado de la política (debe devolver `NoSuchBucketPolicy`):

```bash
aws --endpoint-url $EP s3api get-bucket-policy \
  --bucket actividad3-seguro-local
```

> `NoSuchBucketPolicy` solo significa que el bucket no tiene una política
> adjunta. **No** demuestra por sí solo que sea privado ni público.

También puedes ejecutar todo junto:

```bash
./verificar.sh
```

## 5. Carga y acceso anónimo

```bash
echo "Archivo de prueba - Actividad 3" > test.txt
aws --endpoint-url $EP s3 cp test.txt s3://actividad3-seguro-local/
aws --endpoint-url $EP s3 ls s3://actividad3-seguro-local/
```

Intento de descarga **sin firmar** (anónimo):

```bash
curl -i http://localhost:4566/actividad3-seguro-local/test.txt
```

Registra el resultado real, sea `200` o `403`. LocalStack no aplica todas las
reglas de autorización de AWS, por lo que un `200` **no** debe interpretarse
como que el bucket sería público en AWS real.

## Resultados de la ejecución (2026-11-06)

| Comprobación | Resultado |
|---|---|
| Recursos Terraform | 3 creados |
| Bucket | `actividad3-seguro-local` |
| Cifrado | `AES256` |
| `BlockPublicAcls` / `IgnorePublicAcls` | `true` / `true` |
| `BlockPublicPolicy` / `RestrictPublicBuckets` | `true` / `true` |
| Política del bucket | `NoSuchBucketPolicy` |
| Objeto de prueba | `test.txt` (32 bytes, cifrado AES256) |
| Descarga anónima | `HTTP 200` (limitación del simulador) |

Las salidas completas están en `evidencias/` y el reporte del proceso en
`Actividad-3.org`.

## 6. Dashboard

1. Abre <https://app.localstack.cloud> en el navegador de la misma máquina
   donde corre Docker.
2. Inicia sesión con la cuenta Hobby.
3. Configura/usa el endpoint `http://localhost:4566`.
4. Entra al explorador de recursos S3 y localiza `actividad3-seguro-local`.
5. Verifica el bucket, los objetos y la configuración de seguridad.
6. Toma la captura de evidencia.

## 7. Limpieza

```bash
terraform destroy
docker compose down
```

## Seguridad

- No publicar el `LOCALSTACK_AUTH_TOKEN` (ni en capturas ni en Git).
- No usar información confidencial real.
- No apuntar los comandos a AWS de producción.
- El contenedor se publica solo en `127.0.0.1:4566`.
- `.env`, `*.tfstate` y `.terraform/` están excluidos con `.gitignore`.
- Si LocalStack acepta una solicitud anónima, documéntalo como limitación del
  simulador hasta validarlo de forma independiente.

## Evidencias de entrega

- [x] Captura del plan Hobby, sin datos de cuenta ni token (`evidencias/hobby-plan.png`).
- [x] Versiones de Docker, Compose, Terraform, AWS CLI y contenedor healthy.
- [x] `compose.yaml`, `providers.tf` y `main.tf` (sin credenciales reales).
- [x] Salida de `terraform validate`, `terraform plan` y `terraform apply`.
- [x] Salida de cifrado `AES256` y de los cuatro controles en `true`.
- [x] Carga de `test.txt` y resultado del acceso anónimo.
- [ ] URL del repositorio público de GitHub verificada.
- [x] Captura del Dashboard con el bucket creado (`evidencias/DashBoard.png`).
- [x] Captura del bucket en el explorador S3 (`evidencias/bucket-localstack.png`).
- [x] Conclusión: infraestructura declarada vs. configuración consultada vs.
      seguridad efectivamente aplicada.
