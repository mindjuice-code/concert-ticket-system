pipeline {
    agent any
    triggers {
        // Poll SCM as fallback if webhook fails
        pollSCM('H/1 * * * *')
    }

    
    environment {
        COMPOSE_PROJECT_NAME = 'concert-tickets'
       
        PATH = "C:\\Program Files\\Docker\\Docker\\resources\\bin;C:\\Windows\\System32;${env.PATH}"
        
        DB_HOST = 'db'
        DB_NAME = 'concert_tickets'
        DB_USER = 'root'
        DB_PASSWORD = 'rootpassword'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from repository...'
                checkout scm
            }
        }
        
        stage('Environment Check') {
            steps {
                echo 'Checking environment...'
                bat 'docker --version'
                bat 'docker compose version'
            }
        }
        
        stage('Stop Old Containers') {
            steps {
                echo 'Stopping and removing old containers...'
                bat '''
                    docker compose down -v || exit 0
                    docker rm -f concert_db concert_backend concert_frontend || exit 0
                '''
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building Docker images...'
                bat 'docker compose build --no-cache'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Starting services with Docker Compose...'
                bat 'docker compose up -d'
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Waiting for services to be ready...'
                sleep time: 15, unit: 'SECONDS'
                
                echo 'Checking backend health...'
                script {
                    def maxRetries = 5
                    def retryCount = 0
                    def healthy = false
                    
                    while (retryCount < maxRetries && !healthy) {
                        try {
                            bat 'curl -f http://localhost:8000/index.php/health'
                            healthy = true
                            echo 'Backend is healthy!'
                        } catch (Exception e) {
                            retryCount++
                            echo "Health check attempt ${retryCount} failed, retrying..."
                            sleep time: 5, unit: 'SECONDS'
                        }
                    }
                    
                    if (!healthy) {
                        error 'Backend health check failed after multiple attempts'
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying all services are running...'
                bat 'docker compose ps'
                echo 'Checking logs...'
                bat 'docker compose logs --tail=50'
            }
        }
    }
    
    post {
        success {
            echo '✅ Deployment successful!'
            echo 'Frontend: http://localhost:3000'
            echo 'Backend API: http://localhost:8000'
            echo 'Database: localhost:3307'
        }
        failure {
            echo '❌ Deployment failed!'
            bat 'docker compose logs'
            bat 'docker compose down'
        }
        always {
            echo 'Pipeline execution completed.'
        }
    }
}