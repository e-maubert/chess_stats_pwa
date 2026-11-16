# Chess Stats PWA

Application web (PWA) Flutter qui affiche les statistiques d'un joueur chess.com sur une **période glissante** (« 1 mois » = 30 derniers jours, « 3 mois » = 90 derniers jours, sélecteur dans l'en-tête de la page des stats, choix mémorisé) : par couleur, par ouverture, par pays des adversaires, et répartition des défaites par cause.
L'interface est en **français** ou en **anglais**, selon la langue du navigateur.

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

Aucun problème (« No issues found! »). Une modification ne doit **pas en ajouter**.

## Architecture

Point d'entrée : `lib/main.dart` → `screens/home_screen.dart` (recherche) → `screens/stats_screen.dart` → `widgets/stats_display.dart` (page principale des stats).

| Dossier | Rôle |
|---|---|
| `models/` | Données (`ChessStats`, `CountryGame` = une partie avec pays, cadence, résultat, cause de défaite…) |
| `services/` | Appels à l'API chess.com, cache, calculs/agrégations (`country_stats_service`, `loss_stats_service`) |
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
- Après une modification des `.arb`, régénérer : `C:\src\flutter\bin\flutter.bat gen-l10n` (les fichiers générés sont versionnés).
- Ajouter une langue : créer `lib/l10n/app_<code>.arb` avec toutes les clés de `app_en.arb`, puis régénérer.

Règles :
- Aucun texte visible en dur dans le code.
- Toute nouvelle clé va dans `app_en.arb` **et** dans `app_fr.arb` (et dans chaque autre langue ajoutée).

## Tests

Dans `test/`. Mettre la logique testable (agrégations, tri, filtres) dans `services/` ou `viewmodels/` et la couvrir par un test.

## Mise en ligne (version de test, Netlify)

Netlify n'a pas Flutter : on compile en local et on envoie le dossier `build/web` (config : `netlify.toml`).
Uniquement à la demande de l'utilisateur, depuis `main`.

Site : https://chess-stats-test.netlify.app (le dossier y est relié par `.netlify/state.json`, non versionné).

```
rm -rf build/web
C:\src\flutter\bin\flutter.bat build web --release
export PATH="/c/Users/etien/AppData/Roaming/nvm/v22.23.4:$PATH"   # Bash
npx --yes netlify-cli@27.17.0 deploy --prod --dir build/web
```

- Toujours supprimer `build/web` avant de compiler : un build incrémental peut oublier des fichiers de `web/` (ex. `manifest.json`).
- `netlify-cli` exige Node ≥ 22.13. Le Node par défaut du poste est le 16 (à ne pas changer avec `nvm use`) : préfixer le `PATH` par le Node 22 installé via nvm, seulement pour la commande.
- Si l'outil n'est plus connecté : `npx netlify-cli login` (connexion dans le navigateur, faite par l'utilisateur). Équipe Netlify : slug `etienne-maubert`.
- Logo et icônes : sources dans `design/`, PNG régénérés par `tool/generate_icons.ps1`.

## Modes de travail

Deux modes. **Par défaut : mode perso.** Le mode démo / agence ne s'applique que si l'utilisateur le demande (« mode démo », « mode agence », ou en demandant de passer par les agents ou par Trello).

### Mode perso (par défaut)

Le but est de consommer peu de tokens.
- Développer directement dans la conversation, où le contexte est déjà chargé. Pas d'agent `developpeur-trello` ni `relecteur-code`.
- Pas de suivi Trello obligatoire. Si une carte existe pour le changement, y laisser un seul commentaire court à la fin (branche, ce qui a été fait) et la déplacer.
- Vérifier une seule fois : `flutter analyze` + `flutter test`, et l'app dans le navigateur seulement si le changement est visible et pas couvert par un test. Limiter les captures d'écran.
- Relecture uniquement sur un changement délicat (stockage, calculs de stats) : `/code-review` sur la branche, pas d'agent relecteur.

### Mode démo / agence (agents + Trello)

Pour montrer les agents, ou quand des humains suivent le projet. Les rôles sont décrits plus bas.
- Une seule vérification complète par étape : le relecteur ne relance le navigateur que pour les critères visuels non couverts par un test, et la session principale ne refait pas les vérifications des agents (elle contrôle seulement que les branches existent et que `analyze` / `test` passent).
- Modèles : `developpeur-trello` hérite du modèle de la session ; `reception-client` et `relecteur-code` tournent sur Sonnet (champ `model` de `.claude/agents/`).

## Workflow des agents (Trello, mode démo / agence)

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
