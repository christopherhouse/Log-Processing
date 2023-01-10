using LogProcessing.Functions.Models;
using LogProcessing.Functions.Services;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace LogProcessing.Functions.Functions;

public class GeocodeIpAddressBatchActivity
{
    private readonly ILogger<GeocodeIpAddressBatchActivity> _logger;
    private readonly IHttpClientWithRetry _httpClientWithRetry;

    public GeocodeIpAddressBatchActivity(ILogger<GeocodeIpAddressBatchActivity> logger,
        IHttpClientWithRetry httpClientWithRetry)
    {
        _logger = logger;
        _httpClientWithRetry = httpClientWithRetry;
    }

    [FunctionName(nameof(GeocodeIpAddressBatchActivity))]
    public async Task GeocodeIpAddressBatch([ActivityTrigger] List<ParsedLogEntry> logs,
        [CosmosDB("%cosmosDbDatabaseName%",
            "%cosmosDbContainerName%", 
            Connection = "cosmosDbConnectionString")] IAsyncCollector<GeocodeResultEntity> output)
    {
        var body = await _httpClientWithRetry.PostAsync(logs);

        foreach (var result in body)
        {
            var logEntry = logs.First(_ => _.SourceIpAddress == result.SourceIpAddress);
            var entity = new GeocodeResultEntity(logEntry.Time, result)
            {
                Id = Guid.NewGuid().ToString()
            };
            await output.AddAsync(entity);
        }
    }
}