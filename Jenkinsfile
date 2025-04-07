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
        stage('Clone or Update Repository') {
            steps {
                script {
                    try {
                        // Git clone 또는 pull
                        sh """
                        if [ ! -d "${APP_DIR}/.git" ]; then
                            echo "📥 Git 저장소가 없으므로 clone합니다."
                            git clone ${GIT_REPO} ${APP_DIR}
                        else
                            echo "🔄 Git 저장소가 이미 존재하므로 pull 진행"
                            cd ${APP_DIR}
                            git fetch origin main
                            git reset --hard origin/main
                            git pull origin main
                        fi
                        """

                        // Git 정보 추출
                        dir(APP_DIR) {
                            // 브랜치명 (origin/ 제거)1
                            env.GIT_BRANCH = sh(
                                script: "git rev-parse --abbrev-ref HEAD",
                                returnStdout: true
                            ).trim()

                            echo "📦 원본 브랜치명: ${env.GIT_BRANCH}"

                            def strippedBranch = env.GIT_BRANCH.replaceFirst(/^origin\//, '')
                            echo "📦 접두어 제거된 브랜치명: ${strippedBranch}"

                            // 조건 체크는 제거된 값으로
                            if (strippedBranch == 'main') {
                                echo "📌 값은 main입니다!"
                            } else {
                                echo "📌 값은 main이 아닙니다!"
                            }


                            def gitInfo = sh(
                                script: "git log -1 --pretty='format:%an|%B|%ci'",
                                returnStdout: true
                            ).trim()

                            env.GIT_COMMIT_AUTHOR = gitInfo.split("\\|")[0]
                            env.GIT_COMMIT_MESSAGE = gitInfo.split("\\|")[1]
                            env.GIT_COMMIT_TIME = gitInfo.split("\\|")[2]

                            echo "✅ 브랜치명:${env.GIT_BRANCH}"
                            echo "✅ 커밋 작성자: ${env.GIT_COMMIT_AUTHOR}"
                            echo "✅ 커밋 메시지: ${env.GIT_COMMIT_MESSAGE}"
                            echo "✅ 커밋 시간: ${env.GIT_COMMIT_TIME}"
                        }

                    } catch (Exception e) {
                        sendMailOnFailure("❌ Git clone 또는 업데이트 실패")
                        error("❌ Git 작업 실패")
                    }
                }
            }
        }

        stage('Build & Restart Docker') {
            steps {
                script {
                    try {
                        dir(APP_DIR) {
                            sh """
                            echo "🐳 Docker 이미지 빌드 시작"
                            docker build --no-cache -t ${IMAGE_NAME} .

                            echo "🛑 기존 컨테이너 중지 및 제거"
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true

                            echo "🚀 새 컨테이너 실행"
                            docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}
                            """
                        }
                    } catch (Exception e) {
                        sendMailOnFailure("❌ Docker Build or Run Failed")
                        error("❌ Docker 빌드/실행 실패")
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
            sendMailOnFailure("❌ Pipeline 실패 (Post 단계)")
        }
    }
}


// 빌드 실패 시 이메일
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

// 빌드 성공 시 이메일
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

