#!/bin/bash

# Sanity checks
relog=false
# Check for docker group
if ! $( id -Gn | grep -wq docker ); then
  sudo usermod -aG docker blockchain
  echo "ID blockchain was not a member of the docker group. This has been corrected."
  relog=true
fi
# Update PATH for /usr/local/bin
  echo "export PATH=/usr/local/bin:$PATH" >> $HOME/.profile
  echo "Updated PATH."

# Relog needed?
if [[ "$relog" = true ]]; then
  echo "Some changes have been made that require you to log out and log back in."
  echo "Please do this now and then re-run this script."
  exit 1
fi
# Ensure /data exists
# END Sanity checks

printf "

IBM Master the Mainframe

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::''  ''::'      '::::::  ::::::::::::::'.:::::::::::::::
:::::::::' :. :  :         :::: :  :::::::::::.:::':::::::::::::::
::::::::::  :   :::.       ::: M :::::::..::::'     :::: : :::::::
::::::::    :':  '::'     '' M   M :::::: :'           '' ':::::::
:'        : '   :  ::    . M       M   '                        .:
:               :  .:: . M           M                         :::
:. .,.        :::  ':: M M M       M M M                 .:...::::
:::::::.      '      M   M   M   M   M   M               :: :::::.
::::::::           M     M     M     M     M   '    '   .:::::::::
::::::::.        ::: M   M           M   M :         ''' :::::::::
::::::::::      :::::: M M           M M             :::::::::::::
: .::::::::.   .:''::::: M           M   ::   :   '::.::::::::::::
:::::::::::::::. '  '::::: M       M   :::::.:.:.:.:.:::::::::::::
:::::::::::::::: :     ':::: M   M  ' ,:::::::::: : :.:'::::::::::
::::::::::::::::: '     :::::: M    . :'::::::::::::::' ':::::::::
::::::::::::::::::''   :::::::: : :' : ,:::vem:::::'      ':::::::
:::::::::::::::::'   .::::::::::::  ::::::::::::::::       :::::::
:::::::::::::::::. .::::::::::::::::::::::::::::::::::::.'::::::::

IBM Master the Mainframe

"

#Install NodeJS
echo -e “*** install_nodejs ***”
cd /tmp
wget -q https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-s390x.tar.gz
cd /usr/local && sudo tar --strip-components=1 -xzf /tmp/node-v8.9.4-linux-s390x.tar.gz
npm update -g node@8.9.4
echo -e “*** Done withe NodeJS ***\n”

echo -e "*** Clone and install the Coposer Tools repository.***\n"
mkdir ~/fabric-tools && cd ~/fabric-tools
curl -O https://raw.githubusercontent.com/hyperledger/composer-tools/master/packages/fabric-dev-servers/fabric-dev-servers.tar.gz
tar -xvf fabric-dev-servers.tar.gz
export FABRIC_VERSION=hlfv11
echo "export FABRIC_VERSION=hlfv11" >> $HOME/.profile
#./downloadFabric.sh
unset COMPOSE_PROJECT_NAME
docker rm -f $(docker ps -aq)
./startFabric.sh
./createPeerAdminCard.sh
mkdir ~/playground/
nohup composer-playground >~/playground/playground.stdout 2>~/playground/playground.stderr & disown
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 3000 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 1880 -j ACCEPT
#sudo bash -c "iptables-save > /etc/linuxone/iptables.save"

#Install NodeRed
echo -e "*** Installing NodeRed. ***\n"
sudo npm install -g node-red
nohup node-red >~/playground/nodered.stdout 2>~/playground/nodered.stderr & disown

# Persist docker group addition
sudo usermod -aG docker blockchain

echo "Please log out of this system and log back in to pick up the group and PATH changes."

