using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace project_essai.Models
{
    public class Intervention
    {
        [Key]
        public string? CodeIntervention { get; set; }
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int? IdIntervention { get; set; }  

        public DateTime? DateHeureIntervention { get; set; }  
        public int? Intervenant { get; set; }  
        public bool? Cloture { get; set; } 
        public DateTime? DateHeureCloture { get; set; } 
        public string? OriginePanne { get; set; }  
        public string? Remede { get; set; } 
        public string? CausePanne { get; set; }  
        public bool? InterventionExterne { get; set; }  
        public string? CodeDemande { get; set; }  
        public int? IdTypeIntervention { get; set; }  
        public int? IdPrestataire { get; set; }  
        public bool? ChangementPiece { get; set; }  
        public bool? InterventionPause { get; set; }  
        public int? Terminer { get; set; } 
        public string? Titre { get; set; } 
        public bool? AideIntervenant { get; set; }  
        public int? CreateUser { get; set; }  
        public DateTime? CreateDateTime { get; set; }  
        public int? LastUpdateUser { get; set; }  
        public DateTime? LastUpdateDateTime { get; set; }  
        public string? CreateMachine { get; set; }  
        public DateTime? DateCreateReel { get; set; }  
    }
}
