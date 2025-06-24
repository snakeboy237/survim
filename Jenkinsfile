pipeline {
    agent any

    environment {
        DOCKER_BUILDKIT = '1'
        SONARQUBE_ENV = 'MySonarQube'   // 👈 Jenkins SonarQube server name
        ENABLE_SELENIUM_UI_TESTS = 'true'
        SELENIUM_TEST_IMAGE = 'selenium-test-image' // example name
    }

    stages {

        stage('Clone Repo') {
            steps {
                echo "📥 Checking out branch: ${env.BRANCH_NAME}"
                git branch: "${env.BRANCH_NAME}", url: 'https://github.com/snakeboy237/survim'
            }
        }

        stage('Static Code Analysis - SonarQube') {
            when {
                branch 'main'
            }
            steps {
                echo "🔍 Running SonarQube analysis..."
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    sh 'sonar-scanner'
                }
            }
        }

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

        stage('Deploy Backend') {
            when {
                allOf {
                    changeset "**/web_app/backend-api/**"
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
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

        stage('Deploy Frontend') {
            when {
                allOf {
                    changeset "**/web_app/frontend/**"
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
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

        stage('Run Selenium UI Tests') {
            when {
                allOf {
                    anyOf {
                        changeset "**/web_app/frontend/**"
                        changeset "**/web_app/selenium-tests/**"
                    }
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                    expression {
                        return env.ENABLE_SELENIUM_UI_TESTS == 'true'
                    }
                }
            }
            steps {
                script {
                    echo "🚀 Running Selenium UI tests ..."
                    sh '''
                    docker run --rm \
                        --network="host" \
                        -v $WORKSPACE/web_app/selenium-tests:/tests \
                        $SELENIUM_TEST_IMAGE pytest --html=report.html
                    '''
                }
            }
            post {
                always {
                    echo "📄 Publishing Selenium test report ..."
                    publishHTML(target: [
                        reportDir: '.',
                        reportFiles: 'report.html',
                        reportName: 'Selenium UI Test Report'
                    ])
                }
            }
        }

        stage('Deploy DB Changes') {
            when {
                allOf {
                    changeset "**/web_app/db/*.sql"
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
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
                            sh """
                            echo "⚙️ Applying DB migrations ..."
                            PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/create_tables.sql
                            PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/views.sql
                            PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -f web_app/db/create_stored_procedures.sql
                            """

                            echo "✅ Verifying DB deploy ..."
                            sh """
                            PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -c "\\dt"
                            PGPASSWORD=$DB_PASS psql -h localhost -U $DB_USER -d mydb -c "SELECT * FROM images LIMIT 5;"
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

    post {
        always {
            echo "✅ Pipeline completed for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Pipeline FAILED for branch: ${env.BRANCH_NAME}"
        }
    }
}
