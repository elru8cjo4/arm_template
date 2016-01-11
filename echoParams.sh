getJsonValPre="['runtimeSettings'][0]['handlerSettings']['publicSettings']"

function getJsonVal () {
    python -c "import json,sys;sys.stdout.write(json.dumps(json.load(sys.stdin
)$1))";
}

function getParam() {
    local key=$1
    local paramValue=`cat $configFilePath | getJsonVal "$getJsonValPre['$key']
" | sed 's/"//g'`
    sed -i -e "s/%$key%/$paramValue/g" dsminstall.prop
    eval $key=$paramValue
}

configFileNumber=`ls ../`
configFilePath="../../config/"$configFileNumber".settings"


getParam "adminUserName"
getParam "adminPassword"
getParam "databaseServer"
getParam "databaseName"
getParam "databaseUserName"
getParam "databaseUserPassword"

managerAddress=`curl http://ifconfig.co/?cmd=curl`
sed -i -e "s/%managerAddress%/$managerAddress/g" dsminstall.prop

/tmp/Manager-Linux-9.6.3175.x64.sh -q -console -varfile dsminstall.prop
