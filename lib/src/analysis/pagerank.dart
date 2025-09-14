import 'dart:math';

/// Calculates the PageRank for a given directed graph.
///
/// [graph]: A map where keys are page identifiers (String) and values are
///          lists of page identifiers that the key page links to.
/// [dampingFactor]: The probability that a random surfer will continue clicking
///                  links (typically 0.85).
/// [epsilon]: The convergence threshold. Iteration stops when the maximum
///            change in PageRank scores between iterations falls below this value.
/// [maxIterations]: The maximum number of iterations to perform.
///
/// Returns a map where keys are page identifiers and values are their PageRank scores.
Map<String, double> calculatePageRank(
  Map<String, List<String>> graph, {
  double dampingFactor = 0.85,
  double epsilon = 0.0001,
  int maxIterations = 100,
}) {
  if (graph.isEmpty) {
    return {};
  }

  final allPages = graph.keys.toSet();
  for (final links in graph.values) {
    allPages.addAll(links);
  }

  final numPages = allPages.length;
  if (numPages == 0) {
    return {};
  }

  // Initialize PageRank for all pages equally
  Map<String, double> pageRanks = {
    for (var page in allPages) page: 1.0 / numPages
  };

  // Create a map for incoming links to easily calculate contributions
  Map<String, List<String>> incomingLinks = {};
  for (var page in allPages) {
    incomingLinks[page] = [];
  }
  for (var sourcePage in graph.keys) {
    for (var targetPage in graph[sourcePage]!) {
      incomingLinks[targetPage]?.add(sourcePage);
    }
  }

  for (int i = 0; i < maxIterations; i++) {
    Map<String, double> newPageRanks = {};
    double maxChange = 0.0;

    for (var currentPage in allPages) {
      double rankSum = 0.0;
      for (var incomingPage in incomingLinks[currentPage]!) {
        final outgoingLinksCount = graph[incomingPage]?.length ?? 0;
        if (outgoingLinksCount > 0) {
          rankSum += pageRanks[incomingPage]! / outgoingLinksCount;
        }
      }

      final newRank = (1 - dampingFactor) / numPages + dampingFactor * rankSum;
      newPageRanks[currentPage] = newRank;

      maxChange = max(maxChange, (newRank - pageRanks[currentPage]!).abs());
    }

    pageRanks = newPageRanks;

    if (maxChange < epsilon) {
      break;
    }
  }

  // Normalize PageRanks to ensure they sum to 1 (due to potential floating point inaccuracies)
  final sumRanks = pageRanks.values.reduce((a, b) => a + b);
  if (sumRanks != 0) {
    pageRanks.updateAll((key, value) => value / sumRanks);
  }

  return pageRanks;
}
