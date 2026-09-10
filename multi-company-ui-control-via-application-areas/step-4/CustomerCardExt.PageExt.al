pageextension 80000 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        // This group and all fields inside will only display
        // if ParentCompanyFeatures application area is active
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
        addlast(Promoted)
        {
            actionref(RunParentCompanyAnalysis_Promoted; "Run Parent Company Analysis")
            {
            }
        }
    }
}