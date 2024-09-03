import 'package:daily_sales/pages/produto_table_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:daily_sales/widgets/last_update_widget.dart';
import 'package:daily_sales/pages/sucursal_chart_page.dart';
import 'package:daily_sales/pages/principal_table_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[800],
          titleTextStyle: const TextStyle(fontSize: 16, color: Colors.white),
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oceana Daily Sales'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LastUpdateWidget(), // This widget stays on top, independent of the page
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: const [
                ValorPage(), // Valor page with chart and table
                QtdPage(), // Qtd page
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Valor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Volume',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple[800],
        onTap: _onItemTapped,
        // Reduce icon and label sizes for a smaller bottom bar
        selectedIconTheme: const IconThemeData(
          size: 20, // Smaller selected icon size
        ),
        unselectedIconTheme: const IconThemeData(
          size: 18, // Smaller unselected icon size
        ),
        selectedLabelStyle: const TextStyle(
          fontSize: 12, // Smaller selected label text size
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10, // Smaller unselected label text size
        ),
      ),

    );
  }
}

class ValorPage extends StatelessWidget {
  const ValorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 3,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 16 / 9, // Adjust aspect ratio as needed
              child: SucursalChartPage(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: PrincipalTablePage(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class QtdPage extends StatelessWidget {
  const QtdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: ProdutoTablePage(),
          );
        },
      ),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; // Import this to control device orientation
import 'package:daily_sales/widgets/last_update_widget.dart'; // Import Last Update Widget
import 'package:daily_sales/pages/sucursal_chart_page.dart'; // Import Doughnut Chart Page
import 'package:daily_sales/pages/principal_table_page.dart'; // Import PrincipalTablePage for the SfDataGrid

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Lock the orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Both portrait orientations (normal and upside down)
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[800],
          titleTextStyle: TextStyle(fontSize: 16, color: Colors.white),
          centerTitle: true,
        ),
      ),
      home: const HomePage(), // Use the updated HomePage class
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oceana Daily Sales'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(1.0),
            child: LastUpdateWidget(), // Display last update at the top
          ),
          Expanded(
            flex: 3, // Adjust the space the chart takes
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SucursalChartPage(), // Doughnut Chart in its own section
            ),
          ),
          Expanded(
            flex: 2, // Adjust the space the DataGrid takes
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrincipalTablePage(), // Display the SfDataGrid for PrincipalTablePage
            ),
          ),
        ],
      ),
    );
  }
}
*/
