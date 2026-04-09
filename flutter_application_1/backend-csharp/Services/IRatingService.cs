using System.Collections.Generic;
using System.Threading.Tasks;
using ServitecAPI.DTOs;

namespace ServitecAPI.Services
{
    public interface IRatingService
    {
        Task<int> CreateRatingAsync(CreateRatingRequest request);
        Task<List<RatingResponse>> GetRatingsByTechnicianAsync(int technicianId);
        Task<RatingResponse?> GetRatingByContractionAsync(int contractionId);
    }
}
