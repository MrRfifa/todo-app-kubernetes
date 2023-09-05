pipeline {
    agent any

    tools {
        dockerTool 'docker'
        nodejs 'node js'
    }

    environment {
        IMAGE = "${DOCKER_USERNAME}/${IMAGE_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Image construction') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${IMAGE} ."
                }
            }
        }

        stage('Push image to Docker Hub') {
            steps {
                withCredentials([string(credentialsId: 'docker_access_token', variable: 'DOCKER_PASSWORD')]) {
                    script {
                        // Log in to Docker Hub and push the image
                        sh "docker login -u \$DOCKER_USERNAME -p \$DOCKER_PASSWORD"
                        sh "docker push ${IMAGE}"
                    }
                }
            }
        }

        
        stage('Set Azure Subscription') {
            steps {
                withCredentials([string(credentialsId: 'azure_subscription', variable: 'AZURE_SUBSCRIPTION_ID')]) {
                    script {
                        sh "az cloud set --name AzureCloud"
                        // sh "az login -u johndoe@contoso.com -p secret"
                        sh "az login"
                        sh "az account set --subscription \${AZURE_SUBSCRIPTION_ID}"
                    }
                }
            }
        }
        

        stage('Provision server') {
            environment {
                TF_VAR_env_prefix = "test"
            }
            steps {
                script {
                    dir("terraform") {
                        // Initialize and apply Terraform configuration
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        // Capture the VM's public IP
                        VM_PUBLIC_IP = sh(
                            script: "terraform output vm_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('Deploy to Azure VM') {
    steps {
        script {
            // Define Azure VM SSH credentials from Jenkins Credential store
            def azureVmCredentials = credentials('server-ssh-key')
            echo "VM_PUBLIC_IP: ${VM_PUBLIC_IP}"
            if (azureVmCredentials) {
                echo "Azure VM SSH credentials found"
                // Azure VM SSH connection details
                def azureVmHostname = "${VM_PUBLIC_IP}"
                def azureVmPort = 22 // Default SSH port
                def azureVmUsername = 'azureuser'
                def virtual_machine = "${azureVmUsername}@${azureVmHostname}"
                def shellCmd = "bash ./server-cmds.sh ${IMAGE}"
                // Define the application deployment commands
                def deployCommands = """
                    scp -o StrictHostKeyChecking=no server-cmds.sh docker-compose.yaml ${virtual_machine}:/home/azureuser/
                    ssh -o StrictHostKeyChecking=no -p 22 ${azureVmUsername}@${azureVmHostname} ${shellCmd}
                """
                // Execute SSH commands to deploy the application
                sshagent( ['server-ssh-key']) {
                    sh """
                        ${deployCommands}
                    """
                }
            } else {
                error("Azure VM SSH credentials not found")
            }
        }
    }
}

    }
}
