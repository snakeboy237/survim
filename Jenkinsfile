pipeline {
    agent any

    stages {
        stage('Clone my Repo') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/snakeboy237/survim'
            }
        }

        stage('Build Backend Image') {
            when {
                changeset "**/web_app/backend-api/**"
            }
            steps {
                dir('web_app/backend-api') {
                    script {
                        sh 'docker build -t ai-backend:latest .'
                    }
                }
            }
        }

        stage('Build & Deploy Frontend') {
    when {
        changeset "**/frontend/**"
    }
    steps {
        dir('web_app/frontend') {
            script {
                // Build the image using Dockerfile in this folder
                docker.build('ai-frontend:latest', '.')

                // Stop old container if exists
                sh 'docker rm -f myfrontend || true'

                // Run new container
              //  sh 'docker run -d --name myfrontend -p 8080:80 ai-frontend:latest'
            }
        }
    }
}


        stage('Run DB Migrations') {
            when {
                changeset "**/web_app/db/**"
            }
            steps {
                dir('web_app/db') {
                    script {
                        sh 'psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f create_tables.sql'
                        sh 'psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f views.sql'
                        sh 'psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f create_stored_procedures.sql'
                    }
                }
            }
        }
    }
}
