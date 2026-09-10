pageextension 80001 "Company Information Ext" extends "Company Information"
{
    layout
    {
        addafter(Experience)
        {
            field("Is Parent Company"; Rec."Is Parent Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this company is the parent company.';
            }
        }
    }
}