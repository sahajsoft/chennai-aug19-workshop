persistence:
  existingClaim: ${pvcClaimName}

controller:
  adminUsername: admin
  adminPassword: admin

  additionalPlugins:
  - job-dsl:1.77
  - permissive-script-security:0.6
  - docker-workflow:563.vd5d2e5c4007f

  javaOpts: '-Dpermissive-script-security.enabled=true'

  JCasC:
    defaultConfig: true
    configScripts:
      welcome-message: |
        jenkins:
          systemMessage: Welcome to Kube-Jenkins!
      job-config: |
        jobs:
          - script: >
              folder('testjobs')
          - script: >
              pipelineJob('testjobs/default-agent') {
                definition {
                  cps {
                    script("""\
                      pipeline {
                        agent {
                          kubernetes {
                            label 'dind'
                            defaultContainer 'docker'
                            yaml '''
                              apiVersion: v1
                              kind: Pod
                              metadata:
                                labels:
                                  app: jenkins
                              spec:
                                serviceAccountName: jenkins
                                containers:
                                  - name: docker
                                    image: docker:latest
                                    command:
                                      - /bin/cat
                                    tty: true
                                    volumeMounts:
                                      - name: dind-certs
                                        mountPath: /certs
                                    env:
                                      - name: DOCKER_TLS_CERTDIR
                                        value: /certs
                                      - name: DOCKER_CERT_PATH
                                        value: /certs
                                      - name: DOCKER_TLS_VERIFY
                                        value: 1
                                      - name: DOCKER_HOST
                                        value: tcp://localhost:2376
                                  - name: dind
                                    image: docker:dind
                                    securityContext:
                                      privileged: true
                                    env:
                                      - name: DOCKER_TLS_CERTDIR
                                        value: /certs
                                    volumeMounts:
                                      - name: dind-storage
                                        mountPath: /var/lib/docker
                                      - name: dind-certs
                                        mountPath: /certs/client
                                  - name: kubectl
                                    image: busybox
                                    command:
                                      - sleep
                                      - "3600"
                                volumes:
                                  - name: dind-storage
                                    emptyDir: {}
                                  - name: dind-certs
                                    emptyDir: {}
                              '''
                          }
                        }
                        environment {
                          dockerimagename = "chennai-workshop/react-app"
                          dockerImage = ""
                        }
                        stages {
                          stage ('test') {
                            steps {
                              echo "hello"
                            }
                          }
                          stage('Verify docker works') {
                            steps {
                              sh 'docker version'
                            }
                          }
                          stage ('Checkout Source') {
                            steps {
                              git branch: 'main', url: 'https://github.com/Bravinsimiyu/jenkins-kubernetes-deployment.git'
                            }
                          }
                          stage ('Build image') {
                            steps {
                              script {
                                dockerImage = docker.build dockerimagename
                              }
                            }
                          }
                          stage('Deploying App to Kubernetes') {
                            steps {
                              container('kubectl') {
                                withKubeConfig([namespace: "dlokesh"]) {
                                  sh 'wget "https://storage.googleapis.com/kubernetes-release/release/v1.27.4/bin/linux/arm64/kubectl"'
                                  sh 'chmod u+x ./kubectl'
                                  sh './kubectl version'
                                  sh './kubectl get pods'
                                  sh './kubectl -n dlokesh apply -f deployment.yaml'
                                }
                              }
                            }
                          }
                        }
                      }""".stripIndent())
                    sandbox()
                  }
                }
              }

  # LOCAL ONLY:
  serviceType: NodePort