import 'package:flutter/material.dart';

class RouteInterceptor extends NavigatorObserver {
  var whiteList = {'/auth/register', '/auth/pin', '/auth/authenticate'};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleRouteChange(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _handleRouteChange(newRoute);
  }

  void _handleRouteChange(Route<dynamic>? route) {
    if (whiteList.contains(route?.settings.name)) {
      print('Navigated to ${route!.settings.name}');
    } else {}
  }
}
