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

                    echo "hello world" >> /greeting.txt

                    which aws

                    git clone https://github.com/ruchira088/deployment-utils.git
                """
            }
        }

        stage("Apply Terraform") {
            container("ubuntu") {
                sh """
                    . deployment-utils/scripts/jenkinsfile/apply-terraform.sh

                    cat /greeting.txt
                    which terraform

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
                    which terraform
                    cat /greeting.txt
                    deployment-utils/scripts/jenkinsfile/run-tests.sh
                """
            }
        }

        stage("Push Docker image") {
            container("docker") {
                sh """
                    apk -v --update add bash

                    bash deployment-utils/scripts/jenkinsfile/push-docker-image.sh
                """
            }
        }
    }
}