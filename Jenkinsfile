pipeline {

    agent any

    environment {

        AWS_REGION = 'us-east-1'

        AWS_ACCOUNT_ID = '570367131376'

        ECR_REPOSITORY = 'javaapplication'

        ECR_REGISTRY =
            "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        // Change these three values to match your Terraform resources
        ECS_CLUSTER = 'javaapplication-cluster'

        ECS_SERVICE = 'javaapplication-service'

        ECS_TASK_FAMILY = 'javaapplication-task'

        // Must match the container "name" in your ECS task definition
        CONTAINER_NAME = 'javaapplication'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                script {
                    // Use first 7 characters of Git commit as Docker tag
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=7 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_NAME =
                        "${env.ECR_REGISTRY}/${env.ECR_REPOSITORY}:${env.IMAGE_TAG}"

                    echo "Git Commit: ${env.IMAGE_TAG}"
                    echo "Docker Image: ${env.IMAGE_NAME}"
                }
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

        stage('Push Image to ECR') {
            steps {
                sh '''
                    echo "Pushing image: ${IMAGE_NAME}"

                    docker push ${IMAGE_NAME}
                '''
            }
        }

        stage('Prepare ECS Task Definition') {
            steps {
                sh '''
                    echo "Getting current ECS task definition..."

                    aws ecs describe-task-definition \
                        --task-definition ${ECS_TASK_FAMILY} \
                        --region ${AWS_REGION} \
                        --query taskDefinition \
                        --output json > taskdef.json

                    echo "Updating container image..."

                    jq --arg IMAGE "${IMAGE_NAME}" \
                       --arg CONTAINER "${CONTAINER_NAME}" \
                    '
                    del(
                        .taskDefinitionArn,
                        .revision,
                        .status,
                        .requiresAttributes,
                        .compatibilities,
                        .registeredAt,
                        .registeredBy
                    )
                    |
                    .containerDefinitions |=
                    map(
                        if .name == $CONTAINER
                        then .image = $IMAGE
                        else .
                        end
                    )
                    ' taskdef.json > taskdef-new.json
                '''
            }
        }

        stage('Register ECS Task Definition') {
            steps {
                sh '''
                    echo "Registering new ECS task definition..."

                    aws ecs register-task-definition \
                        --cli-input-json file://taskdef-new.json \
                        --region ${AWS_REGION} \
                        > new-task-definition.json

                    cat new-task-definition.json
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                    NEW_TASK_DEFINITION=$(jq -r \
                        '.taskDefinition.taskDefinitionArn' \
                        new-task-definition.json)

                    echo "Deploying:"
                    echo "${NEW_TASK_DEFINITION}"

                    aws ecs update-service \
                        --cluster ${ECS_CLUSTER} \
                        --service ${ECS_SERVICE} \
                        --task-definition ${NEW_TASK_DEFINITION} \
                        --region ${AWS_REGION}
                '''
            }
        }

        stage('Wait for ECS Deployment') {
            steps {
                sh '''
                    echo "Waiting for ECS deployment..."

                    aws ecs wait services-stable \
                        --cluster ${ECS_CLUSTER} \
                        --services ${ECS_SERVICE} \
                        --region ${AWS_REGION}

                    echo "ECS deployment is stable."
                '''
            }
        }

        stage('Deployment Verification') {
            steps {
                sh '''
                    echo "Checking ECS service..."

                    aws ecs describe-services \
                        --cluster ${ECS_CLUSTER} \
                        --services ${ECS_SERVICE} \
                        --region ${AWS_REGION} \
                        --query 'services[0].deployments'
                '''
            }
        }
    }

    post {

        success {
            echo '''
            ==========================================
               DEPLOYMENT SUCCESSFUL
            ==========================================
            '''

            echo "Docker Image: ${env.IMAGE_NAME}"
            echo "ECS Cluster: ${env.ECS_CLUSTER}"
            echo "ECS Service: ${env.ECS_SERVICE}"
        }

        failure {
            echo '''
            ==========================================
               DEPLOYMENT FAILED
            ==========================================
            '''

            echo 'Check Jenkins console output for the failed stage.'
        }

        always {
            sh '''
                rm -f taskdef.json
                rm -f taskdef-new.json
                rm -f new-task-definition.json
            '''
        }
    }
}
