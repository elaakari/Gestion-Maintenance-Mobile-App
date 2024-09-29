using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace project_essai.models
{
    public class DemandeInterventions
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int? IdDemande { get; set; }
        [Key]
        public string? CodeDemande { get; set; }
        public string? Chaine { get; set; }
        public string? EtatMachine { get; set; }
        public int? CodeUrgence { get; set; }
        public string? ResumePanne { get; set; }
        public int? EtatDemande { get; set; }
        public DateTime? DateHeureDemande { get; set; }
        public int? IdTypeDemande { get; set; }
        public int? IdPanne { get; set; }
        public int? IdUtilisateur { get; set; }
        public string? CodeEquipement { get; set; }
        public int? Terminer { get; set; }
        public string? Observation { get; set; }
        public string? TypeMaintenance { get; set; }
        public string? CodeOrdre { get; set; }
        public int? Priorite { get; set; }
        public int? CreateUser { get; set; }
        public DateTime? CreateDateTime { get; set; }
        public int? LastUpdateUser { get; set; }
        public DateTime? LastUpdateDateTime { get; set; }
        public string? CreateMachine { get; set; }
        public DateTime? DateCreateReel { get; set; }
        public bool? MaintenanceTSV { get; set; }
    }
}