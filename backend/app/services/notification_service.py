import logging
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from app.core.config import settings

logger = logging.getLogger(__name__)


class NotificationService:
    @staticmethod
    @staticmethod
    def send_email(to_email: str, subject: str, message: str) -> bool:
        """Sends an email notification via SMTP."""
        if not settings.SMTP_USER or not settings.SMTP_PASSWORD:
            logger.warning("SMTP credentials not set in backend environment. Email dispatch skipped.")
            return False

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = f"{settings.EMAILS_FROM_NAME} <{settings.EMAILS_FROM_EMAIL}>"
            msg["To"] = to_email

            html_body = f"""
            <div style="font-family: Arial, sans-serif; padding: 20px; background-color: #0f172a; color: #ffffff; border-radius: 12px;">
                <h2 style="color: #f59e0b;">KaratCore Security Notification</h2>
                <p>{message}</p>
            </div>
            """
            msg.attach(MIMEText(html_body, "html"))

            with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
                if settings.SMTP_TLS:
                    server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.sendmail(settings.EMAILS_FROM_EMAIL, to_email, msg.as_string())

            logger.info(f"Email sent successfully to {to_email}")
            return True
        except Exception as e:
            logger.error(f"Failed to send Email to {to_email}: {str(e)}")
            return False

    @staticmethod
    def send_sms(to_phone: str, message: str) -> bool:
        """Sends an SMS notification via Twilio or Fast2SMS."""
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
                    "Body": message,
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
                    "message": message,
                    "language": "english",
                    "route": "q",
                    "numbers": to_phone.replace("+91", "").strip(),
                }).encode("utf-8")

                req = urllib.request.Request(url, data=body_data, method="POST")
                req.add_header("Content-Type", "application/x-www-form-urlencoded")

                with urllib.request.urlopen(req) as resp:
                    logger.info(f"Fast2SMS dispatched to {to_phone}")
                    return resp.status in (200, 201)
            except Exception as e:
                logger.error(f"Fast2SMS dispatch failed: {str(e)}")
                return False

        return False

