using LogProcessing.Functions.Models;

namespace LogProcessing.Functions.Services;

public interface IHttpClientWithRetry
{
    Task<IEnumerable<GeocodeResult>> PostAsync(IList<ParsedLogEntry> logs);
}