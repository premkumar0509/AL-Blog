codeunit 80001 "Holiday Discount" implements IDiscountCalculator
{
    procedure GetDiscountAmount(Price: Decimal): Decimal
    begin
        // Flat 10 dollar discount for the holidays
        exit(10.00);
    end;
}