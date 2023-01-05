using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using LogProcessing.Functions.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;

namespace LogProcessing.Functions.Functions
{
    public class ProcessParsedLogs
    {
        private readonly ILogger<ProcessParsedLogs> _logger;

        public ProcessParsedLogs(ILogger<ProcessParsedLogs> logger)
        {
            _logger = logger;
        }

        [FunctionName("ProcessParsedLogs")]
        public async Task Run([EventHubTrigger("%eventHubName%", Connection = "eventHubListenConnectionString", ConsumerGroup = "%eventHubConsumerGroup%")] EventData[] events,
            [DurableClient] IDurableOrchestrationClient starter,
            ILogger log)
        {
            var exceptions = new List<Exception>();

            foreach (EventData eventData in events)
            {
                try
                {
                    var parsedLogEntry = eventData.EventBody.ToObjectFromJson<ParsedLogEntry>();
                    var instanceId =
                        await starter.StartNewAsync(nameof(BatchGeocodeRequestsOrchestration), parsedLogEntry);

                    _logger.LogInformation($"Started orchestration {instanceId} for source IP {parsedLogEntry.SourceIpAddress}");

                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
    }
}
