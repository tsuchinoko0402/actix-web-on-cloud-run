CMD = ls

RUN_CMD = @cd $@ && \
	echo "Run command in \"$@\"" && \
	${CMD}

help:
	@echo "This is a Makefile for executing commands according to AWS resource dependencies."
	@echo ""
	@echo "To deploy all AWS resources, run make as follows:"
	@tput setaf 2 && \
	 echo "make all CMD=\"terraform init && terraform apply -auto-approve\"" && \
	 tput sgr0

usage: help

### Below, the target resources
.PHONY: cloud_run cloud_sql secret_manager vpc
cloud_run: cloud_sql
	${RUN_CMD}

cloud_sql: secret_manager vpc
	${RUN_CMD}

secret_manager:
	${RUN_CMD}

vpc:
	${RUN_CMD}

all: cloud_run