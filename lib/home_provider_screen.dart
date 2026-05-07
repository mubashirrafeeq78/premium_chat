import 'package:flutter/material.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // 0 Chats, 1 Call History, 2 Create New session(+), 3 My Session, 4 Profile
  int _index = 3; // screenshot میں My Session selected ہے

  static const _titles = <String>[
    "Chats",
    "Call History",
    "Create New session",
    "My Session",
    "Profile",
  ];

  void _setIndex(int i) {
    setState(() => _index = i);
  }

  Widget _body() {
    // ابھی placeholder body — بعد میں آپ ہر tab کی UI یہاں لگا دیں
    return Center(
      child: Text(
        _titles[_index],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00C853);
    const gray = Color(0xFF8E8E93);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.92),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Text(
          _titles[_index],
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Color(0xFFFFC107)),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
          ),
        ),
        child: _body(),
      ),

      // Bottom bar + center FAB style button
      bottomNavigationBar: _BottomBar(
        selectedIndex: _index,
        onTap: _setIndex,
        green: green,
        gray: gray,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  final Color green;
  final Color gray;

  const _BottomBar({
    required this.selectedIndex,
    required this.onTap,
    required this.green,
    required this.gray,
  });

  @override
  Widget build(BuildContext context) {
    final isChats = selectedIndex == 0;
    final isCalls = selectedIndex == 1;
    final isPlus = selectedIndex == 2;
    final isSession = selectedIndex == 3;
    final isProfile = selectedIndex == 4;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 78,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // bar background
            Container(
              height: 64,
              margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    label: "Chats",
                    icon: Icons.chat_bubble_outline,
                    active: isChats,
                    activeColor: green,
                    inactiveColor: gray,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    label: "Call History",
                    icon: Icons.call_outlined,
                    active: isCalls,
                    activeColor: green,
                    inactiveColor: gray,
                    onTap: () => onTap(1),
                  ),

                  const SizedBox(width: 54), // center button space

                  _NavItem(
                    label: "My Session",
                    icon: Icons.view_list,
                    active: isSession,
                    activeColor: green,
                    inactiveColor: gray,
                    onTap: () => onTap(3),
                  ),
                  _NavItem(
                    label: "Profile",
                    icon: Icons.person_outline,
                    active: isProfile,
                    activeColor: green,
                    inactiveColor: gray,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),

            // center + button (always green)
            Positioned(
              bottom: 20,
              child: InkWell(
                onTap: () => onTap(2),
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: isPlus ? 34 : 32),
                ),
              ),
            ),

            // label under +
            Positioned(
              bottom: 8,
              child: Text(
                "Create New session",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isPlus ? green : gray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c),
            ),
          ],
        ),
      ),
    );
  }
}
