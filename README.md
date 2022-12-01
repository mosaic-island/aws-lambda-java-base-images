# AWS Lambda Java Base Images

## !!! IMPORTANT !!!
Please note that these images are not intended for public consumption. They are not supported as such and should not be relied upon. 

They are based on the project (https://github.com/aleph0io/aws-lambda-java-base-images) and you are advised to use that or the official 
Amazon provided base images in ECR/Docker Hub.


This project provides the missing [AWS Lambda base image](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-images.html) for Java 17, 18 & 19. The base images are publicly available in [Docker Hub](https://hub.docker.com/r/miapplicationengineering/jvm-lambda-base). We will be using them directly in our builds. They should be considered *very experimental*, and we do not provide any guarantees or support. Use at own risk.    

## Approach

This project uses the following process to create new Lambda base images:

1. Define a Java maven POM that includes all the [Java Lambda support libraries](https://github.com/aws/aws-lambda-java-libs) as provided scope. This roundabout approach is used to coax @dependabot into flagging new versions as they are published.
2. Use Maven to collect these dependencies and provide them for `docker build` to include.
3. Use Docker hub automated builds to create images and store 

## Example Lambda Function

It's just like building any container lambda function. For ease of use, find the `Dockerfile` below. Note the second `FROM` image. 
The following `Dockerfile`use build stages to Gradle to build a Kotlin based Spring Boot application. It uses a base Java 19 Corretto
image to build the application and then copies the artefacts into the Lambda specific container. The final step is to inform the base 
Lambda container of the class and function used as the entrypoint to the Lambda.
    
    FROM public.ecr.aws/amazoncorretto/amazoncorretto:19 AS lambda-builder

    RUN yum clean all
    RUN yum -y update
    RUN rm -rf /var/cache/yum

    # Copy the source code and build
    COPY . /app
    WORKDIR /app
    RUN ./gradlew clean build --refresh-dependencies

    FROM miapplicationengineering/jvm-lambda-base:19.0.1
    
    COPY target/hello-lambda.jar "${LAMBDA_TASK_ROOT}/lib/"
    
    COPY --from=lambda-builder /app/build/classes/kotlin/main ${LAMBDA_TASK_ROOT}/
    COPY --from=lambda-builder /app/build/dependency/* ${LAMBDA_TASK_ROOT}/lib/
    COPY --from=lambda-builder /app/build/resources/* ${LAMBDA_TASK_ROOT}/
    
    ENV LAMBDA_HANDLER="com.example.aws.LambdaHandler::handleRequest"

## Known Issues and Future Plans

* This image is in no way optimized for cold start time, size, etc. PRs welcome!
* Both Java 17, 18 & 19 are supported. 
* For now, only x86_64 is supported. I hope to publish multiarch builds including arm64 soon.
* Of course, as soon as there *is* an offically-supported AWS Lambda base image for these Java versions, everyone should use that instead! But this project should hopefully fill the gap in the meantime, and will (hopefully) support non-LTS Java versions that will never receive an officially-supported AWS Lambda base image by that time.



## Acknowledgements

Many thanks to [@sigpwned](https://github.com/sigpwned) for the original and base work (https://github.com/aleph0io/aws-lambda-java-base-images)

Managed (originally) by [@sigpwned](https://github.com/sigpwned), and now subsequently by [@garethpowell](https://github.com/garethpowell)
following a fork and refactor.
