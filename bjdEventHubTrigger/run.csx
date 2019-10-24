#r "Microsoft.Azure.EventHubs"
#r "Microsoft.Azure.WebJobs.Extensions.DurableTask"
#r "Newtonsoft.Json"

using System;
using System.Text;
using Microsoft.Azure.EventHubs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

public static async Task Run(
    EventData[] events, 
    DurableOrchestrationClient client,
    ILogger log)
{
    foreach( var e in events ) {
        string messageBody = Encoding.UTF8.GetString(e.Body.Array, e.Body.Offset, e.Body.Count);
        log.LogInformation($"C# Event Hub trigger function processed a message: {messageBody}");

        var instanceId = await client.StartNewAsync("bjdOrchestratorFunc001", messageBody);
        log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

        var status = await client.GetStatusAsync(instanceId);
        var statusString = JsonConvert.SerializeObject(status);
        log.LogInformation($"Status - {statusString}");
    }
}
