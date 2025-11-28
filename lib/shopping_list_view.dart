import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme_manager.dart';
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

  // Colores por categoría (accesible desde todos los métodos)
  final Map<String, Color> categoryColors = {
    'Frutas': const Color(0xFFEF9A9A),
    'Verduras': const Color(0xFFA5D6A7),
    'Lácteos': const Color(0xFF90CAF9),
    'Carnes': const Color(0xFFFFCC80),
    'Panadería': const Color(0xFFF8BBD0),
    'Bebidas': const Color(0xFFB39DDB),
    'Limpieza': const Color(0xFFB2EBF2),
    'Snacks': const Color(0xFFFFF59D),
    'Otros': const Color(0xFFCFD8DC),
  };

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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailView(itemId: id),
      ),
    );

    // Evitar usar context si el widget fue desmontado mientras esperaba
    if (!mounted) return;

    refreshItems();

    // Mostrar SnackBar según acción en ItemDetailView
    if (result == 'created') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item agregado'),
          backgroundColor: const Color(0xFF2a2a2a),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result == 'updated') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cambios guardados'),
          backgroundColor: const Color(0xFF2a2a2a),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Marca/desmarca un item como comprado
  togglePurchased(ShoppingItem item) {
    final updatedItem = item.copy(isPurchased: !item.isPurchased);
    database.update(updatedItem);
    refreshItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(item.isPurchased ? 'Marcado como pendiente' : 'Marcado como comprado'),
        backgroundColor: const Color(0xFF2a2a2a),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Elimina un item con confirmación y SnackBar con Deshacer
  deleteItem(ShoppingItem item) {
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
            onPressed: () async {
              Navigator.pop(context);
              // Guardamos una copia para Deshacer
              final deletedItem = item;

              // Capturar ScaffoldMessenger antes de operaciones async
              final messenger = ScaffoldMessenger.of(context);

              await database.delete(deletedItem.id!);

              if (!mounted) return;

              refreshItems();

              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Item eliminado'),
                  backgroundColor: const Color(0xFF2a2a2a),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Deshacer',
                    textColor: const Color(0xFFFF8A00),
                    onPressed: () async {
                      // Reinsertar sin id para evitar conflictos
                      await database.create(deletedItem.copy(id: null));
                      if (!mounted) return;
                      refreshItems();
                    },
                  ),
                ),
              );
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

    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = const Color(0xFFFF8A00);
    final textPrimary = theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;
    final subtitleColor = theme.textTheme.bodySmall?.color ?? const Color(0xFF6e6e6e);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor controlled by Theme.appBarTheme (transparent)
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mi Lista',
              style: TextStyle(
                color: textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${pendingItems.length} pendientes',
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            )
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simple SVG illustration from a free source (network)
                      SizedBox(
                        width: 200,
                        height: 160,
                        child: SvgPicture.network(
                          'https://www.svgrepo.com/show/331891/shopping-cart.svg',
                          placeholderBuilder: (context) => const CircularProgressIndicator(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu lista está vacía',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Agrega tu primer item para empezar',
                        style: TextStyle(color: Color(0xFF8a8a8a)),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => goToItemDetail(),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A00),
                        ),
                      ),
                    ],
                  ),
                )
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Items pendientes
                    if (pendingItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Por Comprar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ...pendingItems.map((item) => _buildItemCard(item)),
                      const SizedBox(height: 24),
                    ],
                    // Items comprados
                    if (purchasedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Comprados',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9e9e9e),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ...purchasedItems.map((item) => _buildItemCard(item)),
                    ],
                  ],
                ),
      // Center the FAB and provide a BottomAppBar with a notch
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Alternar tema',
                onPressed: () async {
                  await ThemeManager.save(!isDarkMode.value);
                },
                icon: Icon(Icons.brightness_6, color: Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface),
              ),
              // Right-side quick action: limpiar comprados (duplicates AppBar action)
              IconButton(
                tooltip: 'Limpiar comprados',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Eliminar comprados'),
                      content: const Text('¿Eliminar todos los items marcados como comprados?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final removed = await database.deletePurchasedAll();
                    if (!mounted) return;
                    refreshItems();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$removed items eliminados', style: TextStyle(color: textPrimary)),
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.delete_sweep, color: Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToItemDetail(),
        backgroundColor: accent,
        elevation: 10,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Construye cada tarjeta de item
  Widget _buildItemCard(ShoppingItem item) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final accent = const Color(0xFFFF8A00);
    final textPrimary = const Color(0xFF1a1a1a);
        final subtitleColor = const Color(0xFF6e6e6e);

    // Small helper: category color fallback
    final catColor = categoryColors[item.category] ?? const Color(0xFFCFD8DC);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Color((0x1E << 24) | (accent.toARGB32() & 0x00FFFFFF)),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
          child: Icon(Icons.check, color: accent),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0x1EFF0000),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: Colors.red[700]),
      ),
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          togglePurchased(item);
        } else if (direction == DismissDirection.endToStart) {
          final deletedItem = item;
          final messenger = ScaffoldMessenger.of(context);
          await database.delete(deletedItem.id!);
          if (!mounted) return;
          refreshItems();

          messenger.showSnackBar(
            SnackBar(
              content: const Text('Item eliminado'),
              backgroundColor: const Color(0xFF2a2a2a),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Deshacer',
                textColor: accent,
                onPressed: () async {
                  await database.create(deletedItem.copy(id: null));
                  if (!mounted) return;
                  refreshItems();
                },
              ),
            ),
          );
        }
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: item.isPurchased ? const Color(0xFFF2F2F2) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isPurchased ? const Color(0xFFE0E0E0) : Color((0x1E << 24) | (primary.toARGB32() & 0x00FFFFFF)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0A000000),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Hero(
              tag: 'item-${item.id}',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.isPurchased ? const Color(0xFFF2F2F2) : catColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  getCategoryIcon(item.category),
                  color: item.isPurchased ? const Color(0xFF9e9e9e) : Colors.white,
                  size: 24,
                ),
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                color: item.isPurchased ? const Color(0xFF9e9e9e) : textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${item.quantity} • ${item.category}',
                style: TextStyle(
                  color: item.isPurchased ? const Color(0xFF9e9e9e) : subtitleColor,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    item.isPurchased ? Icons.check_circle : Icons.check_circle_outline,
                    color: item.isPurchased ? accent : const Color(0xFF666666),
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
                  onPressed: () => deleteItem(item),
                ),
              ],
            ),
            onTap: () => goToItemDetail(id: item.id),
          ),
        ),
      ),
    );
  }
}