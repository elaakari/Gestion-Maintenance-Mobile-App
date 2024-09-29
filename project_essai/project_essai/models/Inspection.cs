using System;
using System.ComponentModel.DataAnnotations;

public class Inspection
{
    [Key]
    public int IdInspection { get; set; }

    public DateTime? DateInspection { get; set; }

    public string? Observation { get; set; }

    public string CodeElementSection { get; set; }

    public int? IdIntervenant { get; set; }

    public string CodeEquipement { get; set; }

    public DateTime? DateElement { get; set; }

    public string? Resultats { get; set; }

    public string? Urgence { get; set; }

    public string Section { get; set; }

    public string CodeFamille { get; set; }

    public string? TypeMaintenance { get; set; }

    public string? NumeroInter { get; set; }

    public int? CreateUser { get; set; }

    public DateTime? CreateDateTime { get; set; }

    public int? LastUpdateUser { get; set; }

    public DateTime? LastUpdateDateTime { get; set; }

    public string CreateMachine { get; set; }
}
