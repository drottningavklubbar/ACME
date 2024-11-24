# [https://docs.aws.amazon.com/lambda/latest/dg/python-layers.html]
# https://github.com/awsdocs/aws-lambda-developer-guide/blob/main/sample-apps/layer-python/layer/1-install.sh
python3.12 -m venv create_layer
source create_layer/bin/activate
pip install -r requirements.txt --platform=manylinux2014_x86_64 --only-binary=:all: --target ./create_layer/lib/python3.12/site-packages