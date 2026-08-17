page 80000 "Error Handling"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Error Handling';
    PageType = Card;

    actions
    {
        area(Processing)
        {
            // ── Legacy Errors Group ──────────────────────────────────────────
            group(LegacyErrors)
            {
                Caption = 'Legacy Errors';
                Image = ErrorLog;

                action(TestPlainError)
                {
                    ApplicationArea = All;
                    Caption = 'Plain Error';
                    ToolTip = 'Demonstrates the classic Error() call — a plain string message with no actions or details.';
                    Image = Error;

                    trigger OnAction()
                    var
                        ErrorHandling: Codeunit "Error Handling";
                    begin
                        ErrorHandling.PlainError();
                    end;
                }

                action(TestFieldError)
                {
                    ApplicationArea = All;
                    Caption = 'Field Error';
                    ToolTip = 'Demonstrates FieldError — an error scoped to a specific field when its value breaks a business rule.';
                    Image = ErrorLog;

                    trigger OnAction()
                    var
                        ErrorHandling: Codeunit "Error Handling";
                    begin
                        ErrorHandling.FieldError();
                    end;
                }

                action(TestTestField)
                {
                    ApplicationArea = All;
                    Caption = 'Test Field';
                    ToolTip = 'Demonstrates TestField — checks that a required field is not empty before proceeding.';
                    Image = CheckRulesSyntax;

                    trigger OnAction()
                    var
                        ErrorHandling: Codeunit "Error Handling";
                    begin
                        ErrorHandling.TestField();
                    end;
                }
            }
            // ── End Legacy Errors Group ──────────────────────────────────────

            action(TestErrorwithDetails)
            {
                ApplicationArea = All;
                Caption = 'Error with Details';
                ToolTip = 'Simulates an error for a customer who has exceeded their credit limit.';
                Image = Warning;

                trigger OnAction()
                var
                    Customer: Record Customer;
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    Customer.SetFilter("Credit Limit (LCY)", '>%1', 0);
                    Customer.SetAutoCalcFields("Balance (LCY)");
                    if Customer.FindSet() then
                        repeat
                            if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then begin
                                ErrorHandling.ErrorWithDetails(Customer);
                                exit;
                            end;
                        until Customer.Next() = 0;

                    Message('No customers found exceeding their credit limit. Adjust a customer''s balance or limit to test this.');
                end;
            }
            action(TestErrorwithAction)
            {
                ApplicationArea = All;
                Caption = 'Error with Action';
                ToolTip = 'Simulates an error for a blocked item and shows the Unblock action button.';
                Image = Stop;

                trigger OnAction()
                var
                    Item: Record Item;
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    Item.SetRange(Blocked, true);
                    if Item.FindFirst() then
                        ErrorHandling.ErrorWithAction(Item)
                    else
                        Message('No blocked items found. Block an item first to test this action.');
                end;
            }

            action(TestErrorWithNavigationAction)
            {
                ApplicationArea = All;
                Caption = 'Error With Navigation Action';
                ToolTip = 'Checks for a blocked item and throws an error with an Open Item Card navigation action.';
                Image = ItemLedger;

                trigger OnAction()
                var
                    Item: Record Item;
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    Item.SetRange(Blocked, true);
                    if Item.FindFirst() then
                        ErrorHandling.ErrorWithNavigationAction(Item)
                    else
                        Message('No blocked items found. Block an item first to test this action.');
                end;
            }
            action(TestCollectibleErrors)
            {
                ApplicationArea = All;
                Caption = 'Collectible Errors';
                ToolTip = 'Demonstrates collectible errors by validating multiple fields and displaying all errors together instead of stopping at the first one.';
                Image = ErrorLog;

                trigger OnAction()
                var
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    ErrorHandling.CollectibleErrors();
                end;
            }
            action(TestCollectibleErrorsAndShow)
            {
                ApplicationArea = All;
                Caption = 'Collectible Errors And Show';
                ToolTip = 'Demonstrates collectible errors by validating multiple fields and displaying all errors together in a dialog instead of stopping at the first one.';
                Image = ErrorLog;

                trigger OnAction()
                var
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    ErrorHandling.CollectibleErrorsAndShow();
                end;
            }
            action(TestCollectibleErrorsAndNotify)
            {
                ApplicationArea = All;
                Caption = 'Collectible Errors And Notify';
                ToolTip = 'Demonstrates collectible errors by validating multiple fields and displaying all errors as a notification instead of stopping at the first one.';
                Image = ErrorLog;

                trigger OnAction()
                var
                    ErrorHandling: Codeunit "Error Handling";
                begin
                    ErrorHandling.CollectibleErrorsAndNotify();
                end;
            }
        }

        area(Promoted)
        {
            actionref(TestPlainError_Promoted; TestPlainError) { }
            actionref(TestFieldError_Promoted; TestFieldError) { }
            actionref(TestTestField_Promoted; TestTestField) { }
            actionref(TestErrorwithAction_Promoted; TestErrorwithAction) { }
            actionref(TestErrorwithDetails_Promoted; TestErrorwithDetails) { }
            actionref(TestErrorWithNavigationAction_Promoted; TestErrorWithNavigationAction) { }
            actionref(TestCollectibleErrors_Promoted; TestCollectibleErrors) { }
            actionref(TestCollectibleErrorsAndShow_Promoted; TestCollectibleErrorsAndShow) { }
            actionref(TestCollectibleErrorsAndNotify_Promoted; TestCollectibleErrorsAndNotify) { }
        }
    }
}