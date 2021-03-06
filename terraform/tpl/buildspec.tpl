version: 0.2

phases:
  pre_build:
    commands:
      - pip install awscli --upgrade --user
      - echo `aws --version`
      - echo Logging in to Amazon ECR...
      - $(aws ecr get-login --region ${repository_region} --no-include-email)
      - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - echo Entered the pre_build phase...
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - >
        docker build
        -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images $REPOSITORY_URI:$IMAGE_TAG
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - docker push $REPOSITORY_URI:latest
      - echo Writing image definitions file...
      # ${container_name} corresponds to the name of container which is definier in 'container-definitions' json
      - printf '[{"name":"${container_name}","imageUri":"%s"}]' $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions.json
artifacts:
  files: imagedefinitions.json