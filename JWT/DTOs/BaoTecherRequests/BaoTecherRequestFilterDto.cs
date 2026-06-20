namespace JWT.DTOs.BaoTecherRequests
{
    public class BaoTecherRequestFilterDto
    {
        public string? Status { get; set; }

        public int PageNumber { get; set; } = 1;

        public int PageSize { get; set; } = 10;
    }
}
