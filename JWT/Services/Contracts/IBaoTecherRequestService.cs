using JWT.DTOs.BaoTecherRequests;
using JWT.DTOs.Exam;

namespace JWT.Services.Contracts
{
    public interface IBaoTecherRequestService
    {
        Task<BaoTecherRequestResponseDto> CreateAsync(
            BaoTecherRequestCreateDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<PagedResultDto<BaoTecherRequestResponseDto>> GetRequestsAsync(
            BaoTecherRequestFilterDto filter,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoTecherRequestResponseDto> GetRequestByIdAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole);

        Task<List<BaoTecherRequestAvailableSubjectDto>> GetAvailableSubjectsAsync(
            string? currentUserId,
            string? currentUserRole);

        Task<List<BaoTecherRequestResponseDto>> GetMyRequestsAsync(
            string? currentUserId,
            string? currentUserRole);

        Task<BaoTecherRequestResponseDto> ApproveAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoTecherRequestResponseDto> RejectAsync(
            int requestId,
            BaoTecherRequestRejectDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoTecherRequestResponseDto> CancelAsync(
            int requestId,
            string? currentUserId,
            string? currentUserRole);
    }
}
