namespace LogProcessing.Functions.Models;

public class GeocodeResultEntity : GeocodeResult
{
    public GeocodeResultEntity()
    {
    }

    public GeocodeResultEntity(string logEntryDateTime, GeocodeResult result)
    {
        LogEntryDateTime = logEntryDateTime;
        AutonomousSystem = result.AutonomousSystem;
        City = result.City;
        Country = result.Country;
        CountryCode = result.CountryCode;
        InternetServiceProvider = result.InternetServiceProvider;
        Latitude = result.Latitude;
        Longitude = result.Longitude;
        Organization = result.Organization;
        SourceIpAddress = result.SourceIpAddress;
        Region = result.Region;
        RegionName = result.RegionName;
        Status = result.Status;
        Timezone = result.Timezone;
        ZipCode = result.ZipCode;
        Message = result.Message;
    }

    [JsonProperty("id")]
    public string Id { get; set; }

    [JsonProperty("logEntryDateTime")]
    public string LogEntryDateTime { get; set; }

    [JsonProperty("logDate")]
    public string LogDate 
    {
        get
        {
            var logDate = DateTime.UtcNow.ToString("yyyy-MM-dd");
            if (!string.IsNullOrWhiteSpace(LogEntryDateTime) && DateTime.TryParse(LogEntryDateTime, out var logDateTime))
            {
                logDate = logDateTime.ToString("yyyy-MM-dd");
            }

            return logDate;
        }
    }
}