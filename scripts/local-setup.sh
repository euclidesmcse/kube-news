#!/bin/bash

set -e

echo "🚀 Kube-News Pipeline - Local Setup"
echo "===================================="
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado!"
    exit 1
fi

echo "✅ Docker e Docker Compose instalados"
echo ""

# Opções do script
case "${1:-help}" in
    up)
        echo "🐳 Iniciando ambiente com Docker Compose..."
        docker-compose up -d
        echo ""
        echo "✅ Ambiente iniciado!"
        echo "   App: http://localhost:8080"
        echo "   Banco: localhost:5432"
        echo ""
        echo "Próximos passos:"
        echo "  ./scripts/local-setup.sh logs    # Ver logs"
        echo "  ./scripts/local-setup.sh down    # Derrubar ambiente"
        ;;

    down)
        echo "🛑 Encerrando ambiente..."
        docker-compose down
        echo "✅ Ambiente encerrado"
        ;;

    logs)
        echo "📋 Logs da aplicação:"
        docker-compose logs -f kubenews
        ;;

    build)
        echo "🔨 Buildando imagem Docker..."
        docker build -t kubenews:latest .
        echo "✅ Build concluído: kubenews:latest"
        ;;

    test)
        echo "🧪 Testando endpoints..."
        echo ""

        # Wait for app to be ready
        echo "⏳ Aguardando aplicação..."
        for i in {1..30}; do
            if curl -s http://localhost:8080/health > /dev/null 2>&1; then
                echo "✅ Aplicação pronta!"
                break
            fi
            sleep 1
        done

        echo ""
        echo "Testando /health:"
        curl -s http://localhost:8080/health
        echo ""
        echo ""

        echo "Testando /ready:"
        curl -s http://localhost:8080/ready
        echo ""
        echo ""

        echo "Testando /metrics (primeiras 10 linhas):"
        curl -s http://localhost:8080/metrics | head -n 10
        echo ""
        ;;

    deploy-local-k8s)
        echo "🚀 Deploying to local Kubernetes..."
        kubectl apply -f manifests/deployment.yml
        kubectl apply -f manifests/service.yml
        echo "✅ Deployment criado!"
        echo ""
        echo "Ver status:"
        echo "  kubectl get deployment kubenews"
        echo "  kubectl get svc kubenews"
        ;;

    validate)
        echo "✅ Validando arquivos de configuração..."
        echo ""

        echo "Dockerfile:"
        docker build -t kubenews:validate --dry-run . 2>&1 | grep -q "^STEP" && echo "  ✓ Válido" || echo "  ✗ Inválido"

        echo "docker-compose.yml:"
        docker-compose config > /dev/null 2>&1 && echo "  ✓ Válido" || echo "  ✗ Inválido"

        echo "Manifests Kubernetes:"
        kubectl apply -f manifests/ --dry-run=client > /dev/null 2>&1 && echo "  ✓ Válido" || echo "  ✗ Inválido"

        echo ""
        echo "✅ Validação concluída!"
        ;;

    clean)
        echo "🧹 Limpando..."
        docker-compose down -v
        docker image rm kubenews:latest 2>/dev/null || true
        echo "✅ Limpeza concluída"
        ;;

    *)
        echo "Uso: ./scripts/local-setup.sh [comando]"
        echo ""
        echo "Comandos disponíveis:"
        echo "  up              - Inicia o ambiente (Docker Compose)"
        echo "  down            - Para o ambiente"
        echo "  logs            - Mostra logs da aplicação"
        echo "  build           - Build da imagem Docker"
        echo "  test            - Testa os endpoints"
        echo "  validate        - Valida configurações"
        echo "  clean           - Remove tudo (com volumes)"
        echo "  deploy-local-k8s - Deploy em Kubernetes local"
        echo ""
        echo "Exemplo:"
        echo "  ./scripts/local-setup.sh up"
        echo "  ./scripts/local-setup.sh logs"
        ;;
esac
