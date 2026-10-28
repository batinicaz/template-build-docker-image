FROM ubuntu:latest@sha256:0e73b71479e7bc5f006bca872e25c3cd680dc052a0116f90d63ae363537db0dd as build

ARG TERRAFORM_VERSION
ARG TF_LINT_VERSION

RUN apt-get update && apt-get install -y curl git unzip
RUN mkdir "/executables"
RUN curl -fL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && unzip terraform.zip && mv terraform /executables
RUN curl -fL https://github.com/terraform-linters/tflint/releases/download/${TF_LINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip && unzip tflint.zip && mv tflint /executables

FROM cgr.dev/chainguard/python:latest-dev@sha256:8da57dd32b02b27107cd4188255a764b99fdef8760c2c89a785a1ad7225a94ac
# Pre-commit setup
ENV PATH="${PATH}:/home/nonroot/.local/bin"
RUN pip3 install --no-cache-dir checkov pre-commit

# Copy tools used by pre-commit hooks
COPY --from=build /executables/terraform /bin/terraform
COPY --from=build /executables/tflint /bin/tflint

ENTRYPOINT ["/bin/sh", "-c", "git config --global --add safe.directory \"$(pwd)\" && pre-commit run -a"]