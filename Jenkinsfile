pipeline {
    agent any

    // properties([
    //     githubProjectProperty(projectUrlStr: 'https://github.com/denmgarcia/angular-app/')
    // ])

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
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}", ".")
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

                    // sh "docker run --rm ${IMAGE_NAME}:test pnpm exec ng test --watch=false --browsers=ChromeHeadless"
                }
            }
        }

        stage('Build & Push to Registry') {

            steps {
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

        stage('Update Kubernetes Manifests') {
              steps {
                  withCredentials([usernamePassword(credentialsId: 'github-creds',
                                  passwordVariable: 'GIT_PASSWORD',
                                  usernameVariable: 'GIT_USERNAME')]) {
                      script {
                          sh '''
                              TARGET="manifest/deployment.yml"

                              sed -i "s|image: cyborden/angular-app.*|image: cyborden/angular-app:${IMAGE_TAG}|g" "$TARGET"

                              git config user.email "dengarcia.x@gmail.com"
                              git config user.name "Jenkins CI"

                              git add "$TARGET"
                              git commit -m "Update image tag to ${IMAGE_TAG}"

                              # We use the variables GIT_USERNAME and GIT_PASSWORD here
                              git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/denmgarcia/cicd-sample.git HEAD:$BRANCH_NAME
                          '''
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
