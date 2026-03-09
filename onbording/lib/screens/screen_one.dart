import 'package:flutter/material.dart';
import '../overlay/highlight_overlay.dart';
import 'screen_two.dart';

class ScreenOne extends StatefulWidget {
  const ScreenOne({super.key});

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? entry;
  String screentext =" Click to read "
;  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      entry =  HighlightOverlay.show(context, _buttonKey , screentext);
    });
  }

  @override
  void dispose() {
    entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen One")),
      body: Center(
        child: ElevatedButton(
          key: _buttonKey,
          onPressed: () {
             if (entry!.mounted) {
              entry?.remove();
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScreenTwo()),
            );
          },
          child: const Text("Go to Screen Two"),
        ),
      ),
    );
  }
}
