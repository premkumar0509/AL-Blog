codeunit 80004 "Custom Isolated Storage Mgt"
{
    Access = Internal;

    [NonDebuggable]
    procedure SetAsText(KeyName: Text; Value: Text; Scope: DataScope): Boolean
    begin
        if KeyName = '' then
            exit(false);

        if Value = '' then
            exit(false);

        if IsolatedStorage.Contains(KeyName, Scope) then
            IsolatedStorage.Delete(KeyName, Scope);

        if EncryptionEnabled() then
            exit(IsolatedStorage.SetEncrypted(KeyName, Value, Scope))
        else
            exit(IsolatedStorage.Set(KeyName, Value, Scope));
    end;

    [NonDebuggable]
    procedure SetAsSecretText(KeyName: Text; Value: SecretText; Scope: DataScope): Boolean
    begin
        if KeyName = '' then
            exit(false);

        if Value.IsEmpty() then
            exit(false);

        if IsolatedStorage.Contains(KeyName, Scope) then
            IsolatedStorage.Delete(KeyName, Scope);

        if EncryptionEnabled() then
            exit(IsolatedStorage.SetEncrypted(KeyName, Value, Scope))
        else
            exit(IsolatedStorage.Set(KeyName, Value, Scope));
    end;

    // Use only when value was stored via SetSecretAsText
    [NonDebuggable]
    procedure GetAsText(KeyName: Text; Scope: DataScope; var SecretValue: Text): Boolean
    begin
        if not IsolatedStorage.Contains(KeyName, Scope) then
            exit(false);

        exit(IsolatedStorage.Get(KeyName, Scope, SecretValue));
    end;

    // Use only when value was stored via SetSecretAsSecretText
    [NonDebuggable]
    procedure GetAsSecretText(KeyName: Text; Scope: DataScope; var SecretValue: SecretText): Boolean
    begin
        if not IsolatedStorage.Contains(KeyName, Scope) then
            exit(false);

        exit(IsolatedStorage.Get(KeyName, Scope, SecretValue));
    end;

    [NonDebuggable]
    procedure Delete(KeyName: Text; Scope: DataScope): Boolean
    begin
        if IsolatedStorage.Contains(KeyName, Scope) then
            exit(IsolatedStorage.Delete(KeyName, Scope));

        exit(false);
    end;

    procedure Has(KeyName: Text; Scope: DataScope): Boolean
    begin
        exit(IsolatedStorage.Contains(KeyName, Scope));
    end;
}