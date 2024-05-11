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
  bool _isLoading = true;
  String? _error;

  void _loadItems() async {
    try {
      final uri = Uri.https(
        'flutter-shopping-list-ap-a3013-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.get(uri);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Error occurred while fetching data';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

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
        _isLoading = false;
      });

      print(response.body);
    } catch (error) {
      setState(() {
        _error = 'Something went wrong, please try again later.';
      });
    }
  }

  void _addNewItem() async {
    final newItem = await Navigator.push<GroceryItem>(
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

  Future<void> _removeItem(GroceryItem groceryItem) async {
    int index = _groceryItems.indexOf(groceryItem);

    try {
      final uri = Uri.https(
        'flutter-shopping-list-ap-a3013-default-rtdb.firebaseio.com',
        'shopping-list/${groceryItem.id}.json',
      );

      setState(() {
        _groceryItems.remove(groceryItem);
      });

      final response = await http.delete(uri);

      if (response.statusCode >= 400) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error occurred while deleting item.'),
            ),
          );

          _groceryItems.insert(index, groceryItem);
        });
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong, please try again later.'),
        ),
      );
    }
  }

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'You got no items yet!',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = GroceryList(
        groceryItems: _groceryItems,
        onDismissed: (groceryItem) {
          _removeItem(groceryItem);
        },
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
}
