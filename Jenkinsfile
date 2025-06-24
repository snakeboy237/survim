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
                        def imageName = "ai-backend"
                        def gitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def buildDate = new Date().format("yyyyMMdd-HHmm")

                        echo "🚀 Building ${imageName}..."
                        docker.build("${imageName}:latest", '.')

                        echo "🏷️ Tagging..."
                        sh "docker tag ${imageName}:latest ${imageName}:${buildDate}-${gitSha}"
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
                    def rollbackImage = "ai-backend:rollback"

                    sh """
                    echo "🔄 Preparing backend rollback..."
                    if docker ps --filter "name=ai-backend" --format '{{.Names}}' | grep -w ai-backend; then
                        docker commit ai-backend ${rollbackImage}
                    fi

                    docker stop ai-backend || true
                    docker rm ai-backend || true

                    echo "🚀 Running new backend..."
                    docker run -d --name ai-backend -p 3000:3000 ai-backend:latest
                    """
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
                        def imageName = "ai-frontend"
                        def gitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def buildDate = new Date().format("yyyyMMdd-HHmm")

                        echo "🚀 Building ${imageName}..."
                        docker.build("${imageName}:latest", '.')

                        echo "🏷️ Tagging..."
                        sh "docker tag ${imageName}:latest ${imageName}:${buildDate}-${gitSha}"
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
                    try {
                        sh '''
                        docker tag ai-frontend:latest ai-frontend:previous || true
                        docker stop myfrontend || true
                        docker rm myfrontend || true
                        docker run -d --name myfrontend -p 8080:80 ai-frontend:latest
                        '''
                        echo "✅ Frontend deployed!"
                    } catch (err) {
                        echo "❌ Frontend failed — rolling back!"
                        sh '''
                        docker stop myfrontend || true
                        docker rm myfrontend || true
                        docker run -d --name myfrontend -p 8080:80 ai-frontend:previous
                        '''
                        error "Frontend deployment failed and rolled back."
                    }
                }
            }
        }

        // Deploy DB Changes
        stage('Deploy DB Changes') {
            when {
                changeset "**/web_app/db/*.sql"
            }
            steps {
                withCredentials([string(credentialsId: 'postgres-creds', variable: 'PGPASSWORD')]) {
                    script {
                        def dbHost = "mydb"
                        def dbUser = "postgres"
                        def dbName = "mydb"
                        def backupFile = "db-backup-$(date +%Y%m%d-%H%M%S).sql"

                        sh """
                        echo "📦 Taking DB backup..."
                        pg_dump -h ${dbHost} -U ${dbUser} -d ${dbName} -F c -f ${backupFile}

                        echo "⚙️ Applying create_tables.sql ..."
                        psql -h ${dbHost} -U ${dbUser} -d ${dbName} -f web_app/db/create_tables.sql

                        echo "⚙️ Applying views.sql ..."
                        psql -h ${dbHost} -U ${dbUser} -d ${dbName} -f web_app/db/views.sql

                        echo "⚙️ Applying create_stored_procedures.sql ..."
                        psql -h ${dbHost} -U ${dbUser} -d ${dbName} -f web_app/db/create_stored_procedures.sql

                        echo "✅ Verifying DB..."
                        psql -h ${dbHost} -U ${dbUser} -d ${dbName} -c "\\dt"
                        psql -h ${dbHost} -U ${dbUser} -d ${dbName} -c "SELECT * FROM images LIMIT 5;"
                        """
                    }
                }
            }
        }
    }
}
