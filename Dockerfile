# Node.js 기반 React 앱 실행을 위한 Dockerfile

FROM node:18

# 작업 디렉토리 생성
WORKDIR /app

# 소스 복사
COPY . .

# 패키지 설치 및 빌드
RUN npm install
RUN npm run build

# React 앱 실행
CMD ["npm", "start"]

# 컨테이너가 실행될 포트
EXPOSE 3000
#
