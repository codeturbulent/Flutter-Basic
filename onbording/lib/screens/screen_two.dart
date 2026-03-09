import 'package:flutter/material.dart';
import '../overlay/highlight_overlay.dart';

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({super.key});

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  final GlobalKey _backKey = GlobalKey();
  OverlayEntry? entry;
 String screentext = "click to go bak";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      entry = HighlightOverlay.show(context, _backKey , screentext);
    });
  }

  @override
  void dispose() {
       
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Two"),
        leading: IconButton(
          key: _backKey,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (entry!.mounted) {
              entry?.remove();
            }
            
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: Text("Second Screen"),
      ),
    );
  }
}
