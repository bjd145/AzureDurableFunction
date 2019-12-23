# AzureDurableFunction
Quick and Dirty example of how to use Azure Durable Functions

# Manual Deployment
1. Clone repository
2. Create an Azure Event Hub, Azure Storage Account and a Azure Cosmosdb Account.
    * Copy connection scripts for each service and upate local.settings.json 
    * Create event hub named - events001 - in the EventHub Namespace
    * Create databbase named - db - with a container named items in Cosmos DB
3. Update local.settings.json 
4. func azure functionapp publishh <func name>
