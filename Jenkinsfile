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
                    export PROJECT_ROOT=`pwd`

                    . deployment-utils/scripts/jenkinsfile/apply-terraform.sh

                    echo \$terraform
                    ls Software
                    pwd

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

        stage("Running tests (with coverage ?)") {

            container("docker") {
                sh """
                    DOCKER_IMAGE_TAG=$JOB_NAME-$BUILD_NUMBER

                    docker build -t \$DOCKER_IMAGE_TAG -f dev-ops/Dockerfile .

                    docker run \$DOCKER_IMAGE_TAG test
                """
            }
        }

        stage("Build Docker image") {

            container("docker") {
                sh """
                    apk -v --update add python py-pip git && \
                    pip install awscli --upgrade --user && \
                    ln -sf $HOME/.local/bin/aws /usr/local/bin

                    aws ecr get-login --no-include-email --region ap-southeast-2 | sh

                    DOCKER_REPOSITORY_URL=`cat dev-ops/terraform/docker-repository-url.txt`
                    GIT_COMMIT=`git rev-parse HEAD | cut -c1-8`

                    echo "DOCKER_REPOSITORY_URL = \$DOCKER_REPOSITORY_URL"

                    DOCKER_IMAGE_TAG=$JOB_NAME-$BUILD_NUMBER
                    docker build -t \$DOCKER_IMAGE_TAG -f dev-ops/Dockerfile .

                    docker tag \$DOCKER_IMAGE_TAG:latest `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:build-number-$BUILD_NUMBER
                    docker push `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:build-number-$BUILD_NUMBER

                    docker tag \$DOCKER_IMAGE_TAG:latest `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:\$GIT_COMMIT
                    docker push `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:\$GIT_COMMIT

                    docker tag \$DOCKER_IMAGE_TAG:latest `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:latest
                    docker push `echo \$DOCKER_REPOSITORY_URL | tr -d '"'`:latest

                    docker images
                """
            }
        }
    }
}