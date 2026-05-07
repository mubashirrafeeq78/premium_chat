import 'package:flutter/material.dart';
import 'storage.dart';
import 'widgets.dart';
import 'routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = "";
  String _role = "";
  String _phone = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AppStorage.getUser();
    final phone = await AppStorage.getPhone();
    setState(() {
      _name = user?.name ?? "";
      _role = user?.role ?? "";
      _phone = phone ?? "";
    });
  }

  Future<void> _logout() async {
    await AppStorage.clearAll();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.auth, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome: $_name", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text("Phone: $_phone"),
            Text("Role: $_role"),
            const SizedBox(height: 18),
            PrimaryButton(text: "Logout", onPressed: _logout),
          ],
        ),
      ),
    );
  }
}