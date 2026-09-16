import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/swipe_arrow_pad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _DismissDirection { up, down, right }

class _StackCard {
  final int id;
  int initStackPos;
  final Color color;
  final StackUserModel user;

  _StackCard({
    required this.id,
    required this.initStackPos,
    required this.color,
    required this.user,
  });
}

class _StackSnapshot {
  final List<_StackCard> queue;
  final int frontIndex;
  final int nextCardId;
  final Set<int> markedCardIds;
  final Set<int> dismissedUserIds;
  final int dismissedUserId;
  final StackUserModel? savedIdea;

  const _StackSnapshot({
    required this.queue,
    required this.frontIndex,
    required this.nextCardId,
    required this.markedCardIds,
    required this.dismissedUserIds,
    required this.dismissedUserId,
    this.savedIdea,
  });
}

class StackedCardsScreen extends StatefulWidget {
  final List<StackUserModel> users;
  final ValueChanged<StackUserModel>? onCardHearted;
  final ValueChanged<StackUserModel>? onCardUnhearted;
  final VoidCallback? onUserActed;

  const StackedCardsScreen({
    super.key,
    required this.users,
    this.onCardHearted,
    this.onCardUnhearted,
    this.onUserActed,
  });

  @override
  State<StackedCardsScreen> createState() => StackedCardsScreenState();
}

class StackedCardsScreenState extends State<StackedCardsScreen> {
  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const double _swipeDistanceThreshold = 80;
  static const double _swipeVelocityThreshold = 800;
  static const double _dragSlop = 8;

  late List<_StackCard> _queue;
  int _frontIndex = 0;
  int _nextCardId = 0;
  int? _dismissingCardId;
  _DismissDirection? _dismissDirection;
  bool _isDismissing = false;
  bool _isDragging = false;
  double _dragDx = 0;
  double _dragDy = 0;
  int? _dragPointer;
  double _dragStartX = 0;
  double _dragStartY = 0;
  Duration _dragStartTime = Duration.zero;
  final List<_StackSnapshot> _undoHistory = [];
  final Set<int> _markedCardIds = {};
  final Set<int> _dismissedUserIds = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  bool get canUndo => _undoHistory.isNotEmpty && !_isDismissing;

  _StackCard? get _frontCard {
    if (_queue.isEmpty) return null;
    final index = _frontIndex.clamp(0, _queue.length - 1);
    return _queue[index];
  }

  bool get _canSkip => !_isDismissing && _queue.isNotEmpty;

  bool get _canGoBack => !_isDismissing && _frontIndex > 0;

  String _displayName(_StackCard card) {
    return card.user.name.isNotEmpty ? card.user.name : 'Card ${card.id + 1}';
  }

  Future<void> undoLastDismiss() async {
    if (!canUndo) return;

    final snapshot = _undoHistory.removeLast();
    setState(() {
      _isDismissing = true;
    });
    if (snapshot.savedIdea != null) {
      widget.onCardUnhearted?.call(snapshot.savedIdea!);
    }
    if (snapshot.dismissedUserId > 0) {
      await CardsService().deleteSwipe(
        targetUserId: snapshot.dismissedUserId,
      );
    }
    if (!mounted) return;
    setState(() {
      _queue = List<_StackCard>.from(snapshot.queue);
      _frontIndex = snapshot.frontIndex.clamp(
        0,
        _queue.isEmpty ? 0 : _queue.length - 1,
      );
      _nextCardId = snapshot.nextCardId;
      _markedCardIds
        ..clear()
        ..addAll(snapshot.markedCardIds);
      _dismissedUserIds
        ..clear()
        ..addAll(snapshot.dismissedUserIds);
      _isDismissing = false;
    });
  }

  void _showInterest(_StackCard card) {
    if (_isDismissing || _queue.isEmpty) return;
    _markedCardIds.add(card.id);
    _dismissCard(_DismissDirection.right, card, SwipeOutcome.interest);
  }

  @override
  void initState() {
    super.initState();
    _resetFromUsers(widget.users);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant StackedCardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.users.map((user) => user.id).toList();
    final newIds = widget.users.map((user) => user.id).toList();
    if (!listEquals(oldIds, newIds) && !_isDismissing) {
      _resetFromUsers(widget.users);
    }
  }

  void _resetFromUsers(List<StackUserModel> users) {
    _nextCardId = 0;
    _queue = [
      for (var i = 0; i < users.length; i++)
        _stackCardFromUser(user: users[i], initStackPos: i),
    ];
    _frontIndex = 0;
    _markedCardIds.clear();
    _dismissedUserIds.clear();
    _undoHistory.clear();
    _dismissingCardId = null;
    _dismissDirection = null;
    _isDismissing = false;
    _resetDrag();
  }

  void _resetDrag() {
    _isDragging = false;
    _dragDx = 0;
    _dragDy = 0;
    _dragPointer = null;
    _dragStartX = 0;
    _dragStartY = 0;
    _dragStartTime = Duration.zero;
  }

  void _onCardPointerDown(PointerDownEvent event) {
    if (_isDismissing || _queue.isEmpty || _dragPointer != null) return;
    _dragPointer = event.pointer;
    _dragStartX = event.position.dx;
    _dragStartY = event.position.dy;
    _dragStartTime = event.timeStamp;
  }

  void _onCardPointerMove(PointerMoveEvent event) {
    if (event.pointer != _dragPointer || _isDismissing) return;
    final dx = event.position.dx - _dragStartX;
    final dy = event.position.dy - _dragStartY;
    if (!_isDragging && dx.abs() < _dragSlop && dy.abs() < _dragSlop) return;
    setState(() {
      _isDragging = true;
      _dragDx = dx;
      _dragDy = dy;
    });
  }

  void _onCardPointerUp(PointerUpEvent event) {
    if (event.pointer != _dragPointer) return;
    _dragPointer = null;
    if (_isDismissing || !_isDragging) return;
    final elapsedSeconds =
        (event.timeStamp - _dragStartTime).inMicroseconds / 1e6;
    final vx = elapsedSeconds > 0 ? _dragDx / elapsedSeconds : 0.0;
    final vy = elapsedSeconds > 0 ? _dragDy / elapsedSeconds : 0.0;
    _finishDrag(vx, vy);
  }

  void _onCardPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _dragPointer) return;
    _dragPointer = null;
    if (!mounted || _isDismissing) return;
    setState(_resetDrag);
  }

  void _finishDrag(double vx, double vy) {
    final flungLeft = vx <= -_swipeVelocityThreshold;
    final flungRight = vx >= _swipeVelocityThreshold;
    final flungUp = vy <= -_swipeVelocityThreshold;
    final flungDown = vy >= _swipeVelocityThreshold;
    final draggedLeft = _dragDx <= -_swipeDistanceThreshold;
    final draggedRight = _dragDx >= _swipeDistanceThreshold;
    final draggedUp = _dragDy <= -_swipeDistanceThreshold;
    final draggedDown = _dragDy >= _swipeDistanceThreshold;

    final shouldLeft = flungLeft || (draggedLeft && !flungRight);
    final shouldRight = flungRight || (draggedRight && !flungLeft);
    final shouldUp = flungUp || (draggedUp && !flungDown);
    final shouldDown = flungDown || (draggedDown && !flungUp);

    final velocityDominant = vx.abs() >= _swipeVelocityThreshold ||
        vy.abs() >= _swipeVelocityThreshold;
    final useHorizontal = velocityDominant
        ? vx.abs() >= vy.abs()
        : _dragDx.abs() >= _dragDy.abs();

    if (useHorizontal) {
      if (shouldLeft && !shouldRight) {
        setState(_resetDrag);
        _goBack();
        return;
      }
      if (shouldRight && !shouldLeft) {
        setState(_resetDrag);
        _skip();
        return;
      }
    } else {
      if (shouldUp && !shouldDown) {
        setState(() {
          _isDragging = false;
        });
        _dismissFrontCard(_DismissDirection.up, SwipeOutcome.know);
        return;
      }
      if (shouldDown && !shouldUp) {
        setState(() {
          _isDragging = false;
        });
        _dismissFrontCard(_DismissDirection.down, SwipeOutcome.noInterest);
        return;
      }
    }
    setState(_resetDrag);
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  _StackCard _stackCardFromUser({
    required StackUserModel user,
    required int initStackPos,
  }) {
    final id = _nextCardId++;
    return _StackCard(
      id: id,
      initStackPos: initStackPos,
      color: kStackCardColors[id % kStackCardColors.length],
      user: user,
    );
  }

  List<int> _excludeIds({int? extraId}) {
    return {
      ..._queue.map((card) => card.user.id),
      ..._dismissedUserIds,
      if (extraId != null) extraId,
    }.where((id) => id > 0).toList();
  }

  Future<void> _skip() async {
    if (_isDismissing || _queue.isEmpty) return;
    if (_frontIndex < _queue.length - 1) {
      setState(() {
        _frontIndex++;
        _resetDrag();
      });
      return;
    }

    setState(() {
      _isDismissing = true;
    });
    final next = await CardsService().getReplacementUser(
      remainingUserIds: _excludeIds(),
      dismissedUserId: _frontCard?.user.id ?? 0,
    );
    if (!mounted) return;
    if (next == null) {
      setState(() {
        _isDismissing = false;
        _resetDrag();
      });
      return;
    }
    setState(() {
      _queue.add(_stackCardFromUser(user: next, initStackPos: _queue.length));
      _frontIndex = _queue.length - 1;
      _isDismissing = false;
      _resetDrag();
    });
  }

  void _goBack() {
    if (_isDismissing || _frontIndex <= 0) return;
    setState(() {
      _frontIndex--;
      _resetDrag();
    });
  }

  void _notInterested() {
    _dismissFrontCard(_DismissDirection.down, SwipeOutcome.noInterest);
  }

  void _know() {
    _dismissFrontCard(_DismissDirection.up, SwipeOutcome.know);
  }

  Future<void> _dismissFrontCard(
    _DismissDirection direction,
    SwipeOutcome outcome,
  ) async {
    final card = _frontCard;
    if (_isDismissing || card == null) return;
    await _dismissCard(direction, card, outcome);
  }

  Future<void> _dismissCard(
    _DismissDirection direction,
    _StackCard card,
    SwipeOutcome outcome,
  ) async {
    if (_isDismissing || _queue.isEmpty) return;

    final dismissedUserId = card.user.id;
    final snapshotQueue = List<_StackCard>.from(_queue);
    final snapshotIndex = _frontIndex;
    final snapshotDismissedUserIds = Set<int>.from(_dismissedUserIds);
    if (dismissedUserId > 0) {
      _dismissedUserIds.add(dismissedUserId);
    }

    setState(() {
      _isDismissing = true;
    });

    final swipeOk = dismissedUserId > 0
        ? await CardsService().swipeCard(
            outcome: outcome,
            targetUserId: dismissedUserId,
          )
        : true;
    if (!swipeOk) {
      if (!mounted) return;
      setState(() {
        _isDismissing = false;
        _markedCardIds.remove(card.id);
        if (dismissedUserId > 0) {
          _dismissedUserIds.remove(dismissedUserId);
        }
        _resetDrag();
      });
      return;
    }

    widget.onUserActed?.call();

    final remainingAfter = snapshotQueue
        .where((item) => item.id != card.id)
        .map((item) => item.user.id)
        .where((id) => id > 0)
        .toList();
    final replacementFuture = CardsService().getReplacementUser(
      remainingUserIds: [...remainingAfter, ..._dismissedUserIds],
      dismissedUserId: dismissedUserId,
    );

    setState(() {
      _dismissingCardId = card.id;
      _dismissDirection = direction;
      _dragDx = 0;
      _dragDy = 0;
      _isDragging = false;
    });

    await Future.delayed(_animationDuration);
    final replacementUser = await replacementFuture;

    if (!mounted) return;

    final wasInterested =
        outcome == SwipeOutcome.interest && _markedCardIds.contains(card.id);
    setState(() {
      _undoHistory.add(_StackSnapshot(
        queue: snapshotQueue,
        frontIndex: snapshotIndex,
        nextCardId: _nextCardId,
        markedCardIds: Set<int>.from(_markedCardIds)..remove(card.id),
        dismissedUserIds: snapshotDismissedUserIds,
        dismissedUserId: dismissedUserId,
        savedIdea: wasInterested ? card.user : null,
      ));
      _applyDismiss(card, replacementUser);
      _dismissingCardId = null;
      _dismissDirection = null;
      _isDismissing = false;
      _resetDrag();
    });
    if (wasInterested) widget.onCardHearted?.call(card.user);
  }

  void _applyDismiss(
    _StackCard dismissed,
    StackUserModel? replacement,
  ) {
    _markedCardIds.remove(dismissed.id);
    final removedIndex = _queue.indexWhere((card) => card.id == dismissed.id);
    if (removedIndex >= 0) {
      _queue = List<_StackCard>.from(_queue)..removeAt(removedIndex);
    }
    if (replacement != null &&
        !_queue.any(
            (card) => card.user.id == replacement.id && replacement.id > 0)) {
      _queue.add(
        _stackCardFromUser(user: replacement, initStackPos: _queue.length),
      );
    }
    if (_queue.isEmpty) {
      _frontIndex = 0;
    } else if (removedIndex >= _queue.length) {
      _frontIndex = _queue.length - 1;
    } else if (removedIndex >= 0) {
      _frontIndex = removedIndex;
    }
  }

  KeyEventResult _onArrowKeyEvent(FocusNode node, KeyEvent event) {
    final isArrow = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown;
    if (!isArrow) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    if (_isDismissing || _isDragging || _queue.isEmpty) {
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goBack();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _skip();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _know();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _notInterested();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final card = _frontCard;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      body: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _onArrowKeyEvent,
        child: SafeArea(
          child: card == null
              ? Center(
                  child: Text(
                    'No more users in queue. Check again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConfig().colors.txtBodyColor,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(AppConfig().dimens.medium),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: kStackCardWidth,
                            height: kStackHeight,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [_buildCard(card)],
                            ),
                          ),
                        ),
                      ),
                      ExcludeFocus(
                        child: Center(
                          child: SwipeArrowPad(
                            enabled: !_isDismissing && !_isDragging,
                            canSkip: _canSkip,
                            canGoBack: _canGoBack,
                            onSkip: _skip,
                            onGoBack: _goBack,
                            onKnow: _know,
                            onNotInterested: _notInterested,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCard(_StackCard card) {
    final isDismissing = card.id == _dismissingCardId;
    const baseLeft = 0.0;
    const baseTop = (kStackHeight - kStackCardHeight) / 2;
    final dragOffsetX = _dismissingCardId == null ? _dragDx : 0.0;
    final dragOffsetY = _dismissingCardId == null ? _dragDy : 0.0;

    final horizontalDismiss =
        isDismissing && _dismissDirection == _DismissDirection.right
            ? kStackCardWidth * 1.4
            : 0.0;

    final verticalDismiss = isDismissing
        ? switch (_dismissDirection) {
            _DismissDirection.up => -kStackCardHeight * 1.4,
            _DismissDirection.down => kStackCardHeight * 1.4,
            _ => 0.0,
          }
        : 0.0;

    final opacity = isDismissing ? 0.0 : 1.0;
    final isMarked = _markedCardIds.contains(card.id);

    Widget face = StackCardFace(
      user: card.user,
      accentColor: card.color,
      displayName: _displayName(card),
      interestOn: isMarked,
      canToggleInterest: !_isDismissing && !_isDragging,
      onInterestPressed: () => _showInterest(card),
    );
    face = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: const <PointerDeviceKind>{},
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onCardPointerDown,
        onPointerMove: _onCardPointerMove,
        onPointerUp: _onCardPointerUp,
        onPointerCancel: _onCardPointerCancel,
        child: face,
      ),
    );

    return AnimatedPositioned(
      key: ValueKey('card-${card.id}'),
      left: baseLeft + horizontalDismiss + dragOffsetX,
      top: baseTop + verticalDismiss + dragOffsetY,
      width: kStackCardWidth,
      height: kStackCardHeight,
      duration: _isDragging && _dismissingCardId == null
          ? Duration.zero
          : _animationDuration,
      curve: Curves.easeInOutCubic,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
        child: IgnorePointer(
          ignoring: _isDismissing,
          child: face,
        ),
      ),
    );
  }
}
