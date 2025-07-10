.PHONY: install, install-aws-cli, plan, apply
install:
	brew tap hashicorp/tap && brew install hashicorp/tap/terraform

install-aws-cli:
	brew install awscli

plan:
	terraform plan

apply:
	terraform apply

run:
	terraform plan && terraform apply