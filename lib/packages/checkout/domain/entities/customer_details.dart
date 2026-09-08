import 'package:equatable/equatable.dart';

class CustomerDetails extends Equatable {
  final String mobileNumber;
  final String name;
  final String email;
  final String address;
  final String? isoCode;

  const CustomerDetails({
    this.mobileNumber = '',
    this.name = '',
    this.email = '',
    this.address = '',
    this.isoCode,
  });

  CustomerDetails copyWith({
    String? mobileNumber,
    String? name,
    String? email,
    String? address,
    String? isoCode,
  }) {
    return CustomerDetails(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      isoCode: isoCode ?? this.isoCode,
    );
  }

  @override
  List<Object?> get props => [mobileNumber, name, email, address, isoCode];
}
