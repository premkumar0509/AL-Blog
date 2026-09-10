tableextension 80001 "Company Information Ext" extends "Company Information"
{
    fields
    {
        field(80001; "Is Parent Company"; Boolean)
        {
            Caption = 'Is Parent Company';
            trigger OnValidate()
            var
                ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
            begin
                Rec.Modify();
                ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
            end;
        }
    }
}