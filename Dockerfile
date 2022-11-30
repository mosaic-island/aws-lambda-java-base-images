# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

ARG JAVA_VERSION=18
ARG JAVA_REVISION=18.0.2

FROM public.ecr.aws/amazoncorretto/amazoncorretto:${JAVA_VERSION}-amd64 as builder

#RUN touch /var/lib/rpm/*
RUN yum clean all
#RUN yum -y update
#RUN yum install -y wget tar gzip bzip2-devel ed gcc gcc-c++ gcc-gfortran \
#    less libcurl-devel openssl openssl-devel readline-devel xz-devel \
#    zlib-devel glibc-static libcxx libcxx-devel llvm-toolset-7 zlib-static
RUN rm -rf /var/cache/yum

# Copy the source code and build
COPY . /app/
WORKDIR /app
RUN ./mvnw package


FROM public.ecr.aws/amazoncorretto/amazoncorretto:${JAVA_VERSION}-amd64

RUN yum install -y wget unzip

RUN curl -o /tmp/newrelic.zip https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip
RUN unzip /tmp/newrelic.zip -d /opt/
ADD ./newrelic.yml /opt/newrelic/newrelic.yml

COPY --from=builder /app/target/dependencies/* /var/runtime/lib/

ENV LANG=en_US.UTF-8
ENV TZ=:/etc/localtime
ENV PATH=/opt/java/openjdk/bin:/usr/local/bin:/usr/bin:/bin:/opt/bin
ENV LD_LIBRARY_PATH=/lib:/usr/lib:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
ENV LAMBDA_TASK_ROOT=/var/task/
ENV LAMBDA_RUNTIME_DIR=/var/runtime/
ENV MAIN_CLASS="com.amazonaws.services.lambda.runtime.api.client.AWSLambda"

ADD entrypoint.sh /var/task/
ENTRYPOINT /var/task/entrypoint.sh