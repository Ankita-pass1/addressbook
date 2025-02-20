pipeline {
    agent none // No global agent is assigned
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
        IMAGE_NAME = 'ankita2025/devops'
    }
    stages {
        stage('Compile') {
            agent any  // Use any available agent
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
            agent any  // Use any available agent
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
            agent any  // Use any available agent
            steps {
                sshagent(['slave_2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {
                        echo "Containerizing the Build Stage ${params.APPVERSION}"
                        // Ensure SSH access is working
                        //sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'echo Hello'"
                        
                        // Transfer the server-config.sh script and run it on the build server
                        echo "Transferring server-config.sh to build server"
                        sh "scp -o StrictHostkeyChecking=no server-congig.sh ${BUILD_SERVER}:/home/ec2-user"
                        
                        // Execute the configuration script on the build server
                        echo "Running server-config.sh on the build server"
                        sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'bash /home/ec2-user/server-congig.sh' ${IMAGE_NAME} ${BUILD_NUMBER}"
                        
                        // Docker login and push to Docker Hub
                        sh "ssh  -o StrictHostkeyChecking=no ${BUILD_SERVER} sudo docker login -u ${username} -p ${password}"
                        sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Deployment Stage') {
            agent any  // Use any available agent
            steps {
                sshagent(['slave_2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {
                        // SSH login to the deployment server, install Docker, and run the image
                        sh "ssh -o StrictHostkeyChecking=no ${DEPLOY_SERVER} sudo yum install docker -y"
                        sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                        sh "ssh  ${DEPLOY_SERVER} sudo docker login -u ${username} -p ${password}"
                        sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}:${BUILD_NUMBER}"
                    }
                }
            }
        }
    }
}
