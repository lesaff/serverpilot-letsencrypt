# serverpilot-letsencrypt
Bash script to generate and install Let's Encrypt certificate for your websites on your free ServerPilot account. Currently, the only easy way to add SSL to your ServerPilot-powered websites is by subscribing to the paid plan. 

## How to install
- Install Let's Encrypt, please follow [the official instructions here](https://letsencrypt.readthedocs.org/en/latest/using.html#installation)
- Copy `sple.sh` to your `/usr/local/bin` folder
- Run `sudo chmod +x /usr/local/bin/sple.sh`

## How to use
- Run `sple.sh` anywhere from your console as a root
- Follow the on-screen instructions

## Notes
- This script assumes that you did not change your default ServerPilot installation folder
- When entering your domain names, please list the primary root domain name first
- Copy and paste the `cronjob` code generated at the end of the process to schedule a monthly certificate renewal
- To force HTTPS on your website, please follow [instructions here](https://serverpilot.io/community/articles/how-to-force-SSL-by-redirecting-http-to-https.html)
