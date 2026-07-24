enum UserRole {
  superUser,
  admin,
  owner,
  manager,
  waiter,
  cashier,
  staff,
  unknown;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'superuser':
      case 'super_user':
        return UserRole.superUser;
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      case 'manager':
        return UserRole.manager;
      case 'waiter':
        return UserRole.waiter;
      case 'cashier':
        return UserRole.cashier;
      case 'staff':
        return UserRole.staff;
      default:
        return UserRole.unknown;
    }
  }
}
