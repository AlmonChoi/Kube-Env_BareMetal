# ExpressCart docker image build pipeline

## Prepreation
- [GitLab](../infra/GitLab)
- [Sonar-Qube](../infra/sonarqube)
- [Jenkins](../infra/jenkins)
- [Docker Register & UI](../infra/Repo)


## GitLab

- Preapre [.gitlab-ci.yml](./.gitlab-ci.yml) - GitLab CI/CD and save to the Git Repo root folder

- Prepare [`sonar-project.properties`](./sonar-project.properties) and save to the Git Repo root folder

- Prepare [`Jenkinsfile`](./Jenkinsfile) and save to the Git Repo root folder

- [Create Gitlab Runners](https://docs.gitlab.com/ee/tutorials/create_register_first_runner/index.html#create-and-register-a-project-runner)
![Runner](../screen/gitlab_create_runners.jpg)

- Create Jenkins users
![jenkins users](../screen/gitlab_create_jenkins.jpg)

- Add Jenkins as project member
![Assign to group](../screen/gitlab_assign_jenkins.jpg)


## Sonar-Qube

- Create new Project
![Create project](../screen/sonarqube_create_project.jpg)

- Scan Result (scan is automatically performed by GitLab CI/CD Runner when there is project committed)
![Scan Overall](../screen/sonarqube_scan_overall.jpg)

- Open and see result details
![Scan Details](../screen/sonarqube_scan_detailsl.jpg)


## Jenkins 

- Prepare Jenkins build node
![Jenkins node](../screen/jenkins_create_node-1.jpg)

- Start and connect to Jenkins server
![Jenkins node](../screen/jenkins_create_node-2.jpg)

- Create credentials for connect to GitLab
![Jenkins user](../screen/jenkins_create_user.jpg)

- Create multi-branch pipeline
![Jenkins pipeline](../screen/jenkins_create_pipeline.jpg)

- Run pipeline
![Run pipeline](../screen/jenkins_run_pipeline-1.jpg)

![Run pipeline](../screen/jenkins_run_pipeline-2.jpg)

![Run pipeline](../screen/jenkins_run_pipeline-3.jpg)

![Run pipeline](../screen/jenkins_run_pipeline-4.jpg)


## Docker Register
![Docker](../screen/docker_image_repo.jpg)


