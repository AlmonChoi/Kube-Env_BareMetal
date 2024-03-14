ExpressCart docker image build pipeline

# Prepreation
- GitLab
- Docker Register & UI (optional)
- Jenkins
- Sonar-Qube
- Clair

# Automated Code Scan
Automated code scan upon Branch committed

- [Create and Configured Gitlab Runners] (https://docs.gitlab.com/ee/tutorials/create_register_first_runner/index.html#create-and-register-a-project-runner)
- Preapre '.gitlab-ci.yml' - GitLab CI/CD and save to the Git Repo root folder
- Insall and setup Sonar-Qube ()
- Create new Project in Sonar-Qube
- Prepare 'sonar-project.properties' and save to the Git Repo root folder

# Jenkins CI build docker image

- Prepare Jenkins build node
- Create multi-branch pipeline
- Run pipeline

