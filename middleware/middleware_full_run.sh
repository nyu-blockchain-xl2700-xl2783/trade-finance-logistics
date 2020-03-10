
echo -e "\nThis script restarts the network, removes ../middleware/tmp, and runs all of the steps of the Middleware exercise\n"
sleep 3

echo -e "\nWill first remove directory ../middleware/tmp and the do an ls of ../network\n"
rm -r tmp
ls

cd $GOPATH/src/trade-finance-logistics/network
echo -e "\nShifted to " $(pwd) " so that we can bring down and bring up the tradechannel containers"

echo -e "\nRemoving ../network/add_org/docker-compose-exportingEntityOrg.yaml to have a clean start"
rm add_org/docker-compose-exportingEntityOrg.yaml

echo -e "\nNow bringing the network down and back up again\n"
echo "Y" | ./trade.sh down
echo -e "\nThere may be 'orphans' relating to exportingEntityOrg', so doing another sweep of the containers"
CONTAINER_IDS=$(docker ps -aq)
if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
  echo "---- No orphan containers were found, and proceeding to ./trade.sh clean ----"
else
  echo -e "\nFound additional containers " $CONTAINER_IDS
  echo -e "\nRemoving the found containers"
  docker rm -f $CONTAINER_IDS
  echo -e "\nInvoking ./trade.sh down for a second time"
  echo "Y" | ./trade.sh down
  echo -e "\nCalling docker ps -a to see if we got rid of all the containers finally\n"
  docker ps -a
  echo -e "\nBrought the network down and there should be no active containers now"
fi

VOLUME_IDS=$(docker volume ls -q)
if [ -z "$VOLUME_IDS" -o "$VOLUME_IDS" == " " ]; then
  echo "---- No orphan volumes were found, and proceeding to ./trade.sh clean ----"
else
  echo -e "\nFound additional volumes " $VOLUME_IDS
  echo -e "\nRemoving found volumes"
  docker volume rm -f $VOLUME_IDS
  echo -e "\nCalling docker volume ls to see if we got rid of all the containers finally\n"
  docker volume ls
  echo -e "\nBrought the network down and there should be no active containers or volumes now"
fi


echo "Y" | ./trade.sh clean
echo "Cleaned/purged the network"
echo "Y" | ./trade.sh generate -c tradechannel
echo "Generated config files for the new network"
echo "Y" | ./trade.sh up
echo -e "Launched the 9 containers for the network\n"

echo -e "Sleeping for 15 seconds to let containers come up\n"
sleep 15

echo -e "\nListing the active docker containers\n"
docker ps -a

cd $GOPATH/src/trade-finance-logistics/middleware

echo -e "\nHave now switched to " $(pwd)

echo -e "\nNow launching createTradeApp.js "

node createTradeApp.js

echo -e "\nNow launching runTradeScenarioApp.js "

node runTradeScenarioApp.js

echo -e "\nNow invoking ../network/.trade.sh createneworg"

cd $GOPATH/src/trade-finance-logistics/network
echo "Y" | ./trade.sh createneworg

echo -e "\nNow invoking run-upgrade-channel.js in ../middleware"
cd $GOPATH/src/trade-finance-logistics/middleware
node run-upgrade-channel.js

echo -e "\nDoing an ls to show that ../midleware/tmp folder was created\n"
ls

echo -e "\nNow invoking ../network/.trade.sh startneworg"
cd $GOPATH/src/trade-finance-logistics/network
echo "Y" | ./trade.sh startneworg

echo -e "\nInvoking 'docker ps -a' to see the 2 new containers\n"
docker ps -a


echo -e "\nSleeping 5 seconds so that containers can come up fully; perhaps 1 second is enough"
echo -e "Then invoking node new-org-join-channel.js in ../middleware\n"
sleep 5
cd $GOPATH/src/trade-finance-logistics/middleware
node new-org-join-channel.js



echo -e "\nInovking upgrade-chaincode.js to upgrade to trade_workflow_v1"
echo -e "But again sleeping for 5 seconds because seems necessary\n"
sleep 5
node upgrade-chaincode.js

echo -e "\nInvoking five-org-trade-scenario.js to test the new workflow end-to-end"
echo -e "Again, sleeping first\n"
sleep 5
node five-org-trade-scenario.js



echo -e '\nFinished script'