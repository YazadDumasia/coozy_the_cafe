import 'dart:convert';
import 'package:equatable/equatable.dart';

class BusinessProfileEntity extends Equatable {
  final String cafeName;
  final String? logoPath;
  final String address;
  final String phone;
  final String? secondaryPhone;
  final String? email;
  final String? googleMapsUrl;
  final String? websiteUrl;
  final String? instagramUrl;
  final String? receiptFooterMessage;

  const BusinessProfileEntity({
    required this.cafeName,
    this.logoPath,
    required this.address,
    required this.phone,
    this.secondaryPhone,
    this.email,
    this.googleMapsUrl,
    this.websiteUrl,
    this.instagramUrl,
    this.receiptFooterMessage,
  });

  factory BusinessProfileEntity.defaultProfile() {
    return const BusinessProfileEntity(
      cafeName: 'Coozy The Cafe',
      logoPath: null,
      address:
          'G-24, Marvella business hub, Adajan pal, Pal RTO BRTS Rd, Surat, Gujarat 394510',
      phone: '+91 9974776639',
      secondaryPhone: '+91 9725002491',
      email: 'contact@coozythecafe.com',
      googleMapsUrl: 'https://maps.app.goo.gl/coozythecafe',
      websiteUrl: 'https://coozythecafe.com',
      instagramUrl: 'https://instagram.com/coozy_the_cafe',
      receiptFooterMessage:
          'Thank you for dining at Coozy The Cafe! Have a great day.',
    );
  }

  BusinessProfileEntity copyWith({
    String? cafeName,
    String? logoPath,
    bool clearLogo = false,
    String? address,
    String? phone,
    String? secondaryPhone,
    String? email,
    String? googleMapsUrl,
    String? websiteUrl,
    String? instagramUrl,
    String? receiptFooterMessage,
  }) {
    return BusinessProfileEntity(
      cafeName: cafeName ?? this.cafeName,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      address: address ?? this.address,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      email: email ?? this.email,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      receiptFooterMessage: receiptFooterMessage ?? this.receiptFooterMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cafeName': cafeName,
      'logoPath': logoPath,
      'address': address,
      'phone': phone,
      'secondaryPhone': secondaryPhone,
      'email': email,
      'googleMapsUrl': googleMapsUrl,
      'websiteUrl': websiteUrl,
      'instagramUrl': instagramUrl,
      'receiptFooterMessage': receiptFooterMessage,
    };
  }

  factory BusinessProfileEntity.fromMap(Map<String, dynamic> map) {
    return BusinessProfileEntity(
      cafeName: map['cafeName'] as String? ?? 'Coozy The Cafe',
      logoPath: map['logoPath'] as String?,
      address:
          map['address'] as String? ??
          'G-24, Marvella business hub, Adajan pal, Pal RTO BRTS Rd, Surat, Gujarat 394510',
      phone: map['phone'] as String? ?? '+91 9974776639',
      secondaryPhone: map['secondaryPhone'] as String?,
      email: map['email'] as String?,
      googleMapsUrl: map['googleMapsUrl'] as String?,
      websiteUrl: map['websiteUrl'] as String?,
      instagramUrl: map['instagramUrl'] as String?,
      receiptFooterMessage: map['receiptFooterMessage'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusinessProfileEntity.fromJson(String source) {
    try {
      final decoded = json.decode(source) as Map<String, dynamic>;
      return BusinessProfileEntity.fromMap(decoded);
    } catch (_) {
      return BusinessProfileEntity.defaultProfile();
    }
  }

  @override
  List<Object?> get props => [
    cafeName,
    logoPath,
    address,
    phone,
    secondaryPhone,
    email,
    googleMapsUrl,
    websiteUrl,
    instagramUrl,
    receiptFooterMessage,
  ];
}
