#!/bin/bash

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

echo -e "*** Clone and install the Coposer Tools repository.***\n"
mkdir ~/fabric-tools && cd ~/fabric-tools
curl -O https://raw.githubusercontent.com/hyperledger/composer-tools/master/packages/fabric-dev-servers/fabric-dev-servers.tar.gz
tar -xvf fabric-dev-servers.tar.gz
export FABRIC_VERSION=hlfv12
echo "export FABRIC_VERSION=hlfv11" >> $HOME/.profile
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
npm install -g node-red
nohup node-red >~/playground/nodered.stdout 2>~/playground/nodered.stderr & disown

echo -e "*** Setup complete ***\n"
