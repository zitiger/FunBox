import 'package:flutter_test/flutter_test.dart';

import 'package:code/main.dart';

void main() {
  testWidgets('renders the homepage hero, sections, and bottom tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FunBoxApp());

    expect(find.text('今天玩点什么'), findsOneWidget);
    expect(find.text('最近游玩'), findsOneWidget);
    expect(find.text('斗地主'), findsWidgets);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('首页'), findsOneWidget);
    expect(find.text('分类'), findsOneWidget);
    expect(find.text('收藏'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets(
    'shows registry-driven category content instead of placeholder copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(const FunBoxApp());

      await tester.tap(find.text('分类'));
      await tester.pumpAndSettle();
      expect(find.text('分类内容建设中'), findsNothing);
      expect(find.text('2048'), findsWidgets);
      expect(find.text('斗地主'), findsWidgets);

      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();
      expect(find.text('收藏内容建设中'), findsNothing);
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('2048'), findsWidgets);

      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();
      expect(find.text('设置内容建设中'), findsOneWidget);

      await tester.tap(find.text('首页'));
      await tester.pumpAndSettle();
      expect(find.text('今天玩点什么'), findsOneWidget);
    },
  );
}
