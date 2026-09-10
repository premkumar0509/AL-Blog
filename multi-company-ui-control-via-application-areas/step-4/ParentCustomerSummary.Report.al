report 80000 "Parent Customer Summary"
{
    ApplicationArea = ParentCompanyFeatures;
    Caption = 'Parent Company Customer Summary';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.", Name;

            trigger OnAfterGetRecord()
            begin
                CustomerCount += 1;
            end;
        }
    }

    trigger OnPostReport()
    begin
        Message('%1 customer(s) included in the parent company summary.', CustomerCount);
    end;

    var
        CustomerCount: Integer;
}