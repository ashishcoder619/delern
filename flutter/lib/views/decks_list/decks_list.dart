import 'dart:collection';

import 'package:flutter/material.dart';

import '../../flutter/localization.dart';
import '../../view_models/deck_list_view_model.dart';
import '../cards_learning/cards_learning.dart';
import '../cards_list/cards_list.dart';
import '../deck_settings/deck_settings.dart';
import '../deck_sharing/deck_sharing.dart';
import '../helpers/navigation_drawer.dart';
import '../helpers/observing_animated_list.dart';
import '../helpers/search_bar.dart';
import '../helpers/sign_in.dart';
import 'create_deck.dart';

class DecksListPage extends StatefulWidget {
  final String title;

  DecksListPage({@required this.title, Key key})
      : assert(title != null),
        super(key: key);

  @override
  DecksListPageState createState() => DecksListPageState();
}

class DecksListPageState extends State<DecksListPage> {
  DeckListViewModel viewModel;
  bool _active = false;

  @override
  void didChangeDependencies() {
    // TODO(dotdoom): find out deactivate/build/didChangeDependencies flow.
    viewModel ??= DeckListViewModel(CurrentUserWidget.of(context).user.uid)
      ..decks.comparator = (d1, d2) => d1.key.compareTo(d2.key);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    viewModel.deactivate();
    _active = false;
    super.deactivate();
  }

  void setFilter(String input) {
    if (input == null) {
      viewModel.decks.filter = null;
      return;
    }
    input = input.toLowerCase();
    viewModel.decks.filter = (d) =>
        // Case insensitive filter
        d.deck.name.toLowerCase().contains(input);
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) {
      viewModel.activate();
      _active = true;
    }

    return Scaffold(
      appBar: SearchBarWidget(title: widget.title, search: setFilter),
      drawer: NavigationDrawer(),
      body: ObservingAnimatedList(
        list: viewModel.decks,
        itemBuilder: (context, item, animation, index) => SizeTransition(
              child: DeckListItem(item),
              sizeFactor: animation,
            ),
        emptyListUserMessage: AppLocalizations.of(context).emptyDecksList,
      ),
      floatingActionButton: CreateDeck(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }
}

class DeckListItem extends StatelessWidget {
  final DeckListItemViewModel viewModel;

  DeckListItem(this.viewModel);

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: _buildDeckName(context),
                ),
                _buildNumberOfCards(),
                _buildDeckMenu(context),
              ],
            ),
          ),
          Divider(height: 1.0),
        ],
      );

  Widget _buildDeckName(BuildContext context) => Material(
        child: InkWell(
          splashColor: Theme.of(context).splashColor,
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CardsLearning(viewModel.deck)),
              ),
          child: Container(
            padding:
                EdgeInsets.only(top: 14.0, bottom: 14.0, left: 8.0, right: 8.0),
            child: Text(
              viewModel.deck.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );

  Widget _buildNumberOfCards() => Container(
        child: Text(viewModel.cardsToLearn?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 18.0,
            )),
      );

  Widget _buildDeckMenu(BuildContext context) => Material(
        child: InkResponse(
          splashColor: Theme.of(context).splashColor,
          radius: 15.0,
          onTap: () {},
          child: PopupMenuButton<_DeckMenuItemType>(
            onSelected: (itemType) =>
                _onDeckMenuItemSelected(context, itemType),
            itemBuilder: (BuildContext context) => _buildMenu(context)
                .entries
                .map((entry) => PopupMenuItem<_DeckMenuItemType>(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
          ),
        ),
      );

  void _onDeckMenuItemSelected(BuildContext context, _DeckMenuItemType item) {
    switch (item) {
      case _DeckMenuItemType.edit:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CardsListPage(viewModel.deck)),
        );
        break;
      case _DeckMenuItemType.setting:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DeckSettingsPage(viewModel.deck, viewModel.access)),
        );
        break;
      case _DeckMenuItemType.share:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeckSharingPage(viewModel.deck)),
        );
        break;
    }
  }
}

enum _DeckMenuItemType { edit, setting, share }

Map<_DeckMenuItemType, String> _buildMenu(BuildContext context) =>
    LinkedHashMap<_DeckMenuItemType, String>()
      ..[_DeckMenuItemType.edit] =
          AppLocalizations.of(context).editCardsDeckMenu
      ..[_DeckMenuItemType.setting] =
          AppLocalizations.of(context).settingsDeckMenu
      ..[_DeckMenuItemType.share] = AppLocalizations.of(context).shareDeckMenu;
