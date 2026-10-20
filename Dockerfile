FROM ubuntu:latest@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944 as build

ARG TERRAFORM_VERSION
ARG TF_LINT_VERSION

RUN apt-get update && apt-get install -y curl git unzip
RUN mkdir "/executables"
RUN curl -fL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && unzip terraform.zip && mv terraform /executables
RUN curl -fL https://github.com/terraform-linters/tflint/releases/download/${TF_LINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip && unzip tflint.zip && mv tflint /executables

FROM cgr.dev/chainguard/python:latest-dev@sha256:893300b2b4dc590d99237f649495464c3a87a24a13f12010ac0f474245d531ae
# Pre-commit setup
ENV PATH="${PATH}:/home/nonroot/.local/bin"
RUN pip3 install --no-cache-dir checkov pre-commit

# Copy tools used by pre-commit hooks
COPY --from=build /executables/terraform /bin/terraform
COPY --from=build /executables/tflint /bin/tflint

ENTRYPOINT ["/bin/sh", "-c", "git config --global --add safe.directory \"$(pwd)\" && pre-commit run -a"]