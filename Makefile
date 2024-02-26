# Default - top level rule is what gets run when you run just 'make' without specifying a goal/target.
.DEFAULT_GOAL := help

# When a target is built, all lines of the recipe will be given to a single invocation of the shell rather than each
# line being invoked separately.
.ONESHELL:

# If this variable is not set, the program '/bin/sh' is used as the shell.
SHELL := bash

# The default value of .SHELLFLAGS is -c normally, or -ec in POSIX-conforming mode.
# Extra options are set for Bash:
#   -e             Exit immediately if a command exits with a non-zero status.
#   -u             Treat unset variables as an error when substituting.
#   -o pipefail    The return value of a pipeline is the status of the last command to exit with a non-zero status,
#                  or zero if no command exited with a non-zero status.
.SHELLFLAGS := -euo pipefail -c

.RECIPEPREFIX := >

help: ## Get a list of available targets, together with their description.
> @grep -E '^[a-zA-Z0-9_-]+:.*? ## .*$$' $(filter-out .env.make, $(MAKEFILE_LIST)) \
  | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

# Generate Tyk MDCB API client code using the Swagger API specification.
client: ## Generate MDCB Go client.
> mkdir -p $(@D)
> docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli generate \
      --generator-name go \
      --input-spec /local/swagger.yml \
      --output /local/ \
      --git-host github.com \
      --git-user-id TykTechnologies \
      --git-repo-id go-mdcb \
      --package-name mdcb \
      --api-name-suffix API \
      --global-property skipFormModel=true \
      --global-property apis,apiTests=false,apiDocs=false \
      --global-property models,modelTests=false,modelDocs=false \
      --global-property supportingFiles \
      --additional-properties generateInterfaces=true
> if [[ -n "$$(git status --porcelain -- )" ]]; then
>   echo >&2 "Please commit the modified/regenerated code."
>   exit 1
> fi
> touch $@
.PHONY: client
