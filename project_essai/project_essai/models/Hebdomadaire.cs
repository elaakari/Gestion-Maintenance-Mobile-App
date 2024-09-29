using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace project_essai.Models
{
    [Table("Hebdomadaire", Schema = "dbo")]
    public class Hebdomadaire
    {
        [Key]
        public int IdHebdomadaire { get; set; }
        public  string element { get; set; }
        public int RepeterSemaine { get; set; }
        public bool Sunday { get; set; }
        public bool Monday { get; set; }
        public bool Tuesday { get; set; }
        public bool Wednesday { get; set; }
        public bool Thursday { get; set; }
        public bool Friday { get; set; }
        public bool Saturday { get; set; }
        public string CodeFamille { get; set; }
        public string CodeSection { get; set; }
    }
}
