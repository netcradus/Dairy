import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  final user = ref.watch(userProvider);
  return SubscriptionNotifier(service: service, user: user);
});

/// State class for subscription Riverpod provider
class SubscriptionState {
  final bool loading;
  final bool hasError;
  final String? errorMessage;
  final Subscription? subscription;
  final bool? hasActiveSubscription;
  final bool? hasExpiredSubscription;
  final bool? hasCancelledSubscription;

  const SubscriptionState({
    this.loading = false,
    this.hasError = false,
    this.errorMessage,
    this.subscription,
    this.hasActiveSubscription,
    this.hasExpiredSubscription,
    this.hasCancelledSubscription,
  });

  SubscriptionState copyWith({
    bool? loading,
    bool? hasError,
    String? errorMessage,
    Subscription? subscription,
    bool? hasActiveSubscription,
    bool? hasExpiredSubscription,
    bool? hasCancelledSubscription,
  }) {
    return SubscriptionState(
      loading: loading ?? this.loading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      subscription: subscription ?? this.subscription,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      hasExpiredSubscription:
          hasExpiredSubscription ?? this.hasExpiredSubscription,
      hasCancelledSubscription:
          hasCancelledSubscription ?? this.hasCancelledSubscription,
    );
  }
}

/// Subscription notifier that connects to Firestore
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;
  final User _user;

  SubscriptionNotifier({
    required SubscriptionService service,
    required User user,
  })  : _service = service,
        _user = user,
        super(const SubscriptionState()) {
    if (_effectiveUid.isNotEmpty) {
      loadSubscription();
    }
  }

  String get _effectiveUid {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    return _user.id;
  }

  /// Load the current user's subscription from Firestore
  Future<void> loadSubscription() async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: 'No authenticated user',
      );
      return;
    }

    state = state.copyWith(loading: true);
    try {
      final sub = await _service.getCurrentSubscription(uid);
      final isActive = await _service.isSubscriptionActive(uid);
      final status = await _service.getSubscriptionStatus(uid);

      final hasActive = isActive && status == SubscriptionStatus.active;
      final hasExpired = !isActive && status != SubscriptionStatus.cancelled;
      final hasCancelled = status == SubscriptionStatus.cancelled;

      final Subscription? displaySub = sub;

      state = state.copyWith(
        loading: false,
        subscription: displaySub,
        hasActiveSubscription: hasActive,
        hasExpiredSubscription: hasExpired,
        hasCancelledSubscription: hasCancelled,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh the subscription state from Firestore
  Future<void> refresh() async {
    await loadSubscription();
  }

  /// Create a new subscription in Firestore
  Future<void> createSubscription(Subscription subscription) async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to create subscription.');
    }

    state = state.copyWith(loading: true);
    try {
      final created = await _service.createSubscription(uid, subscription);
      state = state.copyWith(
        loading: false,
        subscription: created,
        hasActiveSubscription: true,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Update an existing subscription in Firestore
  Future<void> updateSubscription(Subscription subscription) async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to update subscription.');
    }

    state = state.copyWith(loading: true);
    try {
      final updated = await _service.updateSubscription(uid, subscription);
      state = state.copyWith(
        loading: false,
        subscription: updated,
        hasActiveSubscription: updated.isActiveAndValid,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Cancel the subscription in Firestore
  Future<void> cancelSubscription() async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to cancel subscription.');
    }

    state = state.copyWith(loading: true);
    try {
      final cancelled = await _service.cancelSubscription(uid);
      state = state.copyWith(
        loading: false,
        subscription: cancelled,
        hasCancelledSubscription: true,
        hasActiveSubscription: false,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Pause the subscription (status -> paused)
  Future<void> pauseSubscription() async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to pause subscription.');
    }
    final sub = state.subscription;
    if (sub == null) return;

    state = state.copyWith(loading: true);
    try {
      final updated = await _service.updateSubscription(
          uid,
          sub.copyWith(
            status: SubscriptionStatus.paused,
            updatedAt: DateTime.now(),
          ));
      state = state.copyWith(
        loading: false,
        subscription: updated,
        hasActiveSubscription: updated.isActiveAndValid,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Resume the subscription (status -> active)
  Future<void> resumeSubscription() async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to resume subscription.');
    }
    final sub = state.subscription;
    if (sub == null) return;

    state = state.copyWith(loading: true);
    try {
      final updated = await _service.updateSubscription(
          uid,
          sub.copyWith(
            status: SubscriptionStatus.active,
            updatedAt: DateTime.now(),
          ));
      state = state.copyWith(
        loading: false,
        subscription: updated,
        hasActiveSubscription: updated.isActiveAndValid,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Renew the subscription in Firestore
  Future<void> renewSubscription({Duration? duration}) async {
    final uid = _effectiveUid;
    if (uid.isEmpty) {
      throw Exception('No authenticated user found to renew subscription.');
    }

    state = state.copyWith(loading: true);
    try {
      final renewed = await _service.renewSubscription(uid, duration: duration);
      state = state.copyWith(
        loading: false,
        subscription: renewed,
        hasActiveSubscription: renewed.isActiveAndValid,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}
