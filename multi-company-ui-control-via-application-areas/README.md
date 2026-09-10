# Multi-Company UI Control via Application Areas

Control the visibility of Business Central pages, fields, groups, and actions per company using a custom `ApplicationArea` backed by the existing **Company Information** setup.

This example shows how to expose parent-company functionality only when the current company is marked as a parent company. It avoids adding separate `Visible` expressions to every control that belongs to the feature.

## Overview

Business Central uses the `ApplicationArea` property as a UI visibility filter. A control is available when its application area is enabled for the current experience tier and company.

This sample adds a custom `ParentCompanyFeatures` application area and enables it dynamically based on the `Is Parent Company` field in **Company Information**.

## Step 1: Add a Custom Application Area

Extend the `Application Area Setup` table with a Boolean field. The field name is used as the application area tag in AL controls.

```al
tableextension 80000 "Application Area Setup Ext" extends "Application Area Setup"
{
    fields
    {
        field(80000; ParentCompanyFeatures; Boolean)
        {
            Caption = 'Parent Company Features';
        }
    }
}
```

The custom area can then be referenced as:

```al
ApplicationArea = ParentCompanyFeatures;
```

Do not extend an application area enum. Custom application areas are registered by extending the `Application Area Setup` table with a Boolean field.

## Step 2: Enable the Area Per Company

The event subscriber checks `Company Information` for the current company and sets the custom application area for each supported experience tier.

```al
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetBasicExperienceAppAreas, '', false, false)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetEssentialExperienceAppAreas, '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", OnGetPremiumExperienceAppAreas, '', false, false)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup.ParentCompanyFeatures := IsParentCompanyFeaturesEnabled();
    end;
}
```

The sample also subscribes to `OnValidateApplicationAreas` and raises an error if the custom area is unexpectedly disabled for a parent company. This protects the setup when multiple extensions contribute application areas.

The `Company Information` table and page extensions in this step add the `Is Parent Company` setting that controls the feature:

1. Open **Company Information** in the target company.
2. Set **Is Parent Company** to enable the parent-company features.
3. Refresh or reopen the page where the custom application area is used.

The application area is evaluated in the current company context, so the same extension can provide different UI experiences without separate page extensions per company.

## Step 3: Check the Area in AL Code

Application areas control UI visibility, but business logic may also need to check whether the feature is enabled. Use the helper codeunit for that runtime check:

```al
codeunit 80006 "Parent Company Area Helper"
{
    procedure IsParentCompanyAreaEnabled(): Boolean
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if ApplicationAreaMgmtFacade.GetApplicationAreaSetupRecFromCompany(ApplicationAreaSetup, CompanyName()) then
            exit(ApplicationAreaSetup.ParentCompanyFeatures);
        exit(false);
    end;
}
```

This helper reads the application area setup for the current company and returns `false` when no setup record is available.

## Step 4: Apply the Area to Pages, Actions, and Reports

Apply the custom area to the controls that should be available only for parent companies.

```al
pageextension 80000 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addafter(General)
        {
            group("Special Company Details")
            {
                Caption = 'Parent Company Insights';
                field("Parent Company Account Code"; Rec."Credit Limit (LCY)")
                {
                    ApplicationArea = ParentCompanyFeatures;
                    ToolTip = 'Specifies the account code used by the parent company.';
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action("Run Parent Company Analysis")
            {
                ApplicationArea = ParentCompanyFeatures;
                Caption = 'Run Parent Company Customer Summary';
                Image = AnalysisView;
                ToolTip = 'Runs the parent company customer summary.';
                RunObject = Report "Parent Customer Summary";
            }
        }
    }
}
```

The same application area can be applied to fields, groups, actions, and other supported page controls. The promoted action reference does not need a separate application area because it refers to the action that already has one.

### Parent Customer Summary Report

The report uses the same application area, so it is available only to companies with Parent Company features enabled:

```al
report 80000 "Parent Customer Summary"
{
    ApplicationArea = ParentCompanyFeatures;
    Caption = 'Parent Company Customer Summary';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
}
```

Because the report has a `UsageCategory`, Business Central includes it in **Tell Me**. Users in a parent company can search for **Parent Company Customer Summary** and run the report from the search results. Users in companies where `ParentCompanyFeatures` is disabled will not see the report in Tell Me.

## Why Use Application Areas?

- **Centralized control:** Enable or disable a feature for an entire company from one setup value.
- **Less page clutter:** Avoid repeating company-specific `Visible` variables across many controls.
- **Consistent behavior:** The same application area can be reused across pages, reports, and actions.
- **Company-specific experience:** Keep one extension while showing different functionality in different companies.

## Application Areas and Experience Tiers

Business Central also uses experience tiers such as **Basic**, **Essential**, and **Premium** to determine which standard application areas are available. This sample subscribes to all three experience-tier events so that `ParentCompanyFeatures` follows the company setting regardless of the selected tier.

Use the standard experience-tier configuration when you need to show or hide built-in Business Central modules. Use a custom application area when you need to control your own extension functionality.

## Common Mistakes

| Avoid | Use instead |
| :--- | :--- |
| Extending an application area enum | Extend `Application Area Setup` with a Boolean field |
| Using `Visible` on every company-specific control | Apply one custom `ApplicationArea` to the related controls |
| Checking a hard-coded company name | Store the company capability in `Company Information` |
| Enabling the area for only one experience tier | Subscribe to the experience tiers supported by the extension |
| Assuming UI visibility replaces authorization | Enforce permissions and business rules separately |

## Requirements

- Visual Studio Code
- Microsoft AL Language extension
- Business Central development environment or sandbox
- AL symbols downloaded for the target Business Central version

## Build and Test

1. Open the repository in Visual Studio Code.
2. Download symbols with **AL: Download Symbols**.
3. Package or publish the extension.
4. Open **Company Information** and toggle **Is Parent Company**.
5. Open **Customer Card** and verify that the parent-company group and analysis action appear only when the application area is enabled.

## References

- [Extending Application Areas](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-extending-application-areas)
- [ApplicationArea Property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property)
