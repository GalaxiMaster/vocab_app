// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vocab_app/Pages/add_word.dart';
import 'package:vocab_app/Pages/quizzes.dart';
import 'package:vocab_app/Pages/settings.dart';
import 'package:vocab_app/Pages/word_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  final List<Widget> _pages = [
    WordList(),
    HomePageContent(),
    Quizzes(),
  ];
  @override
  void initState() {
    super.initState();
        // showInstantNotification(
    //   title: 'YOU JUST GOT NOTIFIED', 
    //   description: 'notified', 
    //   androidPlatformChannelSpecifics: NotificationType.wordReminder.details, 
    //   payload: 'wordReminder'
    // );
    // scheduleNotification(
    //   title: 'YOU JUST GOT NOTIFIED', 
    //   description: 'notified', 
    //   duration: Duration(seconds: 1), 
    //   androidPlatformChannelSpecifics: NotificationType.wordReminder.details, 
    //   payload: 'wordReminder'
    // );
  }
  @override
  Widget build(BuildContext context) {
    // resetData(true, false, false);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: const Color.fromARGB(255, 112, 173, 252),
        selectedIndex: _currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Words list',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz),
            label: 'Questions',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            child: IconButton(
              padding: EdgeInsets.all(20),
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage())
                );
              }, 
              icon: Icon(Icons.settings)
            )
          ),
          _pages[_currentIndex],
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Vocab Lab',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWord(),
                  )
              );
            },
            backgroundColor: Colors.blue,
            child: Text(
              "+",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          )
        )
      ],
    );
  }

}