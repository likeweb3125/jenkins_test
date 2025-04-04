pipeline {
    agent { label 'build-agent' } 

    environment {
        GIT_REPO = 'git@github.com:likeweb3125/jenkins_test.git'
        APP_DIR = '/home/test_jenkins_react/jenkins_test'
        CONTAINER_NAME = 'jenkins_test'
        IMAGE_NAME = 'jenkins_test_image'
        HOST_PORT = '3010'
        CONTAINER_PORT = '3000'
        RECIPIENTS = 'crazin@likeweb.co.kr'
    }

    stages {
        stage('Update Repository') {
            steps {
                script {
                    try {
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

                        // 브랜치명 추출 (origin/ 접두어 제거)
                        env.GIT_BRANCH = sh(
                            script: "cd ${APP_DIR} && git rev-parse --abbrev-ref HEAD | sed 's|^origin/||'",
                            returnStdout: true
                        ).trim()

                        // Git 커밋 정보 추출
                        def gitInfo = sh(script: "cd ${APP_DIR} && git log -1 --pretty='format:%an|%B|%ci'", returnStdout: true).trim()
                        env.GIT_COMMIT_AUTHOR = gitInfo.split("\\|")[0]
                        env.GIT_COMMIT_MESSAGE = gitInfo.split("\\|")[1]
                        env.GIT_COMMIT_TIME = gitInfo.split("\\|")[2]

                        echo "🔍 현재 브랜치: ${env.GIT_BRANCH}"
                    } catch (Exception e) {
                        sendMailOnFailure("Update Repository Stage Failed")
                        error("Git 업데이트 실패!")
                    }
                }
            }
        }

        stage('Build & Restart Docker Container') {
            steps {
                script {
                    try {
                        sh """
                        cd ${APP_DIR}
                        docker build --no-cache -t ${IMAGE_NAME} .
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                        docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}
                        """
                    } catch (Exception e) {
                        sendMailOnFailure("Docker Build & Restart Failed")
                        error("Docker 빌드 및 실행 실패!")
                    }
                }
            }
        }
    }

    post {
        success {
            sendMailOnSuccess()
        }
        failure {
            sendMailOnFailure("Pipeline Execution Failed")
        }
    }
}

// 📌 빌드 실패 시 이메일 전송 함수
def sendMailOnFailure(errorMessage) {
    emailext (
        subject: "🔴 빌드 실패: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
        body: """
        <h2>❌ Jenkins 빌드 실패 ❌</h2>
        <p>🔹 프로젝트: ${env.JOB_NAME}</p>
        <p>🔹 브랜치: ${env.GIT_BRANCH}</p>
        <p>🔹 빌드 번호: ${env.BUILD_NUMBER}</p>
        <p>🔹 실패 단계: ${errorMessage}</p>
        <p>🔹 커밋 유저: ${env.GIT_COMMIT_AUTHOR}</p>
        <p>🔹 커밋 메시지: ${env.GIT_COMMIT_MESSAGE}</p>
        <p>🔹 커밋 시간: ${env.GIT_COMMIT_TIME}</p>
        <p>📜 <a href='${env.BUILD_URL}console'>콘솔 로그 확인</a></p>
        """,
        to: "${env.RECIPIENTS}",
        from: "no-reply@likeweb.co.kr"
    )
}

// 📌 빌드 성공 시 이메일 전송 함수
def sendMailOnSuccess() {
    emailext(
        subject: "✅ 빌드 성공: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
        body: """
        <h2>🎉 Jenkins 빌드 성공 🎉</h2>
        <p>🔹 프로젝트: ${env.JOB_NAME}</p>
        <p>🔹 브랜치: ${env.GIT_BRANCH}</p>
        <p>🔹 빌드 번호: ${env.BUILD_NUMBER}</p>
        <p>🔹 커밋 유저: ${env.GIT_COMMIT_AUTHOR}</p>
        <p>🔹 커밋 메시지: ${env.GIT_COMMIT_MESSAGE}</p>
        <p>🔹 커밋 시간: ${env.GIT_COMMIT_TIME}</p>
        <p>📜 <a href='${env.BUILD_URL}console'>콘솔 로그 확인</a></p>
        """,
        to: "${env.RECIPIENTS}",
        from: "no-reply@likeweb.co.kr"
    )
}
