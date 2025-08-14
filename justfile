build-push:
    IMAGE=europe-docker.pkg.dev/superb-blend-305320/lex-prod-registry/exc-clamav TAG=$(date +%Y%m%d%H%M%S) make build push
all: build-push