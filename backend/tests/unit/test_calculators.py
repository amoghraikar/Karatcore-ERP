from decimal import Decimal
import pytest


def test_payment_allocation_decimal_precision():
    amount = Decimal("1000.00")
    principal = Decimal("800.00")
    interest = Decimal("200.00")
    other = Decimal("0.00")

    assert principal + interest + other == amount


def test_interest_calculation_simple():
    principal = Decimal("50000.00")
    rate_annual = Decimal("12.00")  # 12% per annum
    months = Decimal("1.00")  # 1 month

    monthly_interest = (principal * rate_annual / Decimal("100.00") / Decimal("12.00")).quantize(Decimal("0.01"))
    assert monthly_interest == Decimal("500.00")
