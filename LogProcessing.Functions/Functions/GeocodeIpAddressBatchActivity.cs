using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using LogProcessing.Functions.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace LogProcessing.Functions.Functions;

public class GeocodeIpAddressBatchActivity
{
    private readonly ILogger<GeocodeIpAddressBatchActivity> _logger;
    private readonly IHttpClientFactory _httpClientFactory;

    public GeocodeIpAddressBatchActivity(ILogger<GeocodeIpAddressBatchActivity> logger,
        IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
    }

    [FunctionName(nameof(GeocodeIpAddressBatchActivity))]
    public async Task GeocodeIpAddressBatch([ActivityTrigger] List<ParsedLogEntry> logs,
        [CosmosDB("%cosmosDbDatabaseName%",
            "%cosmosDbContainerName%", 
            Connection = "cosmosDbConnectionString")] IAsyncCollector<GeocodeResultEntity> output)
    {
        var uri = new Uri("http://ip-api.com/batch/json");
        var batch = logs.Select(_ => _.SourceIpAddress);
        var bodyString = JsonConvert.SerializeObject(batch);
        var bodyBytes = Encoding.UTF8.GetBytes(bodyString);
        var bodyContent = new ByteArrayContent(bodyBytes);
        bodyContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

        using var client = _httpClientFactory.CreateClient();
        var response = await client.PostAsync(uri, bodyContent);
        var responseString = await response.Content.ReadAsStringAsync();
        var body = JsonConvert.DeserializeObject<IEnumerable<GeocodeResult>>(responseString);

        foreach (var result in body)
        {
            var logEntry = logs.First(_ => _.SourceIpAddress == result.SourceIpAddress);
            var entity = new GeocodeResultEntity(logEntry.Time, result);
            await output.AddAsync(entity);
        }
    }
}