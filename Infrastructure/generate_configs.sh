#!/bin/bash

while (( "$#" )); do
  case "$1" in
    -g|--resource-group)
      RG=$2
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
      echo "Usage: ./generate_configmap.sh -n {App Name} -g {Resource Group} -s {Subscription Name}"
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

#cosmosDBAccountName=db${appName}001
cosmosDBAccountName=db${appName}001
eventHubNameSpace=hub${appName}001
storageAccountName=${appName}sa001
functionAppName=func${appName}001

az account show  >> /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  az login
fi

#Get Subscription Id
az account set -s ${subscription}
subId=`az account show -o tsv --query id`

## Get Cosmos Connection String
cosmosConnectionString=`az cosmosdb list-connection-strings -n ${cosmosDBAccountName} -g ${RG} --query 'connectionStrings[0].connectionString' -o tsv`

## Get Event Hub Connection String 
ehConnectionString=`az eventhubs namespace authorization-rule keys list -g ${RG} --namespace-name ${eventHubNameSpace} --name RootManageSharedAccessKey -o tsv --query primaryConnectionString`

## Get Azure Storage Connection String
storageKey=`az storage account keys list -n ${storageAccountName} --query '[0].value' -o tsv`
storageConnectionString="DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageKey}"

## Get Azure Function Storage Connection String
funcStorageName=${functionAppName}sa
funcSstorageKey=`az storage account keys list -n ${funcStorageName} --query '[0].value' -o tsv`
funcStorageConnectionString="DefaultEndpointsProtocol=https;AccountName=${funcStorageName};AccountKey=${storageKey}"

#Set localSettings Secret for Azure Functions 
read -d '' localSettings << EOF
{ 
  \"IsEncrypted\": false, 
  \"Values\": { 
        \"AzureWebJobsStorage\": \"${funcStorageConnectionString}\",        
        \"FUNCTIONS_WORKER_RUNTIME\": \"dotnet\",                       
        \"EVENTHUB\": \"${ehConnectionString}\",       
        \"DOCUMENTDB\": \"${cosmosConnectionString}\",   
        \"STORAGE\": \"${storageConnectionString}\"   
    } 
} 
EOF
echo Generating Azure Functions Settings File - local.settings.json
echo -e "${localSettings}" > ./local.settings.json
