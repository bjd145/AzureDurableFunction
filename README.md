# Azure Durable Functions
Quick and Dirty example of how to use Azure Durable Functions

#  Deployment
1. Clone repository
2. .\Infrastructure\create_infrastructure.sh -g {Resource Group} -l {location} -s {Subscription Name}
3. func azure functionapp publish {func name} --csx -i 
