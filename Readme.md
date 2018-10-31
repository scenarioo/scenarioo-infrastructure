# Infrastructure of scenarioo

We use ansible to setup our main server which runs:
- Tomcat for the demos
- Ngnix as a proxy
- Overview of all demos: http://demo.scenarioo.org/overview

## Development

To test and run this ansible playbook locally you need to install:
- Vagrant >= 1.8
- Ansible >= 2.5 installed or Docker

**Ansible installed:** 
```
ansible-galaxy install -r requirements.yml
export ENVIRONMENT=dev
ansible-playbook site.yml -i ./hosts/hosts_vagrant --key-file "./docker-ansible-runner/vagrant.key"
```

**Else use provided docker image:**
If you don't have Ansible installed you can use the dockerized version. Build docker image first:
```
docker build -t docker-ansible-runner docker-ansible-runner
```

Then execute: `./infra.sh runAnsible vagrant`

## CLI Usage

The CLI tool `infra.sh` is used to manage demos and run ansible:
 - `./infra.sh deployDemo <branchName> <buildNumber> <triggeredBy> <pullrequestURL> <pullrequestNumber>`
 - `./infra.sh undeployDemo <branchName>`
 - `./infra.sh runAnsible <vagrant|aws> <pathToAlternativeSSHKey>`
 - `./infra.sh updateOverview`
 - `./infra.sh cleanupDemos`
 
### Tests

There are some tests that ensure the generated branch config JSONs are correct, for more info look at [tests/Readme.md](tests/Readme.md)
    
## Config
Configuration is done in `config.json` and under `demos/<branch>.json`.

**config.json**
- `defaultScenariooBranch`: Branch we redirect to by default on demo.scenarioo.org
- `demoConfigFolder`: Where are the config files for demos (useful to change for testing)
- `maxBuildsPerDemo`: Limit the number of builds we keep for each demo
- `maxConcurrentDemos`: Limit the number of demos running in parallel (first in, first out)
- `persistentBranches`: List of demo branches that will not be removed => used for master and develop
- `scenariooDocuFolder`: Where to store scenarioo docu for each branch
- `scenariooHost`: Usually demo.scenarioo.org, can be changed for testing
- `tomcatFolder`: Tomcat base folder

**demos/<branch>.json:** For each demo branch
```
{
  "branchName": "feature-755-investigate-building-docker-image",
  "timestamp": "1540117349",
  "buildNumber": "117",
  "triggeredBy": "cgrossde",
  "pullRequestUrl": "https://github.com/scenarioo/scenarioo/pull/773",
  "pullRequestNumber": "773",
  "buildUrl": "https://circleci.com/gh/scenarioo/scenarioo/117",
  "warArtifact": "https://117-10269178-gh.circle-artifacts.com/0/scenarioo.war",
  "warArtifactSha256": "ad5ca926cc3bc8213635643f549ded7c393bc53630ea58f1cb3387e5c3418932",
  "docuArtifacts": [
    {
      "url": "https://116-10269178-gh.circle-artifacts.com/0/e2eScenariooDocu.zip",
      "sha256": "b049f4e39ea841bbe92452f026f0fb7100de19a671b298d12dd716d2354b79b3",
      "build": "116"
    }
  ]
}
```


## Ansible

Ansible relies on the following environment vars when executed:
- `TOMCAT_USER_PASSWORD`: Used to secure the publish scenarioo docu endpoint. Defaults to: 'scenarioo' and user is always 'scenarioo'.
- `CIRLCE_TOKEN`: Used to download WAR and scenarioo docu artifacts from CircleCI
- `CONFIG_FILE`: Optional. Allows to pass in a different config for testing. Defaults to `config.json`

**CircleCI:** Set these environment variables in the organsation context "scenarioo"
 * https://circleci.com/gh/organizations/scenarioo/settings#contexts
 * Create `CIRCLE_TOKEN` here: https://circleci.com/gh/scenarioo/scenarioo/edit#api 

### Directory paths
**Tomcat:**
- `/var/lib/tomcat8/webapps` 
- `/var/lib/tomcat8/logs` 
- `/var/lib/tomcat8/conf` 
- `/usr/share/tomcat8/bin`

**Nginx:**
- `/etc/nginx/sites-enabled` 

**Scenarioo:**
- `/scenarioo/overviewpage`
- `/scenarioo/data/<branchName>`


### Memory calculations

To get the most out of the box without running into Java OutOfMemoryExceptions we need to keep an eye on memory:

- System: 1GB
- Elasticsearch: 0.8GB  (500MB Java + docker overhead)  see `roles/docker/tasks/main.yml`
- Tomcat: 6GB (1GB per demo is a good measure)  see `roles/tomcat/files/setenv.sh`