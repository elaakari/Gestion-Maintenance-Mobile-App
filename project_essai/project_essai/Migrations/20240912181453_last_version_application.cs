using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace project_essai.Migrations
{
    /// <inheritdoc />
    public partial class last_version_application : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "dbo");

            migrationBuilder.CreateTable(
                name: "Annuel",
                schema: "dbo",
                columns: table => new
                {
                    IdAnnuel = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    element = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ChaqueMens = table.Column<bool>(type: "bit", nullable: false),
                    parMois = table.Column<int>(type: "int", nullable: false),
                    joirMois = table.Column<int>(type: "int", nullable: false),
                    LeMens = table.Column<bool>(type: "bit", nullable: false),
                    SecondeMens = table.Column<int>(type: "int", nullable: false),
                    JourWeekMens = table.Column<int>(type: "int", nullable: false),
                    De = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CodeFamille = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeSection = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Annuel", x => x.IdAnnuel);
                });

            migrationBuilder.CreateTable(
                name: "DemandeInterventions",
                schema: "dbo",
                columns: table => new
                {
                    CodeDemande = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    IdDemande = table.Column<int>(type: "int", nullable: true)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Chaine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EtatMachine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CodeUrgence = table.Column<int>(type: "int", nullable: true),
                    ResumePanne = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EtatDemande = table.Column<int>(type: "int", nullable: true),
                    DateHeureDemande = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IdTypeDemande = table.Column<int>(type: "int", nullable: true),
                    IdPanne = table.Column<int>(type: "int", nullable: true),
                    IdUtilisateur = table.Column<int>(type: "int", nullable: true),
                    CodeEquipement = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Terminer = table.Column<int>(type: "int", nullable: true),
                    Observation = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TypeMaintenance = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CodeOrdre = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Priorite = table.Column<int>(type: "int", nullable: true),
                    CreateUser = table.Column<int>(type: "int", nullable: true),
                    CreateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastUpdateUser = table.Column<int>(type: "int", nullable: true),
                    LastUpdateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreateMachine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DateCreateReel = table.Column<DateTime>(type: "datetime2", nullable: true),
                    MaintenanceTSV = table.Column<bool>(type: "bit", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DemandeInterventions", x => x.CodeDemande);
                });

            migrationBuilder.CreateTable(
                name: "Elements",
                schema: "dbo",
                columns: table => new
                {
                    IdElement = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    codeElement = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Observation = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeSection = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DureeIntervention = table.Column<TimeSpan>(type: "time", nullable: true),
                    NbOccurence = table.Column<int>(type: "int", nullable: true),
                    DateStart = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DateFin = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Debut = table.Column<TimeSpan>(type: "time", nullable: true),
                    Fin = table.Column<TimeSpan>(type: "time", nullable: true),
                    TypeOccurrence = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreateUser = table.Column<int>(type: "int", nullable: true),
                    CreateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastUpdateUser = table.Column<int>(type: "int", nullable: true),
                    LastUpdateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreateMachine = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AlerteAvant = table.Column<int>(type: "int", nullable: true),
                    TypePreventive = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeFamille = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Elements", x => x.IdElement);
                });

            migrationBuilder.CreateTable(
                name: "Hebdomadaire",
                schema: "dbo",
                columns: table => new
                {
                    IdHebdomadaire = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    element = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RepeterSemaine = table.Column<int>(type: "int", nullable: false),
                    Sunday = table.Column<bool>(type: "bit", nullable: false),
                    Monday = table.Column<bool>(type: "bit", nullable: false),
                    Tuesday = table.Column<bool>(type: "bit", nullable: false),
                    Wednesday = table.Column<bool>(type: "bit", nullable: false),
                    Thursday = table.Column<bool>(type: "bit", nullable: false),
                    Friday = table.Column<bool>(type: "bit", nullable: false),
                    Saturday = table.Column<bool>(type: "bit", nullable: false),
                    CodeFamille = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeSection = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Hebdomadaire", x => x.IdHebdomadaire);
                });

            migrationBuilder.CreateTable(
                name: "Inspection",
                schema: "dbo",
                columns: table => new
                {
                    IdInspection = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateInspection = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Observation = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CodeElementSection = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IdIntervenant = table.Column<int>(type: "int", nullable: true),
                    CodeEquipement = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DateElement = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Resultats = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Urgence = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Section = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeFamille = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    TypeMaintenance = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    NumeroInter = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CreateUser = table.Column<int>(type: "int", nullable: true),
                    CreateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastUpdateUser = table.Column<int>(type: "int", nullable: true),
                    LastUpdateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreateMachine = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Inspection", x => x.IdInspection);
                });

            migrationBuilder.CreateTable(
                name: "Intervenants",
                schema: "dbo",
                columns: table => new
                {
                    IdIntervenant = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Fonction = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IdEquipe = table.Column<int>(type: "int", nullable: true),
                    IsActive = table.Column<int>(type: "int", nullable: true),
                    IsDelete = table.Column<int>(type: "int", nullable: true),
                    FirstName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LastName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AideIntervenant = table.Column<bool>(type: "bit", nullable: true),
                    CreateUser = table.Column<int>(type: "int", nullable: true),
                    CreateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastUpdateUser = table.Column<int>(type: "int", nullable: true),
                    LastUpdateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreateMachine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IdSite = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Intervenants", x => x.IdIntervenant);
                });

            migrationBuilder.CreateTable(
                name: "Interventions",
                schema: "dbo",
                columns: table => new
                {
                    CodeIntervention = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    IdIntervention = table.Column<int>(type: "int", nullable: true)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateHeureIntervention = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Intervenant = table.Column<int>(type: "int", nullable: true),
                    Cloture = table.Column<bool>(type: "bit", nullable: true),
                    DateHeureCloture = table.Column<DateTime>(type: "datetime2", nullable: true),
                    OriginePanne = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Remede = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CausePanne = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    InterventionExterne = table.Column<bool>(type: "bit", nullable: true),
                    CodeDemande = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IdTypeIntervention = table.Column<int>(type: "int", nullable: true),
                    IdPrestataire = table.Column<int>(type: "int", nullable: true),
                    ChangementPiece = table.Column<bool>(type: "bit", nullable: true),
                    InterventionPause = table.Column<bool>(type: "bit", nullable: true),
                    Terminer = table.Column<int>(type: "int", nullable: true),
                    Titre = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AideIntervenant = table.Column<bool>(type: "bit", nullable: true),
                    CreateUser = table.Column<int>(type: "int", nullable: true),
                    CreateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LastUpdateUser = table.Column<int>(type: "int", nullable: true),
                    LastUpdateDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreateMachine = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DateCreateReel = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Interventions", x => x.CodeIntervention);
                });

            migrationBuilder.CreateTable(
                name: "Mensuel",
                schema: "dbo",
                columns: table => new
                {
                    IdMensuel = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    element = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Jour = table.Column<bool>(type: "bit", nullable: false),
                    jourMois = table.Column<int>(type: "int", nullable: false),
                    NbMois = table.Column<int>(type: "int", nullable: false),
                    LeMens = table.Column<bool>(type: "bit", nullable: false),
                    SecondMens = table.Column<int>(type: "int", nullable: false),
                    JourweekMens = table.Column<int>(type: "int", nullable: false),
                    LeNbMois = table.Column<int>(type: "int", nullable: false),
                    CodeFamille = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CodeSection = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Mensuel", x => x.IdMensuel);
                });

            migrationBuilder.CreateTable(
                name: "Utilisateurs",
                schema: "dbo",
                columns: table => new
                {
                    Matricule = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Id = table.Column<int>(type: "int", nullable: false),
                    IdSite = table.Column<int>(type: "int", nullable: false),
                    IdGrade = table.Column<int>(type: "int", nullable: false),
                    IdAtelier = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Utilisateurs", x => x.Matricule);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Annuel",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "DemandeInterventions",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Elements",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Hebdomadaire",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Inspection",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Intervenants",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Interventions",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Mensuel",
                schema: "dbo");

            migrationBuilder.DropTable(
                name: "Utilisateurs",
                schema: "dbo");
        }
    }
}
