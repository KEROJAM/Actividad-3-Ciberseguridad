#!/usr/bin/env bash
# Verificaciones del laboratorio con AWS CLI contra LocalStack.
set -uo pipefail

ENDPOINT="${LOCALSTACK_ENDPOINT:-http://localhost:4566}"
BUCKET="${BUCKET:-actividad3-seguro-local}"

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

AWS=(aws --endpoint-url "$ENDPOINT")

echo "== Endpoint =="
echo "$ENDPOINT"
echo

echo "== Salud de LocalStack =="
curl -fsS "$ENDPOINT/_localstack/health" || echo "No se pudo consultar /_localstack/health"
echo

echo "== Buckets =="
"${AWS[@]}" s3api list-buckets
echo

echo "== Cifrado =="
"${AWS[@]}" s3api get-bucket-encryption --bucket "$BUCKET"
echo

echo "== Bloqueo de acceso público =="
"${AWS[@]}" s3api get-public-access-block --bucket "$BUCKET"
echo

echo "== Política del bucket =="
"${AWS[@]}" s3api get-bucket-policy --bucket "$BUCKET" || true
echo

echo "== Objetos =="
"${AWS[@]}" s3 ls "s3://$BUCKET/" || true
