# Define function directory
ARG FUNCTION_DIR="/function"

FROM python:buster as build-image

# Install aws-lambda-cpp build dependencies
RUN apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Create function directory
RUN mkdir -p ${FUNCTION_DIR}

# Copy function code
COPY app/* ${FUNCTION_DIR}

# Install the runtime interface client
RUN pip install --no-cache-dir \
        -r ${FUNCTION_DIR}/requirements.txt \
        --target ${FUNCTION_DIR}

# Multi-stage build: grab a fresh copy of the base image
FROM python:buster

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the build image dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

COPY --from=build-image ${FUNCTION_DIR}/aws-lambda-rie /usr/local/bin/aws-lambda-rie
COPY --from=build-image ${FUNCTION_DIR}/entry_script.sh /
RUN chmod +X /entry_script.sh && chmod 755 /usr/local/bin/aws-lambda-rie

ENTRYPOINT [ "/entry_script.sh" ]
#ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]