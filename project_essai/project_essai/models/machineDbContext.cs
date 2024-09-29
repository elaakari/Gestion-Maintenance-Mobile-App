using Microsoft.EntityFrameworkCore;
using project_essai.Models;

namespace project_essai.models
{
    public class machineDbContext : DbContext
    {
        public machineDbContext(DbContextOptions<machineDbContext> options) : base(options)
        {
        }

        public DbSet<Element> Elements { get; set; }
        public DbSet<Hebdomadaire> Hebdomadaires { get; set; } 
        public DbSet<Mensuel> Mensuels { get; set; } 
        public DbSet<Annuel> Annuels { get; set; }
        public DbSet<Inspection> Inspections { get; set; }
        public DbSet<Utilisateur> Utilisateurs { get; set; }
        public DbSet<Intervention> Interventions { get; set; }
        public DbSet<DemandeInterventions> DemandeInterventions { get; set; }
        public DbSet<Intervenant> Intervenants { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Element>().ToTable("Elements", schema: "dbo");
            modelBuilder.Entity<Hebdomadaire>().ToTable("Hebdomadaire", schema: "dbo"); 
            modelBuilder.Entity<Mensuel>().ToTable("Mensuel", schema: "dbo"); 
            modelBuilder.Entity<Annuel>().ToTable("Annuel", schema: "dbo");
            modelBuilder.Entity<Inspection>().ToTable("Inspection", schema: "dbo");
            modelBuilder.Entity<Utilisateur>().ToTable("Utilisateurs", schema: "dbo");
            modelBuilder.Entity<Intervenant>().ToTable("Intervenants", schema: "dbo");
            modelBuilder.Entity<Intervention>().ToTable("Interventions", schema: "dbo");
            modelBuilder.Entity<DemandeInterventions>().ToTable("DemandeInterventions", schema: "dbo");
        }
    }
}