import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
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
    this.builder = PathWidgetSwitcher.defaultBuilder,
    this.caseSensitive = false,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  })  : vRouterDataOption = none(),
        super(key: key);

  /// Use this constructor when you want to manually pass-in the current
  /// vRouterData.
  PfPathWidgetSwitcher.fromVRouterData({
    Key? key,
    required VRouterData vRouterData,
    required this.pathWidgets,
    this.builder = PathWidgetSwitcher.defaultBuilder,
    this.caseSensitive = false,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  })  : vRouterDataOption = some(vRouterData),
        super(key: key);

  /// See [PathWidgetSwitcher.pathWidgets]
  final List<PathWidget> pathWidgets;

  /// See [PathWidgetSwitcher.caseSensitive]
  final bool caseSensitive;

  /// This will hold some() when the vRouterData has been provided in the
  /// constructor, and none() otherwise.
  final Option<VRouterData> vRouterDataOption;

  /// See [PathWidgetSwitcher.builder]
  final Widget Function(BuildContext context, Widget child) builder;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return vRouterDataOption.match(
      (vRouterData) => PathWidgetSwitcher.fromVRouterData(
        vRouterData: vRouterData,
        pathWidgets: pathWidgets,
        builder: builder,
        caseSensitive: caseSensitive,
      ),
      () => PathWidgetSwitcher(
        pathWidgets: pathWidgets,
        builder: builder,
        caseSensitive: caseSensitive,
      ),
    );
  }
}
