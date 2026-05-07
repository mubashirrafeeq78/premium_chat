import 'package:flutter/material.dart';
import 'provider_list_screen.dart'; // 👈 providers list screen

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  // 0=Chats, 1=Call History, 2=Add Contact, 3=My Spending, 4=Notification
  int _index = 2;

  static const _titles = <String>[
    "Chats",
    "Call History",
    "Add Contact",
    "My Spending",
    "Notification",
  ];

  static const _active = Color(0xFF00C853);
  static const _inactive = Color(0xFF9E9E9E);

  void _setTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final title = _titles[_index];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.8,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () => _setTab(4),
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFC8E6C9),
              Color(0xFFFFF9C4),
            ],
          ),
        ),
        child: _buildBody(),
      ),

      bottomNavigationBar: _BottomBar(
        currentIndex: _index,
        onTap: _setTab,
      ),
    );
  }

  /// 🔑 Body switch (safe & future-proof)
  Widget _buildBody() {
    switch (_index) {
      case 2:
        // ✅ Plus button → Provider users list
        return const ProviderListScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  static const _active = Color(0xFF00C853);
  static const _inactive = Color(0xFF9E9E9E);

  Color _colorFor(int i) {
    if (i == 2) return _active;
    return currentIndex == i ? _active : _inactive;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              label: "Chats",
              icon: Icons.chat_bubble_outline,
              color: _colorFor(0),
              onTap: () => onTap(0),
            ),
            _NavItem(
              label: "Call History",
              icon: Icons.call_outlined,
              color: _colorFor(1),
              onTap: () => onTap(1),
            ),

            // 🔵 Center Plus Button
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _active,
                      boxShadow: [
                        BoxShadow(
                          color: _active.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            _NavItem(
              label: "My Spending",
              icon: Icons.receipt_long_outlined,
              color: _colorFor(3),
              onTap: () => onTap(3),
            ),
            _NavItem(
              label: "Notification",
              icon: Icons.notifications_none,
              color: _colorFor(4),
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
