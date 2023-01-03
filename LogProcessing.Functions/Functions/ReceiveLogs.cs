using System.IO;
using System.Net;
using System.Threading.Tasks;
using LogProcessing.Functions.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;

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
            [EventHub("%eventHubName%", Connection = "eventHubListenConnectionString")] IAsyncCollector<RawLogEntry> events,
            ILogger logger)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var rawLogEntry = await RawLogEntry.FromStreamAsync(req.Body);
            await events.AddAsync(rawLogEntry);


            return new AcceptedResult();
        }
    }
}

