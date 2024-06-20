import 'package:flutter/material.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  bool isGreen = false;

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: _themeData.textTheme.displayMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black26,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Naiomi Jerry", style: _themeData.textTheme.titleLarge),
            Expanded(
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    isGreen = !isGreen;
                  });
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isGreen
                                ? [
                                    Colors.green[900]!,
                                    Colors.green[700]!,
                                    Colors.green[500]!,
                                    Colors.green[300]!,
                                  ]
                                : [
                                    Colors.red[900]!,
                                    Colors.red[300]!,
                                    Colors.red[700]!,
                                    Colors.red[500]!,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(seconds: 1),
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGreen ? Colors.green[200] : Colors.red[200],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Clock Out",
                          style: TextStyle(color: Colors.white, fontSize: 24),
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
    );
  }
}
