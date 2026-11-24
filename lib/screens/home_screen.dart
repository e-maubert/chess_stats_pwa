import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_repository.dart';
import '../services/game_store.dart';
import '../services/player_open_service.dart';
import '../viewmodels/recent_players_viewmodel.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import '../services/layout_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_logo.dart';
import '../widgets/recent_players_options.dart';
import '../widgets/theme_toggle_button.dart';
import 'player_route.dart';

class HomeScreen extends StatefulWidget {
  /// Pseudo pré-rempli (lien vers un joueur introuvable).
  final String? initialUsername;

  /// Afficher tout de suite le message « joueur introuvable ».
  final bool initialError;

  const HomeScreen({Key? key, this.initialUsername, this.initialError = false}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _usernameController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  late final RecentPlayersViewModel _recentPlayers;

  /// Bouton en cours de chargement (null = aucun).
  _HomeAction? _loading;

  @override
  void initState() {
    super.initState();
    _recentPlayers = RecentPlayersViewModel(context.read<GameRepository>())..load();
    if (widget.initialUsername != null) _usernameController.text = widget.initialUsername!;
    if (widget.initialError) WidgetsBinding.instance.addPostFrameCallback((_) => _showError());
  }

  void _showError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.errorFetchingStats),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _recentPlayers.dispose();
    super.dispose();
  }

  Future<void> _searchUser() => _open(_HomeAction.stats);

  Future<void> _open(_HomeAction action) async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || _loading != null) return;

    setState(() => _loading = action);

    try {
      final service = PlayerOpenService(context.read<GameRepository>());
      final Route<void> route;
      if (action == _HomeAction.stats) {
        // Parties déjà stockées : affichées tout de suite, mises à jour
        // ensuite par l'écran suivant. Sinon, premier téléchargement ici.
        // Bilan du mois seulement à la première recherche du joueur.
        route = playerRoute(await service.open(username));
      } else {
        final loaded = await service.loadGames(username);
        route = scoutRoute(username, loaded.games, upToDate: loaded.upToDate);
      }
      if (!mounted) return;

      _usernameFocusNode.unfocus();
      // Au retour, le joueur consulté apparaît en tête des joueurs proposés.
      Navigator.push(context, route).then((_) => _recentPlayers.load());
    } catch (e) {
      _showError();
    } finally {
      if (mounted) {
        setState(() => _loading = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Le nom de l'appli est affiché sous le logo, pas dans la barre.
      appBar: AppBar(
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
        const SizedBox(height: 16),
        // Nom de l'appli sous le logo, puis la consigne en sous-titre.
        Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.enterUsername,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
              hintText: l10n.searchHint,
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
          onPressed: _loading != null ? null : _searchUser,
          child: _loading == _HomeAction.stats ? const _ButtonSpinner() : Text(l10n.showStats),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _loading != null ? null : () => _open(_HomeAction.scout),
          icon: _loading == _HomeAction.scout ? const _ButtonSpinner() : const Icon(Icons.emoji_objects_outlined),
          label: Text(l10n.scoutButton),
        ),
      ],
    );
  }
}

/// Boutons de l'accueil : stats du joueur, ou « Comment battre ce joueur ».
enum _HomeAction { stats, scout }

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
}
