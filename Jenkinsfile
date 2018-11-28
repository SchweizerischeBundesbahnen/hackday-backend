#!groovy

pipeline {
    agent { label 'java' }
    tools {
        maven 'Apache Maven 3.3'
        jdk 'OpenJDK 1.8 64-Bit'
    }
    stages {
        stage("Build Go Project") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'bin.sbb.ch', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASS')]) {
                    sh './ci-build.sh'
                }
            }
        }
        stage("Build Image for Feature") {
            when {
                not { anyOf { branch 'master'; tag '*' } }
            }
            steps {
                script {
                    if (!env.BRANCH_NAME.startsWith('PR')) {
                        def dockerTag = GetDockerTag();
                        cloud_buildDockerImage(artifactoryProject: "blockchain",
                                ocApp: 'hackday-backend',
                                ocAppVersion: dockerTag,
                                dockerDir: ".")
                    }
                }
            }
        }
        stage("Build Image for Master") {
            when {
                branch 'master'
            }
            steps {
                script {
                    if (!env.BRANCH_NAME.startsWith('PR')) {
                        cloud_buildDockerImage(artifactoryProject: "blockchain",
                            ocApp: 'hackday-backend',
                            ocAppVersion: 'latest',
                            dockerDir: ".")
                    }
                }
            }
        }
        stage("Build Image for Tag") {
            when {
                tag '*'
            }
            steps {
                script {
                    if (!env.BRANCH_NAME.startsWith('PR')) {
                        def tagName = "${env.TAG_NAME}";
                        cloud_buildDockerImage(artifactoryProject: "blockchain",
                            ocApp: 'hackday-backend',
                            ocAppVersion: tagName,
                            dockerDir: ".")
                    }
                }
            }
        }
    }
}

def GetDockerTag() {
    return env.BRANCH_NAME.replaceAll('/','_')
}
