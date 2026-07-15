using JWT.DTOs.Auth;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace JWT.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            try
            {
                var result = await _authService.RegisterAsync(request);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("chưa xác nhận"))
                    return BadRequest(new { message = ex.Message, requiresEmailVerification = true });

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("resend-verification-email")]
        public async Task<IActionResult> ResendVerificationEmail(ResendVerificationEmailRequest request)
        {
            try
            {
                var result = await _authService.ResendVerificationEmailAsync(request.Email);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("verify-email")]
        public async Task<IActionResult> VerifyEmail([FromQuery] string token)
        {
            try
            {
                var result = await _authService.VerifyEmailAsync(token);
                return Content(BuildVerifyResultHtml(
                    success: true,
                    title: "Xác nhận thành công!",
                    message: result
                ), "text/html");
            }
            catch (Exception ex)
            {
                return Content(BuildVerifyResultHtml(
                    success: false,
                    title: "Xác nhận thất bại",
                    message: ex.Message
                ), "text/html");
            }
        }

        /// <summary>
        /// Tạo trang HTML đẹp hiển thị kết quả verify email.
        /// User click link trong email → thấy trang này thay vì raw JSON.
        /// </summary>
        private static string BuildVerifyResultHtml(bool success, string title, string message)
        {
            var iconSvg = success
                ? "<circle cx='40' cy='40' r='38' fill='#E8F5E9' stroke='#2E7D32' stroke-width='2'/><path d='M20 40 L34 54 L60 28' fill='none' stroke='#2E7D32' stroke-width='4' stroke-linecap='round' stroke-linejoin='round'/>"
                : "<circle cx='40' cy='40' r='38' fill='#FFEBEE' stroke='#C62828' stroke-width='2'/><path d='M28 28 L52 52 M52 28 L28 52' fill='none' stroke='#C62828' stroke-width='4' stroke-linecap='round'/>";

            var accentColor = success ? "#2E7D32" : "#C62828";
            var bgGradient = success ? "#E8F5E9, #F1F8E9" : "#FFEBEE, #FFF3E0";
            var encodedTitle = System.Net.WebUtility.HtmlEncode(title);
            var encodedMessage = System.Net.WebUtility.HtmlEncode(message);

            return $@"<!DOCTYPE html>
<html lang='vi'>
<head>
    <meta charset='UTF-8'/>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'/>
    <title>{encodedTitle} — FPT ExamHub</title>
    <style>
        * {{ margin:0; padding:0; box-sizing:border-box; }}
        body {{
            min-height:100vh;
            display:flex; align-items:center; justify-content:center;
            background: linear-gradient(135deg, {bgGradient});
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 24px;
        }}
        .card {{
            background:#fff;
            border-radius:20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.08);
            padding:48px 40px;
            max-width:460px;
            width:100%;
            text-align:center;
            animation: fadeUp 0.5s ease-out;
        }}
        @keyframes fadeUp {{
            from {{ opacity:0; transform:translateY(20px); }}
            to {{ opacity:1; transform:translateY(0); }}
        }}
        .icon {{ margin-bottom:24px; }}
        .brand {{
            display:flex; align-items:center; justify-content:center;
            gap:8px; margin-bottom:32px;
        }}
        .brand-dot {{
            width:32px; height:32px; border-radius:50%;
            background: linear-gradient(135deg, #F15A22, #D14307);
            display:flex; align-items:center; justify-content:center;
            color:#fff; font-weight:700; font-size:14px;
        }}
        .brand-name {{ font-size:18px; font-weight:700; color:#F15A22; }}
        h1 {{ font-size:24px; color:#1D3557; margin-bottom:12px; font-weight:700; }}
        p {{ font-size:15px; color:#6B7280; line-height:1.6; margin-bottom:32px; }}
        .btn {{
            display:inline-block;
            padding:14px 32px;
            border-radius:12px;
            font-size:15px; font-weight:600;
            text-decoration:none;
            color:#fff;
            background: {accentColor};
            transition: transform 0.2s, box-shadow 0.2s;
        }}
        .btn:hover {{
            transform:translateY(-2px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
        }}
        .footer {{ margin-top:24px; font-size:12px; color:#9CA3AF; }}
    </style>
</head>
<body>
    <div class='card'>
        <div class='brand'>
            <div class='brand-dot'>E</div>
            <span class='brand-name'>FPT ExamHub</span>
        </div>
        <div class='icon'>
            <svg width='80' height='80' viewBox='0 0 80 80'>{iconSvg}</svg>
        </div>
        <h1>{encodedTitle}</h1>
        <p>{encodedMessage}</p>
        <a class='btn' href='http://localhost:3000'>Mở ứng dụng</a>
        <div class='footer'>© 2026 FPT ExamHub. All rights reserved.</div>
    </div>
</body>
</html>";
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            try
            {
                var result = await _authService.LoginAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken(RefreshTokenRequest request)
        {
            try
            {
                var result = await _authService.RefreshTokenAsync(request.RefreshToken);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout(RefreshTokenRequest request)
        {
            try
            {
                var result = await _authService.LogoutAsync(request.RefreshToken);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Đăng nhập bằng Google.
        /// 
        /// FE gửi idToken từ Google Sign-In SDK.
        /// BE verify token → tìm user đã tồn tại → trả JWT.
        /// KHÔNG tạo user mới nếu email chưa đăng ký.
        /// </summary>
        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin(GoogleLoginRequest request)
        {
            try
            {
                var result = await _authService.GoogleLoginAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            try
            {
                var result = await _authService.ForgotPasswordAsync(request.Email);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword(ResetPasswordRequest request)
        {
            try
            {
                var result = await _authService.ResetPasswordAsync(request.Token, request.NewPassword);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
