using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using LogProcessing.Functions.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace LogProcessing.Functions.Functions
{
    public class BatchGeocodeRequestsOrchestration
    {
        [FunctionName((nameof(BatchGeocodeRequestsOrchestration)))]
        public async Task RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            var logEntry = context.GetInput<ParsedLogEntry>();
        }
    }
}