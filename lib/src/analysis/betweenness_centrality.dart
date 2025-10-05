import 'dart:collection';

Map<String, double> calculateBetweennessCentrality(
  Map<String, Map<String, int>> replies,
) {
  final nodes = replies.keys.toSet();
  // Asegurar que todos los nodos mencionados estén en la lista
  for (var from in replies.keys) {
    for (var to in replies[from]!.keys) {
      nodes.add(to);
    }
  }
  final nodeList = nodes.toList();
  final centrality = {for (var n in nodeList) n: 0.0};

  // Construir grafo dirigido
  Map<String, List<String>> graph = {};
  for (var from in nodeList) {
    graph[from] = [];
    if (replies.containsKey(from)) {
      for (var to in replies[from]!.keys) {
        if (replies[from]![to]! > 0) {
          graph[from]!.add(to);
        }
      }
    }
  }

  // Algoritmo de Brandes para cada fuente s
  for (var s in nodeList) {
    // BFS para distancias y padres
    final distances = {for (var n in nodeList) n: -1}; // -1 = no visitado
    final sigma = {
      for (var n in nodeList) n: 0,
    }; // número de caminos más cortos desde s
    final predecessors = {for (var n in nodeList) n: <String>[]};

    distances[s] = 0;
    sigma[s] = 1;
    Queue<String> q = Queue()..add(s);
    List<String> stack = [];

    while (q.isNotEmpty) {
      var v = q.removeFirst();
      stack.add(v);
      for (var w in graph[v]!) {
        if (distances[w] == -1) {
          distances[w] = distances[v]! + 1;
          q.add(w);
        }
        if (distances[w] == distances[v]! + 1) {
          sigma[w] = sigma[w]! + sigma[v]!;
          predecessors[w]!.add(v);
        }
      }
    }

    // Acumulación hacia atrás
    final delta = {for (var n in nodeList) n: 0.0};
    while (stack.isNotEmpty) {
      var w = stack.removeLast();
      for (var v in predecessors[w]!) {
        double coeff = (sigma[v]! / sigma[w]!) * (1 + delta[w]!);
        delta[v] = delta[v]! + coeff;
      }
      if (w != s) {
        centrality[w] = centrality[w]! + delta[w]!;
      }
    }
  }

  // Normalización a [0, 1]
  double maxVal = centrality.values.reduce((a, b) => a > b ? a : b);
  if (maxVal > 0) {
    centrality.updateAll((node, score) => score / maxVal);
  }

  return centrality;
}
