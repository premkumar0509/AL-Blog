codeunit 80005 "Company App Area Handler"
{
    local procedure IsParentCompanyFeaturesEnabled(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit(false);

        exit(CompanyInformation."Is Parent Company");
    end;

    // Enable for Basic experience tier
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetBasicExperienceAppAreas, '', false, false)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;

    // Enable for Essential experience tier
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetEssentialExperienceAppAreas, '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;

    // Enable for Premium experience tier
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetPremiumExperienceAppAreas, '', false, false)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;

    // Validate the area is correctly registered — runs after all OnGet... events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnValidateApplicationAreas, '', false, false)]
    local procedure OnValidateApplicationAreas(ExperienceTierSetup: Record "Experience Tier Setup"; TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        if (ExperienceTierSetup.Essential or ExperienceTierSetup.Premium) and IsParentCompanyFeaturesEnabled() then
            if not TempApplicationAreaSetup.ParentCompanyFeatures then
                Error('Parent Company Features must be enabled in Company Information.');
    end;
}