using JWT.Data;
using JWT.Hubs;
using JWT.Repositories;
using JWT.Repositories.Contracts;
using JWT.Services;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Security.Claims;
using System.Reflection;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

// ─── CORS: Cho phép Flutter Web và các client dev gọi API ────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterDev", policy =>
    {
        policy
            .SetIsOriginAllowed(_ => true)   // Cho phép mọi origin (chỉ dùng khi dev)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddSignalR();

// ── CORS — cho phép Flutter Web (localhost:3000) gọi API ────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",  // Flutter Web dev
                "http://localhost:5122"   // BE self-origin
            )
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();          // cần cho SignalR WebSocket
    });
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Examination System API",
        Version = "v1",
        Description = "API quan ly he thong thi online."
    });



    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Nhập JWT token vào đây. Ví dụ: Bearer eyJhbGciOi..."

    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });

    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);

    if (File.Exists(xmlPath))
    {
        options.IncludeXmlComments(xmlPath);
    }

});

builder.Services.AddDbContext<ExamDb>(options =>
{
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("MyCnn"),
        sqlOptions => sqlOptions.EnableRetryOnFailure());
});

builder.Services.AddScoped<IAuthRepository, AuthRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IRoleRepository, RoleRepository>();
builder.Services.AddScoped<IExamRepository, ExamRepository>();
builder.Services.AddScoped<IBaoAccessRepository, BaoAccessRepository>();
builder.Services.AddScoped<IBaoNotificationRepository, BaoNotificationRepository>();
builder.Services.AddScoped<IBaoTecherRequestRepository, BaoTecherRequestRepository>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<IExamService, ExamService>();
builder.Services.AddScoped<IBaoAccessService, BaoAccessService>();
builder.Services.AddScoped<IBaoNotificationService, BaoNotificationService>();
builder.Services.AddScoped<IBaoTecherRequestService, BaoTecherRequestService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IEmailService, SmtpEmailService>();
builder.Services.AddScoped<ISubjectRepository, SubjectRepository>();
builder.Services.AddScoped<ISubjectService, SubjectService>();
builder.Services.AddScoped<IQuestionRepository, QuestionRepository>();
builder.Services.AddScoped<IQuestionService, QuestionService>();

builder.Services.AddScoped<ITeacherSubjectRepository, TeacherSubjectRepository>();
var jwtKey = builder.Configuration["Jwt:Key"];

if (string.IsNullOrWhiteSpace(jwtKey))
    throw new Exception("JWT Key is missing.");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;

            if (!string.IsNullOrEmpty(accessToken) &&
                path.StartsWithSegments("/hubs/bao-notifications"))
            {
                context.Token = accessToken;
            }

            return Task.CompletedTask;
        },
        OnTokenValidated = async context =>
        {
            var userIdClaim = context.Principal?.FindFirstValue(ClaimTypes.NameIdentifier);

            if (!int.TryParse(userIdClaim, out var userId))
            {
                context.Fail("Invalid user id claim.");
                return;
            }

            var db = context.HttpContext.RequestServices.GetRequiredService<ExamDb>();
            var user = await db.Users
                .AsNoTracking()
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u =>
                    u.UserId == userId &&
                    !u.IsDeleted &&
                    u.IsActive);

            if (user == null)
            {
                context.Fail("User is inactive or no longer exists.");
                return;
            }

            if (context.Principal?.Identity is ClaimsIdentity identity)
            {
                foreach (var roleClaim in identity.FindAll(ClaimTypes.Role).ToList())
                {
                    identity.RemoveClaim(roleClaim);
                }

                identity.AddClaim(new Claim(ClaimTypes.Role, user.Role?.RoleName ?? "Student"));
            }
        }
    };

    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,

        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],

        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey)
        ),

        ClockSkew = TimeSpan.Zero
    };
});




var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Chỉ redirect HTTP→HTTPS ở môi trường Production.
// Development: tắt để Android Emulator gọi HTTP không bị 307 redirect.
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}
app.UseStaticFiles();

// CORS phải đặt TRƯỚC Authentication/Authorization
app.UseCors("AllowFlutterWeb");

app.UseCors("FlutterDev");   // ← CORS phải đặt trước Authentication
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<BaoNotificationHub>("/hubs/bao-notifications");

using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ExamDb>();
    await db.Database.MigrateAsync();
}

app.Run();
