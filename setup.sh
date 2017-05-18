#/bin/bash

# Variables
storageName="donnamstorage"   # enter storage account name here
resourceGroup="donnam-storage" # enter storage resource group

# Retrieve the Storage Account connection string 
connstr=$(az storage account show-connection-string --name $storageName --resource-group $resourceGroup --query connectionString --output tsv)

# write connection string to settings file
sed -i 's,"AzureWebJobsStorage": "","AzureWebJobsStorage": "'$connstr'",g' CoderCards/local.settings.json

# create input and output containers
az storage container create --connection-string $connstr -n input-local
az storage container create --connection-string $connstr -n output-local

# get SAS token for input-local container
sasToken=$(az storage container generate-sas --connection-string $connstr -n input-local --permissions lrw --expiry 2018-01-01 -o tsv)

# write SAS token to settings file, using bash replacement expression to escape '&'
sed -i 's,"CONTAINER_SAS": "","CONTAINER_SAS": "?'${sasToken//&/\\&}'",g' CoderCards/local.settings.json

az storage container set-permission --connection-string $connstr --public-access blob -n output-local

# set CORS on blobs
# this command does not currently work!
# az storage cors add --connection-string $connstr --origins '*' --methods GET --allowed-headers '*' --exposed-headers '*' --max-age 200 --services blob