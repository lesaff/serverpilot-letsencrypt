#!/bin/bash
# Bash script to create/add Let's Encrypt SSL to ServerPilot app
# by Rudy Affandi (2016)
# Edited Aug 14, 2016

# Todo
# 1. Generate certificate
# /usr/local/bin/certbot-auto certonly --webroot -w /srv/users/$username/apps/appname/public -d appdomain.tld
# 2. Generate appname.ssl.conf file
# 3. Restart nginx
# sudo service nginx-sp restart
# 4. Confirm that it's done and show how to do auto-renew via CRON

# Settings
ubuntu=$(lsb_release -r -s)
certbotfolder=/usr/local/bin/certbot-auto
appfolder=/srv/users/$username/apps
conffolder=/etc/nginx-sp/vhosts.d
acmeconfigfolder=/etc/nginx-sp/letsencrypt.d
acmeconfigfile="$acmeconfigfolder/letsencrypt-acme-challenge.conf"

# Make sure this script is run as root
if [ "$EUID" -ne 0 ]
then 
    echo ""
	echo "Please run this script as root."
	exit
fi

# Check for Ubuntu version
# 14.04 Trusty Tahr
if [ $ubuntu == '14.04' ]
then

    # Check for Let's Encrypt installation
    if [ ! -f "$certbotfolder" ]
    then
        echo "Let's Encrypt is not installed/found in your root folder. Would you like to install it?"
        read -p "Y or N " -n 1 -r
        echo ""
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
            cd /root && sudo wget https://dl.eff.org/certbot-auto
            chmod a+x certbot-auto
            mv certbot-auto /usr/local/bin/
        else
            exit
        fi
    fi
fi

# 16.04 Xenial Xerus
if [ $ubuntu == '16.04' ]
then

    le=$(dpkg-query -W -f='${Status}' letsencrypt 2>/dev/null | grep -c "ok installed")
    
    if [ $le == 0 ]
    then
        echo "Let's Encrypt is not installed/found. Would you like to continue to install it?"
        read -p "Y or N" -n 1 -r
        echo ""
        if [[ "$REPLY" =~ ^[Yy]$ ]]
        then
            sudo apt-get update
            sudo apt-get install letsencrypt -y
        fi 
    fi
fi

echo ""
echo ""
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo ""
echo "  Let's Encrypt SSL Certificate Generator"
echo "  For ServerPilot-managed server instances"
echo ""
echo "  Written by Rudy Affandi (2016)"
echo "  https://github.com/lesaff/"
echo ""
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo ""
echo ""
echo "Please enter your app name:"
read appname
echo ""
echo "Please enter the System User name for the app:"
read username
echo ""
echo "Please enter all the domain names and sub-domain names"
echo "you would like to use, separated by space"
read domains

# Assign domain names to array
APPDOMAINS=()
for domain in $domains; do
   APPDOMAINS+=("$domain")
done

# Assign domain list to array
APPDOMAINLIST=()
for domain in $domains; do
   APPDOMAINLIST+=("-d $domain")
done

# Generate certificate
echo ""
echo ""
echo "Generating SSL certificate for $appname"
echo ""

# Check for Ubuntu version
# 14.04 Trusty Tahr
if [ $ubuntu == '14.04' ]
then
    /usr/local/bin/certbot-auto certonly --webroot -w /srv/users/$username/apps/$appname/public ${APPDOMAINLIST[@]}
fi

# 16.04 Xenial Xerus
if [ $ubuntu == '16.04' ]
then
    letsencrypt certonly --webroot -w /srv/users/$username/apps/$appname/public ${APPDOMAINLIST[@]}
fi

# Check the ACME configuration file for Nginx
if [ ! -f "$acmeconfigfile" ] 
then
    echo ""
    echo ""
    echo "Creating configuration file $acmeconfigfile for ACME"
    
    mkdir $acmeconfigfolder
    touch $acmeconfigfile
    
    echo "location ~ /\.well-known\/acme-challenge {" | sudo tee $acmeconfigfile
    echo "    allow all;" | sudo tee -a $acmeconfigfile
    echo "}" | sudo tee -a $acmeconfigfile
    echo "" | sudo tee -a $acmeconfigfile
    echo "location = /.well-known/acme-challenge/ {" | sudo tee -a $acmeconfigfile
    echo "    return 404;" | sudo tee -a $acmeconfigfile
    echo "}" | sudo tee -a $acmeconfigfile
fi

# Generate nginx configuration file
configfile=$conffolder/$appname.ssl.conf
echo ""
echo ""
echo "Creating configuration file for $appname in the $conffolder"
sudo touch $configfile
echo "server {" | sudo tee $configfile 
echo "   listen 443 ssl http2;" | sudo tee -a $configfile 
echo "   listen [::]:443 ssl http2;" | sudo tee -a $configfile 
echo "   server_name " | sudo tee -a $configfile 
   for domain in $domains; do
      echo -n $domain" " | sudo tee -a $configfile
   done
echo ";" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "   ssl on;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "   # letsencrypt certificates" | sudo tee -a $configfile 
echo "   ssl_certificate      /etc/letsencrypt/live/${APPDOMAINS[0]}/fullchain.pem;" | sudo tee -a $configfile 
echo "   ssl_certificate_key  /etc/letsencrypt/live/${APPDOMAINS[0]}/privkey.pem;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    #SSL Optimization" | sudo tee -a $configfile 
echo "    ssl_session_timeout 1d;" | sudo tee -a $configfile 
echo "    ssl_session_cache shared:SSL:20m;" | sudo tee -a $configfile 
echo "    ssl_session_tickets off;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    # modern configuration" | sudo tee -a $configfile 
echo "    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;" | sudo tee -a $configfile 
echo "    ssl_prefer_server_ciphers on;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK';" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    # OCSP stapling" | sudo tee -a $configfile 
echo "    ssl_stapling on;" | sudo tee -a $configfile 
echo "    ssl_stapling_verify on;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    # verify chain of trust of OCSP response" | sudo tee -a $configfile 
echo "    ssl_trusted_certificate /etc/letsencrypt/live/${APPDOMAINS[0]}/chain.pem;" | sudo tee -a $configfile 
echo "    #root directory and logfiles" | sudo tee -a $configfile 
echo "    root /srv/users/$username/apps/$appname/public;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    access_log /srv/users/$username/log/$appname/${appname}_nginx.access.log main;" | sudo tee -a $configfile 
echo "    error_log /srv/users/$username/log/$appname/${appname}_nginx.error.log;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    #proxyset" | sudo tee -a $configfile 
echo "    proxy_set_header Host \$host;" | sudo tee -a $configfile 
echo "    proxy_set_header X-Real-IP \$remote_addr;" | sudo tee -a $configfile 
echo "    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" | sudo tee -a $configfile 
echo "    proxy_set_header X-Forwarded-SSL on;" | sudo tee -a $configfile 
echo "    proxy_set_header X-Forwarded-Proto \$scheme;" | sudo tee -a $configfile 
echo "" | sudo tee -a $configfile 
echo "    #includes" | sudo tee -a $configfile 
echo "    include /etc/nginx-sp/vhosts.d/$appname.d/*.conf;" | sudo tee -a $configfile 
echo "    include $acmeconfigfolder/*.conf;" | sudo tee -a $configfile 
echo "}" | sudo tee -a $configfile 

# Wrapping it up
echo ""
echo ""
echo "We're almost done here. Opening HTTPS Port and  Restarting nginx..."
sudo ufw allow https
sudo service nginx-sp restart
echo ""
echo ""
echo ""
echo ""
echo "Your Let's Encrypt SSL certificate has been installed. Please update your .htaccess to force HTTPS on your app"
echo ""
echo "To enable auto-renewal, add the following to your crontab:"

# Append new schedule to crontab
# 14.04 Trusty Tahr
if [ $ubuntu == '14.04' ]
then
    echo "0 */12 * * * /usr/local/bin/certbot-auto renew --quiet --no-self-upgrade --post-hook \"service nginx-sp reload\""
fi

# 16.04 Xenial Xerus
if [ $ubuntu == '16.04' ]
then
    echo "0 */12 * * * letsencrypt renew"
fi

echo ""
echo ""
echo "Cheers!"
