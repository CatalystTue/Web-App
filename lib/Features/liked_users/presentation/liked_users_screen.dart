import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LikedUsersScreen extends StatefulWidget {
  final List<StackUserModel>? initialUsers;

  const LikedUsersScreen({
    super.key,
    this.initialUsers,
  });

  @override
  State<LikedUsersScreen> createState() => _LikedUsersScreenState();
}

class _LikedUsersScreenState extends State<LikedUsersScreen> {
  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const double _swipeDistanceThreshold = 80;
  static const double _swipeVelocityThreshold = 800;
  static const double _dragSlop = 8;

  bool _loading = true;
  List<StackUserModel> _allLiked = [];
  late List<_LikedCard> _cards;
  int _windowStart = 0;
  int _frontIndex = 0;
  int _nextCardId = 0;
  int? _dismissingCardId;
  bool _isDismissing = false;
  bool _isDragging = false;
  double _dragDx = 0;
  double _dragDy = 0;
  int? _dragPointer;
  double _dragStartX = 0;
  double _dragStartY = 0;
  Duration _dragStartTime = Duration.zero;
  final Map<int, GlobalKey> _cardKeys = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  double get _stackWidth {
    if (_cards.isEmpty) return 0;
    return kStackCardWidth + (_cards.length - 1) * kStackHorizontalStep;
  }

  int get _maxWindowStart {
    if (_allLiked.length <= kStackVisibleCardCount) return 0;
    return _allLiked.length - kStackVisibleCardCount;
  }

  @override
  void initState() {
    super.initState();
    _cards = [];
    if (widget.initialUsers != null) {
      _allLiked = List<StackUserModel>.from(widget.initialUsers!);
      _rebuildWindowCards();
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

  bool get _canBrowse => _cards.length > 1;
  bool get _canShiftWindow => _allLiked.length > kStackVisibleCardCount;

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
    if (_isDismissing || _cards.isEmpty || _dragPointer != null) return;
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

    if (useHorizontal && _canBrowse) {
      if (shouldLeft && !shouldRight) {
        setState(_resetDrag);
        _bringPreviousCardForward();
        return;
      }
      if (shouldRight && !shouldLeft) {
        setState(_resetDrag);
        _bringNextCardForward();
        return;
      }
    }
    if (!useHorizontal && _canShiftWindow) {
      if (shouldUp && !shouldDown) {
        setState(_resetDrag);
        _shiftWindow(-1);
        return;
      }
      if (shouldDown && !shouldUp) {
        setState(_resetDrag);
        _shiftWindow(1);
        return;
      }
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
    _windowStart = 0;
    _rebuildWindowCards();
    setState(() {
      _loading = false;
    });
    _scrollActiveCardIntoView();
  }

  void _rebuildWindowCards({int? keepFrontInitPos}) {
    final end = (_windowStart + kStackVisibleCardCount).clamp(
      0,
      _allLiked.length,
    );
    final window = _allLiked.sublist(_windowStart, end);
    _nextCardId = 0;
    _cardKeys.clear();
    _cards = [
      for (var i = 0; i < window.length; i++)
        _likedCardFromUser(user: window[i], initStackPos: i),
    ];
    _frontIndex = 0;
    if (keepFrontInitPos != null) {
      final idx =
          _cards.indexWhere((card) => card.initStackPos == keepFrontInitPos);
      if (idx >= 0) _frontIndex = idx;
    } else if (_cards.isNotEmpty) {
      _frontIndex = _indexOfCenterCard();
    }
  }

  _LikedCard _likedCardFromUser({
    required StackUserModel user,
    required int initStackPos,
  }) {
    final id = _nextCardId++;
    return _LikedCard(
      id: id,
      initStackPos: initStackPos,
      color: kStackCardColors[id % kStackCardColors.length],
      user: user,
    );
  }

  String _displayName(_LikedCard card) {
    return card.user.name.isNotEmpty ? card.user.name : 'Card ${card.id + 1}';
  }

  void _bringNextCardForward() {
    if (_isDismissing || _cards.isEmpty) return;
    if (_frontIndex < 0 || _frontIndex >= _cards.length) {
      _frontIndex = 0;
    }
    final nextInitPosition =
        (_cards[_frontIndex].initStackPos + 1) % _cards.length;
    setState(() {
      _frontIndex = _initPositionToIndex(nextInitPosition);
      if (_frontIndex < 0) _frontIndex = 0;
    });
    _scrollActiveCardIntoView();
  }

  void _bringPreviousCardForward() {
    if (_isDismissing || _cards.isEmpty) return;
    if (_frontIndex < 0 || _frontIndex >= _cards.length) {
      _frontIndex = 0;
    }
    final previousInitPosition =
        (_cards[_frontIndex].initStackPos - 1 + _cards.length) % _cards.length;
    setState(() {
      _frontIndex = _initPositionToIndex(previousInitPosition);
      if (_frontIndex < 0) _frontIndex = 0;
    });
    _scrollActiveCardIntoView();
  }

  void _shiftWindow(int delta) {
    if (_isDismissing || _allLiked.length <= kStackVisibleCardCount) return;
    final next = (_windowStart + delta).clamp(0, _maxWindowStart);
    if (next == _windowStart) return;
    setState(() {
      _windowStart = next;
      _rebuildWindowCards(keepFrontInitPos: _cards.isEmpty
          ? null
          : _cards[_frontIndex.clamp(0, _cards.length - 1)].initStackPos);
    });
    _scrollActiveCardIntoView();
  }

  void _scrollActiveCardIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _cards.isEmpty) return;
      if (_frontIndex < 0 || _frontIndex >= _cards.length) return;
      final activeCard = _cards[_frontIndex];
      final cardContext = _cardKeys[activeCard.id]?.currentContext;
      if (cardContext == null) return;

      Scrollable.ensureVisible(
        cardContext,
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    });
  }

  Future<void> _unlikeFrontOrCard(_LikedCard card) async {
    if (_isDismissing || _cards.isEmpty) return;
    if (_stackPosition(card) != 0) return;

    final targetUserId = card.user.id;
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
      _dismissingCardId = card.id;
    });

    await Future.delayed(_animationDuration);
    if (!mounted) return;

    setState(() {
      _allLiked.removeWhere((user) => user.id == card.user.id);
      if (_windowStart > _maxWindowStart) {
        _windowStart = _maxWindowStart;
      }
      _dismissingCardId = null;
      _isDismissing = false;
      _rebuildWindowCards();
    });
    _scrollActiveCardIntoView();
  }

  int _initPositionToIndex(int index) {
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].initStackPos == index) {
        return i;
      }
    }
    return -1;
  }

  int _indexOfCenterCard() {
    if (_cards.isEmpty) return 0;
    final centerPos = (_cards.length - 1) ~/ 2;
    final centerIndex =
        _cards.indexWhere((card) => card.initStackPos == centerPos);
    if (centerIndex >= 0) return centerIndex;

    var closestIndex = 0;
    var closestDistance = 999;
    for (var i = 0; i < _cards.length; i++) {
      final distance = (_cards[i].initStackPos - centerPos).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  int _stackPosition(_LikedCard card) {
    if (_cards.isEmpty || _frontIndex < 0 || _frontIndex >= _cards.length) {
      return 0;
    }
    final frontInitPos = _cards[_frontIndex].initStackPos;
    final count = _cards.length;
    return (card.initStackPos - frontInitPos + count) % count;
  }

  List<_LikedCard> get _sortedCards {
    return List<_LikedCard>.from(_cards)
      ..sort((a, b) => _stackPosition(b).compareTo(_stackPosition(a)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Liked Users',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent ||
              _isDismissing ||
              _isDragging ||
              _cards.isEmpty) {
            return;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _bringPreviousCardForward();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _bringNextCardForward();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _shiftWindow(-1);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _shiftWindow(1);
          }
        },
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _cards.isEmpty
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
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: const <PointerDeviceKind>{},
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Center(
                            child: SizedBox(
                              width: constraints.constrainWidth(kStackMaxWidth),
                              height: kStackHeight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                child: SizedBox(
                                  width: kStackMaxWidth,
                                  height: kStackHeight,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: _sortedCards
                                        .map(_buildStackedCard)
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(_LikedCard card) {
    final stackPos = _stackPosition(card);
    final isFront = stackPos == 0;
    final isDismissing = card.id == _dismissingCardId;
    final originLeft = (kStackMaxWidth - _stackWidth) / 2;
    final baseLeft = originLeft + card.initStackPos * kStackHorizontalStep;
    const baseTop = (kStackHeight - kStackCardHeight) / 2;

    final horizontalDismiss =
        isDismissing ? kStackCardWidth * 1.4 : 0.0;
    final opacity = isDismissing ? 0.0 : (isFront ? 1.0 : 0.9);
    final dragOffsetX =
        isFront && _dismissingCardId == null ? _dragDx : 0.0;
    final dragOffsetY =
        isFront && _dismissingCardId == null ? _dragDy : 0.0;

    Widget face = StackCardFace(
      user: card.user,
      accentColor: card.color,
      displayName: _displayName(card),
      interestOn: true,
      canToggleInterest: isFront && !_isDismissing && !_isDragging,
      onInterestPressed: () => _unlikeFrontOrCard(card),
    );
    if (isFront) {
      face = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onCardPointerDown,
        onPointerMove: _onCardPointerMove,
        onPointerUp: _onCardPointerUp,
        onPointerCancel: _onCardPointerCancel,
        child: face,
      );
    }

    return AnimatedPositioned(
      key: ValueKey('liked-card-${card.id}'),
      left: baseLeft + horizontalDismiss + dragOffsetX,
      top: baseTop + dragOffsetY,
      width: kStackCardWidth,
      height: kStackCardHeight,
      duration: _isDragging && _dismissingCardId == null
          ? Duration.zero
          : _animationDuration,
      curve: Curves.easeInOutCubic,
      child: KeyedSubtree(
        key: _cardKeys.putIfAbsent(card.id, () => GlobalKey()),
        child: AnimatedOpacity(
          opacity: opacity,
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          child: IgnorePointer(
            ignoring: !isFront || _isDismissing,
            child: AnimatedScale(
              scale: isFront ? 1.0 : kStackBehindScale,
              duration: _animationDuration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.center,
              child: face,
            ),
          ),
        ),
      ),
    );
  }
}

class _LikedCard {
  final int id;
  final int initStackPos;
  final Color color;
  final StackUserModel user;

  _LikedCard({
    required this.id,
    required this.initStackPos,
    required this.color,
    required this.user,
  });
}
