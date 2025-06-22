@Library('shared-library') _

pipeline {
    agent none
    
    options {
        skipDefaultCheckout()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    parameters {
        string(name: 'NEW_VERSION', defaultValue: '1.2.0', description: 'Version to bump to')
    }

    environment {
        APP_NAME = 'java-maven-app'
    }

    stages {
        stage('Checkout SCM') {
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                        containers:
                        - name: git
                        image: alpine/git
                        command:
                        - cat
                        tty: true
                    """
                }
            }
            steps {
                container('git') {
                    cleanWs()       // Clear any stale workspace
                    checkout scm
                }
            }
        }
        stage('Update Versions') {
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: maven
                            image: maven:3.6.3-openjdk-8
                            command:
                            - cat
                            tty: true
                    """
                }
            }
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
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: maven
                            image: maven:3.6.3-openjdk-8
                            command:
                            - cat
                            tty: true
                    """
                }
            }
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
            agent {
                kubernetes {
                    yaml """
                        apiVersion: v1
                        kind: Pod
                        spec:
                          containers:
                          - name: docker
                            image: docker:20.10.16-dind
                            securityContext:
                              privileged: true
                            env:
                            - name: DOCKER_TLS_CERTDIR
                              value: ""
                    """
                }
            }
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