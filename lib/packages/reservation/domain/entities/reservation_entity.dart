import 'package:equatable/equatable.dart';

class PreOrderedMenuItemEntity extends Equatable {
  final int itemId;
  final String itemName;
  final int quantity;
  final double price;

  const PreOrderedMenuItemEntity({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'itemName': itemName,
    'quantity': quantity,
    'price': price,
  };

  factory PreOrderedMenuItemEntity.fromJson(Map<String, dynamic> json) {
    return PreOrderedMenuItemEntity(
      itemId: json['itemId'] as int? ?? json['id'] as int? ?? 0,
      itemName:
          json['itemName'] as String? ?? json['item_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  PreOrderedMenuItemEntity copyWith({
    int? itemId,
    String? itemName,
    int? quantity,
    double? price,
  }) {
    return PreOrderedMenuItemEntity(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [itemId, itemName, quantity, price];
}

class ReservationEntity extends Equatable {
  final int? id;
  final String? hashId;
  final String? customerName;
  final String? phoneNumber;
  final String? isoCode;
  final int? customerId;
  final int? tableId;
  final String? tableReservedName;
  final String? reservationDateTime;
  final int? numberOfPeople;
  final int? status; // 0: Pending, 1: Confirmed, 2: Completed, 3: Cancelled
  final String? occasion;
  final String? notes;
  final List<PreOrderedMenuItemEntity> preOrderedItems;
  final String? creationDate;
  final String? modificationDate;

  const ReservationEntity({
    this.id,
    this.hashId,
    this.customerName,
    this.phoneNumber,
    this.isoCode,
    this.customerId,
    this.tableId,
    this.tableReservedName,
    this.reservationDateTime,
    this.numberOfPeople,
    this.status = 0,
    this.occasion,
    this.notes,
    this.preOrderedItems = const [],
    this.creationDate,
    this.modificationDate,
  });

  ReservationEntity copyWith({
    int? id,
    String? hashId,
    String? customerName,
    String? phoneNumber,
    String? isoCode,
    int? customerId,
    int? tableId,
    String? tableReservedName,
    String? reservationDateTime,
    int? numberOfPeople,
    int? status,
    String? occasion,
    String? notes,
    List<PreOrderedMenuItemEntity>? preOrderedItems,
    String? creationDate,
    String? modificationDate,
  }) {
    return ReservationEntity(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isoCode: isoCode ?? this.isoCode,
      customerId: customerId ?? this.customerId,
      tableId: tableId ?? this.tableId,
      tableReservedName: tableReservedName ?? this.tableReservedName,
      reservationDateTime: reservationDateTime ?? this.reservationDateTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      status: status ?? this.status,
      occasion: occasion ?? this.occasion,
      notes: notes ?? this.notes,
      preOrderedItems: preOrderedItems ?? this.preOrderedItems,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    customerName,
    phoneNumber,
    isoCode,
    customerId,
    tableId,
    tableReservedName,
    reservationDateTime,
    numberOfPeople,
    status,
    occasion,
    notes,
    preOrderedItems,
    creationDate,
    modificationDate,
  ];
}
