pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prd'], description: 'Select the deployment environment')
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '1', numToKeepStr: '1'))
    }

    environment {
        // Nexus credentials
        NEXUS_CREDENTIALS = credentials('nexus-credentials')

        // Docker Hub credentials
        DOCKER_CREDENTIALS = credentials('docker-hub-creds')

        // Sonar token (move to Jenkins credentials ideally)
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
                configFileProvider([configFile(fileId: 'maven-settings-xml-id', variable: 'MAVEN_SETTINGS')]) {
                    echo 'Maven settings configured.'
                }
            }
        }

        stage('Clean & Sonar Scan') {
            steps {
                sh 'mvn -s $MAVEN_SETTINGS clean verify sonar:sonar -Dsonar.token=$SONAR_TOKEN -DskipTests'
            }
        }

        stage('Maven Install') {
            steps {
                sh 'mvn -s $MAVEN_SETTINGS install -DskipTests'
            }
        }

        stage('Maven Deploy') {
            steps {
                sh 'mvn -s $MAVEN_SETTINGS deploy -DskipTests'
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
    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
    }
}
