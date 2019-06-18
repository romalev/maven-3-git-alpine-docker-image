# maven-git-3-alpine-docker-image
Docker image that might be used by CI/CD servers to execute the release of project artifacts [by maven-release-plugin].  

*Motivation*
-
DevOps is a popular field nowadays where engineers spending lots of time automating\enhancing continuous delivery process. Many CI/CD servers have 
built-in capabilities to develop CD pipelines. For instance <b>Jenkins</b> has a concept of _Pipeline as code_ or defining the deployment pipeline through code 
rather than configuring a running CI/CD tool, provides tremendous benefits for teams automating infrastructure across their environments.      

[<b>Docker</b>](https://www.docker.com/) is very handy tool these days. CI/CD servers might spin up actual docker containers where CI/CD jobs take place.

Say you were given to design\implement CD pipeline for JVM based projects. Maven is a super popular build/automation tool - so why not to take advantage out of it ? 
There is the [maven-release-plugin](https://maven.apache.org/maven-release/maven-release-plugin/) allowing you to release project with maven, saving a lot of repetitive, manual work.

So you want to: 
* utilize _maven-release-plugin_ 
* and run release job by Jenkins agent 
* where the entire pipeline, or a specific stage, will get executed within docker container. 
* how ? 

*How*
-
There's already available docker image ```maven:3-alpine``` that you might use ... but it does NOT have <b>git</b> installed which is required 
by _maven-release-plugin_. 
In order to let _maven-release-plugin_ push changes to your Git server you have to connect your docker container runtime with Git server. This can be done via [SSH](https://help.github.com/en/articles/connecting-to-github-with-ssh):
* deploy your public key to GIT server.
* normally private key will be available under ```~/.ssh/id_rsa```
* build docker image ```docker build -t maven-git:3-alpine -f Dockerfile .```. Make sure private key was added to ```/root/.ssh/id_rsa``` 

Now your newly built docker image is ready to release projects via _maven-release-plugin_. 
Appropriate Jenkins Pipeline might look like :

```
pipeline {
    agent {
        docker {
            image 'maven-git:3-alpine'
            args '-v /root/.m2:/root/.m2 --network=host'
        }
    }
    
    parameters {
        string defaultValue: '', description: 'Release Version.', name: 'releaseVersion', trim: true
        string defaultValue: '', description: 'Next Devevelopment Version.', name: 'developmentVersion', trim: true
    }
    stages {
        stage('Checkout') {
            steps {
               checkout([$class: 'GitSCM', 
						branches: [[name: 'origin/master']], 
						doGenerateSubmoduleConfigurations: false,  extensions: [[$class: 'LocalBranch', localBranch: 'master']], 
						submoduleCfg: [], 
						userRemoteConfigs: [[credentialsId: 'yourCredsId', url: 'https://github.com/[username]/[project]']]])
            }
        }
        stage('Release') {
            steps {
                sh 'mvn release:clean release:prepare release:perform -DreleaseVersion=${releaseVersion} -DdevelopmentVersion=${developmentVersion}'
            }
        }
    }
}

```

Voilà! 

