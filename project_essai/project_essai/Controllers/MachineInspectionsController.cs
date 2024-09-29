using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
 using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using project_essai.models;
using project_essai.Models;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ElementsController : ControllerBase
{
    private readonly machineDbContext _context;

    public ElementsController(machineDbContext context)
    {
        _context = context;
    }

    // GET: api/Elements
    [HttpGet]
    public async Task<ActionResult<IEnumerable<IGrouping<string, Element>>>> GetElements()
    {
        DateTime currentDate = DateTime.Now.Date;
        DayOfWeek currentDay = currentDate.DayOfWeek;

        var weeklyElements = await (from e in _context.Elements
                                    join h in _context.Hebdomadaires on e.codeElement equals h.element into joined
                                    from h in joined.DefaultIfEmpty()
                                    where e.TypeOccurrence == "Weekly" &&
                                          e.DateStart.HasValue &&
                                          h != null &&
                                          ((currentDay == DayOfWeek.Sunday && h.Sunday) ||
                                           (currentDay == DayOfWeek.Monday && h.Monday) ||
                                           (currentDay == DayOfWeek.Tuesday && h.Tuesday) ||
                                           (currentDay == DayOfWeek.Wednesday && h.Wednesday) ||
                                           (currentDay == DayOfWeek.Thursday && h.Thursday) ||
                                           (currentDay == DayOfWeek.Friday && h.Friday) ||
                                           (currentDay == DayOfWeek.Saturday && h.Saturday))
                                    select e)
                                    .ToListAsync();

        var monthlyElements = await (from e in _context.Elements
                                     join m in _context.Mensuels on e.codeElement equals m.element into joined
                                     from m in joined.DefaultIfEmpty()
                                     where e.TypeOccurrence == "Monthly" &&
                                           e.DateStart.HasValue &&
                                           m != null &&
                                           (m.jourMois == currentDate.Day)
                                     select e)
                                     .ToListAsync();

        var annualElements = await (from e in _context.Elements
                                    join a in _context.Annuels on e.codeElement equals a.element into joined
                                    from a in joined.DefaultIfEmpty()
                                    where e.TypeOccurrence == "Yearly" &&
                                          e.DateStart.HasValue &&
                                          a != null &&
                                          (a.joirMois == currentDate.Day && a.parMois == currentDate.Month)
                                    select e)
                                    .ToListAsync();

        var dailyElements = await _context.Elements
            .Where(e => (e.DateStart.HasValue && e.DateStart.Value.Date == currentDate) ||
                        (e.TypeOccurrence == "Daily" && e.DateStart.HasValue && e.DateStart.Value.Date <= currentDate))
            .ToListAsync();

        var allElements = dailyElements.Concat(weeklyElements)
                                        .Concat(monthlyElements)
                                        .Concat(annualElements)
                                        .Distinct()
                                        .ToList();

        var groupedBySection = allElements.GroupBy(e => e.TypePreventive).ToList();

        return Ok(groupedBySection);
    }

    // GET: api/Elements/date/{date}
    [HttpGet("date/{date}")]
    public async Task<ActionResult<IEnumerable<IGrouping<string, Element>>>> GetElementsByDate(DateTime date)
    {
        DayOfWeek dayOfWeek = date.DayOfWeek;

        var weeklyElements = await (from e in _context.Elements
                                    join h in _context.Hebdomadaires on e.codeElement equals h.element into joined
                                    from h in joined.DefaultIfEmpty()
                                    where e.TypeOccurrence == "Weekly" &&
                                          e.DateStart.HasValue &&
                                          h != null &&
                                          ((dayOfWeek == DayOfWeek.Sunday && h.Sunday) ||
                                           (dayOfWeek == DayOfWeek.Monday && h.Monday) ||
                                           (dayOfWeek == DayOfWeek.Tuesday && h.Tuesday) ||
                                           (dayOfWeek == DayOfWeek.Wednesday && h.Wednesday) ||
                                           (dayOfWeek == DayOfWeek.Thursday && h.Thursday) ||
                                           (dayOfWeek == DayOfWeek.Friday && h.Friday) ||
                                           (dayOfWeek == DayOfWeek.Saturday && h.Saturday))
                                    select e)
                                    .ToListAsync();

        var monthlyElements = await (from e in _context.Elements
                                     join m in _context.Mensuels on e.codeElement equals m.element into joined
                                     from m in joined.DefaultIfEmpty()
                                     where e.TypeOccurrence == "Monthly" &&
                                           e.DateStart.HasValue &&
                                           m != null &&
                                           (m.jourMois == date.Day)
                                     select e)
                                     .ToListAsync();

        var annualElements = await (from e in _context.Elements
                                    join a in _context.Annuels on e.codeElement equals a.element into joined
                                    from a in joined.DefaultIfEmpty()
                                    where e.TypeOccurrence == "Yearly" &&
                                          e.DateStart.HasValue &&
                                          a != null &&
                                          (a.joirMois == date.Day && a.parMois == date.Month)
                                    select e)
                                    .ToListAsync();

        var dailyAndOtherElements = await _context.Elements
            .Where(e => (e.DateStart.HasValue && e.DateStart.Value.Date == date.Date) ||
                        (e.TypeOccurrence == "Daily" && e.DateStart.HasValue && e.DateStart.Value.Date <= date.Date) ||
                        (e.TypeOccurrence == "Monthly" && e.DateStart.HasValue && e.DateStart.Value.AddMonths(1).Date == date.Date) ||
                        (e.TypeOccurrence == "Yearly" && e.DateStart.HasValue && e.DateStart.Value.AddYears(1).Date == date.Date))
            .ToListAsync();

        var allElements = dailyAndOtherElements.Concat(weeklyElements)
                                               .Concat(monthlyElements)
                                               .Concat(annualElements)
                                               .Distinct()
                                               .ToList();

        var groupedBySection = allElements.GroupBy(e => e.TypePreventive).ToList();

        return Ok(groupedBySection);
    }

    // GET: api/Elements/5
    [HttpGet("{id}")]
    public async Task<ActionResult<Element>> GetElement(int id)
    {
        var element = await _context.Elements.FindAsync(id);
        if (element == null)
        {
            return NotFound();
        }

        return element;
    }

    // GET: api/Elements/code/{code}
    [HttpGet("code/{code}")]
    public async Task<ActionResult<Element>> GetElementByCode(string code)
    {
        if (string.IsNullOrEmpty(code))
        {
            return BadRequest("Code élément est requis.");
        }

        var element = await _context.Elements
            .FirstOrDefaultAsync(e => e.codeElement == code);

        if (element == null)
        {
            return NotFound("Élément non trouvé.");
        }

        return Ok(element);
    }

    // POST: api/Elements
    [HttpPost]
    public async Task<ActionResult<Element>> PostElement(Element element)
    {
        _context.Elements.Add(element);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetElement), new { id = element.IdElement }, element);
    }

    // PUT: api/Elements/5
    [HttpPut("{id}")]
    public async Task<IActionResult> PutElement(int id, [FromBody] Element element)
    {
        if (id != element.IdElement)
        {
            return BadRequest("ID mismatch.");
        }

        if (element == null)
        {
            return BadRequest("Element cannot be null.");
        }

        _context.Entry(element).State = EntityState.Modified;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!ElementExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // DELETE: api/Elements/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteElement(int id)
    {
        var element = await _context.Elements.FindAsync(id);
        if (element == null)
        {
            return NotFound();
        }

        _context.Elements.Remove(element);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // POST: api/Elements/saveInspection
    [HttpPost("saveInspection")]
    [ProducesResponseType(201)]
    public async Task<ActionResult<Inspection>> SaveInspection(Inspection inspection)
    {
        if (inspection == null)
        {
            return BadRequest("Inspection object cannot be null.");
        }

        _context.Inspections.Add(inspection);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetInspection), new { id = inspection.IdInspection }, inspection);
    }


    // GET: api/Elements/inspection/5
    [HttpGet("inspection/{id}")]
    public async Task<ActionResult<Inspection>> GetInspection(int id)
    {
        var inspection = await _context.Inspections.FindAsync(id);

        if (inspection == null)
        {
            return NotFound();
        }

        return Ok(inspection);
    }

    // PUT: api/Elements/inspection/{id}
    [HttpPut("inspection/{id}")]
    public async Task<IActionResult> UpdateInspection(int id, Inspection inspection)
    {
        if (id != inspection.IdInspection)
        {
            return BadRequest("ID mismatch");
        }

        var existingInspection = await _context.Inspections.FindAsync(id);
        if (existingInspection == null)
        {
            return NotFound();
        }

        existingInspection.DateInspection = inspection.DateInspection;
        existingInspection.Observation = inspection.Observation;
        existingInspection.CodeElementSection = inspection.CodeElementSection;
        existingInspection.IdIntervenant = inspection.IdIntervenant;
        existingInspection.CodeEquipement = inspection.CodeEquipement;
        existingInspection.DateElement = inspection.DateElement;
        existingInspection.Resultats = inspection.Resultats;
        existingInspection.Urgence = inspection.Urgence;
        existingInspection.Section = inspection.Section;
        existingInspection.CodeFamille = inspection.CodeFamille;
        existingInspection.TypeMaintenance = inspection.TypeMaintenance;
        existingInspection.NumeroInter = inspection.NumeroInter;
        existingInspection.CreateUser = inspection.CreateUser;
        existingInspection.CreateDateTime = inspection.CreateDateTime;
        existingInspection.LastUpdateUser = inspection.LastUpdateUser;
        existingInspection.LastUpdateDateTime = inspection.LastUpdateDateTime;
        existingInspection.CreateMachine = inspection.CreateMachine;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!InspectionExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // DELETE: api/Elements/inspection/{id}
    [HttpDelete("inspection/{id}")]
    public async Task<IActionResult> DeleteInspection(int id)
    {
        var inspection = await _context.Inspections.FindAsync(id);
        if (inspection == null)
        {
            return NotFound();
        }

        _context.Inspections.Remove(inspection);
        await _context.SaveChangesAsync();

        return NoContent();
    }
    /*// GET: api/Elements/inspections/not-ok
    [HttpGet("inspections/not-ok")]
    public async Task<ActionResult<IEnumerable<Inspection>>> GetInspectionsWithResultNotOk()
    {
        var inspections = await _context.Inspections
            .Where(i => i.Resultats != "OK")
            .ToListAsync();

        if (inspections == null || !inspections.Any())
        {
            return NotFound("Aucune inspection trouvée avec un résultat non OK.");
        }

        return Ok(inspections);
    }*/

    // GET: api/Elements/inspections/not-ok?month={month}
    [HttpGet("inspections/not-ok")]
    public async Task<ActionResult<IEnumerable<Inspection>>> GetInspectionsWithResultNotOkForMonth([FromQuery] string month)
    {
        if (string.IsNullOrEmpty(month))
        {
            return BadRequest("Le mois est requis.");
        }

        // Convertir le mois en DateTime
        DateTime startDate;
        try
        {
            startDate = DateTime.ParseExact(month, "MM-yyyy", System.Globalization.CultureInfo.InvariantCulture);
        }

        catch (FormatException)
        {
            return BadRequest("Le mois est dans un format incorrect.");
        }

        // Calculer les dates de début et de fin du mois
        var endDate = startDate.AddMonths(1).AddDays(-1);

        var inspections = await _context.Inspections
            .Where(i => i.Resultats != "OK" &&
                        i.DateInspection.HasValue &&
                        i.DateInspection.Value >= startDate &&
                        i.DateInspection.Value <= endDate)
            .ToListAsync();

        if (inspections == null || !inspections.Any())
        {
            return NotFound("Aucune inspection trouvée avec un résultat non OK pour le mois spécifié.");
        }

        return Ok(inspections);
    }

    // GET: api/Elements/inspections?codeElement={codeElement}&codeSection={codeSection}&date={date}
    [HttpGet("inspections")]
    public async Task<ActionResult<IEnumerable<Inspection>>> GetInspectionsByElementAndDate(
        [FromQuery] string codeElement,
        [FromQuery] string codeSection,
        [FromQuery] DateTime date)
    {
        if (string.IsNullOrEmpty(codeElement) || string.IsNullOrEmpty(codeSection))
        {
            return BadRequest("Code élément est requis.");
        }

        var inspections = await _context.Inspections
            .Where(i => i.CodeElementSection == codeElement &&
                        i.Section == codeSection &&
                        i.DateInspection.HasValue &&
                        i.DateInspection.Value.Date == date.Date)
            .ToListAsync();

        if (inspections == null || !inspections.Any())
        {
            return NotFound("Aucune inspection trouvée pour les critères donnés.");
        }

        return Ok(inspections);
    }
    // GET: api/Elements/intervenant

    [HttpGet("itervenant")]
    public async Task<ActionResult<IEnumerable<Intervenant>>> GetIntervenants()
    {
        return await _context.Intervenants.ToListAsync();
    }


    // GET: api/Elements/intervenant/{id}
    [HttpGet("intervenant/{id}")]
    public async Task<ActionResult<Intervenant>> GetIntervenant(int id)
    {
        var intervenant = await _context.Intervenants
                 .Where(i => i.IdIntervenant == id)
                 .FirstOrDefaultAsync();

        if (intervenant == null)
        {
            return NotFound();
        }

        return intervenant;
    }


    // GET api/Elements//firstname/lastname
    [HttpGet("{firstname}/{lastname}")]
    public async Task<ActionResult<Intervenant>> GetIntervenantByFirstnameLastname(string firstname, string lastname)
    {
        var intervenant = await _context.Intervenants
            .Where(i => i.FirstName.ToLower() == firstname.ToLower() && i.LastName.ToLower() == lastname.ToLower())
            .FirstOrDefaultAsync();

        if (intervenant == null)
        {
            return NotFound();
        }

        return intervenant;
    }

    // GET: api/Elements/intervention
     [HttpGet("intervention")]
     public async Task<ActionResult<IEnumerable<Intervention>>> GetInterventions()
     {
         return await _context.Interventions.ToListAsync();
     }

    // GET: api/Elements/ids/{id}
    [HttpGet("ids/{id}")]
    public async Task<ActionResult<Intervention>> GetbyId(int id)
    {
        var intervention = await _context.Interventions
               .Where(i => i.IdIntervention == id)
               .FirstOrDefaultAsync();

        if (intervention == null)
        {
            return NotFound();
        }

        return intervention;
    } 
    // GET: api/Elements/demandeintervention/{id}
    [HttpGet("demandeintervention/{id}")]
    public async Task<ActionResult<DemandeInterventions>> GetDemandebyId(int id)
    {
        var demandeintervention = await _context.DemandeInterventions
               .Where(i => i.IdDemande == id)
               .FirstOrDefaultAsync();

        if (demandeintervention == null)
        {
            return NotFound();
        }

        return demandeintervention;
    }

    [HttpGet("demande/{code}")]
    public async Task<ActionResult<DemandeInterventions>> GetDemandebyCode(string code)
    {
        var demandeintervention = await _context.DemandeInterventions
               .Where(i => i.CodeDemande == code)
               .FirstOrDefaultAsync();

        if (demandeintervention == null)
        {
            return NotFound();
        }

        return demandeintervention;
    }
    // GET: api/Elements/codes/{codeIntervention}
    [HttpGet("codes/{codeIntervention}")]
     public async Task<ActionResult<Intervention>> GetbyCode(string codeIntervention)
     {
         var intervention = await _context.Interventions
             .FirstOrDefaultAsync(i => i.CodeIntervention == codeIntervention);

         if (intervention == null)
         {
             return NotFound();
         }

         return intervention;
     }

     // GET: api/Elements/intervenants/{idIntervenant}/interventions
     [HttpGet("intervenants/{idIntervenant}/interventions")]
     public async Task<ActionResult<IEnumerable<Intervention>>> GetInterventionsSelectedByIntervenant(int idIntervenant)
     {
         var interventions = await _context.Interventions
             .Where(i => i.Intervenant == idIntervenant)
             .ToListAsync();

         return interventions;
     }

    // GET: api/Elements/interventions/dates/{startDate}/{endDate}
    [HttpGet("interventions/dates/{startDate}/{endDate}")]
    public async Task<ActionResult<IEnumerable<Intervention>>> GetInterventionsBetweenDates(DateTime startDate, DateTime endDate)
    {
        var interventions = await _context.Interventions
            .Where(i => i.DateHeureIntervention.HasValue && i.DateHeureIntervention.Value.Date >= startDate.Date && i.DateHeureIntervention.Value.Date <= endDate.Date)
            .ToListAsync();

        return interventions;
    }
    // POST: api/Elements/intervention
    [HttpPost("intervention")]
    public async Task<ActionResult<Intervention>> AddIntervention(Intervention intervention)
    {
        if (intervention == null)
        {
            return BadRequest("Intervention object cannot be null.");
        }

        // Générer le CodeIntervention
        var dernierIntervention = await _context.Interventions
            .OrderByDescending(i => i.CodeIntervention)
            .FirstOrDefaultAsync();

        int prochainNumeroIntervention = 1; // Numéro de départ par défaut

        if (dernierIntervention != null && !string.IsNullOrEmpty(dernierIntervention.CodeIntervention))
        {
            string dernierCodeIntervention = dernierIntervention.CodeIntervention;
            string numeroStringIntervention = dernierCodeIntervention.Substring(2); // Extrait "000350" de "FI000350"

            if (int.TryParse(numeroStringIntervention, out int numeroIntervention))
            {
                prochainNumeroIntervention = numeroIntervention + 1;
            }
        }

        intervention.CodeIntervention = $"FI{prochainNumeroIntervention:D6}"; // Format "FI000001", "FI000002", etc.

        // Générer le CodeDemande
        var dernierDemande = await _context.Interventions
            .Where(d => d.CodeDemande != null && d.CodeDemande.StartsWith("DI"))
            .OrderByDescending(d => d.CodeDemande)
            .FirstOrDefaultAsync();

        int prochainNumeroDemande = 1; // Numéro de départ par défaut

        if (dernierDemande != null && !string.IsNullOrEmpty(dernierDemande.CodeDemande))
        {
            string dernierCodeDemande = dernierDemande.CodeDemande;
            string numeroStringDemande = dernierCodeDemande.Substring(2); // Extrait "000043" de "DI000043"

            if (int.TryParse(numeroStringDemande, out int numeroDemande))
            {
                prochainNumeroDemande = numeroDemande + 1;
            }
        }

        intervention.CodeDemande = $"DI{prochainNumeroDemande:D6}"; // Format "DI000001", "DI000002", etc.

        intervention.CreateDateTime = DateTime.Now;

        _context.Interventions.Add(intervention);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetbyId), new { id = intervention.IdIntervention }, intervention);
    }


    [HttpPut("Interv/{id}")]
    public async Task<IActionResult> UpdateIntervention(int id, [FromBody] Intervention intervention)
    {
         if (id != intervention.IdIntervention)
        {
            return BadRequest("L'ID de l'intervention ne correspond pas à l'ID dans l'URL.");
        }

         var existingIntervention = await _context.Interventions
            .FirstOrDefaultAsync(i => i.IdIntervention == id);

        if (existingIntervention == null)
        {
            return NotFound("Intervention non trouvée.");
        }

         var originalIdIntervention = existingIntervention.IdIntervention;
        var originalCodeIntervention = existingIntervention.CodeIntervention;
        var originalCodeDemande = existingIntervention.CodeDemande;

         existingIntervention.DateHeureIntervention = intervention.DateHeureIntervention;
        existingIntervention.Intervenant = intervention.Intervenant;
        existingIntervention.Cloture = intervention.Cloture;
        existingIntervention.DateHeureCloture = intervention.DateHeureCloture;
        existingIntervention.OriginePanne = intervention.OriginePanne;
        existingIntervention.Remede = intervention.Remede;
        existingIntervention.CausePanne = intervention.CausePanne;
        existingIntervention.InterventionExterne = intervention.InterventionExterne;
        existingIntervention.IdTypeIntervention = intervention.IdTypeIntervention;
        existingIntervention.IdPrestataire = intervention.IdPrestataire;
        existingIntervention.ChangementPiece = intervention.ChangementPiece;
        existingIntervention.InterventionPause = intervention.InterventionPause;
        existingIntervention.Titre = intervention.Titre;
        existingIntervention.AideIntervenant = intervention.AideIntervenant;
        existingIntervention.CreateUser = intervention.CreateUser;
        existingIntervention.CreateDateTime = intervention.CreateDateTime;
        existingIntervention.LastUpdateUser = intervention.LastUpdateUser;
        existingIntervention.LastUpdateDateTime = intervention.LastUpdateDateTime;
        existingIntervention.CreateMachine = intervention.CreateMachine;
        existingIntervention.DateCreateReel = intervention.DateCreateReel;

         existingIntervention.IdIntervention = originalIdIntervention;
        existingIntervention.CodeIntervention = originalCodeIntervention;
        existingIntervention.CodeDemande = originalCodeDemande;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!InterventionExists(id))
            {
                return NotFound("Intervention non trouvée après la tentative de mise à jour.");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }


    [HttpGet("InterventionBycodeDemande")]
    public async Task<IActionResult> GetInterventionsByDateAndCodeDemande(
        [FromQuery] DateTime date,
        [FromQuery] string? codeDemande)
    {
        try
        {
             if (date == null)
            {
                return BadRequest("La date est requise.");
            }

             var interventions = await _context.Interventions
                .Where(i => i.DateHeureIntervention.HasValue && i.DateHeureIntervention.Value.Date == date.Date &&
                            (codeDemande == null || i.CodeDemande == codeDemande))
                .ToListAsync();

            if (interventions == null || !interventions.Any())
            {
                return NotFound("Aucune intervention trouvée pour les critères donnés.");
            }

            return Ok(interventions);
        }
        catch (Exception ex)
        {
             // Log.Error(ex, "Erreur lors de la récupération des interventions");

            return StatusCode(500, "Erreur interne du serveur");
        }
    }
     // POST :api/Elements/demandeintervention
    [HttpPost("demandeintervention")]
    public async Task<ActionResult<DemandeInterventions>> AddDemandeIntervention(DemandeInterventions demandeIntervention)
    {
        if (demandeIntervention == null)
        {
            return BadRequest("DemandeIntervention object cannot be null.");
        }

        // Generate CodeDemande
        var dernierDemande = await _context.DemandeInterventions
            .OrderByDescending(d => d.CodeDemande)
            .FirstOrDefaultAsync();

        int prochainNumeroDemande = 1; // Default starting number

        if (dernierDemande != null && !string.IsNullOrEmpty(dernierDemande.CodeDemande))
        {
            string dernierCodeDemande = dernierDemande.CodeDemande;
            string numeroStringDemande = dernierCodeDemande.Substring(2); // Extract "000043" from "DI000043"

            if (int.TryParse(numeroStringDemande, out int numeroDemande))
            {
                prochainNumeroDemande = numeroDemande + 1;
            }
        }

        demandeIntervention.CodeDemande = $"DI{prochainNumeroDemande:D6}"; // Format "DI000001", "DI000002", etc.

        // Generate CodeOrdre
        var dernierOrdre = await _context.DemandeInterventions
            .OrderByDescending(o => o.CodeOrdre)
            .FirstOrDefaultAsync();

        int prochainNumeroOrdre = 1; // Default starting number

        if (dernierOrdre != null && !string.IsNullOrEmpty(dernierOrdre.CodeOrdre))
        {
            string dernierCodeOrdre = dernierOrdre.CodeOrdre;
            string numeroStringOrdre = dernierCodeOrdre.Substring(2); // Extract "000000" from "OM000000"

            if (int.TryParse(numeroStringOrdre, out int numeroOrdre))
            {
                prochainNumeroOrdre = numeroOrdre + 1;
            }
        }

        demandeIntervention.CodeOrdre = $"OM{prochainNumeroOrdre:D6}"; // Format "OM000001", "OM000002", etc.

        demandeIntervention.CreateDateTime = DateTime.Now;

        _context.DemandeInterventions.Add(demandeIntervention);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetDemandebyId), new { id = demandeIntervention.IdDemande }, demandeIntervention);
    }
    //GET: api/Elements/utilisateur
    [HttpGet("utilisateur")]
    public async Task<ActionResult<IEnumerable<Utilisateur>>> GetUtilisateurs()
    {
        return Ok(await _context.Utilisateurs.ToListAsync());
    }

    // PUT : api /Elements/demandeintervention/12
    [HttpPut("demandeintervention/{id}")]
    public async Task<IActionResult> UpdateDemandeIntervention(int id, [FromBody] DemandeInterventions demandeIntervention)
    {
        if (id != demandeIntervention.IdDemande)
        {
            return BadRequest("L'ID de la demande d'intervention ne correspond pas à l'ID dans l'URL.");
        }

        var existingDemande = await _context.DemandeInterventions
            .FirstOrDefaultAsync(d => d.IdDemande == id);

        if (existingDemande == null)
        {
            return NotFound("Demande d'intervention non trouvée.");
        }

        // Update properties
        existingDemande.Chaine = demandeIntervention.Chaine;
        existingDemande.EtatMachine = demandeIntervention.EtatMachine;
        existingDemande.CodeUrgence = demandeIntervention.CodeUrgence;
        existingDemande.ResumePanne = demandeIntervention.ResumePanne;
        existingDemande.EtatDemande = demandeIntervention.EtatDemande;
        existingDemande.DateHeureDemande = demandeIntervention.DateHeureDemande;
        existingDemande.IdTypeDemande = demandeIntervention.IdTypeDemande;
        existingDemande.IdPanne = demandeIntervention.IdPanne;
        existingDemande.IdUtilisateur = demandeIntervention.IdUtilisateur;
        existingDemande.CodeEquipement = demandeIntervention.CodeEquipement;
        existingDemande.Terminer = demandeIntervention.Terminer;
        existingDemande.Observation = demandeIntervention.Observation;
        existingDemande.TypeMaintenance = demandeIntervention.TypeMaintenance;
        existingDemande.CreateUser = demandeIntervention.CreateUser;
        existingDemande.CreateDateTime = demandeIntervention.CreateDateTime;
        existingDemande.LastUpdateUser = demandeIntervention.LastUpdateUser;
        existingDemande.LastUpdateDateTime = demandeIntervention.LastUpdateDateTime;
        existingDemande.CreateMachine = demandeIntervention.CreateMachine;
        existingDemande.DateCreateReel = demandeIntervention.DateCreateReel;
        existingDemande.MaintenanceTSV = demandeIntervention.MaintenanceTSV;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!DemandeInterventionExists(id))
            {
                return NotFound("Demande d'intervention non trouvée après la tentative de mise à jour.");
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    private bool DemandeInterventionExists(int id)
    {
        return _context.DemandeInterventions.Any(d => d.IdDemande == id);
    }
    // GET: api/Elements/utilisateur/5
    [HttpGet("utilisateur/{matricule}")]
    public async Task<ActionResult<Utilisateur>> GetUtilisateur(int matricule)
    {
        var utilisateur = await _context.Utilisateurs.FindAsync(matricule);

        if (utilisateur == null)
        {
            return NotFound();
        }

        return utilisateur;

    }

    //Posy: api/Elements/utilisateur 
    [HttpPost("utilisateur")]
    public async Task<ActionResult<Utilisateur>> PostUtilisateur(Utilisateur utilisateur)
    {
        if (utilisateur == null)
        {
            return BadRequest("L'utilisateur ne peut pas être nul.");
        }

         if (UtilisateurExists(utilisateur.Matricule))
        {
            return Conflict("Un utilisateur avec ce matricule existe déjà.");
        }

  
        // Set IDENTITY_INSERT to ON for the Utilisateurs table
        _context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT [dbo].[Utilisateurs] ON");

        try
        {
             _context.Utilisateurs.Add(utilisateur);

             await _context.SaveChangesAsync();

            // Set IDENTITY_INSERT to OFF for the Utilisateurs table
            _context.Database.ExecuteSqlRaw("SET IDENTITY_INSERT [dbo].[Utilisateurs] OFF");
        }
        catch (DbUpdateException ex)
        {
             if (ex.InnerException != null)
            {
                return StatusCode(StatusCodes.Status500InternalServerError,
                    $"Une erreur est survenue lors de la sauvegarde de l'utilisateur : {ex.InnerException.Message}");
            }
            else
            {
                return StatusCode(StatusCodes.Status500InternalServerError,
                    "Une erreur est survenue lors de la sauvegarde de l'utilisateur.");
            }
        }
        catch (Exception ex)
        {
             return StatusCode(StatusCodes.Status500InternalServerError,
                $"Une erreur est survenue lors de la sauvegarde de l'utilisateur : {ex.Message}");
        }

         return CreatedAtAction(nameof(GetUtilisateur), new { matricule = utilisateur.Matricule }, utilisateur);
    }

    // put :api/Elements/utilisateur/807
    [HttpPut("utilisateur/{matricule}")]
    public async Task<IActionResult> PutUtilisateur(int matricule, Utilisateur utilisateur)
    {
        if (matricule != utilisateur.Matricule)
        {
            return BadRequest("Le matricule fourni ne correspond pas à celui de l'utilisateur.");
        }

        var existingUtilisateur = await _context.Utilisateurs.FindAsync(matricule);

        if (existingUtilisateur == null)
        {
            return NotFound();
        }

        existingUtilisateur.IdSite = utilisateur.IdSite;
        existingUtilisateur.IdGrade = utilisateur.IdGrade;
        existingUtilisateur.IdAtelier = utilisateur.IdAtelier;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!UtilisateurExists(matricule))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // DELETE: api/Elements/utilisateur/5
    [HttpDelete("utilisateur/{matricule}")]
    public async Task<IActionResult> DeleteUtilisateur(int matricule)
    {
        var utilisateur = await _context.Utilisateurs.FindAsync(matricule);
        if (utilisateur == null)
        {
            return NotFound();
        }

        _context.Utilisateurs.Remove(utilisateur);
        await _context.SaveChangesAsync();

        return NoContent();
    }

 private bool UtilisateurExists(int matricule)
    {
        return _context.Utilisateurs.Any(e => e.Matricule == matricule);
    }
 
    private bool InterventionExists(int id)
    {
        return _context.Interventions.Any(e => e.IdIntervention== id);
    }

    private bool InspectionExists(int id)
    {
        return _context.Inspections.Any(e => e.IdInspection == id);
    }



    private bool ElementExists(int id)
    {
        return _context.Elements.Any(e => e.IdElement == id);
    }
}
