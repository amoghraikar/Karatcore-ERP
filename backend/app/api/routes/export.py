from typing import Optional
from fastapi import APIRouter, Depends, Response
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_owner
from app.core.database import get_db
from app.models.owner import Owner
from app.services.export_service import ExportService

router = APIRouter(prefix="/export", tags=["File Exports & Document Downloads"])


@router.get("/receipt/{payment_id}/pdf")
def download_receipt_pdf(
    payment_id: str,
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = ExportService(db)
    pdf_bytes = service.generate_receipt_pdf(payment_id)
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=KC-RCP-{payment_id}.pdf"},
    )


@router.get("/reports/pdf")
def download_reports_pdf(
    report_type: Optional[str] = "FINANCIAL_SUMMARY",
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = ExportService(db)
    pdf_bytes = service.generate_reports_pdf(report_type or "FINANCIAL_SUMMARY")
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=KaratCore_{report_type}_Report.pdf"},
    )


@router.get("/reports/csv")
def download_reports_csv(
    category: Optional[str] = "CUSTOMERS",
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = ExportService(db)
    csv_text = service.generate_csv_report(category or "CUSTOMERS")
    return Response(
        content=csv_text.encode("utf-8"),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename=KaratCore_{category}_Export.csv"},
    )


@router.get("/reports/excel")
def download_reports_excel(
    category: Optional[str] = "CUSTOMERS",
    db: Session = Depends(get_db),
    owner: Owner = Depends(get_current_owner),
):
    service = ExportService(db)
    excel_bytes = service.generate_excel_report(category or "CUSTOMERS")
    return Response(
        content=excel_bytes,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f"attachment; filename=KaratCore_{category}_Export.xlsx"},
    )
