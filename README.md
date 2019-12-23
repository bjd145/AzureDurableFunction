# Azure Durable Functions
Quick and Dirty example of how to use Azure Durable Functions

#  Deployment
1. Clone repository
2. .\Infrastructure\create_infrastructure.sh -g {Resource Group} -l {location} -s {Subscription Name}
3. .\Infrastructure\generate_configs.sh -n {App Name} -g {Resource Group} -s {Subscription Name}
4. func azure functionapp fetch-app-settings {func name}
5. func azure functionapp publish {func name} --csx -i 
