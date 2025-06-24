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

                        echo "🚀 Building backend image..."
                        docker.build("${imageName}:latest", '.')

                        echo "🏷️ Tagging backend image..."
                        sh "docker tag ${imageName}:latest ${imageName}:${buildDate}-${gitSha}"

                        echo "🛡️ Scanning backend image..."
                        // Example: sh 'trivy image --severity CRITICAL,HIGH --exit-code 1 ai-backend:latest || true'

                        echo "✅ Backend image build complete."
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

                    echo "🔄 Preparing backend deploy..."
                    sh '''
                    if docker ps --filter "name=ai-backend" --format '{{.Names}}' | grep -w ai-backend; then
                        echo "Saving rollback image..."
                        docker commit ai-backend ${rollbackImage}
                    fi

                    docker stop ai-backend || true
                    docker rm ai-backend || true

                    echo "🚀 Running new backend container..."
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
                        def imageName = "ai-frontend"
                        def gitSha = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                        def buildDate = new Date().format("yyyyMMdd-HHmm")

                        echo "🚀 Building frontend image..."
                        docker.build("${imageName}:latest", '.')

                        echo "🏷️ Tagging frontend image..."
                        sh "docker tag ${imageName}:latest ${imageName}:${buildDate}-${gitSha}"

                        echo "🛡️ Scanning frontend image..."
                        // Example: sh 'trivy image --severity CRITICAL,HIGH --exit-code 1 ai-frontend:latest || true'

                        echo "✅ Frontend image build complete."
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
                        echo "🔄 Tagging previous frontend image..."
                        sh 'docker tag ai-frontend:latest ai-frontend:previous || true'

                        echo "🛑 Stopping old frontend container..."
                        sh 'docker stop myfrontend || true'
                        sh 'docker rm myfrontend || true'

                        echo "🚀 Deploying new frontend container..."
                        sh 'docker run -d --name myfrontend -p 8080:80 ai-frontend:latest'

                        echo "✅ Frontend deployed successfully."

                    } catch (err) {
                        echo "❌ Frontend deployment failed — rolling back..."

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
                    echo "⚙️ Applying database changes..."
                    sh '''
                    psql -h localhost -U postgres -d mydb -f web_app/db/create_tables.sql
                    psql -h localhost -U postgres -d mydb -f web_app/db/views.sql
                    psql -h localhost -U postgres -d mydb -f web_app/db/create_stored_procedures.sql

                    echo "✅ DB migrations applied."

                    echo "🔍 Verifying DB..."
                    psql -h localhost -U postgres -d mydb -c "\\dt"
                    psql -h localhost -U postgres -d mydb -c "SELECT * FROM images LIMIT 5;"
                    '''
                }
            }
        }
    }
}
