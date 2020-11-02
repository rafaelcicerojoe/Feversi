import 'dart:math';

class MinMax {
  int search(int depth, int nodeIndex, bool isMax, List<int> scores, int h) {
    if (depth == h) return scores[nodeIndex];

    if (isMax)
      return max(search(depth + 1, nodeIndex * 2, false, scores, h),
          search(depth + 1, nodeIndex * 2 + 1, false, scores, h));
    else
      return min(search(depth + 1, nodeIndex * 2, true, scores, h),
          search(depth + 1, nodeIndex * 2 + 1, true, scores, h));
  }

  int log2(double n) {
    return (n == 1) ? 0 : 1 + log2(n / 2);
  }

  void debug() {
    List<int> scores = [3, 5, 2, 9, 12, 5, 23, 23];
    int n = scores.length;
    int h = log2(n / 1.0);
    int res = search(0, 0, true, scores, h);
    print("The optimal value is : $res");
  }
}
