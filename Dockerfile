FROM ubuntu:latest@sha256:d66b366dac61b575bee2aef07e9c26e8070096fbe84a3d4d3eb0da069b5d76db as build

ARG TERRAFORM_VERSION
ARG TF_LINT_VERSION

RUN apt-get update && apt-get install -y curl git unzip
RUN mkdir "/executables"
RUN curl -fL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && unzip terraform.zip && mv terraform /executables
RUN curl -fL https://github.com/terraform-linters/tflint/releases/download/${TF_LINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip && unzip tflint.zip && mv tflint /executables

FROM cgr.dev/chainguard/python:latest-dev@sha256:50bef4bfe98ea2f3c8c146a04847c8857e0afb1c8803e2047f140f10c028a7ee
# Pre-commit setup
ENV PATH="${PATH}:/home/nonroot/.local/bin"
RUN pip3 install --no-cache-dir checkov pre-commit

# Copy tools used by pre-commit hooks
COPY --from=build /executables/terraform /bin/terraform
COPY --from=build /executables/tflint /bin/tflint

ENTRYPOINT ["/bin/sh", "-c", "git config --global --add safe.directory \"$(pwd)\" && pre-commit run -a"]