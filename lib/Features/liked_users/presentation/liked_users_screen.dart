import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_chrome.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_outcome_buttons.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum _DismissDirection { up, down }

class LikedUsersScreen extends StatefulWidget {
  final List<StackUserModel>? initialUsers;

  const LikedUsersScreen({
    super.key,
    this.initialUsers,
  });

  @override
  State<LikedUsersScreen> createState() => LikedUsersScreenState();
}

class LikedUsersScreenState extends State<LikedUsersScreen>
    with SingleTickerProviderStateMixin {
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
  bool _dragIsHorizontal = false;
  double _dragDx = 0;
  double _dragDy = 0;
  int? _dragPointer;
  double _dragStartX = 0;
  double _dragStartY = 0;
  Duration _dragStartTime = Duration.zero;
  final FocusNode _keyboardFocusNode = FocusNode();
  final List<_RemovalSnapshot> _undoHistory = [];

  late final AnimationController _browseController;
  int _browseDir = 0;

  bool get _loops => _allLiked.length >= 3;

  bool get _isBrowsing => _browseDir != 0;

  bool get _canGoNext =>
      !_isDismissing &&
      !_isBrowsing &&
      _allLiked.length > 1 &&
      (_loops || _frontIndex < _allLiked.length - 1);

  bool get _canGoPrev =>
      !_isDismissing &&
      !_isBrowsing &&
      _allLiked.length > 1 &&
      (_loops || _frontIndex > 0);

  bool get _canUndo => _undoHistory.isNotEmpty && !_isDismissing;

  StackUserModel? get _frontUser {
    if (_allLiked.isEmpty) return null;
    final index = _frontIndex.clamp(0, _allLiked.length - 1);
    return _allLiked[index];
  }

  @override
  void initState() {
    super.initState();
    _browseController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..addStatusListener((status) {
        if (status != AnimationStatus.completed || _browseDir == 0) return;
        final n = _allLiked.length;
        if (n == 0) {
          _browseDir = 0;
          _browseController.reset();
          return;
        }
        setState(() {
          if (_loops) {
            _frontIndex = (_frontIndex + _browseDir + n) % n;
          } else {
            _frontIndex = (_frontIndex + _browseDir).clamp(0, n - 1);
          }
          _browseDir = 0;
          _browseController.reset();
          _resetDrag();
        });
      });
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
    _browseController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _resetDrag() {
    _isDragging = false;
    _dragIsHorizontal = false;
    _dragDx = 0;
    _dragDy = 0;
    _dragPointer = null;
    _dragStartX = 0;
    _dragStartY = 0;
    _dragStartTime = Duration.zero;
  }

  void _onCardPointerDown(PointerDownEvent event) {
    if (_isDismissing ||
        _isBrowsing ||
        _allLiked.isEmpty ||
        _dragPointer != null) {
      return;
    }
    _dragPointer = event.pointer;
    _dragStartX = event.position.dx;
    _dragStartY = event.position.dy;
    _dragStartTime = event.timeStamp;
  }

  void _onCardPointerMove(PointerMoveEvent event) {
    if (event.pointer != _dragPointer || _isDismissing || _isBrowsing) return;
    var dx = event.position.dx - _dragStartX;
    final dy = event.position.dy - _dragStartY;
    if (!_isDragging && dx.abs() < _dragSlop && dy.abs() < _dragSlop) return;
    final useHorizontal =
        !_isDragging ? dx.abs() >= dy.abs() : _dragIsHorizontal;
    if (useHorizontal) {
      if (dx > 0 && !_canGoNext) dx = 0;
      if (dx < 0 && !_canGoPrev) dx = 0;
    }
    setState(() {
      _isDragging = true;
      _dragIsHorizontal = useHorizontal;
      _dragDx = useHorizontal ? dx : 0;
      _dragDy = useHorizontal ? 0 : dy;
    });
  }

  void _onCardPointerUp(PointerUpEvent event) {
    if (event.pointer != _dragPointer) return;
    _dragPointer = null;
    if (_isDismissing || _isBrowsing || !_isDragging) return;
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
    if (_dragIsHorizontal) {
      final flungLeft = vx <= -_swipeVelocityThreshold;
      final flungRight = vx >= _swipeVelocityThreshold;
      final draggedLeft = _dragDx <= -_swipeDistanceThreshold;
      final draggedRight = _dragDx >= _swipeDistanceThreshold;
      final shouldLeft = flungLeft || (draggedLeft && !flungRight);
      final shouldRight = flungRight || (draggedRight && !flungLeft);
      if (_canGoPrev && shouldLeft && !shouldRight) {
        _animateBrowse(-1);
        return;
      }
      if (_canGoNext && shouldRight && !shouldLeft) {
        _animateBrowse(1);
        return;
      }
      setState(_resetDrag);
      return;
    }

    final flungUp = vy <= -_swipeVelocityThreshold;
    final flungDown = vy >= _swipeVelocityThreshold;
    final draggedUp = _dragDy <= -_swipeDistanceThreshold;
    final draggedDown = _dragDy >= _swipeDistanceThreshold;
    final shouldUp = flungUp || (draggedUp && !flungDown);
    final shouldDown = flungDown || (draggedDown && !flungUp);
    if (shouldUp && !shouldDown) {
      setState(() {
        _isDragging = false;
      });
      _editFront(SwipeOutcome.know, _DismissDirection.up);
      return;
    }
    if (shouldDown && !shouldUp) {
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

  int? _neighbor(int delta) {
    final n = _allLiked.length;
    if (n < 2) return null;
    if (_loops) {
      return (_frontIndex + delta + n) % n;
    }
    final index = _frontIndex + delta;
    if (index < 0 || index >= n) return null;
    return index;
  }

  void _animateBrowse(int dir) {
    if (dir > 0 && !_canGoNext) return;
    if (dir < 0 && !_canGoPrev) return;
    setState(() {
      _browseDir = dir;
      _isDragging = false;
      _dragDx = 0;
      _dragDy = 0;
    });
    _browseController.forward(from: 0);
  }

  void _goNext() => _animateBrowse(1);

  void _goPrev() => _animateBrowse(-1);

  void _dropFrontUser() {
    if (_allLiked.isEmpty) return;
    final index = _frontIndex.clamp(0, _allLiked.length - 1);
    _allLiked.removeAt(index);
    final n = _allLiked.length;
    if (n == 0) {
      _frontIndex = 0;
    } else if (index < n) {
      _frontIndex = index;
    } else {
      _frontIndex = n - 1;
    }
    _cardId++;
  }

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

  Future<void> _editFront(
    SwipeOutcome outcome,
    _DismissDirection direction,
  ) async {
    final user = _frontUser;
    if (_isDismissing || _isBrowsing || user == null) return;

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
                padding: EdgeInsets.fromLTRB(
                  0,
                  kDiscoveryChromeInset,
                  0,
                  AppConfig().dimens.medium,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = discoveryCardWidth(
                      maxWidth: constraints.maxWidth,
                    );
                    final actionsEnabled =
                        !_isDismissing && !_isDragging && !_isBrowsing;
                    final cardHeight = discoveryCardHeight(
                      maxHeight: constraints.maxHeight,
                    );
                    final clipWidth = discoveryCarouselClipWidth(
                      cardWidth: cardWidth,
                      maxWidth: constraints.maxWidth,
                    );
                    return Center(
                      child: SizedBox(
                        width: clipWidth,
                        child: ClipRect(
                          key: const ValueKey('liked-carousel-clip'),
                          clipBehavior: Clip.hardEdge,
                          child: OverflowBox(
                            alignment: Alignment.center,
                            maxWidth: double.infinity,
                            child: DiscoveryActionCluster(
                              cardWidth: cardWidth,
                              topAction: DiscoveryOutcomeButton.know(
                                onPressed: actionsEnabled
                                    ? () => _editFront(
                                          SwipeOutcome.know,
                                          _DismissDirection.up,
                                        )
                                    : null,
                                width: cardWidth,
                              ),
                              cardRow: SizedBox(
                                height: cardHeight,
                                child: _buildCarousel(cardWidth, cardHeight),
                              ),
                              bottomAction:
                                  DiscoveryOutcomeButton.notInterested(
                                onPressed: actionsEnabled
                                    ? () => _editFront(
                                          SwipeOutcome.noInterest,
                                          _DismissDirection.down,
                                        )
                                    : null,
                                width: cardWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                  iconSize: kDiscoveryChromeIconSize,
                  color: AppConfig().colors.primaryColor,
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
                child: DiscoveryUndoLikesSwitch(
                  likesOpen: true,
                  canUndo: _canUndo,
                  onUndo: undoLastUnlike,
                  onLikesPressed: () => closeLikedUsersToHome(context),
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
    if (_isDismissing || _isDragging || _isBrowsing || _allLiked.isEmpty) {
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _goPrev();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _goNext();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _editFront(SwipeOutcome.know, _DismissDirection.up);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _editFront(SwipeOutcome.noInterest, _DismissDirection.down);
    }
    return KeyEventResult.handled;
  }

  Widget _browseChevron({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Opacity(
      opacity: onPressed != null ? 1 : 0.4,
      child: IconButton(
        icon: Icon(icon),
        color: AppConfig().colors.primaryColor,
        iconSize: kDiscoveryChromeIconSize,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCarousel(double cardWidth, double cardHeight) {
    return AnimatedBuilder(
      animation: _browseController,
      builder: (context, _) {
        final peekOffset = stackPeekOffset(cardWidth);
        final browseT = _browseController.value;
        final dragT = _isDragging && _dragIsHorizontal && peekOffset > 0
            ? (_dragDx.abs() / peekOffset).clamp(0.0, 1.0)
            : 0.0;
        final dragDir = _dragDx > 0 ? 1 : (_dragDx < 0 ? -1 : 0);
        final t = _browseDir != 0 ? browseT : dragT;
        final dir = _browseDir != 0 ? _browseDir : dragDir;

        final slots = <_CarouselSlot>[];
        void addSlot(int? index, double slot) {
          if (index == null) return;
          slots.add(_CarouselSlot(index: index, slot: slot));
        }

        addSlot(_frontIndex, 0 - dir * t);
        addSlot(_neighbor(-1), -1 - dir * t);
        addSlot(_neighbor(1), 1 - dir * t);
        if (dir != 0) {
          addSlot(_neighbor(dir * 2), dir * 2.0 - dir * t);
        }

        slots.sort((a, b) => b.slot.abs().compareTo(a.slot.abs()));

        final isDismissing = _cardId == _dismissingCardId;
        final verticalDismiss = isDismissing
            ? switch (_dismissDirection) {
                _DismissDirection.up => -cardHeight * 1.4,
                _DismissDirection.down => cardHeight * 1.4,
                _ => 0.0,
              }
            : 0.0;
        final dragOffsetY =
            !_dragIsHorizontal && _dismissingCardId == null ? _dragDy : 0.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: kDiscoveryChevronExtent,
              child: _browseChevron(
                icon: Icons.arrow_back_ios_new,
                onPressed: _canGoPrev ? _goPrev : null,
              ),
            ),
            SizedBox(width: discoveryPeekPad(cardWidth)),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  for (final item in slots)
                    _buildCarouselFace(
                      item: item,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      peekOffset: peekOffset,
                      isDismissing: isDismissing,
                      verticalDismiss: verticalDismiss,
                      dragOffsetY: dragOffsetY,
                    ),
                ],
              ),
            ),
            SizedBox(width: discoveryPeekPad(cardWidth)),
            SizedBox(
              width: kDiscoveryChevronExtent,
              child: _browseChevron(
                icon: Icons.arrow_forward_ios,
                onPressed: _canGoNext ? _goNext : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCarouselFace({
    required _CarouselSlot item,
    required double cardWidth,
    required double cardHeight,
    required double peekOffset,
    required bool isDismissing,
    required double verticalDismiss,
    required double dragOffsetY,
  }) {
    final user = _allLiked[item.index];
    final isCenter = item.slot.abs() < 0.5;
    final scale = 1 - (1 - kStackPeekScale) * item.slot.abs().clamp(0.0, 1.0);
    final dx = item.slot * peekOffset;
    final fade = item.slot.abs() <= 1
        ? 1.0
        : (1 - (item.slot.abs() - 1)).clamp(0.0, 1.0);
    final opacity = isCenter && isDismissing ? 0.0 : fade;
    final color = stackCardColorFor(user.id > 0 ? user.id : item.index);

    final key = isCenter
        ? const ValueKey('liked-center-card')
        : ValueKey(
            'liked-peek-${item.slot > 0 ? 'next' : 'prev'}-${item.index}',
          );

    Widget face = StackCardFace(
      key: key,
      user: user,
      accentColor: color,
      displayName: _displayName(user),
      width: cardWidth,
      height: cardHeight,
    );

    if (isCenter) {
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
    } else {
      final browse = item.slot > 0 ? _goNext : _goPrev;
      final canBrowse = item.slot > 0 ? _canGoNext : _canGoPrev;
      face = GestureDetector(
        onTap: canBrowse ? browse : null,
        child: face,
      );
    }

    final dy = isCenter ? verticalDismiss + dragOffsetY : 0.0;

    final peekCanBrowse = item.slot > 0 ? _canGoNext : _canGoPrev;
    return IgnorePointer(
      ignoring: _isDismissing || (!isCenter && !peekCanBrowse),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.scale(
          scale: scale,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: _isDragging && _dismissingCardId == null
                ? Duration.zero
                : _animationDuration,
            child: face,
          ),
        ),
      ),
    );
  }
}

class _CarouselSlot {
  final int index;
  final double slot;

  const _CarouselSlot({required this.index, required this.slot});
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
