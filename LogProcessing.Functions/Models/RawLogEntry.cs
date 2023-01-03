using System.IO;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace LogProcessing.Functions.Models;

public class RawLogEntry
{
    [JsonProperty("SOURCE")]
    public string Source { get; set; }

    [JsonProperty("PROGRAM")]
    public string Program { get; set; }

    [JsonProperty("PRIORITY")]
    public string Priority { get; set; }

    [JsonProperty("PID")]
    public string ProcessId { get; set; }

    [JsonProperty("MESSAGE")]
    public string Message { get; set; }

    [JsonProperty("LEGACY_MSGHDR")]
    public string LegacyMessageHeader { get; set; }

    [JsonProperty("HOST_FROM")]
    public string From { get; set; }

    [JsonProperty("HOST")]
    public string Host { get; set; }

    [JsonProperty("FACILITY")]
    public string Facility { get; set; }

    [JsonProperty("@t")]
    public string Time { get; set; }

    [JsonProperty("@m")]
    public string RawMessage { get; set; }

    public ParsedLogEntry ToParsedLogEntry()
    {
        var rawLogEntry = new ParsedLogEntry();

        return rawLogEntry;
    }

    public static async Task<RawLogEntry> FromStreamAsync(Stream stream)
    {
        using var reader = new StreamReader(stream);
        var jsonString = await reader.ReadToEndAsync();

        var rawLogEntry = JsonConvert.DeserializeObject<RawLogEntry>(jsonString);

        return rawLogEntry;
    }
}