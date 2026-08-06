codeunit 80000 "Error Handling"
{
    // ── Legacy Error Procedures ──────────────────────────────────────────────
    procedure PlainError()
    begin
        Error('This is a plain legacy error. No actions, no details — just a message.');
    end;

    procedure FieldError()
    var
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := 'TEST-001';
        Item."Unit Price" := -50;
        if Item."Unit Price" < 0 then
            Item.FieldError("Unit Price", 'must be greater than zero. Negative prices are not allowed.');
    end;

    procedure TestField()
    var
        Item: Record Item;
    begin
        Item.Init();
        Item."No." := 'TEST-002';
        Item."Gen. Prod. Posting Group" := '';
        Item.TestField("Gen. Prod. Posting Group");
    end;

    // ── ErrorInfo Actions (called by the error dialog buttons) ───────────────
    procedure UnblockItemErrorAction(MyErrorInfo: ErrorInfo)
    var
        Item: Record Item;
        ItemNo: Code[20];
    begin
        ItemNo := CopyStr(MyErrorInfo.CustomDimensions.Get('ItemNo'), 1, MaxStrLen(ItemNo));

        if Item.Get(ItemNo) then begin
            Item.Blocked := false;
            Item.Modify();
            Message('Item %1 has been unblocked. You can now post the document.', ItemNo);
        end;
    end;

    procedure ErrorWithDetails(Customer: Record Customer)
    var
        MyErrorInfo: ErrorInfo;
        CustomerBalanceExceedsLimitLbl: Label 'Customer %1 has a balance of %2, but their limit is %3.', Comment = '%1 = Customer No., %2 = Current Balance, %3 = Credit Limit';
    begin
        if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then begin
            MyErrorInfo.Message := 'The customer has exceeded their credit limit.';
            MyErrorInfo.DetailedMessage := StrSubstNo(
                CustomerBalanceExceedsLimitLbl,
                Customer.Name,
                Customer."Balance (LCY)",
                Customer."Credit Limit (LCY)"
            );
            MyErrorInfo.FieldNo(Customer.FieldNo("Credit Limit (LCY)"));
            MyErrorInfo.PageNo(Page::"Customer Card");
            MyErrorInfo.RecordId(Customer.RecordId);
            MyErrorInfo.TableId(Database::Customer);
            Error(MyErrorInfo);
        end;
    end;

    // ── ErrorInfo Procedures (called from the page actions) ──────────────────
    procedure ErrorWithAction(Item: Record Item)
    var
        MyErrorInfo: ErrorInfo;
        ItemBlockedCannotBeSoldLbl: Label 'Item %1 is blocked and cannot be sold.', Comment = '%1 = Item No.';
    begin
        if Item.Blocked then begin
            MyErrorInfo.Message := StrSubstNo(ItemBlockedCannotBeSoldLbl, Item."No.");
            MyErrorInfo.CustomDimensions.Add('ItemNo', Item."No.");
            MyErrorInfo.AddAction(
                'Unblock Item',
                Codeunit::"Error Handling",
                'UnblockItemErrorAction'
            );
            Error(MyErrorInfo);
        end;
    end;

    procedure ErrorWithNavigationAction(Item: Record Item)
    var
        MyErrorInfo: ErrorInfo;
        ItemBlockedCannotBeSoldLbl: Label 'Item %1 is blocked and cannot be sold.', Comment = '%1 = Item No.';
    begin
        if not Item.Blocked then
            exit;

        MyErrorInfo.Message := StrSubstNo(ItemBlockedCannotBeSoldLbl, Item."No.");
        MyErrorInfo.CustomDimensions.Add('ItemNo', Item."No.");
        MyErrorInfo.RecordId := Item.RecordId;
        MyErrorInfo.AddNavigationAction('Open Item Card');
        MyErrorInfo.AddAction(
                            'Unblock Item',
                            Codeunit::"Error Handling",
                            'UnblockItemErrorAction'
                             );
        Error(MyErrorInfo);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CollectibleErrors()
    var
        Item: Record Item;
        MyErrorInfo: ErrorInfo;
    begin
        ClearCollectedErrors();

        // First collectible error - Item No.
        MyErrorInfo := ErrorInfo.Create('Item No. must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("No."));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Second collectible error - Description
        MyErrorInfo := ErrorInfo.Create('Description must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo(Description));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Third collectible error - Base Unit of Measure
        MyErrorInfo := ErrorInfo.Create('Base Unit of Measure must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("Base Unit of Measure"));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CollectibleErrorsAndShow()
    var
        Item: Record Item;
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        MyErrorInfo: ErrorInfo;
        AdditionalInfoLbl: Label 'Collectible Error';
    begin
        ClearCollectedErrors();

        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, Item, 0, AdditionalInfoLbl);

        // First collectible error - Item No.
        MyErrorInfo := ErrorInfo.Create('Item No. must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("No."));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Second collectible error - Description
        MyErrorInfo := ErrorInfo.Create('Description must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo(Description));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Third collectible error - Base Unit of Measure
        MyErrorInfo := ErrorInfo.Create('Base Unit of Measure must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("Base Unit of Measure"));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        if HasCollectedErrors() then
            foreach MyErrorInfo in System.GetCollectedErrors() do
                ErrorMessageManagement.LogError(Item, MyErrorInfo.Message, '');

        if ErrorMessageHandler.HasErrors() then
            ErrorMessageHandler.ShowErrors();

        ClearCollectedErrors();
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure CollectibleErrorsAndNotify()
    var
        Item: Record Item;
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageManagement: Codeunit "Error Message Management";
        MyErrorInfo: ErrorInfo;
        AdditionalInfoLbl: Label 'Collectible Error';
    begin
        ClearCollectedErrors();

        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, Item, 0, AdditionalInfoLbl);

        // First collectible error - Item No.
        MyErrorInfo := ErrorInfo.Create('Item No. must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("No."));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Second collectible error - Description
        MyErrorInfo := ErrorInfo.Create('Description must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo(Description));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        // Third collectible error - Base Unit of Measure
        MyErrorInfo := ErrorInfo.Create('Base Unit of Measure must have a value.');
        MyErrorInfo.Collectible(true);
        MyErrorInfo.FieldNo(Item.FieldNo("Base Unit of Measure"));
        MyErrorInfo.PageNo(Page::"Item Card");
        MyErrorInfo.RecordId(Item.RecordId);
        MyErrorInfo.TableId(Database::Item);
        MyErrorInfo.ErrorType(ErrorType::Client);
        MyErrorInfo.Verbosity(Verbosity::Error);
        Error(MyErrorInfo);

        if HasCollectedErrors() then
            foreach MyErrorInfo in System.GetCollectedErrors() do
                ErrorMessageManagement.LogError(Item, MyErrorInfo.Message, '');

        if ErrorMessageHandler.HasErrors() then
            ErrorMessageHandler.NotifyAboutErrors();

        ClearCollectedErrors();
    end;
}