import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
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

  _StackCard({
    required this.id,
    required this.initStackPos,
    required this.color,
    required this.name,
    required this.description,
  });

  _StackCard copyWith({int? initStackPos}) {
    return _StackCard(
      id: id,
      initStackPos: initStackPos ?? this.initStackPos,
      color: color,
      name: name,
      description: description,
    );
  }
}

class _StackSnapshot {
  final List<_StackCard> cards;
  final List<StackUserModel> userPool;
  final int frontIndex;
  final int nextCardId;
  final Set<int> markedCardIds;

  const _StackSnapshot({
    required this.cards,
    required this.userPool,
    required this.frontIndex,
    required this.nextCardId,
    required this.markedCardIds,
  });
}

class StackedCardsScreen extends StatefulWidget {
  final List<StackUserModel> users;

  const StackedCardsScreen({
    super.key,
    required this.users,
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
  static const double _stackWidth =
      _cardWidth + (_visibleCardCount - 1) * _horizontalStep;
  static const double _stackHeight = 440;
  static const int _centerCardIndex = 2;
  static const int _lastTwoThreshold = 3;

  static const List<Color> _cardColors = [
    Color(0xFF4F5D75),
    Color(0xFFA4D294),
    Color(0xFFFF9B9B),
    Color(0xFF605D64),
    Color(0xFFFA7E7E),
  ];

  late List<_StackCard> _cards;
  late List<StackUserModel> _userPool;
  int _frontIndex = _centerCardIndex;
  int _nextCardId = 0;
  int? _dismissingCardId;
  _DismissDirection? _dismissDirection;
  bool _isDismissing = false;
  final List<_StackSnapshot> _undoHistory = [];
  final Set<int> _markedCardIds = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  bool get canUndo => _undoHistory.isNotEmpty && !_isDismissing;

  void undoLastDismiss() {
    if (!canUndo) return;

    final snapshot = _undoHistory.removeLast();
    setState(() {
      _cards = List<_StackCard>.from(snapshot.cards);
      _userPool = List<StackUserModel>.from(snapshot.userPool);
      _frontIndex = snapshot.frontIndex;
      _nextCardId = snapshot.nextCardId;
      _markedCardIds
        ..clear()
        ..addAll(snapshot.markedCardIds);
    });
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
      }
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  List<_StackCard> _buildInitialCards() {
    final initialUsers = _userPool.take(_visibleCardCount).toList();
    if (initialUsers.length == _userPool.length) {
      _userPool = [];
    } else {
      _userPool = _userPool.sublist(initialUsers.length);
    }

    while (initialUsers.length < _visibleCardCount) {
      initialUsers.add(_nextUserFromPool());
    }

    return List.generate(
      _visibleCardCount,
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
    );
  }

  StackUserModel _nextUserFromPool() {
    if (_userPool.isNotEmpty) {
      return _userPool.removeAt(0);
    }
    return StackUserModel(
      name: 'User ${_nextCardId + 1}',
      description: 'No more users in queue.',
    );
  }

  void _bringNextCardForward() {
    int init_idx = 0;
    if (_isDismissing || _cards.isEmpty) return;
    init_idx = _cards[_frontIndex].initStackPos;
    init_idx = (init_idx + 1) % _cards.length;
    setState(() {
      _frontIndex = _InittoIdx(init_idx);
    });
  }

  void _bringPreviousCardForward() {
    int init_idx = 0;
    if (_isDismissing || _cards.isEmpty) return;
    init_idx = _cards[_frontIndex].initStackPos;
    init_idx = (init_idx - 1 + _cards.length) % _cards.length;
    setState(() {
      _frontIndex = _InittoIdx(init_idx);
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

    setState(() {
      _isDismissing = true;
      _dismissingCardId = card.id;
      _dismissDirection = direction;
    });

    await Future.delayed(_animationDuration);

    if (!mounted) return;

    setState(() {
      _undoHistory.add(_StackSnapshot(
        cards: List<_StackCard>.from(_cards),
        userPool: List<StackUserModel>.from(_userPool),
        frontIndex: _frontIndex,
        nextCardId: _nextCardId,
        markedCardIds: Set<int>.from(_markedCardIds),
      ));
      _applyDismiss(card);
      _dismissingCardId = null;
      _dismissDirection = null;
      _isDismissing = false;
    });
  }

  int _InittoIdx(int index) {
    for (int i = 0; i < _cards.length; i++) {
      if (_cards[i].initStackPos == index) {
        return i;
      }
    }
    return -1;
  }

  void _applyDismiss(_StackCard dismissed) {
    _markedCardIds.remove(dismissed.id);
    final dismissedPos = dismissed.initStackPos;

    if (dismissedPos < _lastTwoThreshold) {
      _cards = _cards.where((card) => card.id != dismissed.id).map((card) {
        if (card.initStackPos < dismissedPos) {
          return card.copyWith(initStackPos: card.initStackPos + 1);
        }
        return card;
      }).toList();

      _cards.add(_stackCardFromUser(
        user: _nextUserFromPool(),
        initStackPos: 0,
      ));
    } else {
      _cards = _cards.where((card) => card.id != dismissed.id).map((card) {
        if (card.initStackPos > dismissedPos) {
          return card.copyWith(initStackPos: card.initStackPos - 1);
        }
        return card;
      }).toList();

      final maxPos = _cards.fold<int>(
        0,
        (max, card) => card.initStackPos > max ? card.initStackPos : max,
      );

      _cards.add(_stackCardFromUser(
        user: _nextUserFromPool(),
        initStackPos: maxPos + 1,
      ));
    }

    _normalizeInitStackPositions();
    _frontIndex = _indexOfCenterCard();
  }

  void _normalizeInitStackPositions() {
    final sorted = List<_StackCard>.from(_cards)
      ..sort((a, b) => a.initStackPos.compareTo(b.initStackPos));

    for (var i = 0; i < sorted.length; i++) {
      final card = sorted[i];
      final listIndex = _cards.indexWhere((c) => c.id == card.id);
      if (listIndex >= 0) {
        _cards[listIndex] = card.copyWith(initStackPos: i);
      }
    }
  }

  int _indexOfCenterCard() {
    final centerIndex =
        _cards.indexWhere((card) => card.initStackPos == _centerCardIndex);
    if (centerIndex >= 0) return centerIndex;

    var closestIndex = 0;
    var closestDistance = 999;
    for (var i = 0; i < _cards.length; i++) {
      final distance = (_cards[i].initStackPos - _centerCardIndex).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  int _stackPosition(_StackCard card) {
    if (_cards.isEmpty) return 0;
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
          if (event is! KeyDownEvent || _isDismissing) return;

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
          child: Padding(
            padding: EdgeInsets.all(AppConfig().dimens.medium),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: _stackWidth,
                        height: _stackHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children:
                              _sortedCards.map(_buildStackedCard).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          _isDismissing ? null : _bringPreviousCardForward,
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
                              : () => _dismissFrontCard(_DismissDirection.up),
                          icon: const Icon(Icons.keyboard_arrow_up),
                          color: AppConfig().colors.primaryColor,
                          iconSize: 32,
                          tooltip: 'I know this person',
                        ),
                        IconButton(
                          onPressed: _isDismissing
                              ? null
                              : () => _dismissFrontCard(_DismissDirection.down),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          color: AppConfig().colors.primaryColor,
                          iconSize: 32,
                          tooltip: 'Not interested',
                        ),
                      ],
                    ),
                    Gap(AppConfig().dimens.medium),
                    IconButton(
                      onPressed: _isDismissing ? null : _bringNextCardForward,
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
    final horizontalOffset =
        (card.initStackPos - _centerCardIndex) * _horizontalStep;

    final horizontalDismiss = isDismissing &&
            _dismissDirection == _DismissDirection.right
        ? 1.4
        : 0.0;

    final verticalDismiss = isDismissing
        ? switch (_dismissDirection) {
            _DismissDirection.up => -1.4,
            _DismissDirection.down => 1.4,
            _ => 0.0,
          }
        : 0.0;

    final opacity = isDismissing ? 0.0 : (isFront ? 1.0 : 0.9);

    return AnimatedOpacity(
      key: ValueKey('card-${card.id}'),
      opacity: opacity,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
      child: AnimatedSlide(
        offset: Offset(
          horizontalOffset / _cardWidth + horizontalDismiss,
          verticalDismiss,
        ),
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
        child: SizedBox(
          width: _cardWidth,
          height: _cardHeight,
          child: AnimatedScale(
            scale: isFront ? 1.0 : _behindScale,
            duration: _animationDuration,
            curve: Curves.easeInOutCubic,
            alignment: Alignment.center,
            child: _buildCardFace(card, isInteractive: isFront),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFace(_StackCard card, {required bool isInteractive}) {
    return Card(
      elevation: 10.0,
      shadowColor: Colors.black.withOpacity(0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: card.color.withOpacity(0.55),
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
                  child: Text(
                    card.description.isNotEmpty
                        ? card.description
                        : 'No description',
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppConfig().colors.txtBodyColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
