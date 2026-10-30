FROM ubuntu:latest@sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c as build

ARG TERRAFORM_VERSION
ARG TF_LINT_VERSION

RUN apt-get update && apt-get install -y curl git unzip
RUN mkdir "/executables"
RUN curl -fL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && unzip terraform.zip && mv terraform /executables
RUN curl -fL https://github.com/terraform-linters/tflint/releases/download/${TF_LINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip && unzip tflint.zip && mv tflint /executables

FROM cgr.dev/chainguard/python:latest-dev@sha256:95d8cc85fad8acc8ebad357e1972f2a975c498a65406cd9b00bb2233371a94a2
# Pre-commit setup
ENV PATH="${PATH}:/home/nonroot/.local/bin"
RUN pip3 install --no-cache-dir checkov pre-commit

# Copy tools used by pre-commit hooks
COPY --from=build /executables/terraform /bin/terraform
COPY --from=build /executables/tflint /bin/tflint

ENTRYPOINT ["/bin/sh", "-c", "git config --global --add safe.directory \"$(pwd)\" && pre-commit run -a"]