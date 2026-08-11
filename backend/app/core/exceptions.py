from typing import Any, Optional
from fastapi import HTTPException, status


class AppException(HTTPException):
    def __init__(
        self,
        status_code: int,
        code: str,
        message: str,
        details: Optional[Any] = None,
    ):
        super().__init__(
            status_code=status_code,
            detail={"error": {"code": code, "message": message, "details": details}},
        )


class AuthenticationError(AppException):
    def __init__(self, message: str = "Invalid authentication credentials"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="AUTHENTICATION_FAILED",
            message=message,
        )


class AuthorizationError(AppException):
    def __init__(self, message: str = "Access Restricted: You do not have permission to perform this action"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            code="ACCESS_RESTRICTED",
            message=message,
        )


class NotFoundError(AppException):
    def __init__(self, message: str = "Requested resource not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="RESOURCE_NOT_FOUND",
            message=message,
        )


class ConflictError(AppException):
    def __init__(self, message: str = "Resource conflict or duplicate entry"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            code="RESOURCE_CONFLICT",
            message=message,
        )


class BusinessRuleError(AppException):
    def __init__(self, message: str):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code="BUSINESS_RULE_VIOLATION",
            message=message,
        )


class AccountingUnbalancedError(BusinessRuleError):
    def __init__(self, debit_sum: float, credit_sum: float):
        super().__init__(
            message=f"Double-Entry Unbalanced Error: Total Debits (₹{debit_sum:.2f}) != Total Credits (₹{credit_sum:.2f})"
        )
