def podLabel = "jenkins-pod-${UUID.randomUUID().toString()}"

podTemplate(
    label: podLabel,
    containers: [
        containerTemplate(
            name: "docker",
            image: "docker",
            ttyEnabled: true
        ),
        containerTemplate(
            name: "nodejs",
            image: "node",
            ttyEnabled: true
        ),
        containerTemplate(
            name: "ubuntu",
            image: "ubuntu",
            ttyEnabled: true
        ),
        containerTemplate(
            name: "java",
            image: "openjdk:8-jdk",
            ttyEnabled: true
        )
    ],
    volumes: [
        hostPathVolume(
            hostPath: "/var/run/docker.sock",
            mountPath: "/var/run/docker.sock"
        )
    ]
) {
    node(podLabel) {

        stage("Checkout source code") {
            checkout scm
        }

        stage("Fetching deployment utilities") {
            container("ubuntu") {
                sh """
                    apt-get update && apt-get install git -y

                    echo "hello world1" >> greeting1.txt
                    echo "hello world2" >> ../greeting2.txt
                    echo "hello world3" >> ../../greeting3.txt
                    echo "hello world4" >> ../../../greeting4.txt
                    echo "hello world5" >> ../../../../greeting4.txt

                    ls -a /
                    ls -a
                    ls -a ../
                    ls -a ../../
                    ls -a ../../../
                    ls -a ../../../../

                    git clone https://github.com/ruchira088/deployment-utils.git
                """
            }
        }

        stage("Apply Terraform") {
            container("ubuntu") {
                sh """
                    . deployment-utils/scripts/jenkinsfile/apply-terraform.sh

                    cat /greeting.txt

                   ls -a /
                                       ls -a
                                       ls -a ../
                                       ls -a ../../
                                       ls -a ../../../
                                       ls -a ../../../../

                    beforeApply

                    \$terraform apply -auto-approve \
                        -var docker_repository_name=$JOB_NAME

                    afterApply
                """
            }
        }

        stage("Running tests with coverage") {
            container("java") {
                sh """
                    ls -a /
                                        ls -a
                                        ls -a ../
                                        ls -a ../../
                                        ls -a ../../../
                                        ls -a ../../../../


                    deployment-utils/scripts/jenkinsfile/run-tests.sh
                """
            }
        }

        stage("Push Docker image") {
            container("docker") {
                sh """
                ls -a /
                                    ls -a
                                    ls -a ../
                                    ls -a ../../
                                    ls -a ../../../
                                    ls -a ../../../../

                    apk -v --update add bash

                    bash deployment-utils/scripts/jenkinsfile/push-docker-image.sh
                """
            }
        }
    }
}