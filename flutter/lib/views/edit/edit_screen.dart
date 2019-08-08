import 'dart:math';

import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/flutter/user_messages.dart';
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/models/deck_access_model.dart';
import 'package:delern_flutter/models/deck_model.dart';
import 'package:delern_flutter/view_models/edit_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/card_create_update/card_create_update.dart';
import 'package:delern_flutter/views/card_preview/card_preview.dart';
import 'package:delern_flutter/views/decks_list/decks_list.dart';
import 'package:delern_flutter/views/edit/deck_settings_widget.dart';
import 'package:delern_flutter/views/edit/scroll_to_beginning_list_widget.dart';
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/empty_list_message_widget.dart';
import 'package:delern_flutter/views/helpers/observing_animated_list_widget.dart';
import 'package:delern_flutter/views/helpers/search_bar_widget.dart';
import 'package:flutter/material.dart';

const int _kUpButtonVisibleRow = 20;
const double _kDividerPadding = 24;

class EditScreen extends StatefulWidget {
  final DeckModel deck;

  const EditScreen({@required this.deck}) : assert(deck != null);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TextEditingController _deckNameController = TextEditingController();
  EditBloc _bloc;
  DeckModel _currentDeckState;
  GlobalKey fabKey = GlobalKey();

  void _searchTextChanged(String input) {
    if (input == null) {
      _bloc.filter = null;
      return;
    }
    input = input.toLowerCase();
    _bloc.filter = (c) =>
        c.front.toLowerCase().contains(input) ||
        c.back.toLowerCase().contains(input);
  }

  @override
  void initState() {
    _bloc = EditBloc(deck: widget.deck);
    _deckNameController.text = widget.deck.name;
    _currentDeckState = widget.deck;
    _bloc.doDeckChanged.listen((deck) {
      _currentDeckState = deck;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView(
        appBar: SearchBarWidget(
          title: localizations.of(context).edit,
          search: _searchTextChanged,
          actions: _buildActions(),
        ),
        body: Column(
          children: <Widget>[
            _buildEditDeck(),
            _buildCardsInDeck(),
            const Divider(
              height: _kDividerPadding,
            ),
            Expanded(child: _buildCardList()),
          ],
        ),
        floatingActionButton: _buildAddCard(),
        bloc: _bloc,
      );

  List<Widget> _buildActions() {
    final menuAction = IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => Dialog(
              child: DeckSettingsWidget(deck: _currentDeckState, bloc: _bloc)),
        );
      },
    );

    return <Widget>[menuAction];
  }

  Widget _buildEditDeck() => TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.edit),
          // We'd like to center text. Because of suffixIcon, the text
          // is placed a little bit to the left. To fix this problem, we
          // add an empty Container with size of Icon to the left.
          prefixIcon: Container(
            height: IconTheme.of(context).size,
            width: IconTheme.of(context).size,
          ),
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: _deckNameController,
        style: app_styles.primaryText,
        onChanged: (text) {
          setState(() {
            _bloc.onDeckName.add(text);
          });
        },
      );

  Widget _buildCardsInDeck() => FutureBuilder<Object>(
      future: _bloc.list.initializationComplete,
      builder: (context, snapshot) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                localizations
                    .of(context)
                    .numberOfCards(_bloc.list.isEmpty ? 0 : _bloc.list.length),
                style: app_styles.secondaryText,
              ),
            ],
          ));

  Widget _buildCardList() {
    final cardVerticalPadding =
        MediaQuery.of(context).size.height * app_styles.kItemListPaddingRatio;
    return ScrollToBeginningListWidget(
      builder: (controller) => ObservingAnimatedListWidget<CardModel>(
        list: _bloc.list,
        itemBuilder: (context, item, animation, index) =>
            _buildCardItem(item, cardVerticalPadding),
        emptyMessageBuilder: () => ArrowToFloatingActionButtonWidget(
            fabKey: fabKey,
            child: EmptyListMessageWidget(
                localizations.of(context).emptyCardsList)),
        controller: controller,
      ),
      minItemHeight: app_styles.kMinItemHeight + 2 * cardVerticalPadding,
      upButtonVisibleRow: _kUpButtonVisibleRow,
    );
  }

  Column _buildCardItem(CardModel item, double verticalPadding) => Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: CardItemWidget(
              card: item,
              deck: widget.deck,
            ),
          ),
        ],
      );

  Builder _buildAddCard() => Builder(
        builder: (context) => FloatingActionButton(
          key: fabKey,
          onPressed: () {
            if (widget.deck.access != AccessType.read) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: '/cards/new'),
                      builder: (context) => CardCreateUpdate(
                            card: CardModel(deckKey: widget.deck.key),
                            deck: widget.deck,
                          )));
            } else {
              UserMessages.showMessage(Scaffold.of(context),
                  localizations.of(context).noAddingWithReadAccessUserMessage);
            }
          },
          child: const Icon(Icons.add),
        ),
      );

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

const double _kCardBorderPadding = 16;
const double _kFrontBackTextPadding = 5;

class CardItemWidget extends StatelessWidget {
  final CardModel card;
  final DeckModel deck;

  const CardItemWidget({@required this.card, @required this.deck})
      : assert(card != null),
        assert(deck != null);

  @override
  Widget build(BuildContext context) {
    final emptyExpanded = Expanded(
      flex: 1,
      child: Container(
        color: Colors.transparent,
      ),
    );

    final minHeight = max(
        MediaQuery.of(context).size.height * app_styles.kItemListHeightRatio,
        app_styles.kMinItemHeight);
    final primaryFontSize =
        max(minHeight * 0.25, app_styles.kMinPrimaryTextSize);
    final primaryTextStyle =
        app_styles.primaryText.copyWith(fontSize: primaryFontSize);
    final secondaryTextStyle = app_styles.secondaryText.copyWith(
        fontSize: primaryFontSize / 1.5,
        color: app_styles.kSecondaryTextDeckItemColor);
    return Row(
      children: <Widget>[
        emptyExpanded,
        Expanded(
          flex: 8,
          child: Material(
            elevation: app_styles.kItemElevation,
            color: specifyCardBackground(deck.type, card.back),
            child: InkWell(
              splashColor: Theme.of(context).splashColor,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: '/cards/preview'),
                      builder: (context) => CardPreview(
                            card: card,
                            deck: deck,
                          ))),
              child: Padding(
                padding: const EdgeInsets.all(_kCardBorderPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      card.front,
                      maxLines: 1,
                      softWrap: true,
                      style: primaryTextStyle,
                    ),
                    Container(
                      padding:
                          const EdgeInsets.only(top: _kFrontBackTextPadding),
                      child: Text(
                        card.back ?? '',
                        maxLines: 1,
                        softWrap: true,
                        style: secondaryTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        emptyExpanded,
      ],
    );
  }
}
