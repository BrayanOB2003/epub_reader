import 'package:flutter_readium/flutter_readium.dart';

/// How many entries a contents list can show before it needs search.
const contentsSearchThreshold = 12;

/// One row of the book index, in tree order.
class ContentsNode {
  const ContentsNode({
    required this.link,
    required this.depth,
    required this.position,
    required this.children,
  });

  final Link link;
  final int depth;

  /// Place in the index, starting at 1. Used when the link has no title.
  final int position;
  final List<ContentsNode> children;

  bool get hasChildren => children.isNotEmpty;
}

/// Index of the book.
///
/// A navigation document wins. The reading order stands in when that
/// document is empty.
List<ContentsNode> contentsTree({
  required List<Link> tableOfContents,
  required List<Link> readingOrder,
}) {
  final source = tableOfContents.isNotEmpty ? tableOfContents : readingOrder;
  var position = 0;
  List<ContentsNode> walk(List<Link> links, int depth) {
    return [
      for (final link in links)
        ContentsNode(
          link: link,
          depth: depth,
          position: ++position,
          children: walk(link.children, depth + 1),
        ),
    ];
  }

  return walk(source, 0);
}

int contentsNodeCount(List<ContentsNode> roots) {
  var count = 0;
  void walk(ContentsNode node) {
    count++;
    node.children.forEach(walk);
  }

  roots.forEach(walk);
  return count;
}

bool contentsShowsSearch(List<ContentsNode> roots) {
  return contentsNodeCount(roots) > contentsSearchThreshold;
}

/// Visible title. A blank link becomes its place in the index.
String contentsTitle(
  ContentsNode node, {
  required String untitled,
  required String Function(int position) chapter,
}) {
  final title = node.link.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  if (node.position > 0) return chapter(node.position);
  return untitled;
}

/// Whether [linkHref] is the resource the reader is on.
///
/// Fragments and query strings are ignored. A full file URI still matches
/// the spine path it ends with.
bool contentsHrefMatches(String linkHref, String locatorHref) {
  final link = _resource(linkHref);
  final locator = _resource(locatorHref);
  if (link.isEmpty || locator.isEmpty) return false;
  if (link == locator) return true;
  return locator.endsWith('/$link') || link.endsWith('/$locator');
}

ContentsNode? currentContentsNode(List<ContentsNode> roots, String? href) {
  if (href == null || href.isEmpty) return null;
  ContentsNode? best;
  void walk(ContentsNode node) {
    if (contentsHrefMatches(node.link.href, href)) {
      final current = best;
      if (current == null || node.depth > current.depth) best = node;
    }
    node.children.forEach(walk);
  }

  roots.forEach(walk);
  return best;
}

/// Parts that must be open so [current] is on screen.
///
/// A part that is itself the current place opens too, so its chapters show.
Set<int> expandedContents(List<ContentsNode> roots, ContentsNode? current) {
  if (current == null) return <int>{};
  final open = <int>{};
  var found = false;
  bool walk(ContentsNode node) {
    if (node.position == current.position) {
      if (node.hasChildren) open.add(node.position);
      found = true;
      return true;
    }
    for (final child in node.children) {
      if (walk(child)) {
        open.add(node.position);
        return true;
      }
    }
    return false;
  }

  for (final root in roots) {
    if (walk(root)) break;
  }
  if (!found) return <int>{};
  return open;
}

/// Rows to paint.
///
/// With an empty [query], children stay hidden until their part is in
/// [expanded]. A query shows each match and the parts above it.
List<ContentsNode> visibleContents({
  required List<ContentsNode> roots,
  required Set<int> expanded,
  required String query,
  required String Function(ContentsNode node) titleOf,
}) {
  final needle = contentsFold(query.trim());
  if (needle.isEmpty) {
    final rows = <ContentsNode>[];
    void walk(ContentsNode node) {
      rows.add(node);
      if (node.hasChildren && expanded.contains(node.position)) {
        node.children.forEach(walk);
      }
    }

    roots.forEach(walk);
    return rows;
  }

  final rows = <ContentsNode>[];
  bool walk(ContentsNode node, List<ContentsNode> into) {
    final nested = <ContentsNode>[];
    var childHit = false;
    for (final child in node.children) {
      if (walk(child, nested)) childHit = true;
    }
    final self = contentsFold(titleOf(node)).contains(needle);
    if (!self && !childHit) return false;
    into
      ..add(node)
      ..addAll(nested);
    return true;
  }

  for (final root in roots) {
    walk(root, rows);
  }
  return rows;
}

/// Estimated scroll offset for a row of about 48px, before layout.
double contentsScrollOffset(List<ContentsNode> rows, int? position) {
  if (position == null) return 0;
  final index = rows.indexWhere((node) => node.position == position);
  if (index <= 0) return 0;
  return index * 48.0;
}

/// Lowercase, with Spanish accents folded, for contents search.
String contentsFold(String value) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

String _resource(String href) => href.split('#').first.split('?').first;
