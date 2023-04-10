import 'package:flutter/material.dart';
import '../pages/configuration_page.dart';
import '../pages/statistics_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sauna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> _appBarTitle = ['Set Configurations', 'View Statistics'];
  late int _selectedPageIndex;
  late List<Widget> _pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = 0;
    _pages = const [
      ConfigurationPage(),
      StatisticsPage(),
    ];

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle[_selectedPageIndex]),
      ),
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: _pages,
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.white,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.teal,
      iconSize: 30,
      items: _buildBottomNavBarItems(),
      currentIndex: _selectedPageIndex,
      onTap: (index) {
        setState(() {
          _selectedPageIndex = index;
          _pageController.jumpToPage(index);
        });
      },
    );
  }

  _buildBottomNavBarItems() {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Configuration',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.auto_graph_rounded),
        label: 'Statistics',
      ),
    ];
  }
}
