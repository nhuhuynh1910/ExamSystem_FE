using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace JWT.Hubs
{
    [Authorize]
    public class BaoNotificationHub : Hub
    {
    }
}
