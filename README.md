
# Deploying Todo App in Azure vm with Terraform

This repository contains a todo app designed to run within a Kubernetes cluster. It includes Dockerfiles for easy containerization.
# Project Files Overview

This repository contains the necessary files and configurations for a Todo app that can run within a Kubernetes cluster. The included files are organized as follows:

## App Files

- `app/index.js`: This file sets up the Express application.
- `app/models/Todo.js`: Defines the data structure for the Todo model.
- `app/routes/todo.js`: Contains the application's route definitions.

## Kubernetes Configurations

- `kubernetes/docker-secret.yaml`: Defines the Kubernetes Secret containing Docker credentials.
- `kubernetes/mongo-deployment.yaml`: Creates the MongoDB deployment and its associated service.
- `kubernetes/todo-app-deployment.yaml`: Establishes the deployment of the todo app and its corresponding service.

## Dockerization and Compose

- `Dockerfile`: Used for creating the Docker image.
- `docker-compose.yaml`: Composes the Docker services for local development.

## Node.js App Dependencies

- `package.json`: Lists the Node.js app's dependencies.
## Prerequisites

Before using these files, make sure you have the following set up:

1. Docker installed. 
2. Kubernetes cluster up and running with `minikube start`.
3. `kubectl` command-line tool installed and configured to interact with your cluster.
## Instructions

1. **Clone this repository** to your local machine:

    ```bash
    git clone https://github.com/MrRfifa/todo-app-kubernetes
    ```

2. **Navigate to the cloned directory**:

    ```bash
    cd todo-app-kubernetes
    ```
3. **Testing the app locally**:

    ```bash
    docker-compose up
    ```

    Use applications like "Postman" or "Insomnia" to test the API locally.

    The main URL for accessing the app's endpoints is : 
    ```bash
     http://localhost:3000/todos
    ```
    Remember to replace 3000 with the appropriate port if you've configured a different port for your app.

    To take down the containers :

    ```bash
    docker-compose down
    ```

4. **Building the Application and Pushing it to Docker Hub**:
    
    Building the docker image
    ```bash
     docker build -t <dockerhub-username>/<image-name>:tag .
    ```

    Pushing the image to Docker Hub

    Before proceeding, ensure that you're logged in to Docker using:
    
    ```bash
     docker login
    ```

    Then, use the following command to push the image to Docker Hub:

    ```bash
     docker push <dockerhub-username>/<image-name>:tag .
    ```

In the subsequent steps, I transitioned the Docker image repository to a private one, aiming to test the process of pulling an image from a private repository.

To achieve this, I need to establish a credential configuration that will be utilized in the upcoming stages.

5. **Creating credentials in windows 11 using powershell**:

```bash
$auth = [System.Text.Encoding]::UTF8.GetBytes('<dockerhub-username>:<dockerhub-password>')
$authBase64 = [System.Convert]::ToBase64String($auth)
$json = '{"auths":{"https://index.docker.io/v1/":{"auth":"' + $authBase64 + '","email":"<your-email>"}}}'
$jsonBase64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($json))
Write-Host $jsonBase64
```

Replace `<dockerhub-username>`, `<dockerhub-password>`, and `<your-email>` with your actual Docker Hub credentials and email address. This code snippet generates a base64-encoded JSON configuration for Docker Hub authentication.

In the `/kubernetes/docker-secret.yaml` file, update the `.dockerconfigjson` field by adding the previously generated base64-encoded string.

6. **Apply the Kubernetes configurations** in the following order:

    ```bash
    kubectl apply -f docker-secret.yaml
    kubectl apply -f mongo-deployment.yaml
    kubectl apply -f todo-app-deployment.yaml
    ```
The files `/kubernetes/mongo-deployment.yaml` and `/kubernetes/todo-app-deployment.yaml` contain the deployment and service components.

7. **Access Todo Application API**:

    After applying the configurations, you can access the API using the following command:

    ```bash
    minikube service todo-app-service
    ```

    The main URL for accessing the app's endpoints will be provided in the output of the previous command. It will look something like:

    ```bash
     http://127.0.0.1:<<port>>
    ```
    To test the API, use applications like "Postman" or "Insomnia." Don't forget to append `/todos` to the URL so it looks like:

    ```bash
     http://127.0.0.1:<<port>>/todos
    ``` 

    This will access the specific todos endpoint of the app for testing purposes.

8. **Cleaning up**:

    When you're done with your work, clean up the resources by deleting the applied configurations:

    ```bash
    kubectl delete -f mongo-deployment.yaml
    kubectl delete -f todo-app-deployment.yaml
    kubectl delete -f docker-secret.yaml
    ```
![blue_ocean-iage](https://github.com/MrRfifa/todo-app-kubernetes/assets/101003527/655191f3-ae2a-475b-a5d4-fe297ca90b43)
![add_todo_object](https://github.com/MrRfifa/todo-app-kubernetes/assets/101003527/2a4b3f65-4ab9-49ac-9f81-a31eb279f0b4)
![getting todos](https://github.com/MrRfifa/todo-app-kubernetes/assets/101003527/3d05c27a-fb54-4930-b1ac-58432c610250)


