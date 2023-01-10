using LogProcessing.Functions;
using LogProcessing.Functions.Services;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Polly;
using Polly.Extensions.Http;

[assembly: FunctionsStartup(typeof(Startup))]

namespace LogProcessing.Functions;

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        var sp = builder.Services.BuildServiceProvider();

        builder.Services.AddHttpClient<HttpClientWithRetry>()
            .AddPolicyHandler(_ =>
            {
                return HttpPolicyExtensions.HandleTransientHttpError()
                    .WaitAndRetryAsync(5,
                        retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                        onRetry: (outcome, timeSpan, retryAttempt, context) =>
                        {
                            var logger = (ILogger<HttpClientWithRetry>) sp.GetService(typeof(ILogger<HttpClientWithRetry>));
                            logger.LogWarning($"HTTP request failed: {outcome?.Result?.RequestMessage?.RequestUri}: Statue Code: {outcome?.Result?.StatusCode}");
                        });
            });
    }

}