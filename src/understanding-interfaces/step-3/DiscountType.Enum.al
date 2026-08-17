enum 80000 "Discount Type" implements IDiscountCalculator
{
    Extensible = true;

    value(0; Holiday)
    {
        Implementation = IDiscountCalculator = "Holiday Discount";
    }
    value(1; VIP)
    {
        Implementation = IDiscountCalculator = "VIP Discount";
    }
}