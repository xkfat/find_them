// cubits/notification_cubit.dart - Modified to work with post-auth FCM init
import 'dart:async';
import 'dart:developer';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService = NotificationService();

  Timer? _refreshTimer;
  String? _currentFilter;

  NotificationCubit() : super(NotificationInitial()) {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      // Only do basic initialization here (no FCM)
      // FCM initialization happens after auth in AuthService
      await _notificationService.initialize();

      // Set up service callbacks
      _notificationService.onNotificationsUpdated = _handleNotificationsUpdated;
      _notificationService.onUnreadCountChanged = _handleUnreadCountChanged;
      _notificationService.onNewNotification = _handleNewNotification;

      // Start periodic refresh (but only if fully initialized)
      _startPeriodicRefreshIfReady();
      
      log('✅ Notification Cubit - Basic initialization completed');
    } catch (e) {
      log('❌ Error in notification cubit initialization: $e');
    }
  }

  // Start periodic refresh only if service is fully initialized
  void _startPeriodicRefreshIfReady() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!isClosed && _notificationService.isFullyInitialized) {
        // Only refresh if service is fully initialized (after auth)
        refreshNotifications();
      }
    });
  }

  // Load notifications
  Future<void> loadNotifications({String? filterType}) async {
    try {
      // Check if service is fully initialized
      if (!_notificationService.isFullyInitialized) {
        log('⚠️ Notification service not fully initialized, showing empty state');
        emit(NotificationEmpty(filterType: filterType));
        return;
      }

      emit(NotificationLoading());
      _currentFilter = filterType;

      final notifications = await _notificationService.getNotifications();

      if (notifications.isEmpty) {
        emit(NotificationEmpty(filterType: filterType));
      } else {
        emit(
          NotificationLoaded(
            notifications: notifications,
            filterType: filterType,
          ),
        );
      }
    } catch (e) {
      log('❌ Error loading notifications: $e');
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    try {
      // Don't refresh if service not fully initialized
      if (!_notificationService.isFullyInitialized) {
        log('⚠️ Cannot refresh - notification service not fully initialized');
        return;
      }

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(NotificationRefreshing(currentState.notifications));
      }

      await _notificationService.refreshNotifications();

      // The service callbacks will handle updating the state
    } catch (e) {
      log('❌ Error refreshing notifications: $e');
      if (state is NotificationRefreshing) {
        final refreshingState = state as NotificationRefreshing;
        emit(
          NotificationLoaded(
            notifications: refreshingState.currentNotifications,
            filterType: _currentFilter,
          ),
        );
      }
    }
  }

Future<void> deleteNotification(int id) async {
  try {
    if (!_notificationService.isFullyInitialized) {
      emit(const NotificationError('Service not initialized. Please log in again.'));
      return;
    }

    // Store current state
    final currentState = state;
    List<NotificationModel> currentNotifications = [];
    
    if (currentState is NotificationLoaded) {
      currentNotifications = currentState.notifications;
    }

    emit(NotificationDeleting(id));

    final success = await _notificationService.deleteNotification(id);

    if (success) {
      log('✅ Notification $id deleted successfully');
      
      // Immediately update UI by removing the notification from current list
      final updatedNotifications = currentNotifications
          .where((notification) => notification.id != id)
          .toList();
      
      if (updatedNotifications.isEmpty) {
        emit(NotificationEmpty(filterType: _currentFilter));
      } else {
        emit(NotificationLoaded(
          notifications: updatedNotifications,
          filterType: _currentFilter,
        ));
      }
      
      // Also refresh from server to ensure consistency
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed) {
          refreshNotifications();
        }
      });
      
    } else {
      log('❌ Failed to delete notification $id');
      emit(const NotificationError('Failed to delete notification'));
      
      // Restore previous state
      if (currentState is NotificationLoaded) {
        emit(currentState);
      } else {
        await loadNotifications(filterType: _currentFilter);
      }
    }
  } catch (e) {
    log('❌ Error deleting notification: $e');
    emit(NotificationError('Failed to delete notification: $e'));
    
    // Reload to restore proper state
    await loadNotifications(filterType: _currentFilter);
  }
}

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      if (!_notificationService.isFullyInitialized) {
        emit(const NotificationError('Service not initialized. Please log in again.'));
        return;
      }

      emit(NotificationClearing());

      final success = await _notificationService.clearAllNotifications();

      if (success) {
        emit(NotificationCleared());
        await Future.delayed(const Duration(milliseconds: 1000));
        emit(NotificationEmpty(filterType: _currentFilter));
      } else {
        emit(const NotificationError('Failed to clear notifications'));
        await loadNotifications(filterType: _currentFilter);
      }
    } catch (e) {
      log('❌ Error clearing notifications: $e');
      emit(NotificationError('Failed to clear notifications: $e'));
      await loadNotifications(filterType: _currentFilter);
    }
  }

  // Filter notifications by type
  Future<void> filterNotifications(String? type) async {
    _currentFilter = type;
    await loadNotifications(filterType: type);
  }

  // Handle service callbacks
  void _handleNotificationsUpdated(List<NotificationModel> notifications) {
    if (!isClosed) {
      // Apply current filter if any
      List<NotificationModel> filteredNotifications = notifications;
      if (_currentFilter != null) {
        filteredNotifications =
            notifications
                .where((n) => n.notificationType == _currentFilter)
                .toList();
      }

      if (filteredNotifications.isEmpty) {
        emit(NotificationEmpty(filterType: _currentFilter));
      } else {
        emit(
          NotificationLoaded(
            notifications: filteredNotifications,
            filterType: _currentFilter,
          ),
        );
      }
    }
  }

  void _handleUnreadCountChanged(int count) {
    if (!isClosed && state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(unreadCount: count));
    }
  }

  void _handleNewNotification(NotificationModel notification) {
    if (!isClosed) {
      // Check if new notification matches current filter
      if (_currentFilter == null ||
          notification.notificationType == _currentFilter) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          final updatedNotifications = [
            notification,
            ...currentState.notifications,
          ];

          emit(
            NotificationNewReceived(
              newNotification: notification,
              allNotifications: updatedNotifications,
            ),
          );

          // After showing the new notification state, update to loaded state
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (!isClosed) {
              emit(
                NotificationLoaded(
                  notifications: updatedNotifications,
                  filterType: _currentFilter,
                ),
              );
            }
          });
        } else {
          // If not in loaded state, just refresh
          loadNotifications(filterType: _currentFilter);
        }
      }
    }
  }

  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Check if service is ready for operations
  bool get isServiceReady => _notificationService.isFullyInitialized;

  // FCM Token management (only works after auth)
  Future<void> updateFCMToken() async {
    try {
      if (!_notificationService.isFullyInitialized) {
        log('⚠️ Cannot update FCM token - service not fully initialized');
        return;
      }
      
      final token = await _notificationService.getFCMToken();
      if (token != null) {
        log('✅ FCM token updated in service');
      }
    } catch (e) {
      log('❌ Error updating FCM token: $e');
    }
  }

  Future<void> removeFCMToken() async {
    try {
      await _notificationService.removeFCMToken();
    } catch (e) {
      log('❌ Error removing FCM token: $e');
    }
  }

  

  // Get specific notification types
  Future<void> loadMissingPersonNotifications() async {
    await filterNotifications('missing_person');
  }

  Future<void> loadLocationNotifications() async {
    await filterNotifications('location_request');
  }

  Future<void> loadReportNotifications() async {
    await filterNotifications('report');
  }

  Future<void> loadCaseUpdates() async {
    await filterNotifications('case_update');
  }

  // Navigation helper
  Map<String, dynamic>? getNavigationDataForNotification(
    NotificationModel notification,
  ) {
    return {
      'route': notification.navigationRoute,
      'arguments': notification.navigationArguments,
    };
  }

  @override
  Future<void> close() {
    _stopPeriodicRefresh();
    _notificationService.dispose();
    return super.close();
  }
}