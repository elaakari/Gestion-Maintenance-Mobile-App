using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace project_essai.models
{
    public class Utilisateur
    {
     [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public int Matricule { get; set; }

    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
   
    public int IdSite { get; set; }
    public int IdGrade { get; set; }
    public int IdAtelier { get; set; }
}

}
