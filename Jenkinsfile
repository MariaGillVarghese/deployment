pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'  // Change to your AWS region
        ECR_REPO = 'my_repo'  // Replace with your ECR repository
        EKS_CLUSTER = 'eks-cluster'  // Replace with your EKS cluster name
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Clean Workspace') { // Correct stage definition
            steps {
                cleanWs()
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

        stage('
