using LogProcessing.Functions.Models.Attributes;

namespace LogProcessing.Functions.Models;

public class ParsedLogEntry
{
    public string Time { get; set; }

    [LogEntryPropertyName("SRC")]
    public string SourceIpAddress { get; set; }

    [LogEntryPropertyNameAttribute("PROTO")]
    public string Protocol { get; set; }

    [LogEntryPropertyName("SPT")]
    public string SourcePort { get; set; }

    [LogEntryPropertyName("DPT")]
    public string DestinationPort { get; set; }
}