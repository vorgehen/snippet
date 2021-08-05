# snippet

## machine (amazon ec2)
1. Choose AMI: Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-09e67e426f25ce0d7 (64-Bit x86) / ami-00d1ab6b335f217cf (64-Bit Arm)
2. Instance Type: t2.large
3. Configue instance: default
4. Memory: default (8GiB)
5. Tags: no
7. security Group: new launch-wizard-2
8. New Key Pair "snippet"
9. Add TCP all Ports to security group
10. 10 Enable DNS hostnames for VPC (some proxies do not allow Ip's?) 

## software
Connect to server with user ubuntu

### git
apt-get update
sudo apt install git-all

### docker
see: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04-de
1. sudo apt install apt-transport-https ca-certificates curl software-properties-common
2. curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
3. sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
4. sudo apt update
5. apt-cache policy docker-ce
6. sudo apt install docker-ce
7. sudo systemctl status docker

### docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

## opencpu image
1. git clone https://github.com/vorgehen/snippet.git
2. cd snippet
3. sudo docker-compose up --build (up to 30 min to build)

## basic docker
- sudo docker container ls 
- sudo docker exec -it ce4d29f10666 /bin/bash 


## workarounds
- cannot connect to Rstudio 
  - cd ~
  - sudo chown -R opencpu opencpu 
