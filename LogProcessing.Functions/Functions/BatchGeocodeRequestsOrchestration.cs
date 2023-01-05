using LogProcessing.Functions.Functions.Entities;
using LogProcessing.Functions.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace LogProcessing.Functions.Functions
{
    public class BatchGeocodeRequestsOrchestration
    {
        private readonly ILogger<BatchGeocodeRequestsOrchestration> _logger;

        public BatchGeocodeRequestsOrchestration(ILogger<BatchGeocodeRequestsOrchestration> logger)
        {
            _logger = logger;
        }

        [FunctionName((nameof(BatchGeocodeRequestsOrchestration)))]
        public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            var logEntry = context.GetInput<ParsedLogEntry>();

            _logger.LogInformation("Adding log entry to queue");

            await context.CallEntityAsync(new EntityId(nameof(IpGeocodeQueue), nameof(IpGeocodeQueue)),
                nameof(IpGeocodeQueue.AddLogEntryToQueue),
                logEntry);
        }
    }
}