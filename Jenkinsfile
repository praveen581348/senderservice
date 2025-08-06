pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prd'], description: 'Select the deployment environment')
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '1'))
    }

    environment {
        // Docker Hub credentials (used in Docker login stage)
        DOCKER_CREDENTIALS = credentials('docker-hub-creds')

        // Sonar token (recommend storing in Jenkins credentials store)
        SONAR_TOKEN = 'sqa_b13073e460ec1d568c989c4a31cf0b3e993a6f6d'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    def branchToBuild = params.ENVIRONMENT == 'prd' ? 'master' : 'dev'
                    echo "Selected environment: ${params.ENVIRONMENT}"
                    echo "Checking out branch: ${branchToBuild}"

                    git branch: branchToBuild,
                        url: 'https://github.com/praveen581348/senderservice.git'
                }
            }
        }

        stage('Setup Maven Config') {
            steps {
                configFileProvider([configFile(fileId: '374801f3-ef12-4da7-8542-302097f1e2d3', variable: 'MAVEN_SETTINGS')]) {
                    echo 'Maven settings file loaded.'
                }
            }
        }

        stage('Clean & Sonar Scan') {
            steps {
                configFileProvider([configFile(fileId: '374801f3-ef12-4da7-8542-302097f1e2d3', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn clean verify sonar:sonar -Dsonar.token=$SONAR_TOKEN -DskipTests --settings $MAVEN_SETTINGS'
                }
            }
        }

        stage('Maven Install') {
            steps {
                configFileProvider([configFile(fileId: '374801f3-ef12-4da7-8542-302097f1e2d3', variable: 'MAVEN_SETTINGS')]) {
                    sh 'mvn install -DskipTests --settings $MAVEN_SETTINGS'
                }
            }
        }

        stage('Maven Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-credentials',
                    usernameVariable: 'NEXUS_USERNAME',
                    passwordVariable: 'NEXUS_PASSWORD'
                )]) {
                    configFileProvider([configFile(fileId: '374801f3-ef12-4da7-8542-302097f1e2d3', variable: 'MAVEN_SETTINGS')]) {
                        sh 'mvn deploy -DskipTests --settings $MAVEN_SETTINGS'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_NAME = "praveen581348/senderservice:${BUILD_NUMBER}"
                }
                sh '''
                    echo "Building Docker image"
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('Docker Login & Push') {
            steps {
                sh '''
                    echo "Logging in to Docker Hub"
                    echo "$DOCKER_CREDENTIALS_PSW" | docker login -u "$DOCKER_CREDENTIALS_USR" --password-stdin
                    echo "Pushing Docker image"
                    docker push $IMAGE_NAME
                '''
            }
        }
        stage('Update Helm values.yaml') {
            steps {
                script {
                    sh '''
                    
                    ./update-helm-values.sh ${BUILD_NUMBER}
                '''
                }
            }
        }
        stage('Update Helm values.yaml') {
            steps {
                script {
                    sh '''
                    git add .
                    git commit -m "Tag upgrade helm"
                    git push
                '''
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
    }
}
