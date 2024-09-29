using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace project_essai.Models
{
     public class Annuel
    {
        [Key]
        public int IdAnnuel { get; set; }
        public string element { get; set; }
        public bool ChaqueMens { get; set; }
        public int parMois { get; set; } // Mois de l'année (1 à 12)
        public int joirMois { get; set; } // Jour du mois (1 à 31)
        public bool LeMens { get; set; }
        public int SecondeMens { get; set; }
        public int JourWeekMens { get; set; } // Jour de la semaine (0 à 6, où 0 = Dimanche)
        public DateTime De { get; set; } // Date de début
        public string CodeFamille { get; set; }
        public string CodeSection { get; set; }
    }
}
