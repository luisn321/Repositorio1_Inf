using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ServitecAPI.Models;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class RatingRepository : IRatingRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<RatingRepository> _logger;

        public RatingRepository(DatabaseService db, ILogger<RatingRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<int> CreateAsync(RatingModel rating)
        {
            try
            {
                _logger.LogInformation($"⭐ [RatingRepository.CreateAsync] Guardando calificación para tecnico {rating.IdTecnico}");
                
                int ratingId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO calificaciones (id_contratacion, id_tecnico, puntuacion, comentario, fotos_resena_urls)
                      VALUES (@contratacion, @tecnico, @puntuacion, @comentario, @fotos);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "contratacion", (object?)rating.IdContratacion ?? DBNull.Value },
                        { "tecnico", (object?)rating.IdTecnico ?? DBNull.Value },
                        { "puntuacion", rating.Puntuacion },
                        { "comentario", (object?)rating.Comentario ?? DBNull.Value },
                        { "fotos", (object?)rating.FotosResenaUrls ?? DBNull.Value }
                    }
                );

                _logger.LogInformation($"✅ Calificación guardada con ID: {ratingId}");
                return ratingId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ Error en RatingRepository.CreateAsync: {ex.Message}");
                throw;
            }
        }

        public async Task<List<RatingModel>> GetByTechnicianAsync(int technicianId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT c.*, cl.nombre as nombre_cliente, cl.apellido as apellido_cliente, cl.foto_perfil_url as foto_cliente 
                      FROM calificaciones c 
                      LEFT JOIN contrataciones con ON c.id_contratacion = con.id_contratacion 
                      LEFT JOIN clientes cl ON con.id_cliente = cl.id_cliente 
                      WHERE c.id_tecnico = @id 
                      ORDER BY c.created_at DESC",
                    new Dictionary<string, object> { { "id", technicianId } }
                );

                return data.Select(MapToRatingModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting ratings by technician: {ex.Message}");
                throw;
            }
        }

        public async Task<RatingModel?> GetByContractionAsync(int contractionId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM calificaciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (data.Count == 0) return null;
                return MapToRatingModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting rating by contraction: {ex.Message}");
                throw;
            }
        }

        private RatingModel MapToRatingModel(Dictionary<string, object> data)
        {
            return new RatingModel
            {
                IdCalificacion = Convert.ToInt32(data["id_calificacion"]),
                IdContratacion = data["id_contratacion"] != DBNull.Value ? Convert.ToInt32(data["id_contratacion"]) : (int?)null,
                IdTecnico = data["id_tecnico"] != DBNull.Value ? Convert.ToInt32(data["id_tecnico"]) : (int?)null,
                Puntuacion = Convert.ToInt32(data["puntuacion"]),
                Comentario = (data.GetValueOrDefault("comentario") != DBNull.Value) ? (string?)data.GetValueOrDefault("comentario") : null,
                FotosResenaUrls = (data.GetValueOrDefault("fotos_resena_urls") != DBNull.Value) ? (string?)data.GetValueOrDefault("fotos_resena_urls") : null,
                NombreCliente = (data.GetValueOrDefault("nombre_cliente") != DBNull.Value) ? 
                    $"{data["nombre_cliente"]} {data.GetValueOrDefault("apellido_cliente", "")}".Trim() : null,
                FotoPerfilCliente = (data.GetValueOrDefault("foto_cliente") != DBNull.Value) ? (string?)data.GetValueOrDefault("foto_cliente") : null,
                CreatedAt = Convert.ToDateTime(data["created_at"])
            };
        }
    }
}
