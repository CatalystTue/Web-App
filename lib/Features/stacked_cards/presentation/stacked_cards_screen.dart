import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

enum _DismissDirection { up, down, right }

class _StackCard {
  final int id;
  int initStackPos;
  final Color color;
  final String name;
  final String description;
  final String affiliation;
  final String position;
  final String location;
  final StackUserModel user;

  _StackCard({
    required this.id,
    required this.initStackPos,
    required this.color,
    required this.name,
    required this.description,
    required this.affiliation,
    required this.position,
    required this.location,
    required this.user,
  });

  _StackCard copyWith({int? initStackPos}) {
    return _StackCard(
      id: id,
      initStackPos: initStackPos ?? this.initStackPos,
      color: color,
      name: name,
      description: description,
      affiliation: affiliation,
      position: position,
      location: location,
      user: user,
    );
  }
}

class _StackSnapshot {
  final List<_StackCard> cards;
  final List<StackUserModel> userPool;
  final int frontIndex;
  final int nextCardId;
  final Set<int> markedCardIds;
  final Set<int> dismissedUserIds;
  final int dismissedUserId;
  final StackUserModel? savedIdea;

  const _StackSnapshot({
    required this.cards,
    required this.userPool,
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

  const StackedCardsScreen({
    super.key,
    required this.users,
    this.onCardHearted,
    this.onCardUnhearted,
  });

  @override
  State<StackedCardsScreen> createState() => StackedCardsScreenState();
}

class StackedCardsScreenState extends State<StackedCardsScreen> {
  static const int _visibleCardCount = 5;
  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const double _cardWidth = 260;
  static const double _cardHeight = 400;
  static const double _cardGap = -150;
  static const double _behindScale = 0.4;
  static const double _horizontalStep = _cardWidth + _cardGap;
  static const double _maxStackWidth =
      _cardWidth + (_visibleCardCount - 1) * _horizontalStep;
  static const double _stackHeight = 440;

  static const List<Color> _cardColors = [
    Color(0xFF4F5D75),
    Color(0xFFA4D294),
    Color(0xFFFF9B9B),
    Color(0xFF605D64),
    Color(0xFFFA7E7E),
  ];

  late List<_StackCard> _cards;
  late List<StackUserModel> _userPool;
  int _frontIndex = 0;
  int _nextCardId = 0;
  int? _dismissingCardId;
  _DismissDirection? _dismissDirection;
  bool _isDismissing = false;
  final List<_StackSnapshot> _undoHistory = [];
  final Set<int> _markedCardIds = {};
  final Set<int> _dismissedUserIds = {};
  final Map<int, GlobalKey> _cardKeys = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  bool get canUndo => _undoHistory.isNotEmpty && !_isDismissing;

  double get _stackWidth {
    if (_cards.isEmpty) return 0;
    return _cardWidth + (_cards.length - 1) * _horizontalStep;
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
      _cards = List<_StackCard>.from(snapshot.cards);
      _userPool = List<StackUserModel>.from(snapshot.userPool);
      _frontIndex = snapshot.frontIndex;
      _nextCardId = snapshot.nextCardId;
      _markedCardIds
        ..clear()
        ..addAll(snapshot.markedCardIds);
      _dismissedUserIds
        ..clear()
        ..addAll(snapshot.dismissedUserIds);
      _isDismissing = false;
    });
    _scrollActiveCardIntoView();
  }

  void _heartCard(int cardId) {
    if (_isDismissing || _cards.isEmpty) return;

    final cardIndex = _cards.indexWhere((card) => card.id == cardId);
    if (cardIndex < 0 || _stackPosition(_cards[cardIndex]) != 0) return;

    _markedCardIds.add(cardId);
    _dismissCard(_DismissDirection.right, _cards[cardIndex]);
  }

  @override
  void initState() {
    super.initState();
    _userPool = List<StackUserModel>.from(widget.users);
    _cards = _buildInitialCards();
    _frontIndex = _cards.isEmpty ? 0 : _indexOfCenterCard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
        _scrollActiveCardIntoView();
      }
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  List<_StackCard> _buildInitialCards() {
    final takeCount = _userPool.length < _visibleCardCount
        ? _userPool.length
        : _visibleCardCount;
    final initialUsers = _userPool.take(takeCount).toList();
    _userPool =
        _userPool.length == takeCount ? [] : _userPool.sublist(takeCount);

    return List.generate(
      initialUsers.length,
      (index) => _stackCardFromUser(
        user: initialUsers[index],
        initStackPos: index,
      ),
    );
  }

  _StackCard _stackCardFromUser({
    required StackUserModel user,
    required int initStackPos,
  }) {
    final id = _nextCardId++;
    return _StackCard(
      id: id,
      initStackPos: initStackPos,
      color: _cardColors[id % _cardColors.length],
      name: user.name.isNotEmpty ? user.name : 'Card ${id + 1}',
      description: user.description,
      affiliation: user.affiliation,
      position: user.position,
      location: user.location,
      user: user,
    );
  }

  StackUserModel? _nextUserFromPool() {
    if (_userPool.isEmpty) return null;
    return _userPool.removeAt(0);
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

  void _scrollActiveCardIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _cards.isEmpty) return;
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

  Future<void> _dismissFrontCard(_DismissDirection direction) async {
    if (_isDismissing || _cards.isEmpty) return;
    await _dismissCard(direction, _cards[_frontIndex]);
  }

  Future<void> _dismissCard(
    _DismissDirection direction,
    _StackCard card,
  ) async {
    if (_isDismissing || _cards.isEmpty) return;

    final dismissedUserId = card.user.id;
    final snapshotDismissedUserIds = Set<int>.from(_dismissedUserIds);
    if (dismissedUserId > 0) {
      _dismissedUserIds.add(dismissedUserId);
    }

    final remainingUserIds = <int>{
      ..._cards.where((item) => item.id != card.id).map((item) => item.user.id),
      ..._dismissedUserIds,
    }.where((id) => id > 0).toList();

    setState(() {
      _isDismissing = true;
    });

    final swipeOk = dismissedUserId > 0
        ? await CardsService().swipeCard(
            interested: direction == _DismissDirection.right,
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
      });
      return;
    }

    final replacementFuture = CardsService().getReplacementUser(
      remainingUserIds: remainingUserIds,
      dismissedUserId: dismissedUserId,
    );

    setState(() {
      _dismissingCardId = card.id;
      _dismissDirection = direction;
    });

    await Future.delayed(_animationDuration);
    final replacementUser = await replacementFuture;

    if (!mounted) return;

    final wasHearted = direction == _DismissDirection.right &&
        _markedCardIds.contains(card.id);
    setState(() {
      _undoHistory.add(_StackSnapshot(
        cards: List<_StackCard>.from(_cards),
        userPool: List<StackUserModel>.from(_userPool),
        frontIndex: _frontIndex,
        nextCardId: _nextCardId,
        markedCardIds: Set<int>.from(_markedCardIds)..remove(card.id),
        dismissedUserIds: snapshotDismissedUserIds,
        dismissedUserId: dismissedUserId,
        savedIdea: wasHearted ? card.user : null,
      ));
      _applyDismiss(card, replacementUser);
      _dismissingCardId = null;
      _dismissDirection = null;
      _isDismissing = false;
    });
    _scrollActiveCardIntoView();
    if (wasHearted) widget.onCardHearted?.call(card.user);
  }

  int _initPositionToIndex(int index) {
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].initStackPos == index) {
        return i;
      }
    }
    return -1;
  }

  void _applyDismiss(
    _StackCard dismissed,
    StackUserModel? replacement,
  ) {
    _markedCardIds.remove(dismissed.id);
    _cardKeys.remove(dismissed.id);
    final dismissedPos = dismissed.initStackPos;
    _cards = _cards.where((card) => card.id != dismissed.id).toList();

    final nextUser = replacement ?? _nextUserFromPool();
    if (nextUser != null) {
      final replacementCard = _stackCardFromUser(
        user: nextUser,
        initStackPos: dismissedPos,
      );
      _cards.add(replacementCard);
      _frontIndex = _cards.indexWhere((card) => card.id == replacementCard.id);
      return;
    }

    _cards = [
      for (final card in _cards)
        card.initStackPos > dismissedPos
            ? card.copyWith(initStackPos: card.initStackPos - 1)
            : card,
    ];

    if (_cards.isEmpty) {
      _frontIndex = 0;
      return;
    }

    final shiftedIntoHole =
        _cards.indexWhere((card) => card.initStackPos == dismissedPos);
    if (shiftedIntoHole >= 0) {
      _frontIndex = shiftedIntoHole;
      return;
    }

    final leftNeighbor =
        _cards.indexWhere((card) => card.initStackPos == dismissedPos - 1);
    _frontIndex = leftNeighbor >= 0 ? leftNeighbor : 0;
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

  int _stackPosition(_StackCard card) {
    if (_cards.isEmpty || _frontIndex < 0 || _frontIndex >= _cards.length) {
      return 0;
    }
    final frontInitPos = _cards[_frontIndex].initStackPos;
    final count = _cards.length;
    return (card.initStackPos - frontInitPos + count) % count;
  }

  List<_StackCard> get _sortedCards {
    return List<_StackCard>.from(_cards)
      ..sort((a, b) => _stackPosition(b).compareTo(_stackPosition(a)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      body: KeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent || _isDismissing || _cards.isEmpty) {
            return;
          }

          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _bringPreviousCardForward();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _bringNextCardForward();
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _dismissFrontCard(_DismissDirection.up);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _dismissFrontCard(_DismissDirection.down);
          }
        },
        child: SafeArea(
          child: _cards.isEmpty
              ? Center(
                  child: Text(
                    'No more users in queue.',
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
                        child: LayoutBuilder(
                          builder: (context, constraints) => Center(
                            child: SizedBox(
                              width: constraints.constrainWidth(_maxStackWidth),
                              height: _stackHeight,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                child: SizedBox(
                                  width: _maxStackWidth,
                                  height: _stackHeight,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _isDismissing
                                ? null
                                : _bringPreviousCardForward,
                            icon: const Icon(Icons.arrow_back_ios_new),
                            color: AppConfig().colors.primaryColor,
                            iconSize: 32,
                            tooltip: 'Previous card',
                          ),
                          Gap(AppConfig().dimens.medium),
                          Column(
                            children: [
                              IconButton(
                                onPressed: _isDismissing
                                    ? null
                                    : () => _dismissFrontCard(
                                          _DismissDirection.up,
                                        ),
                                icon: const Icon(Icons.keyboard_arrow_up),
                                color: AppConfig().colors.primaryColor,
                                iconSize: 32,
                                tooltip: 'I know this person',
                              ),
                              IconButton(
                                onPressed: _isDismissing
                                    ? null
                                    : () => _dismissFrontCard(
                                          _DismissDirection.down,
                                        ),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                color: AppConfig().colors.primaryColor,
                                iconSize: 32,
                                tooltip: 'Not interested',
                              ),
                            ],
                          ),
                          Gap(AppConfig().dimens.medium),
                          IconButton(
                            onPressed:
                                _isDismissing ? null : _bringNextCardForward,
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: AppConfig().colors.primaryColor,
                            iconSize: 32,
                            tooltip: 'Next card',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(_StackCard card) {
    final stackPos = _stackPosition(card);
    final isFront = stackPos == 0;
    final isDismissing = card.id == _dismissingCardId;
    final originLeft = (_maxStackWidth - _stackWidth) / 2;
    final baseLeft = originLeft + card.initStackPos * _horizontalStep;
    const baseTop = (_stackHeight - _cardHeight) / 2;

    final horizontalDismiss =
        isDismissing && _dismissDirection == _DismissDirection.right
            ? _cardWidth * 1.4
            : 0.0;

    final verticalDismiss = isDismissing
        ? switch (_dismissDirection) {
            _DismissDirection.up => -_cardHeight * 1.4,
            _DismissDirection.down => _cardHeight * 1.4,
            _ => 0.0,
          }
        : 0.0;

    final opacity = isDismissing ? 0.0 : (isFront ? 1.0 : 0.9);

    return AnimatedPositioned(
      key: ValueKey('card-${card.id}'),
      left: baseLeft + horizontalDismiss,
      top: baseTop + verticalDismiss,
      width: _cardWidth,
      height: _cardHeight,
      duration: _animationDuration,
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
              scale: isFront ? 1.0 : _behindScale,
              duration: _animationDuration,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.center,
              child: _buildCardFace(card, isInteractive: isFront),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(_StackCard card, {required bool isInteractive}) {
    return Card(
      elevation: 10.0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: card.color.withValues(alpha: 0.55),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(AppConfig().dimens.medium),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: card.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Gap(AppConfig().dimens.medium),
                Text(
                  card.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConfig().colors.txtHeaderColor,
                  ),
                ),
                Gap(AppConfig().dimens.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.affiliation.isNotEmpty
                            ? card.affiliation
                            : 'No affiliation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConfig().colors.txtBodyColor,
                        ),
                      ),
                      Gap(AppConfig().dimens.small),
                      Text(
                        card.position.isNotEmpty
                            ? card.position
                            : 'No position',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConfig().colors.txtBodyColor,
                        ),
                      ),
                      if (card.location.isNotEmpty) ...[
                        Gap(AppConfig().dimens.small),
                        Text(
                          card.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppConfig().colors.txtBodyColor,
                          ),
                        ),
                      ],
                      Gap(AppConfig().dimens.small),
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: Text(
                              card.description.isNotEmpty
                                  ? card.description
                                  : 'No description',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppConfig().colors.txtBodyColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildHeartButton(
                card.id,
                canHeart: isInteractive && !_isDismissing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartButton(int cardId, {required bool canHeart}) {
    final isMarked = _markedCardIds.contains(cardId);
    final red = AppConfig().colors.redColor;

    return IconButton(
      onPressed: canHeart ? () => _heartCard(cardId) : null,
      tooltip: canHeart ? 'Heart card' : null,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isMarked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isMarked),
          color: red,
          size: 32,
        ),
      ),
    );
  }
}
