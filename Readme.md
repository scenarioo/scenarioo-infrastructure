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
ansible-playbook site.yml -i ./ansible/hosts_vagrant --key-file "./docker-ansible-runner/vagrant.key"
```

**Else use provided docker image:**
If you don't have Ansible installed you can use the dockerized version. Build docker image first:
```
docker build -t docker-ansible-runner docker-ansible-runner
```

Then execute: `./runAnsible.sh`

## CLI Usage

The CLI tool `infra.sh` is used to add new demos:
 - `./infra.sh deployDemo <branchName> <buildNumber> <triggeredBy> <pullrequestURL> <pullrequestNumber>`
    
## Config
Configuration is done in `config.json` and under `demos/<branch>.json`.
**config.json**
- `scenariooDocuFolder`: Where to store scenarioo docu for each branch
- `maxConcurrentDemos`: Limit the number of demos running in parallel (first in, first out)
- `maxBuildsPerDemo`: Limit the number of builds we keep for each demo
- `persistentBranches`: List of demo branches that will not be removed => used for master and develop

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
**Important:** The target host to be provisioned has to have Python 2.7 installed! Otherwise ansible will abort with a not so helpful SSH error.

Ansible relies on the following environment vars when executed:
- `TOMCAT_USER_PASSWORD`: Used to secure the publish scenarioo docu endpoint. Defaults to: 'scenarioo' and user is always 'scenarioo'.
- `CIRLCE_TOKEN`: Used to download WAR and scenarioo docu artifacts from CircleCI

**CircleCI:** Set these environment variables in the organsation context "scenarioo". 

### Directory paths
**Tomcat:**
- `/opt/tomcat/webapps` 
- `/opt/tomcat/logs` 
- `/opt/tomcat/conf` 
- `/opt/tomcat/bin`

**Nginx:**
- `/etc/nginx/sites-enabled` 

**Scenarioo:**
- `/scenarioo/overviewpage`
- `/scenarioo/data/<branchName>`