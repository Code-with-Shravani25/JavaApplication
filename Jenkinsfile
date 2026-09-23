pipeline {

    agent any

    environment {

        AWS_REGION = 'us-east-1'

        AWS_ACCOUNT_ID = '570367131376'

        ECR_REPOSITORY = 'javaApplication'

        ECR_REGISTRY =
            "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        IMAGE_TAG =
            "${env.GIT_COMMIT.substring(0, 7)}"

        IMAGE_NAME =
            "${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Maven Test') {
            steps {
                sh '''
                    cd app
                    mvn clean test
                '''
            }
        }

        stage('Maven Package') {
            steps {
                sh '''
                    cd app
                    mvn package -DskipTests
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${IMAGE_NAME} .
                '''
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                    aws ecr get-login-password \
                    --region ${AWS_REGION} |
                    docker login \
                    --username AWS \
                    --password-stdin \
                    ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    docker push ${IMAGE_NAME}
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    cd terraform

                    terraform plan \
                    -var="image_tag=${IMAGE_TAG}"
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    cd terraform

                    terraform apply \
                    -auto-approve \
                    -var="image_tag=${IMAGE_TAG}"
                '''
            }
        }

    }

    post {

        success {
            echo 'Deployment successful!'
        }

        failure {
            echo 'Deployment failed!'
        }
    }
}
