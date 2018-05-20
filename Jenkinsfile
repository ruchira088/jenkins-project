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

                    git clone https://github.com/ruchira088/deployment-utils.git
                """
            }
        }

        stage("Apply Terraform") {
            container("ubuntu") {
                sh """
                    apt-get update && apt-get install jq -y

                    export PROJECT_ROOT=`pwd`

                    # This is a comment
                    . deployment-utils/scripts/jenkinsfile/apply-terraform.sh

                    cd dev-ops/terraform
                    sed -i "s/BACKEND_KEY/`echo $JOB_NAME | tr / -`/g" resources.tf

                    \$terraform init
                    \$terraform apply -auto-approve \
                        -var docker_repository_name=$JOB_NAME

                    \$terraform show
                    DOCKER_REPOSITORY_URL=`\$terraform output -json | jq .dockerRepositoryUrl.value`

                    echo \$DOCKER_REPOSITORY_URL >> docker-repository-url.txt

                    cd \$PROJECT_ROOT
                """
            }
        }

        stage("Running tests with coverage") {

            container("docker") {
                sh """
                    # DOCKER_IMAGE_TAG=$JOB_NAME-$BUILD_NUMBER

                    # docker build -t \$DOCKER_IMAGE_TAG -f dev-ops/Dockerfile .

                    # docker run \$DOCKER_IMAGE_TAG test
                """
            }
        }

        stage("Push Docker image") {

            container("docker") {
                sh """
                    apk -v --update add bash && bash

                    . deployment-utils/scripts/jenkinsfile/push-docker-image.sh
                """
            }
        }
    }
}