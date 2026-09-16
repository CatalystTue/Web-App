import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/swipe_arrow_pad.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum _DismissDirection { up, down, right }

class LikedUsersScreen extends StatefulWidget {
  final List<StackUserModel>? initialUsers;

  const LikedUsersScreen({
    super.key,
    this.initialUsers,
  });

  @override
  State<LikedUsersScreen> createState() => LikedUsersScreenState();
}

class LikedUsersScreenState extends State<LikedUsersScreen> {
  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const double _swipeDistanceThreshold = 80;
  static const double _swipeVelocityThreshold = 800;
  static const double _dragSlop = 8;

  bool _loading = true;
  List<StackUserModel> _allLiked = [];
  int _frontIndex = 0;
  int _cardId = 0;
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
  final FocusNode _keyboardFocusNode = FocusNode();
  final List<_RemovalSnapshot> _undoHistory = [];

  bool get _canSkip =>
      !_isDismissing &&
      _allLiked.length > 1 &&
      _frontIndex < _allLiked.length - 1;

  bool get _canGoBack => !_isDismissing && _frontIndex > 0;

  StackUserModel? get _frontUser {
    if (_allLiked.isEmpty) return null;
    final index = _frontIndex.clamp(0, _allLiked.length - 1);
    return _allLiked[index];
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialUsers != null) {
      _allLiked = List<StackUserModel>.from(widget.initialUsers!);
      _frontIndex = 0;
      _loading = false;
    } else {
      _loadLiked();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
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
    if (_isDismissing || _allLiked.isEmpty || _dragPointer != null) return;
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
      if (_canGoBack && shouldLeft && !shouldRight) {
        setState(_resetDrag);
        _goBack();
        return;
      }
      if (_canSkip && shouldRight && !shouldLeft) {
        setState(_resetDrag);
        _skip();
        return;
      }
    } else if (shouldUp && !shouldDown) {
      setState(() {
        _isDragging = false;
      });
      _editFront(SwipeOutcome.know, _DismissDirection.up);
      return;
    } else if (shouldDown && !shouldUp) {
      setState(() {
        _isDragging = false;
      });
      _editFront(SwipeOutcome.noInterest, _DismissDirection.down);
      return;
    }
    setState(_resetDrag);
  }

  Future<void> _loadLiked() async {
    setState(() {
      _loading = true;
    });
    try {
      _allLiked = await CardsService().getSavedIdeas();
    } catch (_) {
      _allLiked = [];
    }
    if (!mounted) return;
    _frontIndex = 0;
    setState(() {
      _loading = false;
    });
  }

  String _displayName(StackUserModel user) {
    return user.name.isNotEmpty ? user.name : 'Card ${_cardId + 1}';
  }

  void _skip() {
    if (!_canSkip) return;
    setState(() {
      _frontIndex++;
    });
  }

  void _goBack() {
    if (!_canGoBack) return;
    setState(() {
      _frontIndex--;
    });
  }

  void _dropFrontUser() {
    if (_allLiked.isEmpty) return;
    final index = _frontIndex.clamp(0, _allLiked.length - 1);
    final wasLast = index == _allLiked.length - 1;
    _allLiked.removeAt(index);
    if (_allLiked.isEmpty) {
      _frontIndex = 0;
    } else if (wasLast) {
      _frontIndex = _allLiked.length - 1;
    } else {
      _frontIndex = index;
    }
    _cardId++;
  }

  bool get _canUndo => _undoHistory.isNotEmpty && !_isDismissing;

  Future<void> undoLastUnlike() async {
    if (!_canUndo) return;

    final snapshot = _undoHistory.last;
    setState(() {
      _isDismissing = true;
    });

    final targetUserId = snapshot.removedUser.id;
    final postOk = targetUserId > 0
        ? await CardsService().swipeCard(
            outcome: SwipeOutcome.interest,
            targetUserId: targetUserId,
          )
        : true;
    if (!postOk) {
      if (!mounted) return;
      setState(() {
        _isDismissing = false;
      });
      return;
    }

    _undoHistory.removeLast();
    if (!mounted) return;
    setState(() {
      _allLiked = List<StackUserModel>.from(snapshot.allLiked);
      _frontIndex = snapshot.frontIndex.clamp(
        0,
        _allLiked.isEmpty ? 0 : _allLiked.length - 1,
      );
      _cardId++;
      _isDismissing = false;
    });
  }

  _RemovalSnapshot _snapshotFront() {
    return _RemovalSnapshot(
      allLiked: List<StackUserModel>.from(_allLiked),
      frontIndex: _frontIndex,
      removedUser: _frontUser!,
    );
  }

  Future<void> _unlikeFront() async {
    final user = _frontUser;
    if (_isDismissing || user == null) return;

    final snapshot = _snapshotFront();
    final targetUserId = user.id;
    setState(() {
      _isDismissing = true;
    });

    final deleteOk = targetUserId > 0
        ? await CardsService().deleteSwipe(targetUserId: targetUserId)
        : true;
    if (!deleteOk) {
      if (!mounted) return;
      setState(() {
        _isDismissing = false;
      });
      return;
    }

    setState(() {
      _dismissingCardId = _cardId;
      _dismissDirection = _DismissDirection.right;
    });

    await Future.delayed(_animationDuration);
    if (!mounted) return;

    setState(() {
      _undoHistory.add(snapshot);
      _dropFrontUser();
      _dismissingCardId = null;
      _dismissDirection = null;
      _isDismissing = false;
      _resetDrag();
    });
  }

  Future<void> _editFront(
    SwipeOutcome outcome,
    _DismissDirection direction,
  ) async {
    final user = _frontUser;
    if (_isDismissing || user == null) return;

    final snapshot = _snapshotFront();
    final targetUserId = user.id;
    setState(() {
      _isDismissing = true;
    });

    final postOk = targetUserId > 0
        ? await CardsService().swipeCard(
            outcome: outcome,
            targetUserId: targetUserId,
          )
        : true;
    if (!postOk) {
      if (!mounted) return;
      setState(() {
        _isDismissing = false;
        _resetDrag();
      });
      return;
    }

    setState(() {
      _dismissingCardId = _cardId;
      _dismissDirection = direction;
      _dragDx = 0;
      _dragDy = 0;
      _isDragging = false;
    });

    await Future.delayed(_animationDuration);
    if (!mounted) return;

    setState(() {
      _undoHistory.add(snapshot);
      _dropFrontUser();
      _dismissingCardId = null;
      _dismissDirection = null;
      _isDismissing = false;
      _resetDrag();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _frontUser;
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : user == null
            ? Center(
                child: Text(
                  'No liked users yet.',
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
                            children: [_buildCard(user)],
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
                          onKnow: () => _editFront(
                              SwipeOutcome.know, _DismissDirection.up),
                          onNotInterested: () => _editFront(
                            SwipeOutcome.noInterest,
                            _DismissDirection.down,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Focus(
            focusNode: _keyboardFocusNode,
            autofocus: true,
            onKeyEvent: _onArrowKeyEvent,
            child: SafeArea(child: body),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppConfig().dimens.medium,
                  top: AppConfig().dimens.small,
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  color: Colors.black,
                  tooltip: 'Settings',
                  onPressed: () => Get.toNamed(AppConfig().routes.settings),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: AppConfig().dimens.medium,
                  top: AppConfig().dimens.small,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo),
                      color: Colors.black,
                      tooltip: 'Undo',
                      onPressed: undoLastUnlike,
                    ),
                    IconButton(
                      icon: const Icon(Icons.lightbulb),
                      color: AppConfig().colors.sparkYellow,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  KeyEventResult _onArrowKeyEvent(FocusNode node, KeyEvent event) {
    final isArrow = event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown;
    if (!isArrow) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    if (_isDismissing || _isDragging || _allLiked.isEmpty) {
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goBack();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _skip();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _editFront(SwipeOutcome.know, _DismissDirection.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _editFront(SwipeOutcome.noInterest, _DismissDirection.down);
    }
    return KeyEventResult.handled;
  }

  Widget _buildCard(StackUserModel user) {
    final isDismissing = _cardId == _dismissingCardId;
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
    final color = kStackCardColors[_frontIndex % kStackCardColors.length];

    final face = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: const <PointerDeviceKind>{},
      ),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onCardPointerDown,
        onPointerMove: _onCardPointerMove,
        onPointerUp: _onCardPointerUp,
        onPointerCancel: _onCardPointerCancel,
        child: StackCardFace(
          user: user,
          accentColor: color,
          displayName: _displayName(user),
          interestOn: true,
          canToggleInterest: !_isDismissing && !_isDragging,
          onInterestPressed: _unlikeFront,
        ),
      ),
    );

    return AnimatedPositioned(
      key: ValueKey('liked-card-$_cardId'),
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

class _RemovalSnapshot {
  final List<StackUserModel> allLiked;
  final int frontIndex;
  final StackUserModel removedUser;

  const _RemovalSnapshot({
    required this.allLiked,
    required this.frontIndex,
    required this.removedUser,
  });
}
