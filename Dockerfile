FROM debian:11.6-slim

ARG TERRAFORM_VERSION="1.3.6"

WORKDIR /home

RUN apt-get update && apt-get install -y curl && apt-get install -y unzip


RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "terraform.zip" | unzip terraform.zip && mv terraform /usr/local/bin && rm terraform.zip

# Support multi architecture images by 
# conditinally downloading x86 or ARM binaries based on what architecture we build this image in
RUN /bin/bash -c 'set -ex && \
    ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
       echo "x86_64" && \
       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$ARCH" == "aarch64" ]; then \
        echo "ARM architecture ($ARCH)" && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
       echo "unknown arch ($ARCH)" && \
       exit 1; \
    fi'

RUN unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm awscliv2.zip && rm -rf aws

ENTRYPOINT [""]
