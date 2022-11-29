DATABASE_FQDN=$1
APPLICATION_IDENTITY_APPID=$2
DATABASE_NAME=$3
USER_NAME=$4

echo "Creating AADUSER role in database ${DATABASE_NAME} on ${DATABASE_FQDN}..."

RDBMS_ACCESS_TOKEN=$(az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken)

AZ_POSTGRESQL_AD_MI_USERID=$(az ad sp show --id ${APPLICATION_IDENTITY_APPID} --query appId --output tsv)

psql "host=${DATABASE_FQDN} user=${USER_NAME} dbname=${DATABASE_NAME} port=5432 password=${RDBMS_ACCESS_TOKEN} sslmode=require" <<EOF

SET aad_auth_validate_oids_in_tenant = OFF;

DROP ROLE IF EXISTS "AADUSER";

CREATE ROLE "AADUSER" WITH LOGIN PASSWORD '$AZ_POSTGRESQL_AD_MI_USERID' IN ROLE azure_ad_user;

GRANT ALL PRIVILEGES ON DATABASE ${DATABASE_NAME} TO "AADUSER";

EOF
