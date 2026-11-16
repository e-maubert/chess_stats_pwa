import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_repository.dart';
import '../services/game_store.dart';
import '../viewmodels/recent_players_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/layout_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_logo.dart';
import '../widgets/recent_players_options.dart';
import '../widgets/theme_toggle_button.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  late final RecentPlayersViewModel _recentPlayers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recentPlayers = RecentPlayersViewModel(context.read<GameRepository>())..load();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _recentPlayers.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Parties déjà stockées : affichées tout de suite, mises à jour
      // ensuite par l'écran des stats. Sinon, premier téléchargement ici.
      final repository = context.read<GameRepository>();
      final stored = await repository.storedGames(username);
      final games = stored ?? await repository.updateGames(username);
      if (!mounted) return;

      _usernameFocusNode.unfocus();
      // Au retour, le joueur consulté apparaît en tête des joueurs proposés.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StatsScreen(
            username: username,
            initialGames: games,
            upToDate: stored == null,
          ),
        ),
      ).then((_) => _recentPlayers.load());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorFetchingStats),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [ThemeToggleButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  // Sur ordinateur, champ et bouton gardent une largeur
                  // raisonnable au lieu de s'étirer sur tout l'écran.
                  constraints: const BoxConstraints(maxWidth: LayoutService.maxSearchWidth),
                  child: _buildSearchForm(context, l10n),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 120),
        const SizedBox(height: 24),
        Text(
          l10n.enterUsername,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Un clic dans le champ propose les joueurs déjà consultés, filtrés
        // pendant la saisie.
        RawAutocomplete<StoredPlayer>(
          textEditingController: _usernameController,
          focusNode: _usernameFocusNode,
          displayStringForOption: (player) => player.username,
          optionsBuilder: (value) => _recentPlayers.matching(value.text),
          onSelected: (player) => _searchUser(),
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) => TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: l10n.enterUsername,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _searchUser(),
          ),
          optionsViewBuilder: (context, onSelected, options) => RecentPlayersOptions(
            viewModel: _recentPlayers,
            controller: _usernameController,
            onSelected: onSelected,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _searchUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.search),
        ),
      ],
    );
  }
}
