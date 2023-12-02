#!/bin/bash

echo "VAULT_ADDR: $VAULT_ADDR" && [ -z "$VAULT_ADDR" ] && echo "... variable not set" && exit 1
echo "VAULT_SKIP_VERIFY: $VAULT_SKIP_VERIFY" && [ -z "$VAULT_SKIP_VERIFY" ] && echo "... variable not set" && exit 1
echo "VAULT_TOKEN: $VAULT_TOKEN" && [ -z "$VAULT_TOKEN" ] && echo "... variable not set" && exit 1
echo "VAULT_SECRET_PATH: $VAULT_SECRET_PATH" && [ -z "$VAULT_SECRET_PATH" ] && echo "... variable not set" && exit 1
echo "RETENTION: $RETENTION" && [ -z "$RETENTION" ] && echo "... variable not set" && exit 1
echo "S3_URL: $S3_URL" && [ -z "$S3_URL" ] && echo "... variable not set" && exit 1
echo "S3_ACCESS_KEY: $(echo "${S3_ACCESS_KEY//?/*}")" && [ -z "$S3_ACCESS_KEY" ] && echo "... variable not set" && exit 1
echo "S3_SECRET_KEY: $(echo "${S3_SECRET_KEY//?/*}")" && [ -z "$S3_SECRET_KEY" ] && echo "... variable not set" && exit 1

set -euo pipefail

echo "Adding $S3_URL as backup_storage..."
mc alias set backup_storage $S3_URL $S3_ACCESS_KEY $S3_SECRET_KEY

echo "Generating public-key.pem..."
openssl rsa -in private-key.pem -pubout -out public-key.pem

echo "Starting Vault backup..."
mc mb --ignore-existing backup_storage/vault-backup 
medusa export $VAULT_SECRET_PATH --encrypt="true" --public-key="public-key.pem" | mc pipe -q backup_storage/vault-backup/encrypted-vault-backup-$(date '+%Y-%m-%d-%H-%M').txt
echo -e "Backup finished."

echo -e "Existing backups:"
mc ls backup_storage/vault-backup
echo -e "Removing backups older than $RETENTION:"
mc find backup_storage/vault-backup --older-than $RETENTION --exec "mc rm {}"
echo -e "Done"
