using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using project_essai.models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly machineDbContext _context;

    public AuthController(IConfiguration configuration, machineDbContext context)
    {
        _configuration = configuration;
        _context = context;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] UserLogin userLogin)
    {
        var user = await _context.Utilisateurs
            .Where(u => u.Matricule == userLogin.Matricule)
            .FirstOrDefaultAsync();

        if (user != null && userLogin.Password == "test123")
        {
            var token = GenerateJwtToken(userLogin.Matricule);
            return Ok(new { token });
        }

        return Unauthorized();
    }

    private string GenerateJwtToken(int matricule)
    {
        var claims = new[]
        {
        new Claim(JwtRegisteredClaimNames.Sub, matricule.ToString()),
        new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
    };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.Now.AddMinutes(30),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }


}
