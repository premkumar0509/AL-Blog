codeunit 80002 "VIP Discount" implements IDiscountCalculator
{
    procedure GetDiscountAmount(Price: Decimal): Decimal
    begin
        // VIP customers get 20% off the price
        exit(Price * 0.20);
    end;
}