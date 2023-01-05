using System.Collections.Generic;
using System.Threading.Tasks;
using LogProcessing.Functions.Models;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.DurableTask;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace LogProcessing.Functions.Functions.Entities;

[JsonObject(MemberSerialization.OptIn)]
public class IpGeocodeQueue
{
    private readonly TelemetryClient _telemetryClient;
    private readonly ILogger<IpGeocodeQueue> _logger;
    private const int MAX_QUEUE_DEPTH = 100;  // hard coded is fine since this limit won't change

    public IpGeocodeQueue(TelemetryClient telemetryClient, ILogger<IpGeocodeQueue> logger)
    {
        _telemetryClient = telemetryClient;
        _logger = logger;
        GeocodeBatchQueue = new List<ParsedLogEntry>(MAX_QUEUE_DEPTH);
    }

    [JsonProperty(nameof(GeocodeBatchQueue))]
    public List<ParsedLogEntry> GeocodeBatchQueue { get; }

    public void AddLogEntryToQueue(ParsedLogEntry logEntry)
    {
        GeocodeBatchQueue.Add(logEntry);

        _logger.LogInformation($"Added source IP {logEntry.SourceIpAddress} to queue");
        _telemetryClient.TrackEvent("QueueItemAdded", new Dictionary<string, string>{{"source", logEntry.SourceIpAddress}});

        if (GeocodeBatchQueue.Count > (MAX_QUEUE_DEPTH - 1))
        {
            var batchToRun = new List<ParsedLogEntry>();
            var counter = 0;

            while (counter < MAX_QUEUE_DEPTH)
            {
                var itemToAdd = GeocodeBatchQueue[counter];
                batchToRun.Add(itemToAdd);
                counter++;
            }

            GeocodeBatchQueue.RemoveRange(0, MAX_QUEUE_DEPTH);

            _telemetryClient.TrackEvent("QueueBatchCreated");
        }
    }

    [FunctionName(nameof(IpGeocodeQueue))]
    public static Task Run([EntityTrigger] IDurableEntityContext context) =>
        context.DispatchAsync<IpGeocodeQueue>();
}