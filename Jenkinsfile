pipeline {
    agent any

    environment {
        IMAGE_NAME = "cyborden/angular-app"
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG} .")
                }
            }
        }

        stage('Prepare Build') {
            steps {
                echo 'Building base image for testing...'
                sh "docker build --target build -t ${IMAGE_NAME}:test ."
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running Unit Tests & Linting...'
                script {

                    sh "docker run --rm ${IMAGE_NAME}:test pnpm exec ng lint"

                    sh "docker run --rm ${IMAGE_NAME}:test pnpm exec ng test --watch=false --browsers=ChromeHeadless"
                }
            }
        }

        stage('Build & Push to Registry') {

            steps {
                // script {
                //     echo 'Tests passed. Building final dev image...'
                //     sh "docker build -t ${REGISTRY_USER}/${IMAGE_NAME}:dev ."

                //     withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                //         sh "echo $PASS | docker login -u $USER --password-stdin"
                //         sh "docker push ${REGISTRY_USER}/${IMAGE_NAME}:dev"
                //     }
                // }

                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def myImage = docker.image("${IMAGE_NAME}:${IMAGE_TAG}")
                        myImage.push()

                        if (env.BRANCH_NAME == 'main') {
                            myImage.push("latest")
                        } else {
                            myImage.push("${env.BRANCH_NAME}")
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
            sh "docker image prune -f"
        }
        failure {
            echo "Pipeline failed at Stage: ${env.STAGE_NAME}. Remote deployment skipped."
        }
    }
}
