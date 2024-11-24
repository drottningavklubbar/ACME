# mkdir python
# cp -r create_layer/lib python/
# zip -r psycopg2_layer.zip python

# [https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/layer-python/layer/2-package.sh]

mkdir -p python/lib/python3.12/site-packages
cp -r create_layer/lib/python3.12/site-packages/* python/lib/python3.12/site-packages/
zip -r layer_content.zip python
