#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -g|--resource-group)
      RG=$2
      shift 2
      ;;
    -l|--location)
      location=$2
      shift 2
      ;;
    -s|--subscription)
      subscription=$2
      shift 2
      ;;
    -n|--name)
      appName=$2
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./create_infrastructure.sh -n {App Name} -g {Resource Group} -l {location} -s {Subscription Name}"
      exit 0
      ;;
    --) 
      shift
      break
      ;;
    -*|--*=) 
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${appName}" ]]; then
  appName=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`
fi 

echo "Generated Application Name - ${appName}"

cosmosDBAccountName=db${appName}001
functionAppName=func${appName}001
eventHubNameSpace=hub${appName}001
storageAccountName=${appName}sa001

az account show  >> /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  az login
fi

#Get Subscription Id
az account set -s ${subscription}
subId=`az account show -o tsv --query id`

#Create Resource Group
az group create -n $RG -l $location

#Create Cosmos
database=db
collection=Items

az cosmosdb create -g ${RG} -n ${cosmosDBAccountName} --kind GlobalDocumentDB 
az cosmosdb database create  -g ${RG} -n ${cosmosDBAccountName} -d ${database}
az cosmosdb collection create -g ${RG} -n ${cosmosDBAccountName} -d ${database} -c ${collection} --partition-key-path '/keyId'

#Create Event Hub
hub=events001
az eventhubs namespace create -g ${RG} -n ${eventHubNameSpace} -l ${location} --sku Standard --enable-auto-inflate --maximum-throughput-units 5 --enable-kafka
az eventhubs eventhub create -g ${RG} --namespace-name ${eventHubNameSpace} -n ${hub} --message-retention 7 --partition-count 1

#Create Azure Storage
az storage account create --name ${storageAccountName} --location $location --resource-group $RG --sku Standard_LRS

# Create an Azure Function with storage accouunt in the resource group.
if ! `az functionapp show --name $functionAppName --resource-group $RG -o none`
then
    funcStorageName=${functionAppName}sa
    az storage account create --name $funcStorageName --location $location --resource-group $RG --sku Standard_LRS
    az functionapp create --name $functionAppName --storage-account $funcStorageName --consumption-plan-location $location --resource-group $RG
    az functionapp identity assign --name $functionAppName --resource-group $RG
fi

## Get Connection Strings
cosmosConnectionString=`az cosmosdb list-connection-strings -n ${cosmosDBAccountName} -g ${RG} --query 'connectionStrings[0].connectionString' -o tsv` 
ehConnectionString=`az eventhubs namespace authorization-rule keys list -g ${RG} --namespace-name ${eventHubNameSpace} --name RootManageSharedAccessKey -o tsv --query primaryConnectionString`
storageKey=`az storage account keys list -n ${storageAccountName} --query '[0].value' -o tsv`
storageConnectionString="DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageKey}"

az functionapp config appsettings set -g $RG -n $functionAppName --settings STORAGE=${storageConnectionString}
az functionapp config appsettings set -g $RG -n $functionAppName --settings EVENTHUB=${ehConnectionString}
az functionapp config appsettings set -g $RG -n $functionAppName --settings DOCUMENTDB=${cosmosConnectionString}