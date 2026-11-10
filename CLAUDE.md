# Chess Stats PWA

Application web (PWA) Flutter qui affiche les statistiques d'un joueur chess.com pour le **mois en cours** : par couleur, par ouverture, par pays des adversaires, et répartition des défaites par cause.
Pour l'instant, l'interface est uniquement en **français**.

## Commandes

Flutter n'est pas dans le PATH : utiliser le chemin complet.

```
C:\src\flutter\bin\flutter.bat analyze
C:\src\flutter\bin\flutter.bat test
```

- Lancer l'app : configuration `flutter-web` de `.claude/launch.json` (http://localhost:8080), via `preview_start`, pas via Bash.
- Le serveur ne recompile pas sur un simple rechargement du navigateur : après une modification, l'arrêter puis le relancer.
- Compte de test pratique : `hikaru` (beaucoup de parties). Pour vérifier des chiffres, comparer avec l'API publique `https://api.chess.com/pub/player/<pseudo>/games/<AAAA>/<MM>`.

## État connu de `flutter analyze`

Il reste 2 erreurs préexistantes, dans du **code mort** que `main.dart` n'atteint pas :
- `lib/l10n/translations_delegate.dart` (importé nulle part) ;
- `lib/views/stats_page.dart` et `lib/views/search_page.dart` (`topOpenings` inexistant ; rien n'importe `search_page.dart`).

Ne pas les compter comme des régressions. Une modification ne doit **pas en ajouter** d'autres.

## Architecture

Point d'entrée : `lib/main.dart` → `screens/home_screen.dart` (recherche) → `screens/stats_screen.dart` → `widgets/stats_display.dart` (page principale des stats).

| Dossier | Rôle |
|---|---|
| `models/` | Données (`ChessStats`, `CountryGame` = une partie avec pays, cadence, résultat, cause de défaite…) |
| `services/` | Appels à l'API chess.com, cache, calculs/agrégations (`country_stats_service`, `loss_stats_service`) |
| `viewmodels/` | État d'écran (filtres de cadence, tri) en `ChangeNotifier` |
| `screens/`, `views/`, `widgets/` | Affichage uniquement, aucune logique métier |

- État géré avec `provider` (`ChangeNotifierProvider` + `Consumer`).
- Graphiques avec `fl_chart`.
- Cache : `services/cache_service.dart`, `SharedPreferences`, durée 1 h, clé préfixée `chess_stats_v6_`. **Si la forme des données en cache change, incrémenter la version de la clé**, sinon d'anciennes entrées incomplètes seront relues.
- Résultats chess.com : `win`, `checkmated`, `resigned`, `timeout`, `abandoned`, nulles diverses… `checkmated` est une défaite ; `resigned` et `abandoned` sont regroupés en « Par abandon ».

## Localisation

Deux systèmes coexistent :
- **`lib/l10n/translations.dart`** (classe `Translations`, locale fixée à `fr`) : utilisé par les écrans historiques.
- **Fichiers `.arb`** (`lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, classe générée `AppLocalizations`) : utilisés par les fonctionnalités récentes. Leur locale est forcée sur celle de `Translations` dans `main.dart`, pour que toute l'app reste dans la même langue quel que soit le navigateur.

Règles :
- Aucun texte visible en dur dans le code.
- Toute nouvelle clé va dans `app_en.arb` **et** dans `app_fr.arb`.

## Tests

Dans `test/`. Mettre la logique testable (agrégations, tri, filtres) dans `services/` ou `viewmodels/` et la couvrir par un test.

## Workflow des agents (Trello)

Tableau « Retours client – Chess Stats » : https://trello.com/b/xJvUOeeJ/retours-client-chess-stats
Colonnes : **À faire → En cours → En relecture → Livré**.

| Agent | Rôle |
|---|---|
| `reception-client` | Mails client → cartes dans « À faire » (besoin, priorité, points ambigus, checklist « Critères d'acceptation »), brouillon de réponse. Ne touche pas au code. |
| `developpeur-trello` | Développe les cartes de « À faire » et celles renvoyées dans « En cours », puis les passe dans « En relecture ». Pose ses questions en commentaire si la demande est ambiguë. |
| `relecteur-code` | Relit les cartes de « En relecture », coche les critères vérifiés, puis « Livré » ou renvoi dans « En cours ». Ne modifie jamais le code. |

Les instructions détaillées sont dans `.claude/agents/`. Les décisions du client se trouvent dans les commentaires des cartes : les lire avant de développer.

Git : jamais de commit direct sur `main` (= prod). Une branche par carte ou par changement (`fix/…` bug, `feat/…` évolution, `chore/…` maintenance), fusionnée dans `main` uniquement à la demande de l'utilisateur. Aucun `git push` sans demande.

Étiquettes : rouge = bug, bleue = évolution (l'outil Trello ne peut ni créer ni renommer d'étiquette).
