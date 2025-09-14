import 'dart:math';

Map<String, Map<String, int>> squareMatrix(Map<String, Map<String, int>> matrix) {
  final participants = matrix.keys.toList();
  final squaredMatrix = <String, Map<String, int>>{};

  for (final p1 in participants) {
    squaredMatrix[p1] = {};
    for (final p2 in participants) {
      int sum = 0;
      for (final p3 in participants) {
        sum += (matrix[p1]?[p3] ?? 0) * (matrix[p3]?[p2] ?? 0);
      }
      squaredMatrix[p1]![p2] = sum;
    }
  }

  return squaredMatrix;
}

Map<String, Map<String, double>> normalizeMatrix(
    Map<String, Map<String, int>> matrix) {
  final normalizedMatrix = <String, Map<String, double>>{};
  final participants = matrix.keys.toList();

  for (final p1 in participants) {
    normalizedMatrix[p1] = {};
    final rowSum = matrix[p1]!.values.reduce((a, b) => a + b);

    for (final p2 in participants) {
      if (rowSum == 0) {
        normalizedMatrix[p1]![p2] = 0;
      } else {
        normalizedMatrix[p1]![p2] = (matrix[p1]![p2] ?? 0) / rowSum;
      }
    }
  }

  return normalizedMatrix;
}

Map<String, Map<String, double>> _normalizeMatrixByMax(
    Map<String, Map<String, int>> matrix) {
  final normalizedMatrix = <String, Map<String, double>>{};
  final participants = matrix.keys.toList();

  int maxVal = 0;
  for (final p1 in participants) {
    for (final p2 in participants) {
      final val = matrix[p1]?[p2] ?? 0;
      if (val > maxVal) {
        maxVal = val;
      }
    }
  }

  if (maxVal == 0) return {};

  for (final p1 in participants) {
    normalizedMatrix[p1] = {};
    for (final p2 in participants) {
      normalizedMatrix[p1]![p2] = (matrix[p1]?[p2] ?? 0) / maxVal;
    }
  }
  return normalizedMatrix;
}

Map<String, Map<String, double>> calculateCompositeAffinity(
    Map<String, Map<String, int>> A,
    Map<String, Map<String, int>> B,
    double alpha) {
  final participants = A.keys.toList();
  final compositeAffinityMatrix = <String, Map<String, double>>{};

  final normalizedA = _normalizeMatrixByMax(A);
  final normalizedB = _normalizeMatrixByMax(B);

  for (final p1 in participants) {
    compositeAffinityMatrix[p1] = {};
    for (final p2 in participants) {
      final valA = normalizedA[p1]?[p2] ?? 0.0;
      final valB = normalizedB[p1]?[p2] ?? 0.0;
      compositeAffinityMatrix[p1]![p2] = alpha * valA + (1 - alpha) * valB;
    }
  }

  return compositeAffinityMatrix;
}

double _dotProduct(List<int> v1, List<int> v2) {
  double sum = 0;
  for (int i = 0; i < v1.length; i++) {
    sum += v1[i] * v2[i];
  }
  return sum;
}

double _magnitude(List<int> v) {
  double sum = 0;
  for (int i = 0; i < v.length; i++) {
    sum += v[i] * v[i];
  }
  return sqrt(sum);
}

Map<String, Map<String, double>> calculateCosineSimilarityMatrix(
    Map<String, Map<String, int>> matrix, bool byRow) {
  final participants = matrix.keys.toList();
  final similarityMatrix = <String, Map<String, double>>{};

  for (final p1 in participants) {
    similarityMatrix[p1] = {};
    for (final p2 in participants) {
      if (p1 == p2) {
        similarityMatrix[p1]![p2] = 1.0; // Similarity with itself is 1
        continue;
      }

      List<int> vec1;
      List<int> vec2;

      if (byRow) {
        // Emitter similarity (rows)
        vec1 = participants.map((p) => matrix[p1]?[p] ?? 0).toList();
        vec2 = participants.map((p) => matrix[p2]?[p] ?? 0).toList();
      } else {
        // Receiver similarity (columns)
        vec1 = participants.map((p) => matrix[p]?[p1] ?? 0).toList();
        vec2 = participants.map((p) => matrix[p]?[p2] ?? 0).toList();
      }

      final dot = _dotProduct(vec1, vec2);
      final mag1 = _magnitude(vec1);
      final mag2 = _magnitude(vec2);

      if (mag1 == 0 || mag2 == 0) {
        similarityMatrix[p1]![p2] = 0.0; // Avoid division by zero
      } else {
        similarityMatrix[p1]![p2] = dot / (mag1 * mag2);
      }
    }
  }

  return similarityMatrix;
}

double calculateGiniCoefficient(List<int> values) {
  if (values.isEmpty) return 0.0;

  // Sort values in ascending order
  values.sort();

  final n = values.length;
  double sumOfDifferences = 0;
  double sumOfValues = values.reduce((a, b) => a + b).toDouble();

  if (sumOfValues == 0) return 0.0; // Avoid division by zero if all values are zero

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      sumOfDifferences += (values[i] - values[j]).abs();
    }
  }

  return sumOfDifferences / (2 * n * n * sumOfValues);
}
