import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

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
  final List<_StackCard> cards;
  final List<StackUserModel> userPool;
  final int nextCardId;
  final Set<int> markedCardIds;
  final Set<int> dismissedUserIds;
  final int dismissedUserId;
  final StackUserModel? savedIdea;

  const _StackSnapshot({
    required this.cards,
    required this.userPool,
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
  static const int _visibleCardCount = 1;

  late List<_StackCard> _cards;
  late List<StackUserModel> _userPool;
  int _nextCardId = 0;
  int? _dismissingCardId;
  _DismissDirection? _dismissDirection;
  bool _isDismissing = false;
  final List<_StackSnapshot> _undoHistory = [];
  final Set<int> _markedCardIds = {};
  final Set<int> _dismissedUserIds = {};
  final FocusNode _keyboardFocusNode = FocusNode();

  bool get canUndo => _undoHistory.isNotEmpty && !_isDismissing;

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
      _cards = List<_StackCard>.from(snapshot.cards);
      _userPool = List<StackUserModel>.from(snapshot.userPool);
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
    if (_isDismissing || _cards.isEmpty) return;
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
    _userPool = List<StackUserModel>.from(users);
    _nextCardId = 0;
    _cards = _buildInitialCards();
    _markedCardIds.clear();
    _dismissedUserIds.clear();
    _undoHistory.clear();
    _dismissingCardId = null;
    _dismissDirection = null;
    _isDismissing = false;
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
      color: kStackCardColors[id % kStackCardColors.length],
      user: user,
    );
  }

  StackUserModel? _nextUserFromPool() {
    if (_userPool.isEmpty) return null;
    return _userPool.removeAt(0);
  }

  Future<void> _dismissFrontCard(
    _DismissDirection direction,
    SwipeOutcome outcome,
  ) async {
    if (_isDismissing || _cards.isEmpty) return;
    await _dismissCard(direction, _cards.first, outcome);
  }

  Future<void> _dismissCard(
    _DismissDirection direction,
    _StackCard card,
    SwipeOutcome outcome,
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
      });
      return;
    }

    widget.onUserActed?.call();

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

    final wasInterested = outcome == SwipeOutcome.interest &&
        _markedCardIds.contains(card.id);
    setState(() {
      _undoHistory.add(_StackSnapshot(
        cards: List<_StackCard>.from(_cards),
        userPool: List<StackUserModel>.from(_userPool),
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
    });
    if (wasInterested) widget.onCardHearted?.call(card.user);
  }

  void _applyDismiss(
    _StackCard dismissed,
    StackUserModel? replacement,
  ) {
    _markedCardIds.remove(dismissed.id);
    _cards = _cards.where((card) => card.id != dismissed.id).toList();

    final nextUser = replacement ?? _nextUserFromPool();
    if (nextUser != null) {
      final replacementCard = _stackCardFromUser(
        user: nextUser,
        initStackPos: 0,
      );
      _cards.add(replacementCard);
    }
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

          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _dismissFrontCard(_DismissDirection.up, SwipeOutcome.know);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _dismissFrontCard(
              _DismissDirection.down,
              SwipeOutcome.noInterest,
            );
          }
        },
        child: SafeArea(
          child: _cards.isEmpty
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
                              children: _cards.map(_buildCard).toList(),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: 280,
                            child: CustomIconButton(
                              title: 'I know this person',
                              onTap: _isDismissing
                                  ? null
                                  : () => _dismissFrontCard(
                                        _DismissDirection.up,
                                        SwipeOutcome.know,
                                      ),
                              txtColor: Colors.white,
                              color: AppConfig().colors.primaryColor,
                            ),
                          ),
                          Gap(AppConfig().dimens.small),
                          SizedBox(
                            width: 280,
                            child: CustomOutlineIconButton(
                              title: "I'm not interested",
                              onTap: _isDismissing
                                  ? null
                                  : () => _dismissFrontCard(
                                        _DismissDirection.down,
                                        SwipeOutcome.noInterest,
                                      ),
                            ),
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

  Widget _buildCard(_StackCard card) {
    final isDismissing = card.id == _dismissingCardId;
    const baseLeft = 0.0;
    const baseTop = (kStackHeight - kStackCardHeight) / 2;

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

    return AnimatedPositioned(
      key: ValueKey('card-${card.id}'),
      left: baseLeft + horizontalDismiss,
      top: baseTop + verticalDismiss,
      width: kStackCardWidth,
      height: kStackCardHeight,
      duration: _animationDuration,
      curve: Curves.easeInOutCubic,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: _animationDuration,
        curve: Curves.easeInOutCubic,
        child: IgnorePointer(
          ignoring: _isDismissing,
          child: StackCardFace(
            user: card.user,
            accentColor: card.color,
            displayName: _displayName(card),
            interestOn: isMarked,
            canToggleInterest: !_isDismissing,
            onInterestPressed: () => _showInterest(card),
          ),
        ),
      ),
    );
  }
}
