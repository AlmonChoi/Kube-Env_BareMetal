ExpressCart docker image build pipeline

# Prepreation
- GitLab
- Docker Register & UI (optional)
- Jenkins
- Sonar-Qube
- Clair

## GitLab

### Preapre [.gitlab-ci.yml](./.gitlab-ci.yml) - GitLab CI/CD and save to the Git Repo root folder

### [Create Gitlab Runners] (https://docs.gitlab.com/ee/tutorials/create_register_first_runner/index.html#create-and-register-a-project-runner)
![Runner](../infra/_screen/gitlab_create_runners.jpg)

### Create Jenkins users
![jenkins users](../infra/_screen/gitlab_create_jenkins.jpg)

### Add Jenkins as project member
![Assign to group](../infra/_screen/gitlab_assign_jenkins.jpg)


## Sonar-Qube

### Insall and setup Sonar-Qube ()

### Create new Project
![Create project](../infra/_screen/sonarqube_create_project.jpg)

### Prepare ['sonar-project.properties'](./sonar-project.properties) and save to the Git Repo root folder

# Jenkins CI build docker image

- Prepare Jenkins build node
- Create multi-branch pipeline
- Run pipeline

# Automated Code Scan
Automated code scan upon Branch committed

