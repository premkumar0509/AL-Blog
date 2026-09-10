tableextension 80000 "Application Area Setup Ext" extends "Application Area Setup"
{
    fields
    {
        // Spaces in the field name are omitted in the ApplicationArea attribute.
        // Usage: ApplicationArea = ParentCompanyFeatures;
        field(80000; ParentCompanyFeatures; Boolean)
        {
            Caption = 'Parent Company Features';
        }
    }
}