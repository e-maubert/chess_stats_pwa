/// Répartition des défaites du joueur selon leur cause.
class LossStats {
  final int timeout;
  final int checkmated;

  /// Abandon volontaire et abandon de partie / déconnexion, fusionnés
  /// à la demande du client.
  final int resigned;

  /// Défaites dont la cause n'est ni le temps, ni le mat, ni l'abandon
  /// (ex. résultat générique « lose » des variantes chess.com).
  final int other;

  const LossStats({
    this.timeout = 0,
    this.checkmated = 0,
    this.resigned = 0,
    this.other = 0,
  });

  int get total => timeout + checkmated + resigned + other;

  double _rate(int count) => total > 0 ? count / total : 0;
  double get timeoutRate => _rate(timeout);
  double get checkmatedRate => _rate(checkmated);
  double get resignedRate => _rate(resigned);
  double get otherRate => _rate(other);
}
