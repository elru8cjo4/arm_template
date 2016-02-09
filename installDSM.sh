installFilePath="/tmp/dsminstall.prop"
installLogPath="/opt/trend/dsm_app/dsm_azure_app/azure_install.log"

function getParam() {
    local key=$1
    local paramValue=`AzureVMMetadata.py $key`
    sed -i -e "s/%$key%/$paramValue/g" $installFilePath
    eval $key=$paramValue
}

configFileNumber=`ls ../`
configFilePath="../../config/"$configFileNumber".settings"
cp $configFilePath /opt/trend/packages/dsm/default/0.settings

#restart web installer to load setting files.
ps aux | grep run.py | head -1 | awk '{print "kill "$2}' | sh


cp dsminstall.prop $installFilePath
getParam "adminUserName"
getParam "adminPassword"
getParam "databaseServer"
getParam "databaseName"
getParam "databaseUserName"
getParam "databaseUserPassword"

# Deal with manager address
fqdn=`AzureVMMetadata.py publicIPDomainNameLabel`
location=`AzureVMMetadata.py location`
if [ "$fqdn" != "" ]; then
    managerAddress=$fqdn"."$location".cloudapp.azure.com"
else
    managerAddress=`curl http://ifconfig.co/?cmd=curl 2>/dev/null`
fi
sed -i -e "s/%managerAddress%/$managerAddress/g" $installFilePath

sleep 5

r=1
times=0
while [ $r -ne 0 ] && [ $times -lt 3 ]; do
    /opt/trend/packages/dsm/default/Manager-Azure-9.6.11857.x64.sh -q -console -varfile $installFilePath > $installLogPath 2>&1 
    r=$?
    (( times++ ))
    sleep 5
done

if [ $? != 0 ]; then
    echo "DSM install failed. Please visited https://$managerAddress:8080 to install DSM again."
    exit 1
fi

#remove tmp prop file
rm $installFilePath > /dev/null 2>&1
exit 0
