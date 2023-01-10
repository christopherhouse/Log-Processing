using System.Net.Http.Headers;
using System.Text;
using LogProcessing.Functions.Models;

namespace LogProcessing.Functions.Services;

public class HttpClientWithRetry
{
    private readonly HttpClient _httpClient;
    private static readonly Uri _uri = new Uri("http://ip-api.com/batch/json");

    public HttpClientWithRetry(HttpClient httpClient)
    {
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
    }

    public async Task<IEnumerable<GeocodeResult>> PostAsync(IList<ParsedLogEntry> logs)
    {
        var batchToPost = logs.Select(_ => _.SourceIpAddress);
        var bodyString = JsonConvert.SerializeObject(batchToPost);
        var bodyBytes = Encoding.UTF8.GetBytes(bodyString);
        var bodyContent = new ByteArrayContent(bodyBytes);
        bodyContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");

        var result = await _httpClient.PostAsync(_uri, bodyContent);
        var responseString = await result.Content.ReadAsStringAsync();
        var body = JsonConvert.DeserializeObject<IEnumerable<GeocodeResult>>(responseString);

        return body;
    }
}