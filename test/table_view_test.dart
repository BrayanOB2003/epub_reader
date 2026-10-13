import 'package:epub_reader/features/reader/table_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_readium/flutter_readium.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the table document keeps the markup and drops active content', () {
    const event = EpubTableOpenEvent(
      html:
          '<table onclick="alert(1)"><tr><td>Uno</td></tr></table>'
          '<script>alert(2)</script>',
      textColor: 'rgb(42, 33, 24)',
      backgroundColor: '#F7F1E8',
      fontFamily: 'serif<bad>',
      fontSizePx: 18,
    );

    final document = tableViewDocument(event);

    expect(document, contains('<td>Uno</td>'));
    expect(document, isNot(contains('alert')));
    expect(document, isNot(contains('onclick')));
    expect(document, contains('font-size: 18'));
    expect(document, contains('serifbad'));
    expect(tableViewColor(event.backgroundColor), const Color(0xFFF7F1E8));
    expect(tableViewColor(event.textColor), const Color(0xFF2A2118));
  });
}
