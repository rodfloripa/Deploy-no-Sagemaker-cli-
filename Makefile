# ==========================================
# Variáveis - AJUSTE SE NECESSÁRIO
# ==========================================
ROLE_ARN=arn:aws:iam::634510061385:role/RodneySageMakerRole
BUCKET_NAME=rodney-sagemaker-deploy-1770336638
REGION=us-east-1
IMAGE_NAME=meu-modelo

# ==========================================
# Constantes (Geradas automaticamente)
# ==========================================
AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)
ECR_URI=$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(IMAGE_NAME)
SAGEMAKER_MODEL_NAME=$(IMAGE_NAME)
SAGEMAKER_ENDPOINT_NAME=$(IMAGE_NAME)-endpoint

# ==========================================
# Fluxo de Build e Upload
# ==========================================
build:
	docker build -t $(IMAGE_NAME) .

create-repo:
	aws ecr describe-repositories --repository-names $(IMAGE_NAME) --region $(REGION) || \
	aws ecr create-repository --repository-name $(IMAGE_NAME) --region $(REGION)

login:
	aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(ECR_URI)

tag:
	docker tag $(IMAGE_NAME):latest $(ECR_URI):latest

push: create-repo tag
	docker push $(ECR_URI):latest

package-model:
	touch .empty && tar -czvf model.tar.gz .empty
	aws s3 cp model.tar.gz s3://$(BUCKET_NAME)/model.tar.gz

# ==========================================
# Recursos SageMaker (Serverless)
# ==========================================
create-model:
	aws sagemaker create-model \
		--model-name $(SAGEMAKER_MODEL_NAME) \
		--execution-role-arn $(ROLE_ARN) \
		--primary-container Image=$(ECR_URI):latest,ModelDataUrl=s3://$(BUCKET_NAME)/model.tar.gz

create-endpoint-config:
	aws sagemaker create-endpoint-config \
		--endpoint-config-name $(SAGEMAKER_ENDPOINT_NAME)-config \
		--production-variants VariantName=variant1,ModelName=$(SAGEMAKER_MODEL_NAME),ServerlessConfig="{MemorySizeInMB=2048,MaxConcurrency=1}"

create-endpoint:
	aws sagemaker create-endpoint \
		--endpoint-name $(SAGEMAKER_ENDPOINT_NAME) \
		--endpoint-config-name $(SAGEMAKER_ENDPOINT_NAME)-config

# ==========================================
# Comandos de Utilidade
# ==========================================

# Limpa tudo e ESPERA a AWS deletar de fato para não dar erro no deploy
clean:
	@echo "Iniciando limpeza de recursos antigos..."
	aws sagemaker delete-endpoint --endpoint-name $(SAGEMAKER_ENDPOINT_NAME) || true
	@echo "Aguardando confirmação de deleção do endpoint (isso evita erros de 'Already Exists')..."
	aws sagemaker wait endpoint-deleted --endpoint-name $(SAGEMAKER_ENDPOINT_NAME) || true
	aws sagemaker delete-endpoint-config --endpoint-config-name $(SAGEMAKER_ENDPOINT_NAME)-config || true
	aws sagemaker delete-model --model-name $(SAGEMAKER_MODEL_NAME) || true
	@echo "Ambiente limpo e pronto!"

# Verifica o status atual
status:
	@aws sagemaker describe-endpoint --endpoint-name $(SAGEMAKER_ENDPOINT_NAME) --query "EndpointStatus" --output text || echo "Endpoint não encontrado."

# ==========================================
# COMANDO MESTRE
# ==========================================

# Executa a limpeza, o build e o deploy em uma única sequência
deploy: clean build login push package-model create-model create-endpoint-config create-endpoint
	@echo "--------------------------------------------------------"
	@echo "DEPLOY FINALIZADO COM SUCESSO!"
	@echo "Monitore o status com: make status"
	@echo "Quando estiver 'InService', seu modelo estará online."
	@echo "--------------------------------------------------------"

destroy:
	@echo "Iniciando destruição total dos recursos..."
	-aws sagemaker delete-endpoint --endpoint-name meu-modelo-endpoint
	@echo "Aguardando deleção do endpoint..."
	-aws sagemaker wait endpoint-deleted --endpoint-name meu-modelo-endpoint
	-aws sagemaker delete-endpoint-config --endpoint-config-name meu-modelo-endpoint-config
	-aws sagemaker delete-model --model-name meu-modelo
	@echo "------------------------------------------------"
	@echo "✅ Tudo limpo! Nenhum recurso ativo no SageMaker."
	@echo "------------------------------------------------"
