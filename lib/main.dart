import 'dart:async';
import 'dart:math'; // Add this import for random number generation

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Lottie Spinner'),
                Tab(text: 'Fortune Wheel'),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    LottieSpinnerTab(
                      launchConfetti: _launchConfetti,
                      onResultSelected:
                          _showResultDialog, // Pass the dialog function
                    ),
                    FortuneWheelTab(
                      launchConfetti: _launchConfetti,
                      onResultSelected:
                          _showResultDialog, // Pass the dialog function
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _launchConfetti() {
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 100,
        spread: 70,
        y: 0.6,
        colors: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
        ],
      ),
    );
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Result'),
          content: Text(result),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class LottieSpinnerTab extends StatefulWidget {
  final Function() launchConfetti;
  final Function(String) onResultSelected; // Add callback for result

  const LottieSpinnerTab(
      {super.key,
      required this.launchConfetti,
      required this.onResultSelected});

  @override
  LottieSpinnerTabState createState() => LottieSpinnerTabState();
}

class LottieSpinnerTabState extends State<LottieSpinnerTab> {
  bool _isSpinning = false;

  void _startSpinning() {
    setState(() {
      _isSpinning = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isSpinning = false;
      });
      int result = Random().nextInt(10) + 1; // Random number between 1 and 10
      widget.onResultSelected(
          'Lottie Spinner stopped at: $result'); // Pass result to dialog
      widget.launchConfetti();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Lottie.asset(
              'assets/spinner.json',
              repeat: _isSpinning,
              animate: _isSpinning,
            ),
          ),
          ElevatedButton(
            onPressed: _isSpinning ? null : _startSpinning,
            child: const Text('Start Spinning'),
          ),
        ],
      ),
    );
  }
}

class FortuneWheelTab extends StatefulWidget {
  const FortuneWheelTab(
      {super.key,
      required this.launchConfetti,
      required this.onResultSelected});
  final Function() launchConfetti;
  final Function(String) onResultSelected; // Add callback for result

  @override
  FortuneWheelTabState createState() => FortuneWheelTabState();
}

class FortuneWheelTabState extends State<FortuneWheelTab> {
  StreamController<int> controller = StreamController<int>();
  int _currentResult = 0;

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FortuneWheel(
            animateFirst: false,
            selected: controller.stream,
            items: const [
              FortuneItem(child: Text('1')),
              FortuneItem(child: Text('2')),
              FortuneItem(child: Text('3')),
              FortuneItem(child: Text('4')),
              FortuneItem(child: Text('5')),
              FortuneItem(child: Text('6')),
              FortuneItem(child: Text('7')),
              FortuneItem(child: Text('8')),
              FortuneItem(child: Text('9')),
              FortuneItem(child: Text('10')),
            ],
            onAnimationEnd: () {
              widget.launchConfetti(); // Launch confetti
              widget.onResultSelected(
                  'Fortune Wheel stopped at: $_currentResult');
            },
          ),
        ),
        ElevatedButton(
          onPressed: _startSpinning,
          child: const Text('Start Spinning'),
        ),
      ],
    );
  }

  void _startSpinning() {
    setState(() {
      _currentResult = Fortune.randomInt(1, 10);
      controller.add(_currentResult - 1);
    });
  }
}
