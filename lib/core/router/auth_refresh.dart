import 'package:flutter/foundation.dart';

/// Global [Listenable] consumed by GoRouter's [refreshListenable].
///
/// It lets route redirects re-run whenever the authenticated user/session
/// changes, WITHOUT recreating the [GoRouter] instance (recreating the router
/// resets navigation to [GoRouter.initialLocation] and can trigger mid-build
/// layout assertions).
final authRefreshNotifier = ValueNotifier<int>(0);

/// Notify the router that the session/user changed so it re-evaluates
/// redirection. Call this from [UserNotifier] on login, logout and role switch.
void notifyAuthStateChanged() => authRefreshNotifier.value++;
