# Serverpilot Let's Encrypt [![Ubuntu 14.04](https://img.shields.io/badge/Ubuntu-14.04-brightgreen.svg)]() [![Ubuntu 16.04](https://img.shields.io/badge/Ubuntu-16.04-brightgreen.svg)]()[![Ubuntu 18.04](https://img.shields.io/badge/Ubuntu-18.04-brightgreen.svg)]()

Bash script to generate and install Let's Encrypt certificate for your websites on your free/paid ServerPilot account. Currently, the only easy way to add SSL to your ServerPilot-powered websites is by subscribing to the paid plan.

## How to install
- ssh to your server, `sudo su` to act as root
- Copy `sple.sh` to your `/usr/local/bin` folder
  ```
  cd /usr/local/bin && wget https://raw.githubusercontent.com/lesaff/serverpilot-letsencrypt/master/sple.sh
  ```
- Run `sudo chmod +x sple.sh` to make it executable

## How to use
- Run `sple.sh` anywhere from your console as root
- Follow the on-screen instructions

## Why `root`?
This script updates/create script in the `/etc/nginx-sp` that requires root access

## IF things go wrong
- Check `/var/log/letsencrypt` for detailed error messages
- ssh to your sp server as `root`  
  `cd /etc/nginx-sp/vhosts.d`  
- List all the `ssl` config files  
  `ls *ssl*`  
- Delete the `<appname>.ssl.conf` that is causing problem

Restart nginx
`sudo service nginx-sp restart`

## Schedule auto renewal
Add the following to your crontab (`crontab -e`)

**For Ubuntu 14.04**  
```
0 */12 * * * /usr/local/bin/certbot-auto renew --quiet --no-self-upgrade --post-hook "service nginx-sp reload"
```

**For Ubuntu 16.04**  
```
0 */12 * * * letsencrypt renew && service nginx-sp reload
```

**For Ubuntu 18.04**  
```
0 */12 * * * letsencrypt renew && service nginx-sp reload
```

## Notes
- This script assumes that you did not change your default ServerPilot installation folder
- When entering your domain names, please list the primary root domain name first
- To force HTTPS on your website, please follow [instructions here](https://serverpilot.io/community/articles/how-to-force-SSL-by-redirecting-http-to-https.html)
- To redirect www to non-www or non-www to www on your website, please follow [instructions here](https://serverpilot.io/community/articles/how-to-redirect-to-a-different-domain.html)
- Obey/observe the rate limits. [Read the full documentation](https://letsencrypt.org/docs/rate-limits/) on the Let's Encrypt website for more information.
