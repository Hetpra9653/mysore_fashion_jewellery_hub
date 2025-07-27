import 'package:flutter/material.dart';
import 'package:mysore_fashion_jewellery_hub/src/core/constants/app_colors.dart';

// Add failed states to the enum
enum LTDState { initial, loading, transition, done, failed, transitionToFailed }

class LoadingToDoneTransitionController extends ChangeNotifier {
  LTDState state = LTDState.loading;

  LoadingToDoneTransitionController();

  /// If Duration is specified it will move state back to initial in given duration
  Future<void> animateToDone({Duration? duration}) async {
    state = LTDState.transition;
    notifyListeners();
    if (duration != null) {
      await Future.delayed(duration, initial);
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  /// Animate to failed state showing error icon
  Future<void> animateToFailed({Duration? duration}) async {
    state = LTDState.transitionToFailed;
    notifyListeners();
    if (duration != null) {
      await Future.delayed(duration, initial);
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  void initial() {
    state = LTDState.initial;
    notifyListeners();
  }

  void done() {
    state = LTDState.done;
    notifyListeners();
  }

  void failed() {
    state = LTDState.failed;
    notifyListeners();
  }

  void loading() {
    state = LTDState.loading;
    notifyListeners();
  }
}

class LoadingToDoneTransition extends StatefulWidget {
  final Widget loadingWidget;
  final Widget finalWidget;
  final Widget? failedWidget;
  final LoadingToDoneTransitionController controller;
  final Duration? duration;
  final Widget initial;
  final Color? failedColor;

  const LoadingToDoneTransition({
    Key? key,
    this.duration,
    required this.loadingWidget,
    required this.finalWidget,
    this.failedWidget,
    required this.controller,
    required this.initial,
    this.failedColor,
  }) : super(key: key);

  @override
  State<LoadingToDoneTransition> createState() =>
      _LoadingToDoneTransitionState();
}

class _LoadingToDoneTransitionState extends State<LoadingToDoneTransition> {
  @override
  void initState() {
    super.initState();
    widget.controller.state = LTDState.initial;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, value) {
        if (widget.controller.state == LTDState.initial) {
          return widget.initial;
        }

        // Determine border color based on state
        Color borderColor = AppColors.logoBlueColor;
        if (widget.controller.state == LTDState.failed ||
            widget.controller.state == LTDState.transitionToFailed) {
          borderColor = widget.failedColor ?? Colors.red;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1, color: borderColor),
          ),
          alignment: Alignment.center,
          child: Builder(
            builder: (context) {
              if (widget.controller.state == LTDState.loading) {
                return widget.loadingWidget;
              } else if (widget.controller.state == LTDState.transition) {
                return TweenAnimationBuilder(
                  curve: Curves.bounceInOut,
                  onEnd: () {
                    widget.controller.done();
                  },
                  tween: Tween<double>(begin: 0, end: 1),
                  duration:
                  widget.duration ?? const Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: value * value,
                          child: widget.finalWidget,
                        ),
                        Transform.scale(
                          scale: 1 - value,
                          child: widget.loadingWidget,
                        ),
                      ],
                    );
                  },
                );
              } else if (widget.controller.state == LTDState.transitionToFailed) {
                // Transition to failed state
                return TweenAnimationBuilder(
                  curve: Curves.bounceInOut,
                  onEnd: () {
                    widget.controller.failed();
                  },
                  tween: Tween<double>(begin: 0, end: 1),
                  duration:
                  widget.duration ?? const Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: value * value,
                          child: widget.failedWidget ?? Icon(
                            Icons.error_outline_rounded,
                            color: widget.failedColor ?? Colors.red,
                            size: 22,
                          ),
                        ),
                        Transform.scale(
                          scale: 1 - value,
                          child: widget.loadingWidget,
                        ),
                      ],
                    );
                  },
                );
              } else if (widget.controller.state == LTDState.done) {
                return widget.finalWidget;
              } else if (widget.controller.state == LTDState.failed) {
                // Show failed widget
                return widget.failedWidget ?? Icon(
                  Icons.error_outline_rounded,
                  color: widget.failedColor ?? Colors.red,
                  size: 22,
                );
              }
              return const Offstage();
            },
          ),
        );
      },
    );
  }
}