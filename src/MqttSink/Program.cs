using Microsoft.AspNetCore.HttpLogging;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddHealthChecks();
builder.Services.AddControllers().AddDapr();

builder.Services.AddHttpLogging(options => { options.LoggingFields = HttpLoggingFields.All; });

var app = builder.Build();

app.UseHealthChecks("/healthz");
app.UseHttpLogging();

app.MapSubscribeHandler();
app.MapControllers();

app.Run();