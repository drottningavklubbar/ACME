mkdir -p lambda_layer/python/lib/python3.13/site-packages
# pip3 install psycopg2-binary -t lambda_layer/python/lib/python3.13/site-packages
mv ./psycopg2 lambda_layer/python/lib/python3.13/site-packages
cd lambda_layer
zip -r psycopg2_lambda_layer.zip .
# [https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/layer-python/layer/2-package.sh]
# [https://docs.aws.amazon.com/lambda/latest/dg/python-layers.html]
# [https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/layer-python/layer/1-install.sh]
# [https://github.com/jkehler/awslambda-psycopg2?tab=readme-ov-file]
# for this issue https://www.reddit.com/r/aws/comments/1034r3h/psycopg2_not_working_with_lambda/?rdt=43512
# aws lambda publish-layer-version --profile 253490793778 --region eu-central-1 --layer-name psycopg2_lambda_layer4 --zip-file fileb://psycopg2_lambda_layer.zip --compatible-runtimes python3.13