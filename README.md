# serverpilot-letsencrypt
Bash script to generate and install Let's Encrypt certificate for your websites on your free/paid ServerPilot account. Currently, the only easy way to add SSL to your ServerPilot-powered websites is by subscribing to the paid plan. 

## Notes
I am currently working on an updated version of this script. Still testing. If you would like to try it, it's in the [certbot branch](https://github.com/lesaff/serverpilot-letsencrypt/tree/certbot) 
The new version will support the updated certbot script and also support Ubuntu 14.04 and 16.04.

## How to install
- ssh to your server, `sudo su` to act as root
- Copy `sple.sh` to your `/usr/local/bin` folder
- Run `sudo chmod +x /usr/local/bin/sple.sh` to make it executable

## How to use
- Run `sple.sh` anywhere from your console as root
- Follow the on-screen instructions

## Why `root`?
This script updates/create script in the `/etc/nginx-sp` that requires root access

## IF things go wrong
ssh to your sp server as `root`  
`cd /etc/nginx-sp/vhosts.d`  
List all the `ssl` config files  
`ls *ssl*`  
Delete the `<appname>.ssl.conf` that is causing problem

Restart nginx
`sudo service nginx-sp restart`

## Notes
- This script assumes that you did not change your default ServerPilot installation folder
- When entering your domain names, please list the primary root domain name first
- This script adds cron job to schedule automatic renewal every two months at 1am
- To force HTTPS on your website, please follow [instructions here](https://serverpilot.io/community/articles/how-to-force-SSL-by-redirecting-http-to-https.html)
- Apparently it is not compatible with Ubuntu 16.04 (per [#5](https://github.com/lesaff/serverpilot-letsencrypt/issues/5)) but I have not tested it myself
