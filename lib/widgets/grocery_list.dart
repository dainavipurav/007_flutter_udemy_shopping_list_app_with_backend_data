import 'package:flutter/material.dart';

import '../models/grocery_item.dart';

class GroceryList extends StatelessWidget {
  final List<GroceryItem> groceryItems;
  final Function(GroceryItem groceryItem) onDismissed;
  const GroceryList(
      {super.key, required this.groceryItems, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: groceryItems.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            onDismissed(groceryItems[index]);
          },
          background: Container(
            color: Colors.black54,
          ),
          child: ListTile(
            leading: Container(
              height: 24,
              width: 24,
              color: groceryItems[index].category.color,
            ),
            title: Text(groceryItems[index].name),
            trailing: Text(
              groceryItems[index].quantity.toString(),
            ),
          ),
        );
      },
    );
  }
}
