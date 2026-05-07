import 'package:flutter/material.dart';

class ProviderListScreen extends StatelessWidget {
  const ProviderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Contact"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search user name or mobile number...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Provider List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _ProviderTile(
                  name: "Amir",
                  phoneMasked: "*******3333",
                  imageUrl: null,
                ),
                _ProviderTile(
                  name: "Mubashir 2",
                  phoneMasked: "*******1111",
                  imageUrl: null,
                ),
                _ProviderTile(
                  name: "Saqib",
                  phoneMasked: "*******4444",
                  imageUrl: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.name,
    required this.phoneMasked,
    this.imageUrl,
  });

  final String name;
  final String phoneMasked;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phoneMasked),
            const SizedBox(height: 4),
            const Text(
              "0 Sessions Booked • Avg. 0.0 ⭐⭐⭐⭐⭐",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF00C853)),
          onPressed: () {
            // TODO: Add contact logic later
          },
        ),
      ),
    );
  }
}
