# Chess Stats PWA

Application web (PWA) Flutter qui affiche les statistiques d'un joueur chess.com sur une **période glissante** (« 1 mois » = 30 derniers jours, « 3 mois » = 90 derniers jours) : par couleur, par ouverture, par pays des adversaires, et gestion du temps sur les défaites (dont les défaites au temps). Un bilan du mois en diapositives s'affiche à la première recherche de chaque joueur. « Comment battre ce joueur » (bouton de l'accueil, menu « Plus » des stats) donne en diapositives ses points faibles et des conseils (`services/scouting_service.dart`, `screens/scouting_screen.dart`).

La page des stats a des filtres communs à toutes les cartes : période, parties classées ou toutes, cadence, couleur, ouverture (`viewmodels/stats_filter_viewmodel.dart`, base des cartes `viewmodels/filtered_stats_viewmodel.dart`). Ils sont dans `widgets/stats_filter_panel.dart` : panneau fixe à gauche sur grand écran ; sur mobile / tablette, menu glissant (bouton en haut à gauche, avec aussi une section « Plus » : bilan, actualiser, thème) et résumé des filtres sous la barre du haut. Ils ne sont pas mémorisés : remis à 1 mois / parties classées / toutes cadences / les deux couleurs / toutes ouvertures pour chaque joueur consulté.
L'interface est en **français** ou en **anglais**, selon la langue du navigateur.

## Commandes

```
flutter analyze
flutter test
flutter gen-l10n
```

Si Flutter n'est pas dans le PATH du poste, utiliser son chemin complet (précisé dans le `CLAUDE.local.md` du poste s'il existe).

- Lancer l'app : configuration `flutter-web` de `.claude/launch.json` (http://localhost:8080), via `preview_start`, pas via Bash. Le chemin de Flutter y est celui du poste d'Etienne : sur un autre poste, l'adapter localement sans commiter ce changement.
- Le serveur ne recompile pas sur un simple rechargement du navigateur : après une modification, l'arrêter puis le relancer.
- Compte de test pratique : `hikaru` (beaucoup de parties). Pour vérifier des chiffres, comparer avec l'API publique `https://api.chess.com/pub/player/<pseudo>/games/<AAAA>/<MM>`.

## État connu de `flutter analyze`

Aucun problème (« No issues found! »). Une modification ne doit **pas en ajouter**.

## Architecture

Point d'entrée : `lib/main.dart` → `screens/home_screen.dart` (recherche) → `screens/stats_screen.dart` → `widgets/stats_display.dart` (page principale des stats).

Adresses : `/` = accueil, `/<pseudo>` = stats du joueur, `/<pseudo>/recap` = son bilan, `/<pseudo>/scout` = « Comment battre ce joueur » dans sa cadence la plus jouée, `/<pseudo>/scout/<bullet|blitz|rapid>` = dans cette cadence (choix et raccourci vers sa cadence la plus faible sur la 1re diapo) (liens à partager : bouton de partage dans les stats et en fin de chaque diaporama ; diaporama ouvert par lien = au-dessus des stats). Le bilan ne s'ouvre tout seul qu'après une recherche (première recherche du joueur sur l'appareil), jamais à l'ouverture d'un lien. Routes dans `main.dart` et `screens/player_route.dart`, analyse de l'adresse dans `services/player_link_service.dart`. Netlify renvoie toute adresse inconnue vers `index.html` (`netlify.toml`).

| Dossier | Rôle |
|---|---|
| `models/` | Données (`ChessStats`, `CountryGame` = une partie avec pays, cadence, résultat, cause de défaite…) |
| `services/` | Appels à l'API chess.com, cache, calculs/agrégations (`country_stats_service`, `time_management_service`, `recap_service`) |
| `viewmodels/` | État d'écran (filtres de cadence, tri) en `ChangeNotifier` |
| `screens/`, `widgets/` | Affichage uniquement, aucune logique métier |
| `theme/` | Thèmes clair et sombre (`AppTheme`) et couleurs de texte adaptées au thème |

- État géré avec `provider` (`ChangeNotifierProvider` + `Consumer`).
- Graphiques avec `fl_chart`.
- Thème : clair ou sombre selon le système, ou selon le choix fait avec le bouton soleil / lune de la barre du haut (mémorisé, `services/theme_preference_service.dart`). Toute nouvelle carte doit rester lisible dans les deux thèmes : couleurs du `ColorScheme`, ou `AppTheme.positiveText` / `negativeText` / `warningText` pour les textes colorés, pas de teinte foncée en dur.
- Parties : stockage local IndexedDB (`sembast` / `sembast_web`) par (joueur, mois), via `services/game_repository.dart` (point d'accès unique « parties du joueur X pour le mois M », source `MonthlyGamesSource` = API chess.com). Seuls les mois manquants ou pas encore clos sont téléchargés ; règles (mois clos, purge, conservation) dans `services/game_storage_policy.dart`, purge au lancement. **Si la forme des données stockées change, incrémenter `GameStore.schemaVersion`** (les anciennes données sont alors effacées).
- Résultats chess.com : `win`, `checkmated`, `resigned`, `timeout`, `abandoned`, nulles diverses… `checkmated` est une défaite ; `resigned` et `abandoned` sont regroupés en « Par abandon ».

## Localisation

Un seul système : fichiers **`.arb`** (`lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`) et classe générée `AppLocalizations` (`AppLocalizations.of(context)!`).
- La langue suit celle du navigateur ; une langue non prise en charge retombe sur l'anglais (première de `preferred-supported-locales` dans `l10n.yaml`). `main.dart` n'impose aucune `locale`.
- Après une modification des `.arb`, régénérer : `flutter gen-l10n` (les fichiers générés sont versionnés).
- Ajouter une langue : créer `lib/l10n/app_<code>.arb` avec toutes les clés de `app_en.arb`, puis régénérer.

Règles :
- Aucun texte visible en dur dans le code.
- Toute nouvelle clé va dans `app_en.arb` **et** dans `app_fr.arb` (et dans chaque autre langue ajoutée).

## Tests

Dans `test/`. Mettre la logique testable (agrégations, tri, filtres) dans `services/` ou `viewmodels/` et la couvrir par un test.

## Design

- Sources du logo et des icônes dans `design/` (SVG), PNG régénérés par `tool/generate_icons.ps1` (PowerShell).
- Toute modification visuelle doit rester lisible en thème clair **et** sombre, sur mobile comme sur grand écran (voir « Thème » plus haut).
- Couleurs et styles centralisés dans `theme/` (`AppTheme`) : y ajouter une couleur plutôt que la mettre en dur dans un widget.

## Travail à plusieurs (Git / GitHub)

Le projet est sur GitHub (`e-maubert/chess_stats_pwa`) et partagé entre plusieurs personnes, chacune avec son Claude.

- **Au début de chaque tâche** : `git fetch --prune`, puis regarder les branches distantes et les Pull Requests ouvertes (`gh pr list`) pour savoir ce qui est en cours et éviter de toucher aux mêmes fichiers.
- Jamais de commit direct sur `main` (= prod). Une branche par changement, partie d'un `origin/main` à jour : `fix/…` bug, `feat/…` évolution, `chore/…` maintenance, `design/…` visuel.
- **Ne jamais modifier, rebaser ni supprimer la branche de quelqu'un d'autre.**
- Fin d'un changement : pousser la branche et ouvrir une **Pull Request** vers `main` (seulement quand l'utilisateur le demande). Le merge se fait sur GitHub, par une personne, jamais par Claude.
- Avant d'ouvrir une PR : `flutter analyze` (aucun nouveau problème) et `flutter test` passent ; décrire dans la PR ce qui change pour l'utilisateur, avec une capture si c'est visible.
- **Numéro de version** (`pubspec.yaml`), **nouveautés** (`changelogV<version>` dans les `.arb`) et `GameStore.schemaVersion` : ne les changer que si la PR le nécessite vraiment, et vérifier juste avant le merge qu'une autre PR ne les a pas déjà incrémentés.
- Nouveautés d'une version : 3 à 5 puces courtes et un peu vagues, centrées sur ce que l'utilisateur voit, sans détail technique. En FR et en EN.

## Mise en ligne (Netlify)

Site de test : https://chess-stats-test.netlify.app. Netlify n'a pas Flutter : on compile en local et on envoie le dossier `build/web` (config : `netlify.toml`).

**Seul Etienne déploie**, depuis `main`, en regroupant plusieurs fonctionnalités (crédits Netlify limités). Ne jamais déployer ni proposer de déployer après chaque changement : vérifier en local avec `preview_start`.
