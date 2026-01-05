import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int quantity = 0;
  String? brand;
  int threshold = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Brand (optional)',
                ),
                onSaved: (v) =>
                    brand = v?.trim().isEmpty ?? true ? null : v?.trim(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Initial quantity',
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                validator: (v) =>
                    (v == null || int.tryParse(v) == null || int.parse(v) < 0)
                    ? 'Enter 0 or positive'
                    : null,
                onSaved: (v) => quantity = int.parse(v ?? '0'),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Reorder threshold (optional)',
                ),
                keyboardType: TextInputType.number,
                initialValue: '0',
                validator: (v) =>
                    (v == null || int.tryParse(v) == null || int.parse(v) < 0)
                    ? 'Enter 0 or positive'
                    : null,
                onSaved: (v) => threshold = int.parse(v ?? '0'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final navigator = Navigator.of(context);
                    final prov = Provider.of<StockProvider>(
                      context,
                      listen: false,
                    );
                    await prov.addItem(name, quantity, brand, threshold);
                    if (!mounted) return;
                    navigator.pop();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
