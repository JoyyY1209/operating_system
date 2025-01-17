import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'logs_page.dart'; // Import LogsPage

class DiningPhilosophersApp extends StatefulWidget {
  @override
  _DiningPhilosophersAppState createState() => _DiningPhilosophersAppState();
}

class _DiningPhilosophersAppState extends State<DiningPhilosophersApp> with SingleTickerProviderStateMixin {
  final List<String> _logs = [];
  final List<String> _displayedLogs = [];
  final List<int> _sequence = [];
  int numPhilosophers = 5;
  int numCycles = 3;

  late List<Semaphore> forks;
  late Semaphore room;
  bool isSimulationCompleted = false;
  bool isAnimationVisible = false; // Track whether animation should be visible

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  Color completionColor = Colors.red; // Default color before starting simulation
  String completionText = "Waiting for Input"; // Default text before starting simulation
  double completionContainerHeight = 100; // Default container height before completion

  @override
  void initState() {
    super.initState();
    initializeSimulation();

    // Initialize the animation controller and opacity animation
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void initializeSimulation() {
    forks = List.generate(numPhilosophers, (_) => Semaphore(1));
    room = Semaphore(numPhilosophers - 1);
    _sequence.clear();
  }

  void addLog(String message) {
    setState(() {
      _logs.add(message);
      _displayedLogs.add(message);

      if (_displayedLogs.length > 3) {
        _displayedLogs.removeAt(0);
      }
    });
  }

  Future<void> philosopher(int id) async {
    final random = Random();
    for (int cycle = 0; cycle < numCycles; cycle++) {
      addLog("Philosopher $id is thinking (Cycle ${cycle + 1}).");
      await Future.delayed(Duration(seconds: random.nextInt(3) + 1));

      addLog("Philosopher $id is hungry (Cycle ${cycle + 1}).");
      await room.acquire();

      await forks[id].acquire();
      await forks[(id + 1) % numPhilosophers].acquire();

      addLog("Philosopher $id is eating (Cycle ${cycle + 1}).");
      await Future.delayed(Duration(seconds: random.nextInt(3) + 1));

      forks[(id + 1) % numPhilosophers].release();
      forks[id].release();

      room.release();
      addLog("Philosopher $id finished eating and is thinking again (Cycle ${cycle + 1}).");
    }

    setState(() {
      _sequence.add(id);
    });
  }

  Future<void> startSimulation() async {
    setState(() {
      isSimulationCompleted = false;
      isAnimationVisible = true; // Show animation when simulation starts
      completionColor = Colors.yellow; // Set completion color to yellow when simulation starts
      completionText = "Processing..."; // Update text to Processing
      completionContainerHeight = 100; // Set container height to normal size when processing starts
    });

    _logs.clear();
    _sequence.clear();
    final tasks = List.generate(numPhilosophers, (i) => philosopher(i));
    await Future.wait(tasks);

    setState(() {
      isSimulationCompleted = true;
      isAnimationVisible = false; // Hide animation when simulation completes
      completionColor = Colors.green; // Set completion color to green when simulation completes
      completionText = "Philosophers Order: ${_sequence.join(", ")}"; // Display philosopher completion order
      completionContainerHeight = 120; // Smaller container height when simulation completes
    });

    addLog("Simulation completed.");
    addLog("Sequence of philosophers completing eating: ${_sequence.join(", ")}");
  }

  void showInputDialog(BuildContext context) {
    final numPhilosophersController = TextEditingController(text: numPhilosophers.toString());
    final numCyclesController = TextEditingController(text: numCycles.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Simulation Parameters"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numPhilosophersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Number of Philosophers"),
              ),
              TextField(
                controller: numCyclesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Number of Cycles"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  numPhilosophers = int.tryParse(numPhilosophersController.text) ?? 5;
                  numCycles = int.tryParse(numCyclesController.text) ?? 3;
                  initializeSimulation();
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void resetSimulation() {
    setState(() {
      numPhilosophers = 5;
      numCycles = 3;
      _logs.clear();
      _displayedLogs.clear();
      _sequence.clear();
      completionText = "Waiting for Input";
      completionColor = Colors.red;
      isSimulationCompleted = false;
      isAnimationVisible = false;
      completionContainerHeight = 100;
    });
    initializeSimulation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade200, // Darker background for AppBar
        title: const Text("Dining Philosophers", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center( // Center everything on the screen
        child: SingleChildScrollView( // Wrap everything in a SingleChildScrollView
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isSimulationCompleted) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green.shade200, // White text for button
                    ),
                    onPressed: () => showInputDialog(context),
                    child: const Text("Set Parameters"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green.shade200, // White text for button
                    ),
                    onPressed: startSimulation,
                    child: const Text("Start Simulation"),
                  ),
                ],
                const SizedBox(height: 20),
                // Lottie animation appears below the Start Simulation button
                if (isAnimationVisible)
                  Lottie.asset(
                    'assets/animations/2circle_loading.json', // Path to your Lottie animation file
                    width: 100, // Set the desired width for the animation
                    height: 100, // Set the desired height for the animation
                    repeat: true, // Loop the animation
                    animate: true, // Start animation automatically
                  ),
                const SizedBox(height: 20),
                // Displaying logs dynamically
                if (_displayedLogs.isNotEmpty)
                  AnimatedOpacity(
                      opacity: _displayedLogs.isNotEmpty ? 0.5 : 1.0, // Set opacity for the first log
                      duration: const Duration(milliseconds: 500),
                      child: Center(child: Text(_displayedLogs[0], style: TextStyle(fontSize: 16)))),
                if (_displayedLogs.length > 1)
                  Center(child: Text(_displayedLogs[1], style: TextStyle(fontSize: 16))),
                if (_displayedLogs.length > 2)
                  AnimatedOpacity(
                      opacity: _displayedLogs.isNotEmpty ? 0.5 : 1.0, // Set opacity for the third log
                      duration: const Duration(milliseconds: 500),
                      child: Center(child: Text(_displayedLogs[2], style: TextStyle(fontSize: 16)))),
                // Positioning the View All Logs button
                if (isSimulationCompleted) // Only show button when simulation is complete
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green.shade200, // White text for button
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogsPage(logs: List.unmodifiable(_logs)), // Pass all logs
                          ),
                        );
                      },
                      child: const Text("View All Logs"),
                    ),
                  ),
                // Try Another Button after completion
                if (isSimulationCompleted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green.shade200, // White text for button
                      ),
                      onPressed: resetSimulation,
                      child: const Text("Try Another"),
                    ),
                  ),
                // Completion sequence container at the bottom
                SizedBox(height: 50),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: completionColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 70,
                    width: max(200, 20 + completionText.length * 12.0), // Dynamically adjust width
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Completion Sequence:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            completionText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSimulationCompleted ? 20 : 16, // Adjust text size dynamically
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Semaphore {
  int _permits;
  Semaphore(this._permits);

  Future<void> acquire() async {
    while (_permits <= 0) {
      await Future.delayed(const Duration(milliseconds: 1));
    }
    _permits--;
  }

  void release() {
    _permits++;
  }
}

// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: DiningPhilosophersApp(),
//   ));
// }
