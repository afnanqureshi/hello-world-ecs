# Python Hello World Application

In this project a basic Hello World python application is containerized and deployed on Amazon ECS using Terraform.
The following steps have been used to deploy the application:

1. A python script main.py generates an application using flask on host 0.0.0.0 and port 8080. The Flask requirement is added in requirements.txt file and app.yaml file for python.
2. The application is containerized by a Dockerfile which copies all the files in the docker image runs the python application at runtime.
3. Docker image is built and stored in Amazon ECR (Follow image push steps in your Amazon ECR repo documentation).
4. Container is built and deployed on ECS using Terraform.