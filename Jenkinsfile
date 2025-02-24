pipeline {
    agent none
    tools {
        maven "mymaven"
    }
    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'Environment to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'Decide to run tests')
        choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'])
    }
    environment {
        BUILD_SERVER = 'ec2-user@172.31.27.112'
        DEPLOY_SERVER = 'ec2-user@172.31.27.28'
        IMAGE_NAME = 'ankita2025/docker'
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                sshagent(['slave_2']) {
                    echo "Compile the code in ${params.Env}"
                    sh "mvn compile"
                }
            }
        }
        stage('UnitTest') {
            when {
                expression {
                    params.executeTests == true
                }
            }
            agent any
            steps {
                sshagent(['slave_2']) {
                    echo "Test the code"
                    sh "mvn test"
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Containerizing build stage') {
            agent any
            steps {
                sshagent(['slave_2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {
                        // Verify Dockerfile exists
                        sh '''
                            if [ ! -f Dockerfile ]; then
                                echo "Error: Dockerfile not found!"
                                exit 1
                            fi
                            echo "Dockerfile found. Proceeding with build..."
                        '''

                        // Transfer Dockerfile to the build server
                        sh "scp -o StrictHostKeyChecking=no Dockerfile ${BUILD_SERVER}:/home/ec2-user"

                        // Docker login
                        sh """
                            ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'echo ${password} | sudo docker login -u ${username} --password-stdin'
                        """

                        // Docker build with logging
                        sh """
                            ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'cd /home/ec2-user && sudo docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .' > docker-build.log 2>&1
                            cat docker-build.log
                        """

                        // Verify Docker image
                        sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'sudo docker images'"

                        // Docker push
                        sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}'"
                    }
                }
            }
        }
        stage('Deployment Stage') {
            agent any
            steps {
                sshagent(['slave_2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {
                        // Docker login
                        sh """
                            ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} 'echo ${password} | sudo docker login -u ${username} --password-stdin'
                        """

                        // Docker run
                        sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} 'sudo docker run -itd -P ${IMAGE_NAME}:${BUILD_NUMBER}'"
                    }
                }
            }
        }
    }
    post {
        failure {
            echo "Pipeline failed! Check logs for details."
        }
        success {
            echo "Pipeline succeeded!"
        }
    }
}