import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/widgets/path_widget_switcher/path_widget.dart';
import 'package:vrouter_x/src/widgets/path_widget_switcher/path_widget_switcher.dart';

/// Same as [PathWidgetSwitcher], but implements [PreferredSizeWidget] for usage
/// as an AppBar for example.
class PfPathWidgetSwitcher extends StatelessWidget
    implements PreferredSizeWidget {
  /// Use this constructor when you want to automatically extract the current
  /// vRouterData from the context.
  PfPathWidgetSwitcher({
    Key? key,
    required this.pathWidgets,
    this.duration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.caseSensitive = false,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  }) : super(key: key) {
    getVRouterData = (context) => context.vRouter;
  }

  /// Use this constructor when you want to manually pass-in the current
  /// vRouterData.
  PfPathWidgetSwitcher.fromVRouterData({
    Key? key,
    required VRouterData vRouterData,
    required this.pathWidgets,
    this.duration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.caseSensitive = false,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  }) : super(key: key) {
    getVRouterData = (context) => vRouterData;
  }

  /// See [PathWidgetSwitcher.getVRouterData]
  late final VRouterData Function(BuildContext context) getVRouterData;

  /// See [PathWidgetSwitcher.duration]
  final Duration duration;

  /// See [PathWidgetSwitcher.transitionBuilder]
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  /// See [PathWidgetSwitcher.pathWidgets]
  final List<PathWidget> pathWidgets;

  /// See [PathWidgetSwitcher.caseSensitive]
  final bool caseSensitive;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return PathWidgetSwitcher(
      key: key,
      pathWidgets: pathWidgets,
      duration: duration,
      transitionBuilder: transitionBuilder,
      caseSensitive: caseSensitive,
    );
  }
}
