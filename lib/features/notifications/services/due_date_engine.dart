import '../../loans/models/loan_model.dart';
import '../models/notification_models.dart';

abstract class IDueDateEngineService {
  List<DueDateItemModel> getUpcomingDueItems(List<LoanModel> loans, {int windowDays = 30});
  List<DueDateItemModel> getOverdueItems(List<LoanModel> loans);
  List<NotificationModel> generateDueNotifications(List<LoanModel> loans);
}

class DueDateEngineService implements IDueDateEngineService {
  const DueDateEngineService();

  @override
  List<DueDateItemModel> getUpcomingDueItems(List<LoanModel> loans, {int windowDays = 30}) {
    final now = DateTime.now();
    final results = <DueDateItemModel>[];

    for (final loan in loans) {
      if (loan.status == LoanStatus.closed ||
          loan.status == LoanStatus.cancelled ||
          loan.status == LoanStatus.writtenOff) {
        continue;
      }
      final dueDate = loan.nextDueDate;
      final daysRemaining = dueDate.difference(now).inDays;
      if (daysRemaining >= 0 && daysRemaining <= windowDays) {
        results.add(
          DueDateItemModel(
            loanId: loan.id,
            customerName: loan.customerName,
            principalAmount: loan.principalAmount,
            interestDue: loan.accruedInterest,
            dueDate: dueDate,
            daysRemaining: daysRemaining,
            isOverdue: false,
          ),
        );
      }
    }

    results.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return results;
  }

  @override
  List<DueDateItemModel> getOverdueItems(List<LoanModel> loans) {
    final now = DateTime.now();
    final results = <DueDateItemModel>[];

    for (final loan in loans) {
      if (loan.status == LoanStatus.closed ||
          loan.status == LoanStatus.cancelled ||
          loan.status == LoanStatus.writtenOff) {
        continue;
      }
      final dueDate = loan.nextDueDate;

      if (dueDate.isBefore(now) || loan.status == LoanStatus.overdue) {
        final daysRemaining = dueDate.difference(now).inDays; // negative number
        results.add(
          DueDateItemModel(
            loanId: loan.id,
            customerName: loan.customerName,
            principalAmount: loan.principalAmount,
            interestDue: loan.accruedInterest,
            dueDate: dueDate,
            daysRemaining: daysRemaining,
            isOverdue: true,
          ),
        );
      }
    }

    results.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return results;
  }

  @override
  List<NotificationModel> generateDueNotifications(List<LoanModel> loans) {
    final notifications = <NotificationModel>[];
    final now = DateTime.now();

    for (final loan in loans) {
      if (loan.status == LoanStatus.closed ||
          loan.status == LoanStatus.cancelled ||
          loan.status == LoanStatus.writtenOff) {
        continue;
      }

      final dueDate = loan.nextDueDate;
      final diffDays = dueDate.difference(now).inDays;

      if (diffDays < 0 || loan.status == LoanStatus.overdue) {
        final overdueDays = diffDays.abs();
        notifications.add(
          NotificationModel(
            id: 'NOTIF-DUE-OVERDUE-${loan.id}',
            title: 'Overdue Loan Alert: ${loan.id}',
            message: 'Loan ${loan.id} for ${loan.customerName} is overdue by $overdueDays days. Interest accrued: ₹${loan.accruedInterest.toStringAsFixed(0)}.',
            type: NotificationType.critical,
            category: NotificationCategory.dueDates,
            priority: NotificationPriority.urgent,
            status: NotificationState.unread,
            createdAt: now.subtract(Duration(hours: overdueDays * 6)),
            relatedEntityType: 'LOAN',
            relatedEntityId: loan.id,
            actionLabel: 'View Overdue Loan',
            actionRoute: '/loans/${loan.id}',
          ),
        );
      } else if (diffDays <= 7) {
        final priority = diffDays <= 1 ? NotificationPriority.high : NotificationPriority.normal;
        notifications.add(
          NotificationModel(
            id: 'NOTIF-DUE-SOON-${loan.id}',
            title: 'Payment Due Soon: ${loan.id}',
            message: diffDays == 0
                ? 'Loan ${loan.id} payment for ${loan.customerName} is due TODAY.'
                : 'Loan ${loan.id} payment for ${loan.customerName} is due in $diffDays days.',
            type: NotificationType.warning,
            category: NotificationCategory.dueDates,
            priority: priority,
            status: NotificationState.unread,
            createdAt: now.subtract(const Duration(hours: 2)),
            relatedEntityType: 'LOAN',
            relatedEntityId: loan.id,
            actionLabel: 'Record Payment',
            actionRoute: '/loans/${loan.id}',
          ),
        );
      }
    }

    return notifications;
  }
}
