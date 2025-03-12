pipeline {
    agent any

    environment {
        GIT_REPO = 'git@github.com:likeweb3125/jenkins_test.git' // SSH 방식으로 변경
        APP_DIR = '/home/test_jenkins_react/jenkins_test'
        CONTAINER_NAME = 'jenkins_test'
        IMAGE_NAME = 'jenkins_test_image'
        PORT = '3010'
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // 기존 폴더 삭제 후 다시 클론
                    sh "rm -rf ${APP_DIR}"
                    sh "git clone ${GIT_REPO} ${APP_DIR}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    cd ${APP_DIR}
                    docker build -t ${IMAGE_NAME} .
                    """
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // 기존 컨테이너 정리 후 새로운 컨테이너 실행
                    sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p ${PORT}:3010 ${IMAGE_NAME}
                    """
                }
            }
        }
    }
}

