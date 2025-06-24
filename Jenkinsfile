pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/snakeboy237/survim'
            }
        }

        // Build Backend Image
        stage('Build Backend Image') {
            when {
                changeset "**/web_app/backend-api/**"
            }
            steps {
                dir('web_app/backend-api') {
                    script {
                        docker.build('ai-backend:latest', '.')
                    }
                }
            }
        }

        // Deploy Backend
        stage('Deploy Backend') {
            when {
                changeset "**/web_app/backend-api/**"
            }
            steps {
                script {
                    sh '''
                    docker stop ai-backend || true
                    docker rm ai-backend || true
                    docker run -d --name ai-backend -p 3000:3000 ai-backend:latest
                    '''
                }
            }
        }

        // Build Frontend Image
        stage('Build Frontend Image') {
            when {
                changeset "**/web_app/frontend/**"
            }
            steps {
                dir('web_app/frontend') {
                    script {
                        docker.build('ai-frontend:latest', '.')
                    }
                }
            }
        }

        // Deploy Frontend
        stage('Deploy Frontend') {
            when {
                changeset "**/web_app/frontend/**"
            }
            steps {
                script {
                    sh '''
                    docker stop myfrontend || true
                    docker rm myfrontend || true
                    docker run -d --name myfrontend -p 8080:80 ai-frontend:latest
                    '''
                }
            }
        }

        // Deploy DB (Run SQL)
        stage('Deploy DB Changes') {
            when {
                changeset "**/web_app/db/*.sql"
            }
            steps {
                script {
                    sh '''
                    psql -h localhost -U postgres -d mydb -f web_app/db/create_tables.sql || true
                    psql -h localhost -U postgres -d mydb -f web_app/db/views.sql || true
                    psql -h localhost -U postgres -d mydb -f web_app/db/create_stored_procedures.sql || true
                    '''
                }
            }
        }
    }
}
