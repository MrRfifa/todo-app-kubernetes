pipeline
{
  agent any
  tools {
    dockerTool 'docker'
    nodejs 'node js'
  }
  environment{
    IMAGE= "$DOCKER_USERNAME/$IMAGE_NAME"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Image construction') {

        stage('Build image') {
          steps {
              sh "docker build -t ${IMAGE} ."
          }
        }
    }

    stage('Push image to Docker Hub') {
      steps {
        withCredentials([string(credentialsId: 'docker_access_token', variable: 'DOCKER_PASSWORD')]){
            script{
                sh 'docker login -u $DOCKER_USERNAME -p \$DOCKER_PASSWORD'
                sh "docker push ${IMAGE}"
            }
        }
      }
    }
    // stage('Set Azure Subscription') {
    //   steps {
    //     withCredentials([string(credentialsId: 'azure_subscription', variable: 'AZURE_SUBSCRIPTION_ID')]) {
    //       script {
    //         sh "az cloud set --name AzureCloud"
    //         sh "az login --identity -u /subscriptions/\${AZURE_SUBSCRIPTION_ID}/resourcegroups/myRG/providers/Microso
    //     ft.ManagedIdentity/userAssignedIdentities/myID"
    //         //  sh "az account set --subscription \${AZURE_SUBSCRIPTION_ID}"
    //       }
    //     }
    //   }
    // }

    stage('Provision server'){
        environment{
          subscription_id = credentials("azure_subscription")
          tenant_id =  credentials("tenant_id")
          TF_VAR_env_prefix= "test"
        }
        steps{
            script{
              dir("terraform"){
                 sh "terraform init"
                 sh "terraform apply --auto-approve"
                 VM_PUBLIC_IP = sh (
                  script:"terraform output vm_ip",
                  returnStdout : true
                 ).trim()
              }
            }
        }
    }

    stage('Deploy to Azure VM') {
            steps {
                script {
                    echo "Waiting for vm to initialize"
                    sleep(time: 120, unit: "SECONDS")
                    // Define Azure VM SSH credentials from Jenkins Credential store
                    def azureVmCredentials = credentials('server-ssh-key')
                    echo "${VM_PUBLIC_IP}"
                    if (azureVmCredentials) {
                        // Azure VM SSH connection details
                        def azureVmHostname = "${VM_PUBLIC_IP}"
                        def azureVmPort = 22  // Default SSH port
                        def azureVmUsername = 'azureuser'
                        def virtual_machine= "${azureVmUsername}@${azureVmHostname}"
                        def shellCmd="bash ./server-cmds.sh ${IMAGE}"
                        // Define the application deployment commands
                        def deployCommands = """
                            scp -o StrictHostKeyChecking=no server-cmds.sh ${virtual_machine}:/home/azureuser
                            scp -o StrictHostKeyChecking=no docker-compose.yaml ${virtual_machine}:/home/azureuser
                            scp -o StrictHostKeyChecking=no ${virtual_machine} 
                        """

                        // Execute SSH commands to deploy the application
                        sshagent(credentials: [azureVmCredentials]) {
                            sh """\
                                ssh -o StrictHostKeyChecking=no -p ${azureVmPort} ${virtual_machine} <<EOF
                                ${deployCommands}
                                EOF
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
