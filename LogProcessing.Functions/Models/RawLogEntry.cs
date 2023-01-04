using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using LogProcessing.Functions.Models.Attributes;
using Newtonsoft.Json;

namespace LogProcessing.Functions.Models;

public class RawLogEntry
{
    private static Regex _firewallMatchRegex = new Regex("DESCR=\"WAN DROPS\"", RegexOptions.Compiled|RegexOptions.Singleline);

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

    public bool IsFirewallLogEntry()
    {
        var result = !string.IsNullOrWhiteSpace(Message) && _firewallMatchRegex.IsMatch(Message);

        return result;
    }

    public ParsedLogEntry ToParsedLogEntry()
    {
        var parsedLogEntry = new ParsedLogEntry
        {
            Time = this.Time
        };

        var messageItems = Message.Split(' ');
        var messageItemKeyValuePairs = messageItems.Select(item => item.Split('='))
            .ToDictionary(itemArray =>
            {
                var item = itemArray[0];

                if (item == "LEN")
                {
                    item = Guid.NewGuid().ToString();
                }

                return item;
            }, itemArray =>
            {
                var item = string.Empty;
                if (itemArray.Length == 2)
                {
                    item = itemArray[1];
                }

                return item;
            });

        var propertyInfos = typeof(ParsedLogEntry).GetProperties(BindingFlags.Public | BindingFlags.Instance);

        foreach (var propertyInfo in propertyInfos)
        {
            var attribute = propertyInfo.GetCustomAttribute<LogEntryPropertyNameAttribute>();

            if (attribute != null)
            {
                var value = messageItemKeyValuePairs[attribute.PropertyName];
                propertyInfo.SetValue(parsedLogEntry, value);
            }
        }

        return parsedLogEntry;
    }

    public static async Task<RawLogEntry> FromStreamAsync(Stream stream)
    {
        using var reader = new StreamReader(stream);
        var jsonString = await reader.ReadToEndAsync();

        var rawLogEntry = JsonConvert.DeserializeObject<RawLogEntry>(jsonString);

        return rawLogEntry;
    }
}