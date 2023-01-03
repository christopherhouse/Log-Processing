namespace LogProcessing.Functions.Models;

public class ParsedLogEntry
{
    public string Time { get; set; }

    public string SourceIpAddress { get; set; }

    public string Length { get; set; }

    public string Protocol { get; set; }

    public string SourcePort { get; set; }

    public string DestinationPort { get; set; }
}