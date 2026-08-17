codeunit 80003 "Process Sales"
{
    procedure RunApplyDiscount()
    var
        ProcessSales: Codeunit "Process Sales";
        Price: Decimal;
        DiscountType: Enum "Discount Type";
    begin
        Price := 100.00;
        DiscountType := DiscountType::VIP;

        ProcessSales.ApplyDiscount(Price, DiscountType);
    end;

    procedure ApplyDiscount(Price: Decimal; TypeOfDiscount: Enum "Discount Type")
    var
        Calculator: Interface IDiscountCalculator;
        DiscountAmount: Decimal;
    begin
        // Assign the enum — AL figures out which codeunit to use automatically
        Calculator := TypeOfDiscount;

        // Call the procedure — no IF statements needed
        DiscountAmount := Calculator.GetDiscountAmount(Price);

        Message('Your discount is %1', DiscountAmount);
    end;
}