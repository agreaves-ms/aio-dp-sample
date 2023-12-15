using System.Text;
using System.Text.Json;
using Dapr;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.WebUtilities;

namespace MqttSink.Controllers;

[ApiController]
[Route("[controller]")]
public class SinkController : Controller
{
    private const string PubSubName = "aio-mq-pubsub";
    private readonly DaprClient _daprClient;

    private readonly ILogger<SinkController> _logger;

    public SinkController(ILogger<SinkController> logger, DaprClient daprClient)
    {
        _logger = logger;
        _daprClient = daprClient;
    }

    [Topic(PubSubName, "aio/data/#", true)]
    [HttpPost]
    public async Task<IActionResult> Subscribe()
    {
        _logger.LogInformation("Received new message from topic...");

        using var reader = new HttpRequestStreamReader(Request.Body, Encoding.UTF8);
        var body = await reader.ReadToEndAsync();
        var json = JsonSerializer.Deserialize<JsonElement>(body);
        var (topic, data) = ParseEvent(json);
        var jsonData = JsonSerializer.Deserialize<JsonElement>(data);

        _logger.LogInformation("[topic]: {topic}, [data]: {data}", topic, data);

        var pubTopic = $"sink/data/{topic}";
        await _daprClient.PublishEventAsync(
            PubSubName,
            pubTopic,
            jsonData,
            new Dictionary<string, string> { { "rawPayload", "true" } });

        _logger.LogInformation("Published new message to [topic]: {topic}", pubTopic);

        return Ok();
    }

    private (string topic, string data) ParseEvent(JsonElement json)
    {
        // Get the topic that triggered this pub/sub endpoint.
        string? topic = null;
        if (json.TryGetProperty("topic", out var topicJson)) topic = topicJson.GetString();

        if (string.IsNullOrEmpty(topic)) throw new BadHttpRequestException("Missing 'topic' from body");

        // Read out the data and deserialize it as json. The data will generally be in a 'data_base64' field.
        // If it's base64 encoded then deserialize it as base64.
        string? data = null;
        if (json.TryGetProperty("data", out var dataJson))
            data = dataJson.Deserialize<string>();
        else if (json.TryGetProperty("data_base64", out var dataBase64Json))
            data = Encoding.UTF8.GetString(dataBase64Json.GetBytesFromBase64());

        if (string.IsNullOrEmpty(data)) throw new BadHttpRequestException("Missing 'data' from body");

        return (topic, data);
    }
}