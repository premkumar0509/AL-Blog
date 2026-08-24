page 80002 "Isolated Storage"
{
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group("General")
            {
                Caption = 'General';

                field(APIKeyField; APIKey)
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ToolTip = 'Specifies the secret key for authenticating with the external service.';
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        if (APIKey = '') or (APIKey = PlaceholderLbl) then
                            exit;

                        IsolatedStorageMgt.SetAsText(ExternalApiKeyLbl, APIKey, DataScope::Company);
                        HasKey := true;
                        Message('API Secret has been securely stored in Isolated Storage.');
                    end;
                }

                field(IsKeyConfigured; HasKey)
                {
                    ApplicationArea = All;
                    Caption = 'Key Configured';
                    ToolTip = 'Indicates if an API key has been stored in Isolated Storage.';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        HasKey := IsolatedStorageMgt.Has(ExternalApiKeyLbl, DataScope::Company);

        if HasKey then
            APIKey := PlaceholderLbl;
    end;

    var
        IsolatedStorageMgt: Codeunit "Custom Isolated Storage Mgt";
        APIKey: Text;
        HasKey: Boolean;
        ExternalApiKeyLbl: Label 'ExternalApiKey', Locked = true;
        PlaceholderLbl: Label '***********';
}