import 'package:flutter/material.dart';
import 'shopping_item.dart';
import 'shopping_database.dart';
import 'item_detail_view.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  ShoppingDatabase database = ShoppingDatabase.instance;
  List<ShoppingItem> items = [];
  bool isLoading = false;

  @override
  void initState() {
    refreshItems();
    super.initState();
  }

  @override
  dispose() {
    database.close();
    super.dispose();
  }

  // Obtiene todos los items de la base de datos
  refreshItems() {
    setState(() => isLoading = true);
    database.readAll().then((value) {
      setState(() {
        items = value;
        isLoading = false;
      });
    });
  }

  // Navega a la vista de detalles
  goToItemDetail({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailView(itemId: id),
      ),
    );
    refreshItems();
  }

  // Marca/desmarca un item como comprado
  togglePurchased(ShoppingItem item) {
    final updatedItem = item.copy(isPurchased: !item.isPurchased);
    database.update(updatedItem);
    refreshItems();
  }

  // Elimina un item con confirmación
  deleteItem(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar item?'),
        content: const Text('Esta acción no se puede deshacer'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              database.delete(id);
              Navigator.pop(context);
              refreshItems();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Obtiene el ícono según la categoría
  IconData getCategoryIcon(String category) {
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

  @override
  Widget build(BuildContext context) {
    // Separa items comprados y pendientes
    final pendingItems = items.where((item) => !item.isPurchased).toList();
    final purchasedItems = items.where((item) => item.isPurchased).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1a1a1a),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Lista',
              style: TextStyle(
                color: Color(0xFFFFF9C4),
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${pendingItems.length} pendientes',
              style: const TextStyle(
                color: Color(0xFF9e9e9e),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFF9C4),
              ),
            )
          : items.isEmpty
              ? const Center(
                  child: Text(
                    'No hay items en tu lista\nPresiona + para agregar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9e9e9e),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Items pendientes
                    if (pendingItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Por Comprar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF9e9e9e),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      ...pendingItems.map((item) => _buildItemCard(item)),
                      const SizedBox(height: 24),
                    ],
                    // Items comprados
                    if (purchasedItems.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Comprados',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF666666),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      ...purchasedItems.map((item) => _buildItemCard(item)),
                    ],
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToItemDetail(),
        backgroundColor: const Color(0xFFFFF9C4),
        elevation: 8,
        child: const Icon(
          Icons.add,
          color: Color(0xFF1a1a1a),
          size: 28,
        ),
      ),
    );
  }

  // Construye cada tarjeta de item
  Widget _buildItemCard(ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isPurchased
              ? const Color(0xFF404040)
              : const Color(0xFFFFF9C4).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.isPurchased
                ? const Color(0xFF404040)
                : const Color(0xFFFFF9C4).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            getCategoryIcon(item.category),
            color: item.isPurchased
                ? const Color(0xFF666666)
                : const Color(0xFFFFF9C4),
            size: 24,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased
                ? const Color(0xFF666666)
                : const Color(0xFFe0e0e0),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${item.quantity} • ${item.category}',
            style: TextStyle(
              color: item.isPurchased
                  ? const Color(0xFF555555)
                  : const Color(0xFF9e9e9e),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                item.isPurchased
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: item.isPurchased
                    ? const Color(0xFFFFF9C4)
                    : const Color(0xFF666666),
                size: 26,
              ),
              onPressed: () => togglePurchased(item),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFF666666),
                size: 22,
              ),
              onPressed: () => deleteItem(item.id!),
            ),
          ],
        ),
        onTap: () => goToItemDetail(id: item.id),
      ),
    );
  }
}