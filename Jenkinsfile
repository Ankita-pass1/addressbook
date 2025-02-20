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
    environment {  // Define environment variables for the whole pipeline
       BUILD_SERVER = 'ec2-user@172.31.27.112'
       DEPLOY_SERVER = 'ec2-user@172.31.27.28'
       IMAGE_NAME= 'ankita2025/devops'
    }
    stages {
        //stage('Checkout') {
          //  agent any
            //steps {
                // Checkout the code, ensuring BRANCH_NAME is available
              //  checkout scm
                //echo "Checked out to branch: ${env.BRANCH_NAME}"  // Debugging BRANCH_NAME
            //}
        //}
        stage('Compile') {
            agent any
            steps {
                echo "Compile the code in ${params.Env}"
                sh "mvn compile"
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
                echo "Test the code"
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        // stage('Package') {
        //     agent any
        //     // input {
        //     //     message "Select the version to deploy"
        //     //     ok "Version selected"
        //     //     parameters {
        //     //         choice(name: 'NEWAPP', choices: ['1.2', '2.1', '3.1'])
        //     //     }
        //     // }
        //     steps {
        //             sshagent(['slave_2']) {
        //         //echo "BRANCH_NAME: ${env.BRANCH_NAME}"  // Debugging BRANCH_NAME
        //         // script {
        //         //     // if (env.BRANCH_NAME == 'b1') {
        //              echo "Packaging the code ${params.NEWAPP}"
        //              sh "scp -o StrictHostkeyChecking=no server-congig.sh ${BUILD_SERVER} :/home/ec2-user"
        //              sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'bash server-congig.sh'"
        //         //     //     sh "mvn package"
        //         //     // } else {
        //         //     //     echo "Skipping Package stage as branch is not 'b1'"
        //            // sh "mvn package"
        //         //     // }
        //         // }
        //             }
        //     }
        // }
        
        stage('Containarizing build stage') {
            agent any
            steps {
                sshagent(['slave_2']){
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {

                    echo "Containarizing the Build Stage ${params.NEWAPP}"

                    // Ensure SSH access is working
                   // sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'echo Hello'"

                    // Transfer the server-config.sh script and run it on the build server
                    echo "Transferring server-config.sh to build server"
                    sh "scp -o StrictHostkeyChecking=no server-congig.sh ${BUILD_SERVER}:/home/ec2-user"

                    // Execute the configuration script on the build server
                    echo "Running server-config.sh on the build server"
                    sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'bash /home/ec2-user/server-congig.sh' ${IMAGE_NAME} ${BUILD_NUMBER}"

                    // Run Maven package after the server setup
                   //echo "Running Maven package"
                    
                    //sh "mvn package"
                    sh "ssh  -o StrictHostkeyChecking=no ${BUILD_SERVER} sudo docker login -u ${username} -p ${password}"
                    sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
                }
            }
        }
        stage('Deployment Stae') {
            agent any
            steps {
                sshagent(['slave_2']){
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'password', usernameVariable: 'username')]) {

                    //echo "Containarizing the Build Stage ${params.NEWAPP}"

                    // Ensure SSH access is working
                   // sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'echo Hello'"

                    // Transfer the server-config.sh script and run it on the build server
                   // echo "Transferring server-config.sh to build server"
                    //sh "scp -o StrictHostkeyChecking=no server-congig.sh ${BUILD_SERVER}:/home/ec2-user"

                    // Execute the configuration script on the build server
                    //echo "Running server-config.sh on the build server"
                    //sh "ssh -o StrictHostkeyChecking=no ${BUILD_SERVER} 'bash /home/ec2-user/server-congig.sh' ${IMAGE_NAME} ${BUILD_NUMBER}"

                    // Run Maven package after the server setup
                   //echo "Running Maven package"
                    
                    //sh "mvn package"
                    sh "ssh -o StrictHostkeyChecking=no ${DEPLOY_SERVER} sudo yum docker install -y"
                    sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                    sh "ssh  ${DEPLOY_SERVER} sudo docker login -u ${username} -p ${password}"
                    sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
                }
            }
        }

    }
}
