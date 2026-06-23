using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace JWT.DTOs.BaoTecherRequests
{
    public class BaoTecherRequestCreateDto
    {
        [Required]
        public int SubjectId { get; set; }

        public IFormFile? CertificationFile { get; set; }

        [Required]
        public string Reason { get; set; } = string.Empty;
    }
}
