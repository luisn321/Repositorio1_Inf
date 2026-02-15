using MySql.Data.MySqlClient;
using System.Security.Cryptography;
using System.Text;

namespace ServitecAPI.Services
{
    public class DatabaseService
    {
        private readonly string _connectionString;

        public DatabaseService(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("Connection string not found.");
        }

        public MySqlConnection GetConnection()
        {
            return new MySqlConnection(_connectionString);
        }

        public string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

        public bool VerifyPassword(string password, string hash)
        {
            return BCrypt.Net.BCrypt.Verify(password, hash);
        }

        public async Task<T?> ExecuteScalarAsync<T>(string query, Dictionary<string, object>? parameters = null)
        {
            using (var connection = GetConnection())
            {
                await connection.OpenAsync();
                using (var command = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            command.Parameters.AddWithValue($"@{param.Key}", param.Value);
                        }
                    }
                    var result = await command.ExecuteScalarAsync();
                    return result != null ? (T)Convert.ChangeType(result, typeof(T)) : default;
                }
            }
        }

        public async Task<int> ExecuteNonQueryAsync(string query, Dictionary<string, object>? parameters = null)
        {
            using (var connection = GetConnection())
            {
                await connection.OpenAsync();
                using (var command = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            command.Parameters.AddWithValue($"@{param.Key}", param.Value);
                        }
                    }
                    return await command.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task<List<Dictionary<string, object>>> ExecuteQueryAsync(string query, Dictionary<string, object>? parameters = null)
        {
            var results = new List<Dictionary<string, object>>();
            using (var connection = GetConnection())
            {
                await connection.OpenAsync();
                using (var command = new MySqlCommand(query, connection))
                {
                    if (parameters != null)
                    {
                        foreach (var param in parameters)
                        {
                            command.Parameters.AddWithValue($"@{param.Key}", param.Value);
                        }
                    }
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            var row = new Dictionary<string, object>();
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                row[reader.GetName(i)] = reader.GetValue(i);
                            }
                            results.Add(row);
                        }
                    }
                }
            }
            return results;
        }
    }
}
