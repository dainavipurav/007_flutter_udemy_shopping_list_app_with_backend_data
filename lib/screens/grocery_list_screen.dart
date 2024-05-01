import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';

import '../widgets/grocery_list.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<GroceryItem> _groceryItems = [];

  void _addNewItem() async {
    final newItem = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const NewItemScreen();
        },
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = GroceryList(
      groceryItems: _groceryItems,
      onDismissed: onDismissed,
    );

    if (_groceryItems.isEmpty) {
      content = const Center(
        child: Text(
          'You got no items yet!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addNewItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }

  Future<void> onDismissed(groceryItem) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text(
            'Are you sure you want to delete this grocery item?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                int index = _groceryItems.indexOf(groceryItem);
                Navigator.of(ctx).pop();
                setState(() {
                  _groceryItems.remove(groceryItem);
                  _groceryItems.insert(index, groceryItem);
                });
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();

                int index = _groceryItems.indexOf(groceryItem);

                setState(() {
                  _groceryItems.remove(groceryItem);
                });

                ScaffoldMessenger.of(context).clearSnackBars();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Item deleted successfully'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        setState(() {
                          _groceryItems.remove(groceryItem);
                          _groceryItems.insert(index, groceryItem);
                        });
                      },
                    ),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
