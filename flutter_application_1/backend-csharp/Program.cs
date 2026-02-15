using ServitecAPI.Services;
using ServitecAPI.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Cargar configuración
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables();

// Agregar servicios
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    });

// Registrar Data Access Layer
builder.Services.AddScoped<DatabaseService>();

// Registrar Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<ITechnicianRepository, TechnicianRepository>();

// Registrar Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ITechnicianService, TechnicianService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Agregar CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", b =>
    {
        b.AllowAnyOrigin()
         .AllowAnyMethod()
         .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configurar middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

Console.WriteLine("Servidor Servitec (C# ADO.NET) corriendo en puerto 3000");
Console.WriteLine("URL: http://localhost:3000");
Console.WriteLine("Health check: http://localhost:3000/api/health");

app.Run("http://0.0.0.0:3000");