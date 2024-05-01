import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';
import 'package:http/http.dart' as http;

import '../widgets/grocery_list.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<GroceryItem> _groceryItems = [];

  void _loadItems() async {
    final uri = Uri.https(
      'flutter-shopping-list-ap-a3013-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    final response = await http.get(uri);
    final Map<String, dynamic> listData = json.decode(response.body);

    List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (element) => element.value.name == item.value['category'],
          )
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadedItems;
    });

    print(response.body);
  }

  void _addNewItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const NewItemScreen();
        },
      ),
    );

    _loadItems();
  }

  @override
  void initState() {
    _loadItems();
    super.initState();
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
