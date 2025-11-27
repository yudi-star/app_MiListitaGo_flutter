// Modelo para los items de compra
class ShoppingItemFields {
  static const List<String> values = [
    id,
    name,
    quantity,
    category,
    isPurchased,
    createdTime,
  ];

  static const String tableName = 'shopping_items';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';

  static const String id = '_id';
  static const String name = 'name';
  static const String quantity = 'quantity';
  static const String category = 'category';
  static const String isPurchased = 'is_purchased';
  static const String createdTime = 'created_time';
}

class ShoppingItem {
  int? id;
  final String name;
  final int quantity;
  final String category;
  final bool isPurchased;
  final DateTime? createdTime;

  ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.isPurchased = false,
    this.createdTime,
  });

  // Convierte el objeto a Map para guardar en la base de datos
  Map<String, Object?> toJson() => {
        ShoppingItemFields.id: id,
        ShoppingItemFields.name: name,
        ShoppingItemFields.quantity: quantity,
        ShoppingItemFields.category: category,
        ShoppingItemFields.isPurchased: isPurchased ? 1 : 0,
        ShoppingItemFields.createdTime: createdTime?.toIso8601String(),
      };

  // Convierte Map de la base de datos a objeto
  factory ShoppingItem.fromJson(Map<String, Object?> json) => ShoppingItem(
        id: json[ShoppingItemFields.id] as int?,
        name: json[ShoppingItemFields.name] as String,
        quantity: json[ShoppingItemFields.quantity] as int,
        category: json[ShoppingItemFields.category] as String,
        isPurchased: json[ShoppingItemFields.isPurchased] == 1,
        createdTime: DateTime.tryParse(
            json[ShoppingItemFields.createdTime] as String? ?? ''),
      );

  // Crea una copia del objeto con cambios opcionales
  ShoppingItem copy({
    int? id,
    String? name,
    int? quantity,
    String? category,
    bool? isPurchased,
    DateTime? createdTime,
  }) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        category: category ?? this.category,
        isPurchased: isPurchased ?? this.isPurchased,
        createdTime: createdTime ?? this.createdTime,
      );
}