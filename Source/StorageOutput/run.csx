#r "Microsoft.Azure.WebJobs.Extensions.DurableTask"
using Microsoft.Extensions.Logging;

public static void Run(
    string input,
    out string outputBlob,
    ILogger log)
{
    log.LogInformation($"Storage Activity: '{input}'..");
    outputBlob = input; 
}