import 'dart:collection';
import 'dart:math';

Map<String, double> calculateBetweennessCentrality(
  Map<String, Map<String, int>> replies,
) {
  final nodes = replies.keys.toList();
  final centrality = {for (var n in nodes) n: 0.0};

  // Convertir a grafo sin direcciones estrictas (opcional, depende de tu caso)
  Map<String, Set<String>> graph = {};
  for (var from in replies.keys) {
    graph[from] ??= {};
    for (var to in replies[from]!.keys) {
      if (replies[from]![to]! > 0) {
        graph[from]!.add(to);
        graph[to] ??= {};
        graph[to]!.add(from);
      }
    }
  }

  // Para cada par de nodos, buscamos caminos más cortos
  for (int i = 0; i < nodes.length; i++) {
    for (int j = i + 1; j < nodes.length; j++) {
      final s = nodes[i];
      final t = nodes[j];

      // BFS para encontrar distancias mínimas y padres
      final distances = {for (var n in nodes) n: double.infinity};
      final parents = {for (var n in nodes) n: <String>[]};
      distances[s] = 0;

      Queue<String> q = Queue()..add(s);
      while (q.isNotEmpty) {
        final current = q.removeFirst();
        for (var neighbor in graph[current] ?? {}) {
          if (distances[neighbor]! == double.infinity) {
            distances[neighbor] = distances[current]! + 1;
            q.add(neighbor);
          }
          if (distances[neighbor] == distances[current]! + 1) {
            parents[neighbor]!.add(current);
          }
        }
      }

      // Contar caminos más cortos usando programación dinámica
      Map<String, int> pathCounts = {for (var n in nodes) n: 0};
      pathCounts[s] = 1;

      List<String> order = [...nodes]
        ..sort((a, b) => distances[b]!.compareTo(distances[a]!));

      for (var v in order) {
        for (var p in parents[v]!) {
          pathCounts[v] = pathCounts[v]! + pathCounts[p]!;
        }
      }

      final totalPaths = pathCounts[t]!.toDouble();
      if (totalPaths == 0) continue;

      // Repartir contribuciones a nodos intermedios
      void dfs(String v, Set<String> visited) {
        if (v == s || v == t) return;
        if (visited.contains(v)) return;
        visited.add(v);
        if (distances[v]! < double.infinity) {
          centrality[v] = centrality[v]! + pathCounts[v]! / totalPaths;
        }
        for (var p in parents[v]!) {
          dfs(p, visited);
        }
      }

      dfs(t, {});
    }
  }

  // Normalización opcional
  final maxVal = centrality.values.fold<double>(0, max);
  if (maxVal > 0) {
    centrality.updateAll((k, v) => v / maxVal);
  }

  return centrality;
}
