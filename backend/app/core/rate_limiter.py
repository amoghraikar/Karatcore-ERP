import time
from typing import Dict, Tuple
from fastapi import HTTPException, Request, status

# Memory store for rate limiting: ip_address -> (attempt_count, first_attempt_timestamp)
_auth_attempts: Dict[str, Tuple[int, float]] = {}

WINDOW_SECONDS = 60
MAX_ATTEMPTS = 5


def check_rate_limit(client_ip: str) -> None:
    now = time.time()
    if client_ip in _auth_attempts:
        count, first_time = _auth_attempts[client_ip]
        if now - first_time > WINDOW_SECONDS:
            _auth_attempts[client_ip] = (1, now)
        else:
            if count >= MAX_ATTEMPTS:
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Too many authentication attempts. Please try again after 60 seconds.",
                )
            _auth_attempts[client_ip] = (count + 1, first_time)
    else:
        _auth_attempts[client_ip] = (1, now)
