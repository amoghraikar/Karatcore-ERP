import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from app.core.config import settings

logger = logging.getLogger(__name__)


class NotificationService:
    @staticmethod
    def send_otp_email(to_email: str, otp_code: str) -> bool:
        """Sends a 6-digit OTP verification email via SMTP."""
        if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
            logger.warning("SMTP credentials not set in backend environment. Email dispatch skipped.")
            return False

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = f"[{settings.EMAILS_FROM_NAME}] Your 6-Digit OTP Verification Code"
            msg["From"] = f"{settings.EMAILS_FROM_NAME} <{settings.EMAILS_FROM_EMAIL}>"
            msg["To"] = to_email

            html_body = f"""
            <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #0f172a; color: #ffffff; border-radius: 12px;">
                <h2 style="color: #f59e0b;">KaratCore Security Authentication</h2>
                <p>Use the following 6-digit verification code to complete your login:</p>
                <div style="font-size: 32px; font-weight: bold; letter-spacing: 6px; padding: 16px; background-color: #1e293b; color: #10b981; text-align: center; border-radius: 8px;">
                    {otp_code}
                </div>
                <p style="color: #94a3b8; font-size: 12px; margin-top: 20px;">This code will expire in 10 minutes. If you did not request this, please contact your store administrator.</p>
            </div>
            """
            msg.attach(MIMEText(html_body, "html"))

            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                if settings.SMTP_TLS:
                    server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.sendmail(settings.EMAILS_FROM_EMAIL, to_email, msg.as_string())

            logger.info(f"OTP Email sent successfully to {to_email}")
            return True
        except Exception as e:
            logger.error(f"Failed to send OTP Email to {to_email}: {str(e)}")
            return False

    @staticmethod
    def send_otp_sms(to_phone: str, otp_code: str) -> bool:
        """Sends a 6-digit OTP SMS via Twilio or Fast2SMS."""
        if settings.SMS_PROVIDER == "twilio":
            if not settings.TWILIO_ACCOUNT_SID or not settings.TWILIO_AUTH_TOKEN:
                logger.warning("Twilio credentials not configured in backend environment.")
                return False
            try:
                import urllib.parse
                import urllib.request
                import base64

                url = f"https://api.twilio.com/2010-04-01/Accounts/{settings.TWILIO_ACCOUNT_SID}/Messages.json"
                body_data = urllib.parse.urlencode({
                    "From": settings.TWILIO_FROM_NUMBER,
                    "To": to_phone,
                    "Body": f"Your KaratCore Security verification code is: {otp_code}. Valid for 10 minutes."
                }).encode("utf-8")

                req = urllib.request.Request(url, data=body_data, method="POST")
                auth_str = f"{settings.TWILIO_ACCOUNT_SID}:{settings.TWILIO_AUTH_TOKEN}"
                b64_auth = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
                req.add_header("Authorization", f"Basic {b64_auth}")

                with urllib.request.urlopen(req) as resp:
                    logger.info(f"Twilio SMS dispatched to {to_phone}. Response status: {resp.status}")
                    return resp.status in (200, 201)
            except Exception as e:
                logger.error(f"Twilio SMS dispatch failed: {str(e)}")
                return False

        elif settings.SMS_PROVIDER == "fast2sms":
            if not settings.FAST2SMS_API_KEY:
                logger.warning("Fast2SMS API key not configured in backend environment.")
                return False
            try:
                import urllib.parse
                import urllib.request

                url = "https://www.fast2sms.com/dev/bulkV2"
                body_data = urllib.parse.urlencode({
                    "authorization": settings.FAST2SMS_API_KEY,
                    "variables_values": otp_code,
                    "route": "otp",
                    "numbers": to_phone.replaceAll("+91", "").trim(),
                }).encode("utf-8")

                req = urllib.request.Request(url, data=body_data, method="POST")
                req.add_header("Content-Type", "application/x-www-form-urlencoded")

                with urllib.request.urlopen(req) as resp:
                    logger.info(f"Fast2SMS dispatched to {to_phone}")
                    return resp.status == 200
            except Exception as e:
                logger.error(f"Fast2SMS dispatch failed: {str(e)}")
                return False

        return False
