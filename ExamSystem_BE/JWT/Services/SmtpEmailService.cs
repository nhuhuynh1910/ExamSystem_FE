using JWT.Services.Contracts;
using System.Net;
using System.Net.Mail;
using System.Net.Mime;
using System.Text.Encodings.Web;

namespace JWT.Services
{
    public class SmtpEmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public SmtpEmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendVerifyEmailAsync(string toEmail, string fullName, string verifyLink)
        {
            var host = GetRequiredSetting("Smtp:Host");
            var fromEmail = GetRequiredSetting("Smtp:FromEmail");
            var fromName = _configuration["Smtp:FromName"];
            var username = GetRequiredSetting("Smtp:Username").Trim();
            var password = GetRequiredSetting("Smtp:Password").Replace(" ", string.Empty).Trim();
            var port = _configuration.GetValue("Smtp:Port", 587);
            var enableSsl = _configuration.GetValue("Smtp:EnableSsl", true);

            using var message = new MailMessage
            {
                From = string.IsNullOrWhiteSpace(fromName)
                    ? new MailAddress(fromEmail)
                    : new MailAddress(fromEmail, fromName),
                Subject = "X\u00e1c nh\u1eadn t\u00e0i kho\u1ea3n",
                Body = BuildVerifyEmailBody(fullName, verifyLink),
                IsBodyHtml = true
            };

            message.To.Add(new MailAddress(toEmail));
            message.AlternateViews.Add(AlternateView.CreateAlternateViewFromString(
                message.Body,
                null,
                MediaTypeNames.Text.Html));

            using var client = new SmtpClient(host, port)
            {
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(username, password),
                EnableSsl = enableSsl
            };

            await client.SendMailAsync(message);
        }

        private string GetRequiredSetting(string key)
        {
            var value = _configuration[key];

            if (string.IsNullOrWhiteSpace(value))
                throw new Exception($"{key} is missing.");

            return value;
        }

        private static string BuildVerifyEmailBody(string fullName, string verifyLink)
        {
            var encodedName = HtmlEncoder.Default.Encode(fullName);
            var encodedVerifyLink = HtmlEncoder.Default.Encode(verifyLink);

            return $@"
                <h2>Xin ch&agrave;o {encodedName},</h2>
                <p>B&#7841;n v&#7915;a &#273;&#259;ng k&yacute; t&agrave;i kho&#7843;n tr&ecirc;n h&#7879; th&#7889;ng thi online.</p>
                <p>Vui l&ograve;ng b&#7845;m v&agrave;o n&uacute;t b&ecirc;n d&#432;&#7899;i &#273;&#7875; x&aacute;c nh&#7853;n email:</p>
                <p>
                    <a href='{encodedVerifyLink}'
                       style='display:inline-block;padding:10px 16px;background:#2563eb;color:white;text-decoration:none;border-radius:6px;'>
                        X&aacute;c nh&#7853;n email
                    </a>
                </p>
                <p>N&#7871;u b&#7841;n kh&ocirc;ng &#273;&#259;ng k&yacute; t&agrave;i kho&#7843;n, vui l&ograve;ng b&#7887; qua email n&agrave;y.</p>
            ";
        }
    }
}
