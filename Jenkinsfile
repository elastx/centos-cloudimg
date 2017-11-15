pipeline {
  agent {
    label 'qemu-kvm'
  }

  environment {
    CENTOS7_VERSION = sh(
      script: 'curl -s http://mirror.centos.org/centos/7/isos/x86_64/sha256sum.txt | sed -n "s/^.*\\(CentOS-7-x86_64-Minimal-[0-9]\\+\\)\\.iso.*$/\\1/p"',
      returnStdout: true
    ).trim()
  }

  stages {
    stage('Build images') {
      steps {
        sh "packer build -var centos7_image=${CENTOS7_VERSION} build-cloudimg.json"
      }
      post {
        success {
          archive 'build/*.qcow2c'
        }
      }
    }
  }

  post {
    always {
      dir("$WORKSPACE") {
        deleteDir()
      }
    }
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    timeout(time: 60, unit: 'MINUTES')
  }

}
