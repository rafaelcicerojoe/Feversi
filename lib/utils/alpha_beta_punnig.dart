import 'dart:math';

class AlphaBetaPunning {
  final int maxAlpha = 1000;
  final int minAlpha = -1000;

  int search(int depth, int nodeIndex, bool maximizingPlayer, List<int> values,
      int alpha, int beta) {
    if (depth == 3) return values[nodeIndex];

    if (maximizingPlayer) {
      int best = minAlpha;

      for (int i = 0; i < 2; i++) {
        int val =
            search(depth + 1, nodeIndex * 2 + i, false, values, alpha, beta);
        best = max(best, val);
        alpha = max(alpha, best);

        if (beta <= alpha) break;
      }
      return best;
    } else {
      int best = maxAlpha;

      for (int i = 0; i < 2; i++) {
        int val =
            search(depth + 1, nodeIndex * 2 + i, true, values, alpha, beta);
        best = min(best, val);
        beta = min(beta, best);

        if (beta <= alpha) break;
      }
      return best;
    }
  }

  void debug() {
    List<int> values = [3, 5, 6, 9, 1, 2, 0, -1];
    final solution = search(0, 0, true, values, minAlpha, maxAlpha);
    print("The optimal value is : $solution");
  }
}
