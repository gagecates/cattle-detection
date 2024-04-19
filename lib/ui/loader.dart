import 'package:flutter/material.dart';

import 'package:gif/gif.dart';

// loading indication Widget
class LoaderState extends StatefulWidget {
  const LoaderState({super.key});

  @override
  State<LoaderState> createState() => _LoaderStateState();
}

class _LoaderStateState extends State<LoaderState>
    with TickerProviderStateMixin {
  late final GifController controller1;
  bool _isVisible = false;

  @override
  void initState() {
    controller1 = GifController(vsync: this);
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isVisible = true; // Change the visibility after 1 second
      });
    });
  }

  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            width: 70,
            height: 70,
            child: Container(
              child: _isVisible
                  ? Gif(
                      image: AssetImage("assets/loading.gif"),
                      controller: controller1,
                      autostart: Autostart.loop,
                      onFetchCompleted: () {
                        controller1.reset();
                        controller1.forward();
                      },
                    )
                  : Container(),
            )));
  }
}
