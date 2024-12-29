pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'  // Change to your AWS region
        ECR_REPO = 'my_repo'  // Replace with your ECR repository
        EKS_CLUSTER = 'eks-cluster'  // Replace with your EKS cluster name
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Clone the repository where your app is located
                git 'https://github.com/MariaGillVarghese/deployment.git'  // Replace with your repo
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
                }
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                script {
                    // Authenticate Docker to ECR
                    sh '''
                    $(aws ecr get-login --no-include-email --region $AWS_REGION)
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    // Tag and push the image to ECR
                    sh '''
                    docker tag $ECR_REPO:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Get kubeconfig for the EKS cluster
                    sh '''
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER
                    '''

                    // Apply Kubernetes deployment and service files to deploy the app
                    sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
}
