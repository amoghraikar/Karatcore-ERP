import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../loans/providers/loan_providers.dart';
import '../models/notification_models.dart';
import '../repository/api_notification_repository.dart';
import '../repository/notification_repository.dart';
import '../services/communication_service.dart';
import '../services/due_date_engine.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return ApiNotificationRepository(ref.watch(apiClientProvider));
});

final communicationServiceProvider = Provider<ICommunicationService>((ref) {
  return CommunicationService();
});

final dueDateEngineServiceProvider = Provider<IDueDateEngineService>((ref) {
  return const DueDateEngineService();
});

class NotificationFilterState {
  const NotificationFilterState({
    this.searchQuery = '',
    this.categoryFilter,
    this.priorityFilter,
    this.statusFilter,
    this.activeTab = 'All',
  });

  final String searchQuery;
  final NotificationCategory? categoryFilter;
  final NotificationPriority? priorityFilter;
  final NotificationState? statusFilter;
  final String activeTab; // 'All', 'Unread', 'Important', 'Loans', 'Payments', 'KYC', 'Security', 'System'

  NotificationFilterState copyWith({
    String? searchQuery,
    NotificationCategory? categoryFilter,
    NotificationPriority? priorityFilter,
    NotificationState? statusFilter,
    String? activeTab,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearStatus = false,
  }) {
    return NotificationFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
      priorityFilter: clearPriority ? null : (priorityFilter ?? this.priorityFilter),
      statusFilter: clearStatus ? null : (statusFilter ?? this.statusFilter),
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

final notificationFilterProvider = StateProvider<NotificationFilterState>((ref) {
  return const NotificationFilterState();
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsNotifier(this._repo, this._dueDateEngine, this._ref)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final INotificationRepository _repo;
  final IDueDateEngineService _dueDateEngine;
  final Ref _ref;

  Future<void> loadNotifications() async {
    try {
      final baseNotifs = await _repo.getNotifications();

      // Dynamically merge due date notifications from LoanRepository
      try {
        final loans = await _ref.read(loanRepositoryProvider).getLoans();
        final dueNotifs = _dueDateEngine.generateDueNotifications(loans);

        final idSet = baseNotifs.map((n) => n.id).toSet();
        for (final dn in dueNotifs) {
          if (!idSet.contains(dn.id)) {
            baseNotifs.insert(0, dn);
          }
        }
      } catch (_) {
        // Fallback gracefully if loans list is loading/error
      }

      state = AsyncValue.data(baseNotifs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    state.whenData((list) {
      state = AsyncValue.data(list.map((n) {
        if (n.id == id) return n.copyWith(status: NotificationState.read, readAt: DateTime.now());
        return n;
      }).toList());
    });
  }

  Future<void> markAsUnread(String id) async {
    await _repo.markAsUnread(id);
    state.whenData((list) {
      state = AsyncValue.data(list.map((n) {
        if (n.id == id) return n.copyWith(status: NotificationState.unread, readAt: null);
        return n;
      }).toList());
    });
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    final now = DateTime.now();
    state.whenData((list) {
      state = AsyncValue.data(list.map((n) {
        if (n.status == NotificationState.unread) {
          return n.copyWith(status: NotificationState.read, readAt: now);
        }
        return n;
      }).toList());
    });
  }

  Future<void> archiveNotification(String id) async {
    await _repo.archiveNotification(id);
    state.whenData((list) {
      state = AsyncValue.data(list.map((n) {
        if (n.id == id) return n.copyWith(status: NotificationState.archived);
        return n;
      }).toList());
    });
  }

  Future<void> dismissNotification(String id) async {
    await _repo.dismissNotification(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((n) => n.id != id).toList());
    });
  }
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationsNotifier(
    ref.watch(notificationRepositoryProvider),
    ref.watch(dueDateEngineServiceProvider),
    ref,
  );
});

final filteredNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifsAsync = ref.watch(notificationsNotifierProvider);
  final filters = ref.watch(notificationFilterProvider);

  final list = notifsAsync.valueOrNull ?? [];

  return list.where((n) {
    if (n.status == NotificationState.dismissed) return false;

    // Search query filter
    if (filters.searchQuery.isNotEmpty) {
      final q = filters.searchQuery.toLowerCase();
      final matchTitle = n.title.toLowerCase().contains(q);
      final matchMsg = n.message.toLowerCase().contains(q);
      final matchMeta = n.relatedEntityId?.toLowerCase().contains(q) ?? false;
      if (!matchTitle && !matchMsg && !matchMeta) return false;
    }

    // Active tab filter
    switch (filters.activeTab) {
      case 'Unread':
        if (n.status != NotificationState.unread) return false;
        break;
      case 'Important':
        if (!n.isImportant) return false;
        break;
      case 'Loans':
        if (n.category != NotificationCategory.loans && n.category != NotificationCategory.dueDates) return false;
        break;
      case 'Payments':
        if (n.category != NotificationCategory.payments && n.category != NotificationCategory.receipts) return false;
        break;
      case 'KYC':
        if (n.category != NotificationCategory.kyc) return false;
        break;
      case 'Security':
        if (n.category != NotificationCategory.security) return false;
        break;
      case 'System':
        if (n.category != NotificationCategory.system && n.category != NotificationCategory.accounting && n.category != NotificationCategory.documents) return false;
        break;
    }

    // Explicit Dropdown Filters
    if (filters.categoryFilter != null && n.category != filters.categoryFilter) return false;
    if (filters.priorityFilter != null && n.priority != filters.priorityFilter) return false;
    if (filters.statusFilter != null && n.status != filters.statusFilter) return false;

    return true;
  }).toList();
});

final unreadCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsNotifierProvider);
  final list = notifsAsync.valueOrNull ?? [];
  return list.where((n) => n.status == NotificationState.unread).length;
});

final urgentAlertsCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsNotifierProvider);
  final list = notifsAsync.valueOrNull ?? [];
  return list.where((n) => n.status == NotificationState.unread && n.priority == NotificationPriority.urgent).length;
});

class NotificationPreferencesNotifier extends StateNotifier<AsyncValue<NotificationPreferencesModel>> {
  NotificationPreferencesNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadPreferences();
  }

  final INotificationRepository _repo;

  Future<void> loadPreferences() async {
    try {
      final prefs = await _repo.getPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePreferences(NotificationPreferencesModel prefs) async {
    state = AsyncValue.data(prefs);
    await _repo.updatePreferences(prefs);
  }
}

final notificationPreferencesNotifierProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, AsyncValue<NotificationPreferencesModel>>((ref) {
  return NotificationPreferencesNotifier(ref.watch(notificationRepositoryProvider));
});

final communicationLogsProvider = FutureProvider<List<CommunicationLogModel>>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getCommunicationLogs();
});

final upcomingDueItemsProvider = FutureProvider<List<DueDateItemModel>>((ref) async {
  final loans = await ref.watch(loanRepositoryProvider).getLoans();
  final engine = ref.watch(dueDateEngineServiceProvider);
  return engine.getUpcomingDueItems(loans);
});

final overdueItemsProvider = FutureProvider<List<DueDateItemModel>>((ref) async {
  final loans = await ref.watch(loanRepositoryProvider).getLoans();
  final engine = ref.watch(dueDateEngineServiceProvider);
  return engine.getOverdueItems(loans);
});
