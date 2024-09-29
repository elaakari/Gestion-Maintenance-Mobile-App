using System.ComponentModel.DataAnnotations;

namespace project_essai.Models
{
    public class Intervenant
    {
        [Key]
        public int? IdIntervenant { get; set; }  

        public string? Fonction { get; set; } 
        public int? IdEquipe { get; set; }  
        public int? IsActive { get; set; } 
        public int? IsDelete { get; set; }
        public string? FirstName { get; set; }  
        public string? LastName { get; set; }  
        public bool? AideIntervenant { get; set; }  
        public int? CreateUser { get; set; } 
        public DateTime? CreateDateTime { get; set; }  
        public int? LastUpdateUser { get; set; } 
        public DateTime? LastUpdateDateTime { get; set; }  
        public string? CreateMachine { get; set; }  
        public int? IdSite { get; set; }  
    }
}
