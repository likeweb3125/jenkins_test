pipeline {
    agent any

    environment {
        GIT_REPO = 'git@github.com:likeweb3125/jenkins_test.git'
        APP_DIR = '/home/test_jenkins_react/jenkins_test'
        CONTAINER_NAME = 'jenkins_test'
        IMAGE_NAME = 'jenkins_test_image'
        HOST_PORT = '3010'  // 변경된 호스트 포트
        CONTAINER_PORT = '3000'  // 컨테이너 내부 포트
    }

    stages {
        stage('Update Repository') {
            steps {
                script {
                    sh """
                    if [ ! -d "${APP_DIR}/.git" ]; then
                        git clone ${GIT_REPO} ${APP_DIR}
                    else
                        cd ${APP_DIR}
                        git fetch origin main
                        git reset --hard origin/main
                        git pull origin main
                    fi
                    """
                }
            }
        }

        stage('Build & Restart Docker Container') {
            steps {
                script {
                    sh """
                    cd ${APP_DIR}
                    docker build --no-cache -t ${IMAGE_NAME} .
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}
                    """
                }
            }
        }
    }
}
