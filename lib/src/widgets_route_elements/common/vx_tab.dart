import 'package:flutter/material.dart';

class VxTab {
  const VxTab(this.lastVisitedUrl, this.child);

  final String lastVisitedUrl;
  final Widget child;

  @override
  String toString() => 'VTab(lastVisitedUrl: $lastVisitedUrl, child: $child)';

  VxTab copyWith({
    String? lastVisitedUrl,
    Widget? child,
  }) {
    return VxTab(
      lastVisitedUrl ?? this.lastVisitedUrl,
      child ?? this.child,
    );
  }
}
