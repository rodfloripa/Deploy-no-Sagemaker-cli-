# Deploy-no-Sagemaker-cli-
Deploy de um .py no Sagemaker usando  aws cli

1. Instale a aws cli

2. No Makefile coloque suas variáveis ROLE_ARN,BUCKET_NAME,REGION,IMAGE_NAME

3. make clean

4. aws sagemaker wait endpoint-deleted --endpoint-name meu-modelo-endpoint

5. make deploy
