using JWT.DTOs.BaoAccess;

namespace JWT.Services.Contracts
{
    public interface IBaoAccessService
    {
        Task<BaoAccessResponseDto> CheckAccessAsync(
            int targetId,
            BaoAccessRequestDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoStartResponseDto> StartAsync(
            int targetId,
            BaoAccessRequestDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoAttemptDetailResponseDto> GetAttemptAsync(
            int attemptId,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoSaveAnswerResponseDto> SaveAnswerAsync(
            int attemptId,
            BaoSaveAnswerRequestDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoSubmitResponseDto> SubmitAsync(
            int attemptId,
            BaoSubmitRequestDto request,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoResultResponseDto> GetResultAsync(
            int targetId,
            string? currentUserId,
            string? currentUserRole);

        Task<BaoRankingResponseDto> GetRankingAsync(int targetId, int top);
    }
}
