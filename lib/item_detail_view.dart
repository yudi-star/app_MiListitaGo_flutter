import 'package:flutter/material.dart';
import 'shopping_item.dart';
import 'shopping_database.dart';

class ItemDetailView extends StatefulWidget {
  const ItemDetailView({super.key, this.itemId});

  final int? itemId;

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _formKey = GlobalKey<FormState>();
  ShoppingDatabase database = ShoppingDatabase.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: '1');

  late ShoppingItem item;
  bool isLoading = false;
  bool isNewItem = false;
  String selectedCategory = 'Otros';

  // Lista de categorías disponibles
  final List<String> categories = [
    'Frutas',
    'Verduras',
    'Lácteos',
    'Carnes',
    'Panadería',
    'Bebidas',
    'Limpieza',
    'Snacks',
    'Otros',
  ];

  @override
  void initState() {
    loadItem();
    super.initState();
  }

  // Carga el item si está editando, sino es uno nuevo
  loadItem() {
    if (widget.itemId == null) {
      setState(() => isNewItem = true);
      return;
    }

    database.read(widget.itemId!).then((value) {
      setState(() {
        item = value;
        nameController.text = item.name;
        quantityController.text = item.quantity.toString();
        selectedCategory = item.category;
      });
    });
  }

  // Guarda o actualiza el item
  saveItem() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final newItem = ShoppingItem(
      name: nameController.text.trim(),
      quantity: int.parse(quantityController.text),
      category: selectedCategory,
      isPurchased: false,
      createdTime: DateTime.now(),
    );

    if (isNewItem) {
      database.create(newItem);
    } else {
      newItem.id = item.id;
      database.update(newItem);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1a1a1a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFF9C4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isNewItem ? 'Nuevo Item' : 'Editar Item',
          style: const TextStyle(
            color: Color(0xFFFFF9C4),
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: saveItem,
            icon: const Icon(
              Icons.check,
              color: Color(0xFFFFF9C4),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFF9C4)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de nombre
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Color(0xFFe0e0e0)),
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        labelStyle: const TextStyle(color: Color(0xFF9e9e9e)),
                        prefixIcon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFFFFF9C4),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2a2a2a),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFF9C4),
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo de cantidad
                    TextFormField(
                      controller: quantityController,
                      style: const TextStyle(color: Color(0xFFe0e0e0)),
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: const TextStyle(color: Color(0xFF9e9e9e)),
                        prefixIcon: const Icon(
                          Icons.numbers,
                          color: Color(0xFFFFF9C4),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2a2a2a),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFF9C4),
                            width: 1,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una cantidad';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Debe ser un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Selector de categoría
                    const Text(
                      'Categoría',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF9e9e9e),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((category) {
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedCategory = category);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFF9C4).withOpacity(0.15)
                                  : const Color(0xFF2a2a2a),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFFF9C4)
                                    : const Color(0xFF404040),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFFFF9C4)
                                    : const Color(0xFF9e9e9e),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF9C4),
                          foregroundColor: const Color(0xFF1a1a1a),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isNewItem ? 'Agregar a la Lista' : 'Guardar Cambios',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}