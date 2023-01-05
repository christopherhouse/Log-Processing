using LogProcessing.Functions.Models;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;

namespace LogProcessing.Functions.Functions.Entities;

[JsonObject(MemberSerialization.OptIn)]
public class IpGeocodeQueue
{
    private readonly TelemetryClient _telemetryClient;
    private readonly ILogger<IpGeocodeQueue> _logger;
    private static int _maxQueueDepth = Convert.ToInt32(Environment.GetEnvironmentVariable("maxQueueDepth"));

    public IpGeocodeQueue(TelemetryClient telemetryClient, ILogger<IpGeocodeQueue> logger)
    {
        _telemetryClient = telemetryClient;
        _logger = logger;
        GeocodeBatchQueue = new List<ParsedLogEntry>(_maxQueueDepth);
    }

    [JsonProperty(nameof(GeocodeBatchQueue))]
    public List<ParsedLogEntry> GeocodeBatchQueue { get; }

    public void AddLogEntryToQueue(ParsedLogEntry logEntry)
    {
        GeocodeBatchQueue.Add(logEntry);

        _logger.LogInformation($"Added source IP {logEntry.SourceIpAddress} to queue");
        _telemetryClient.TrackEvent("QueueItemAdded", new Dictionary<string, string>{{"source", logEntry.SourceIpAddress}});

        if (GeocodeBatchQueue.Count > (_maxQueueDepth - 1))
        {
            var batchToRun = new List<ParsedLogEntry>();
            var counter = 0;

            while (counter < _maxQueueDepth)
            {
                var itemToAdd = GeocodeBatchQueue[counter];
                batchToRun.Add(itemToAdd);
                counter++;
            }

            GeocodeBatchQueue.RemoveRange(0, _maxQueueDepth);

            Entity.Current.StartNewOrchestration(nameof(GeocodeIpAddressBatchOrchestration), batchToRun);

            _telemetryClient.TrackEvent("QueueBatchCreated");
        }
    }

    [FunctionName(nameof(IpGeocodeQueue))]
    public static Task Run([EntityTrigger] IDurableEntityContext context) =>
        context.DispatchAsync<IpGeocodeQueue>();
}