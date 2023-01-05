using LogProcessing.Functions.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace LogProcessing.Functions.Functions;

public class GeocodeIpAddressBatchOrchestration
{
    private readonly ILogger<GeocodeIpAddressBatchOrchestration> _logger;

    public GeocodeIpAddressBatchOrchestration(ILogger<GeocodeIpAddressBatchOrchestration> logger)
    {
        _logger = logger;
    }

    [FunctionName(nameof(GeocodeIpAddressBatchOrchestration))]
    public async Task RunOrchestration([OrchestrationTrigger] IDurableOrchestrationContext context)
    {
        var input = context.GetInput<List<ParsedLogEntry>>();
        await context.CallActivityAsync(nameof(GeocodeIpAddressBatchActivity), input);
    }
}