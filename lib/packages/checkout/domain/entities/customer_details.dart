import 'package:equatable/equatable.dart';

class CustomerDetails extends Equatable {
  final String mobileNumber;
  final String name;
  final String email;
  final String address;

  const CustomerDetails({
    this.mobileNumber = '',
    this.name = '',
    this.email = '',
    this.address = '',
  });

  CustomerDetails copyWith({
    String? mobileNumber,
    String? name,
    String? email,
    String? address,
  }) {
    return CustomerDetails(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [mobileNumber, name, email, address];
}
