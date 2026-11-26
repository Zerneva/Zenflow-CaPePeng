import 'package:hive/hive.dart';

enum TransactionType { income, expense }

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }
}

class TransactionItem {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String note;

  TransactionItem({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.note,
  });

  TransactionItem copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 1;

  @override
  TransactionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionItem(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as TransactionType,
      categoryId: fields[3] as String,
      date: fields[4] as DateTime,
      note: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }
}
