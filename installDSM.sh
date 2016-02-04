getJsonValPre="['runtimeSettings'][0]['handlerSettings']['publicSettings']"

function getJsonVal () {
    python -c "import json,sys;sys.stdout.write(json.dumps(json.load(sys.stdin
)$1))";
}

installFilePath="/tmp/dsminstall.prop"
installLogPath="/opt/trend/dsm_app/dsm_azure_app/azure_install.log"

function getParam() {
    local key=$1
    local paramValue=`cat $configFilePath | getJsonVal "$getJsonValPre['$key']   
" | sed 's/"//g'`
    sed -i -e "s/%$key%/$paramValue/g" $installFilePath
    eval $key=$paramValue
}

configFileNumber=`ls ../`
configFilePath="../../config/"$configFileNumber".settings"
cp $configFilePath /opt/trend/packages/dsm/default/0.settings

cp dsminstall.prop $installFilePath
getParam "adminUserName"
getParam "adminPassword"
getParam "databaseServer"
getParam "databaseName"
getParam "databaseUserName"
getParam "databaseUserPassword"

managerAddress=`curl http://ifconfig.co/?cmd=curl 2>/dev/null`
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
