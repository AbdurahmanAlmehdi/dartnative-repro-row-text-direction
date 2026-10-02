import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  DartNativePluginRegistrant.registerAll();
  runApp(const RowDirectionRepro());
}

const _ink = TextStyle(fontSize: 14, color: Color(0xFF111111));
const _red = TextStyle(fontSize: 14, color: Color(0xFFC62828));
const _head = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111111));

Widget _box(String label, int color) => Container(
      width: 56,
      height: 36,
      color: Color(color),
      alignment: Alignment.center,
      child: Text(label, style: _head),
    );

Widget _numbers() => Row(children: [
      _box('1', 0xFFFFCDD2),
      _box('2', 0xFFC8E6C9),
      _box('3', 0xFFBBDEFB),
    ]);

Widget _frame(Widget child) => Container(
      color: const Color(0xFFF1F1F1),
      padding: const EdgeInsets.all(8),
      child: child,
    );

class RowDirectionRepro extends StatelessWidget {
  const RowDirectionRepro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text('Row ignores Directionality')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expected (Flutter): a Row lays its children out in the direction of '
              'the nearest Directionality.',
              style: _ink,
            ),
            const SizedBox(height: 4),
            const Text(
              'Actual: the Row keeps the app\'s direction (LTR here). In the same '
              'subtree TextAlign.start and EdgeInsetsDirectional follow it; '
              'AlignmentDirectional and CrossAxisAlignment.start do not.',
              style: _red,
            ),
            const SizedBox(height: 4),
            Text('App direction here: ${Directionality.of(context).name}', style: _ink),
            const SizedBox(height: 16),
            const Text('A. Directionality(rtl) > Row [1, 2, 3]', style: _head),
            const Text('Expected: 3 2 1, with 1 at the right edge', style: _ink),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: _frame(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _numbers(),
                  const SizedBox(height: 6),
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) => Text(
                      'Directionality.of here = ${Directionality.of(context).name}',
                      style: _ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Same subtree, each should hug the RIGHT edge:', style: _ink),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      color: const Color(0xFFFFF59D),
                      alignment: AlignmentDirectional.centerStart,
                      child: const Text('AlignmentDirectional.centerStart', style: _ink),
                    ),
                  ),
                  const SizedBox(
                    width: double.infinity,
                    child: Text('TextAlign.start', textAlign: TextAlign.start, style: _ink),
                  ),
                  Container(
                    color: const Color(0xFFFFE0B2),
                    padding: const EdgeInsetsDirectional.only(start: 60),
                    child: const Text('EdgeInsetsDirectional(start: 60)', style: _ink),
                  ),
                ],
              )),
            ),
            const SizedBox(height: 20),
            const Text(
              'B. Directionality(rtl) > … > Directionality(ltr) > Row',
              style: _head,
            ),
            const Text('Expected: +218 then 912345678, left to right', style: _ink),
            const Text(
              '(Right on this run only because the app itself is LTR; it matters in an '
              'RTL app, where the Row has no textDirection to force LTR.)',
              style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: _frame(const Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    Text('+218', style: _head),
                    SizedBox(width: 8),
                    Text('912345678', style: _head),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
