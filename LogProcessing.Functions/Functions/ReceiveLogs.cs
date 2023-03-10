using System.Net;
using System.Web.Http;
using LogProcessing.Functions.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.OpenApi.Models;

namespace LogProcessing.Functions.Functions
{
    public class ReceiveLogs
    {
        private readonly ILogger<ReceiveLogs> _logger;

        public ReceiveLogs(ILogger<ReceiveLogs> log)
        {
            _logger = log;
        }

        [FunctionName("ReceiveLogs")]
        [OpenApiOperation(operationId: "Run", tags: new[] { "name" })]
        [OpenApiSecurity("function_key", SecuritySchemeType.ApiKey, Name = "code", In = OpenApiSecurityLocationType.Query)]
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required = true, Type = typeof(string), Description = "The **Name** parameter")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.Accepted, contentType: "application/json", bodyType: typeof(string), Description = "The OK response")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            [EventHub("%eventHubName%", Connection = "eventHubSendConnectionString")] IAsyncCollector<ParsedLogEntry> events,
            ILogger logger)
        {
            IActionResult result = null;

            try
            {
                var rawLogEntry = await RawLogEntry.FromStreamAsync(req.Body);

                if (rawLogEntry.IsFirewallLogEntry())
                {
                    var parsedLogEntry = rawLogEntry.ToParsedLogEntry();
                    await events.AddAsync(parsedLogEntry);
                }
                else
                {
                    _logger.LogInformation("Received message that was not a firewall drop");
                }

                result = new OkResult();
            }
            catch (Exception e)
            {
                _logger.LogError(e, $"Error in ReceiveLogs: {e.Message}");
                result = new InternalServerErrorResult();
            }

            return result;
        }
    }
}

