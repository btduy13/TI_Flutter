import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/database_service.dart';
import 'screens/order_list_screen.dart';
import 'screens/add_order_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/edit_order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'Tape Inventory',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const MainScreen(),
        routes: {
          '/order_list': (context) => const OrderListScreen(),
          '/add_order': (context) => const AddOrderScreen(),
          '/order_detail': (context) => const OrderDetailScreen(),
          '/history': (context) => const HistoryScreen(),
          '/edit_order': (context) => const EditOrderScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const OrderListScreen(),
    const HistoryScreen(),
  ];

  final List<String> _titles = ['Quản lý đơn hàng', 'Lịch sử đơn hàng'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close drawer
        },
        children: const [
          NavigationDrawerDestination(
            icon: Icon(Icons.format_list_bulleted),
            label: Text('Danh sách đơn hàng'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.history),
            label: Text('Lịch sử đơn hàng'),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_order');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
