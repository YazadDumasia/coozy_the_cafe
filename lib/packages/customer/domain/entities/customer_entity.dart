import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

// ignore: must_be_immutable
class CustomerEntity extends Equatable implements shared.ISuspensionBean {
  final int? id;
  final String? hashId;
  final String? name;
  final String? phoneNumber;
  final String? isoCode;
  final String? createdDate;
  final String tagIndex;

  @override
  bool isShowSuspension = false;

  CustomerEntity({
    this.id,
    this.hashId,
    this.name,
    this.phoneNumber,
    this.isoCode,
    this.createdDate,
    this.tagIndex = '#',
    this.isShowSuspension = false,
  });

  CustomerEntity copyWith({
    int? id,
    String? hashId,
    String? name,
    String? phoneNumber,
    String? isoCode,
    String? createdDate,
    String? tagIndex,
    bool? isShowSuspension,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isoCode: isoCode ?? this.isoCode,
      createdDate: createdDate ?? this.createdDate,
      tagIndex: tagIndex ?? this.tagIndex,
      isShowSuspension: isShowSuspension ?? this.isShowSuspension,
    );
  }

  @override
  String getSuspensionTag() {
    if (name != null && name!.isNotEmpty) {
      final tag = name![0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(tag)) {
        return tag;
      }
    }
    return '#';
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    name,
    phoneNumber,
    isoCode,
    createdDate,
    tagIndex,
    isShowSuspension,
  ];
}
