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
    stages {
        stage('Checkout') {
            agent any
            steps {
                // Checkout the code, ensuring BRANCH_NAME is available
                checkout scm
                echo "Checked out to branch: ${env.BRANCH_NAME}"  // Debugging BRANCH_NAME
            }
        }
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
        stage('Package') {
            agent any
            input {
                message "Select the version to deploy"
                ok "Version selected"
                parameters {
                    choice(name: 'NEWAPP', choices: ['1.2', '2.1', '3.1'])
                }
            }
            steps {
                echo "BRANCH_NAME: ${env.BRANCH_NAME}"  // Debugging BRANCH_NAME
                script {
                    if (env.BRANCH_NAME == 'b1') {
                        echo "Packaging the code ${params.NEWAPP}"
                        sh "mvn package"
                    } else {
                        echo "Skipping Package stage as branch is not 'b1'"
                    }
                }
            }
        }
    }
}
