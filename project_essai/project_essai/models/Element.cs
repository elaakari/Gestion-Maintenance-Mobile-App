using System.ComponentModel.DataAnnotations;

namespace project_essai.Models
{
    public class Element
    {
        [Key]
        public int IdElement { get; set; }
        [Required]
        public string codeElement { get; set; }
        public string Observation { get; set; }
        public string CodeSection { get; set; }
        public TimeSpan? DureeIntervention { get; set; }
        public int? NbOccurence { get; set; }
        public DateTime? DateStart { get; set; }
        public DateTime? DateFin { get; set; }
        public TimeSpan? Debut { get; set; }
        public TimeSpan? Fin { get; set; }
        public string TypeOccurrence { get; set; }
        public int? CreateUser { get; set; }
        public DateTime? CreateDateTime { get; set; }
        public int? LastUpdateUser { get; set; }
        public DateTime? LastUpdateDateTime { get; set; }
        public string CreateMachine { get; set; }
        public int? AlerteAvant { get; set; }
        public string TypePreventive { get; set; }
        public string CodeFamille { get; set; }
    }
}
