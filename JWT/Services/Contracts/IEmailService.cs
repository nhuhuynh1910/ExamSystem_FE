namespace JWT.Services.Contracts
{
    public interface IEmailService
    {
        Task SendVerifyEmailAsync(string toEmail, string fullName, string verifyLink);
    }
}
