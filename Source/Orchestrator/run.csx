#r "Microsoft.Azure.WebJobs.Extensions.DurableTask"
using Microsoft.Extensions.Logging;

public static async Task Run(
    DurableOrchestrationContext context,
    ILogger log)
{
    var message = context.GetInput<string>(); 
    
    log.LogInformation($"Started Orchestrator: '{message}'.");
    await context.CallActivityAsync<string>("bjdStorageFunc002", message);
    await context.CallActivityAsync<string>("bjdCosmosFunc001", message );

}