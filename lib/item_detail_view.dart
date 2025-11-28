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

  // Devuelve un ícono según la categoría (coincide con shopping_list_view)
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Frutas':
        return Icons.apple;
      case 'Verduras':
        return Icons.grass;
      case 'Lácteos':
        return Icons.local_drink;
      case 'Carnes':
        return Icons.lunch_dining;
      case 'Panadería':
        return Icons.bakery_dining;
      case 'Bebidas':
        return Icons.local_cafe;
      case 'Limpieza':
        return Icons.cleaning_services;
      case 'Snacks':
        return Icons.cookie;
      default:
        return Icons.shopping_basket;
    }
  }

  // Colores por categoría (coincide con shopping_list_view)
  Color _categoryColor(String category) {
    const map = {
      'Frutas': Color(0xFFEF9A9A),
      'Verduras': Color(0xFFA5D6A7),
      'Lácteos': Color(0xFF90CAF9),
      'Carnes': Color(0xFFFFCC80),
      'Panadería': Color(0xFFF8BBD0),
      'Bebidas': Color(0xFFB39DDB),
      'Limpieza': Color(0xFFB2EBF2),
      'Snacks': Color(0xFFFFF59D),
      'Otros': Color(0xFFCFD8DC),
    };
    return map[category] ?? const Color(0xFFCFD8DC);
  }

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

    // Return a result so the previous screen can show a SnackBar
    Navigator.pop(context, isNewItem ? 'created' : 'updated');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textPrimary = theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final subtitleColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface.withAlpha((0.7 * 255).round());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isNewItem ? 'Nuevo Item' : 'Editar Item',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: saveItem,
            icon: Icon(
              Icons.check,
              color: primary,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero target for the item's category icon (only when editing existing item)
                    if (!isNewItem && widget.itemId != null && nameController.text.isNotEmpty) ...[
                      Center(
                        child: Hero(
                          tag: 'item-${widget.itemId}',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _categoryColor(selectedCategory),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(selectedCategory),
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Campo de nombre
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(
                          Icons.shopping_bag_outlined,
                          color: primary,
                        ),
                        filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primary,
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
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(color: subtitleColor),
                        prefixIcon: Icon(
                          Icons.numbers,
                          color: primary,
                        ),
                        filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primary,
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
                    Text(
                      'Categoría',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        letterSpacing: 1.2,
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
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
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
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
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