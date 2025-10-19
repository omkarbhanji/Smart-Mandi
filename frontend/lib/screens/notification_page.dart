import 'package:flutter/material.dart';
import 'package:frontend/screens/buy_requests.dart';
import 'package:frontend/services/buy_requests_service.dart';
import 'package:frontend/services/capitalize_text.dart';
import 'package:frontend/theme.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key, required this.notifications});

  final List<dynamic> notifications;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<dynamic> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text("No notifications yet"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                String message =
                    "${capitalize(notification['customer']['name'])} is interested in buying ${notification['inventory']['cropName']}";

                return Dismissible(
                  key: Key(notification['id'].toString()),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    setState(() {
                      _notifications.removeAt(index);
                    });

                    await BuyRequestService.markAsSeen(
                        buyRequestId: notification['id'], context: context);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                      ),
                      title: Text(message),
                      subtitle: Text(
                        "Quantity: ${notification['inventory']?['quantity'] ?? '-'} ${notification['inventory']?['unit'] ?? ''} | Price: ₹${notification['inventory']?['price'] ?? '-'}",
                      ),
                      onTap: () async {
                        await BuyRequestService.markAsSeen(
                            buyRequestId: notification['id'], context: context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyRequests(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
