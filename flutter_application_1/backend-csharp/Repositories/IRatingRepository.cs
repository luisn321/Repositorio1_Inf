using System.Collections.Generic;
using System.Threading.Tasks;
using ServitecAPI.Models;

namespace ServitecAPI.Repositories
{
    public interface IRatingRepository
    {
        Task<int> CreateAsync(RatingModel rating);
        Task<List<RatingModel>> GetByTechnicianAsync(int technicianId);
        Task<RatingModel?> GetByContractionAsync(int contractionId);
    }
}
