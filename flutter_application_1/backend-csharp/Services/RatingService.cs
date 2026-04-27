using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services
{
    public class RatingService : IRatingService
    {
        private readonly IRatingRepository _repo;
        private readonly ITechnicianRepository _technicianRepo; 
        private readonly ILogger<RatingService> _logger;

        public RatingService(IRatingRepository repo, ITechnicianRepository technicianRepo, ILogger<RatingService> logger)
        {
            _repo = repo;
            _technicianRepo = technicianRepo; 
            _logger = logger;
        }

        public async Task<int> CreateRatingAsync(CreateRatingRequest request)
        {
            try
            {
                if (request.Puntuacion < 1 || request.Puntuacion > 5)
                    throw new ArgumentException("La puntuación debe estar entre 1 y 5");

                var rating = new RatingModel
                {
                    IdContratacion = request.IdContratacion,
                    IdTecnico = request.IdTecnico,
                    Puntuacion = request.Puntuacion,
                    Comentario = request.Comentario,
                    FotosResenaUrls = request.FotosResenaUrls
                };

                var ratingId = await _repo.CreateAsync(rating);

                // Actualizar estadísticas del técnico (promedio y conteo)
                var allRatings = await _repo.GetByTechnicianAsync(request.IdTecnico);
                if (allRatings.Any())
                {
                    double average = allRatings.Average(r => r.Puntuacion);
                    int count = allRatings.Count;
                    await _technicianRepo.UpdateRatingAsync(request.IdTecnico, average, count);
                    _logger.LogInformation($" Estadísticas actualizadas para técnico {request.IdTecnico}: Promedio {average}, Conteo {count}");
                }

                return ratingId;
            }
            catch (Exception ex)
            {
                _logger.LogError($" Error creating rating: {ex.Message}");
                throw;
            }
        }

        public async Task<List<RatingResponse>> GetRatingsByTechnicianAsync(int technicianId)
        {
            try
            {
                var ratings = await _repo.GetByTechnicianAsync(technicianId);
                return ratings.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting ratings: {ex.Message}");
                throw;
            }
        }

        public async Task<RatingResponse?> GetRatingByContractionAsync(int contractionId)
        {
            try
            {
                var rating = await _repo.GetByContractionAsync(contractionId);
                if (rating == null) return null;
                return MapToResponse(rating);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting rating for contraction {contractionId}: {ex.Message}");
                throw;
            }
        }

        private RatingResponse MapToResponse(RatingModel rating)
        {
            return new RatingResponse
            {
                IdCalificacion = rating.IdCalificacion,
                IdContratacion = rating.IdContratacion ?? 0,
                IdTecnico = rating.IdTecnico ?? 0,
                Puntuacion = rating.Puntuacion,
                Comentario = rating.Comentario,
                FotosResenaUrls = rating.FotosResenaUrls,
                NombreCliente = rating.NombreCliente,
                FotoPerfilCliente = rating.FotoPerfilCliente,
                CreatedAt = rating.CreatedAt
            };
        }
    }
}
