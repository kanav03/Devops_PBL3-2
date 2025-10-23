pipeline {
  agent any
  environment {
    DOCKER_IMAGE = "kanav2003/flask-app"
  }
  stages {
    stage('Build Docker') {
      steps {
        sh 'docker build -t $DOCKER_IMAGE:${BUILD_NUMBER} .'
      }
    }
    stage('Push Docker') {
      steps {
        withCredentials([usernamePassword(credentialsId: "dockerhub-creds", usernameVariable: "DOCKER_USER", passwordVariable: "DOCKER_PASS")]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker push $DOCKER_IMAGE:${BUILD_Number}'
        }
      }
    }
    stage('Deploy Green') {
      steps {
        withCredentials([file(credentialsId: "kubeconfig", variable: "KUBECONFIG_FILE")]) {
          sh 'export KUBECONFIG=$KUBECONFIG_FILE'
          sh "sed 's|REPLACE_IMAGE|$DOCKER_IMAGE:${BUILD_NUMBER}|' deployment-green.yaml | kubectl apply -f -"
        }
      }
    }
    stage('Switch Traffic') {
      steps {
        withCredentials([file(credentialsId: "kubeconfig", variable: "KUBECONFIG_FILE")]) {
          sh 'export KUBECONFIG=$KUBECONFIG_FILE'
          sh "kubectl patch service flask-service -p '{\"spec\":{\"selector\":{\"app\":\"flask\",\"version\":\"green\"}}}'"
        }
      }
    }
    stage('Cleanup Blue') {
      steps {
        withCredentials([file(credentialsId: "kubeconfig", variable: "KUBECONFIG_FILE")]) {
          sh 'export KUBECONFIG=$KUBECONFIG_FILE'
          sh 'kubectl delete deployment flask-blue --ignore-not-found=true'
        }
      }
    }
  }
}