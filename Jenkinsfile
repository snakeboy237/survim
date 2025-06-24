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
        script {
            def timestamp = sh(script: "date +%Y%m%d-%H%M%S", returnStdout: true).trim()
            def backupFile = "db-backup-${timestamp}.sql"

            withCredentials([usernamePassword(credentialsId: 'postgres-creds', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS')]) {

                echo "🔄 Backing up current DB to ${backupFile} ..."
                sh """
                PGPASSWORD=$DB_PASS pg_dump -h localhost -U $DB_USER -d mydb -f ${backupFile}
                """

                try {
                    // Apply DB migrations
                    sh """
                    echo "⚙️ Applying create_tables.sql ..."
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/create_tables.sql

                    echo "⚙️ Applying views.sql ..."
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/views.sql

                    echo "⚙️ Applying create_stored_procedures.sql ..."
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/create_stored_procedures.sql
                    """

                    // Simple test
                    sh """
                    echo "✅ Verifying DB deploy ..."
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -c "\\dt"
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -c "SELECT * FROM images LIMIT 5;"
                    echo "✅ DB deploy verification completed."
                    """

                } catch (err) {
                    echo "❌ DB deploy failed — rolling back from ${backupFile} ..."
                    sh """
                    PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f ${backupFile}
                    """
                    error "DB deploy failed and rolled back."
                }
            }
        }
    }
}
}
}
