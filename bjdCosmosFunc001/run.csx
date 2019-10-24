#r "Microsoft.Azure.WebJobs.Extensions.DurableTask"
#r "Newtonsoft.Json"

using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

public static void Run(
    string input,
    out object document,
    ILogger log)
{
    log.LogInformation($"Cosmos Activity: '{input}'..");

    dynamic obj = JObject.Parse(input);

    document = new {
        keyId = obj.keyId,
        key = obj.key,
        host = obj.host,
        timeStamp = obj.timeStamp
    };

}