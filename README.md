# ACME
ACME Corporation's Database Adventure


This project uses terraform

1. terraform init
In case the layer is not published use 
aws lambda publish-layer-version --profile 253490793778 --region eu-central-1 --layer-name psycopg2_lambda_layer --zip-file fileb://psycopg2_lambda_layer.zip --compatible-runtimes python3.13
3. terraform plan
4. terraform apply
5. psycopg2 needed just for eventually changes otherwise is not working with pip3 or pip - some configurations _psycopg2 is missing - this layer is not working correctly
6. terraform fmt

