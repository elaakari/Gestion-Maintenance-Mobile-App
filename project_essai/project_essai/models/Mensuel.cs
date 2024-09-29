using System;
using System.ComponentModel.DataAnnotations;
 
namespace project_essai.Models
{
     public class Mensuel
    {
        [Key]
        public int IdMensuel { get; set; }
        public string element { get; set; } 
        public bool Jour { get; set; }
        public int jourMois { get; set; }
        public int NbMois { get; set; }
        public bool LeMens { get; set; }
        public int SecondMens { get; set; }
        public int JourweekMens { get; set; }
        public int LeNbMois { get; set; }
        public string CodeFamille { get; set; }
        public string CodeSection { get; set; }
    }
}
