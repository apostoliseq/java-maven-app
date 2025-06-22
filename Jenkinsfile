@Library('shared-library') _

pipeline {
    agent {
        kubernetes {
            yaml """
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: git
                    image: alpine/git:2.49.0
                    command: [cat]
                    tty: true
                  - name: maven
                    image: maven:3.6.3-openjdk-8
                    command: [cat]
                    tty: true
                  - name: docker
                    image: docker:28.2.2-dind
                    command: [cat]
                    tty: true
                    securityContext:
                      privileged: true
            """
        }
    }
    
    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    parameters {
        string(name: 'NEW_VERSION', description: 'Version to bump to')
    }

    environment {
        APP_NAME = 'java-maven-app'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                container('git') {
                    cleanWs()       // Clear any stale workspace
                    checkout scm
                }
            }
        }
        stage('Update Versions') {
            steps {
                container('maven') {
                    echo "Updating versions to ${params.NEW_VERSION}"

                    script {
                        updatePomVersion(params.NEW_VERSION)
                    }
                }
            }
        }
        
        stage('Build & Push Application') {
            steps {
                container('maven') {
                    echo "Building and pushing Maven application"
                    sh '''
                        echo "Running Maven clean package..."
                        mvn clean package -DskipTests
                        
                        echo "Listing target directory..."
                        ls -la target/
                    '''
                }
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                container('docker') {
                echo "Building and pushing Docker image"
                    script {
                        pushDockerImageToNexus(env.APP_NAME, params.NEW_VERSION, [
                            nexusRegistry: '192.168.138.154:5000/repository/docker-hosted',
                            credentialsId: 'nexus-jenkins'
                        ])
                    }
                }
            }
        }
    }
}