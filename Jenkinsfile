pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/snakeboy237/survim'
            }
        }

        stage('Build Backend Image') {
            steps {
                dir('web_app/backend-api') {
                    script {
                        docker.build('ai-backend:latest', '.')
                    }
                }
            }
        }
    }
}
