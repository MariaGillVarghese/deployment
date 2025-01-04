pipeline {
    agent any
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev'], description: 'Select the target environment')
    }

    environment {
        GIT_REPO = 'https://github.com/MariaGillVarghese/deployment.git' 
        GIT_BRANCH = 'main'
        IMAGE_NAME = 'mariagill321/deploymentapp'
        DEPLOY_IMAGE = 'docker.avitech-ag.intra/aviview/alpine:latest'
        KUBECONFIG_PATH = "/home/my_jenkins_home/.kube/config-aviview-${params.ENVIRONMENT}"
        KNOWN_HOSTS_PATH = '/home/my_jenkins_home/.ssh/known_hosts'
        IMAGE_TAG = 'latest' 
    }

    stages {
       
            stage('Prepare Helm Environment') {
            steps {
                script {
                    
                        sh """
                        # Create a Docker container and keep it running
                        docker run -d --name helm_env \\
                        -v ${env.KUBECONFIG_PATH}:/root/.kube/config \\
                        -v ${env.KNOWN_HOSTS_PATH}:/root/.ssh/known_hosts \\
                        -v /var/run/docker.sock:/var/run/docker.sock \\
                        ${env.DEPLOY_IMAGE} sleep infinity

                        docker exec helm_env sh -c "apk update && apk add --no-cache git curl"
                        docker exec helm_env sh -c "apk add --no-cache docker-cli"
                        
                        # Fetch the latest release version of kubectl
                        docker exec helm_env sh -c "curl -LO 'https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'"
                        docker exec helm_env sh -c "chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl"

                       


                        # Clone the repository directly into the container
                        docker exec helm_env git -c http.sslVerify=false clone -b ${GIT_BRANCH} ${GIT_REPO} /repo

                        

                        """
                    
                }
            }
        }
        stage('Print cloned folder') {
            steps {
                script {
                     sh """
                    docker exec helm_env sh -c 'ls ./repo'
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker exec helm_env sh -c 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
                    """
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([url: "https://index.docker.io/v1/", credentialsId: 'dockerhub-credentials']) {
                        sh """
                        docker exec helm_env sh -c  'docker push $IMAGE_NAME:$IMAGE_TAG'
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    docker exec helm_env sh -c 'kubectl apply -f k8s/deployment.yaml'
                    docker exec helm_env sh -c 'kubectl apply -f k8s/service.yaml'
                    """
                }
            }
        }
        
        
    }
     post {
        always {
            sh "docker stop helm_env || true"
            sh "docker rm helm_env || true"
        }
    }
}
