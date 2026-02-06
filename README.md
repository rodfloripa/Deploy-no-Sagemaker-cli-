# Deploy-no-Sagemaker-cli-
Deploy de um .py no Sagemaker usando  aws cli

1. Instale a aws cli

2. aws configure

3. No Makefile coloque suas variáveis ROLE_ARN, BUCKET_NAME, REGION, IMAGE_NAME

4. make deploy

5. make status

6. Teste quando terminar de criar 

## Testando

echo '{"input": "Teste final"}' > test_input.json

aws sagemaker-runtime invoke-endpoint \
    --endpoint-name meu-modelo-endpoint \
    --region us-east-1 \
    --body fileb://test_input.json \
    --content-type application/json \
    output.json

cat output.json
