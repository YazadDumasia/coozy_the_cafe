import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

abstract class BaseTable extends Table {
  IntColumn get createdBy => integer().nullable()();
  IntColumn get updatedBy => integer().nullable()();
}

@DataClassName('TableInfoData')
@TableIndex(name: 'idx_table_info_sort_order', columns: {#sortOrderIndex})
class TableInfoTable extends BaseTable {
  @override
  String get tableName => 'table_info';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get tableLabel => text().nullable()();
  TextColumn get tableNo => text().nullable()();
  TextColumn get colorValue => text().nullable()();
  IntColumn get sortOrderIndex => integer().nullable()();
  IntColumn get nosOfChairs => integer().nullable()();
  BoolColumn get isActive => boolean().nullable()();
}

@DataClassName('Category')
@TableIndex(name: 'idx_categories_position', columns: {#position})
@TableIndex(name: 'idx_categories_name', columns: {#name})
class CategoriesTable extends BaseTable {
  @override
  String get tableName => 'menu_categories';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  BoolColumn get isActive => boolean().nullable()();
  IntColumn get position => integer().nullable()();
  TextColumn get createdDate => text().nullable()();
}

@DataClassName('Subcategory')
@TableIndex(name: 'idx_subcategories_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_subcategories_position', columns: {#position})
class SubcategoriesTable extends BaseTable {
  @override
  String get tableName => 'menu_subcategories';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  TextColumn get createdDate => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(
    CategoriesTable,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  BoolColumn get isActive => boolean().nullable()();
  IntColumn get position => integer().nullable()();
}

@DataClassName('MenuItem')
@TableIndex(name: 'idx_menu_items_category_id', columns: {#categoryId})
@TableIndex(name: 'idx_menu_items_subcategory_id', columns: {#subcategoryId})
@TableIndex(name: 'idx_menu_items_name', columns: {#name})
@TableIndex(name: 'idx_menu_items_sort_order', columns: {#sortOrderIndex})
class MenuItemsTable extends BaseTable {
  @override
  String get tableName => 'menu_items';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get foodType => text().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
  IntColumn get duration => integer().nullable()();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get subcategoryId => integer().nullable()();
  BoolColumn get isTodayAvailable => boolean().nullable()();
  BoolColumn get isSimpleVariation => boolean().nullable()();
  RealColumn get costPrice => real().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  RealColumn get stockQuantity => real().nullable()();
  TextColumn get quantity => text().nullable()();
  TextColumn get purchaseUnit => text().nullable()();
  IntColumn get sortOrderIndex => integer().nullable()();
}

@DataClassName('MenuItemVariation')
@TableIndex(
  name: 'idx_menu_item_variations_menu_item_id',
  columns: {#menuItemId},
)
@TableIndex(
  name: 'idx_menu_item_variations_sort_order',
  columns: {#sortOrderIndex},
)
class MenuItemVariationsTable extends BaseTable {
  @override
  String get tableName => 'menu_item_variations';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  IntColumn get menuItemId => integer().nullable().references(
    MenuItemsTable,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  IntColumn get quantity => integer().nullable()();
  TextColumn get purchaseUnit => text().nullable()();
  BoolColumn get isTodayAvailable => boolean().nullable()();
  RealColumn get costPrice => real().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  IntColumn get stockQuantity => integer().nullable()();
  IntColumn get sortOrderIndex => integer().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
}

@DataClassName('MenuItemReview')
@TableIndex(name: 'idx_menu_item_reviews_item_id', columns: {#itemId})
@TableIndex(name: 'idx_menu_item_reviews_customer_id', columns: {#customerId})
class MenuItemReviewsTable extends BaseTable {
  @override
  String get tableName => 'menu_item_reviews';
  IntColumn get id => integer()();
  IntColumn get itemId => integer().nullable()();
  IntColumn get customerId => integer().nullable()();
  RealColumn get rating => real().nullable()();
  TextColumn get reviewText => text().nullable()();
  DateTimeColumn get reviewDate => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InventoryItem')
@TableIndex(name: 'idx_inventory_name', columns: {#name})
class InventoryTable extends BaseTable {
  @override
  String get tableName => 'inventory';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  TextColumn get shortDescription => text().nullable()();
  TextColumn get purchaseUnit => text().nullable()();
  RealColumn get currentStock => real().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get createdDate => text().nullable()();
  TextColumn get modifiedDate => text().nullable()();
}

@DataClassName('PurchaseRecord')
@TableIndex(name: 'idx_purchase_inventoryId', columns: {#inventoryId})
@TableIndex(name: 'idx_purchase_datetime', columns: {#purchaseDateTime})
class PurchaseTable extends BaseTable {
  @override
  String get tableName => 'purchase';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  IntColumn get inventoryId =>
      integer().nullable().references(InventoryTable, #id)();
  TextColumn get name => text().nullable()();
  TextColumn get purchaseUnit => text().nullable()();
  RealColumn get purchaseQty => real().nullable()();
  TextColumn get purchaseDateTime => text().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get createdDate => text().nullable()();
  TextColumn get modifiedDate => text().nullable()();
}

@DataClassName('Customer')
@TableIndex(name: 'idx_customers_name', columns: {#name})
@TableIndex(name: 'idx_customers_phone', columns: {#phoneNumber})
class CustomersTable extends BaseTable {
  @override
  String get tableName => 'customers';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  TextColumn get createdDate => text().nullable()();
}

@DataClassName('Order')
@TableIndex(name: 'idx_orders_table_info_id', columns: {#tableInfoId})
@TableIndex(name: 'idx_orders_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_orders_status', columns: {#status})
@TableIndex(name: 'idx_orders_creation_date', columns: {#creationDate})
@TableIndex(name: 'idx_orders_reservation_id', columns: {#reservationId})
class OrdersTable extends BaseTable {
  @override
  String get tableName => 'orders';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  IntColumn get tableInfoId =>
      integer().nullable().references(TableInfoTable, #id)();
  TextColumn get tableNameText => text().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
  BoolColumn get isCanceled => boolean().nullable()();
  BoolColumn get isDeleted => boolean().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get orderType => text().nullable()();
  TextColumn get paymentMethodName => text().nullable()();
  TextColumn get paymentMethodDetails => text().nullable()();
  TextColumn get deliveryAddress => text().nullable()();
  IntColumn get customerId =>
      integer().nullable().references(CustomersTable, #id)();
  TextColumn get customerName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  IntColumn get reservationId => integer().nullable().references(
    ReservationsTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

@DataClassName('OrderItem')
@TableIndex(name: 'idx_order_items_order_id', columns: {#orderId})
@TableIndex(name: 'idx_order_items_item_id', columns: {#itemId})
@TableIndex(name: 'idx_order_items_menu_item_id', columns: {#menuItemId})
@TableIndex(
  name: 'idx_order_items_variation_id',
  columns: {#selectedVariationId},
)
@TableIndex(name: 'idx_order_items_status', columns: {#status})
class OrderItemsTable extends BaseTable {
  @override
  String get tableName => 'order_items';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().nullable().references(OrdersTable, #id)();
  @ReferenceName('orderItemsByItemId')
  IntColumn get itemId =>
      integer().nullable().references(MenuItemsTable, #id)();
  IntColumn get quantity => integer().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  RealColumn get costPrice => real().nullable()();
  TextColumn get status => text().nullable()();
  BoolColumn get isMenuItem => boolean().nullable()();
  @ReferenceName('orderItemsByMenuItemId')
  IntColumn get menuItemId =>
      integer().nullable().references(MenuItemsTable, #id)();
  IntColumn get selectedVariationId =>
      integer().nullable().references(MenuItemVariationsTable, #id)();
  TextColumn get remarks => text().nullable()();
  BoolColumn get isParcel => boolean().withDefault(const Constant(false))();
  TextColumn get creationDate => text().nullable()();
}

@DataClassName('PaymentMode')
@TableIndex(name: 'idx_payment_modes_name', columns: {#paymentMethodName})
@TableIndex(name: 'idx_payment_modes_hash', columns: {#hashId})
class PaymentModesTable extends BaseTable {
  @override
  String get tableName => 'payment_modes';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get paymentMethodName => text()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
}

@DataClassName('Invoice')
@TableIndex(name: 'idx_invoices_orderId', columns: {#orderId})
@TableIndex(name: 'idx_invoices_customerId', columns: {#customerId})
@TableIndex(name: 'idx_invoices_paymentModeId', columns: {#paymentModeId})
@TableIndex(
  name: 'idx_invoices_search',
  columns: {#hashId, #customerName, #phoneNumber},
)
@TableIndex(name: 'idx_invoices_createdDate', columns: {#createdDate})
class InvoicesTable extends BaseTable {
  @override
  String get tableName => 'invoices';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().nullable().references(
    OrdersTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  RealColumn get taxPercentage => real().withDefault(const Constant(0.0))();
  IntColumn get discountType => integer().withDefault(const Constant(0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalCost => real().withDefault(const Constant(0.0))();
  RealColumn get taxCost => real().withDefault(const Constant(0.0))();
  RealColumn get taxableAmount => real().withDefault(const Constant(0.0))();
  RealColumn get netPaymentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get createdDate => text().nullable()();
  TextColumn get modifiedDate => text().nullable()();
  IntColumn get customerId => integer().nullable().references(
    CustomersTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get customerName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  IntColumn get paymentModeId => integer().nullable().references(
    PaymentModesTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get paymentMethodName => text().nullable()();
  RealColumn get recordAmountPaid => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethodDetails => text().nullable()();
}

@DataClassName('InvoiceItem')
@TableIndex(name: 'idx_invoiceItems_invoiceId', columns: {#invoiceId})
@TableIndex(name: 'idx_invoiceItems_item_id', columns: {#itemId})
class InvoiceItemsTable extends BaseTable {
  @override
  String get tableName => 'invoice_items';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().nullable().references(
    InvoicesTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get orderItemId => integer().nullable()();
  IntColumn get itemId => integer().nullable()();
  TextColumn get itemName => text().nullable()();
  IntColumn get quantity => integer().nullable()();
  RealColumn get sellingPrice => real().nullable()();
  RealColumn get totalPrice => real().nullable()();
  RealColumn get taxPercentage => real().nullable()();
  RealColumn get taxAmount => real().nullable()();
  RealColumn get discountAmount => real().nullable()();
  TextColumn get createdDate => text().nullable()();
}

@DataClassName('PaymentTransaction')
@TableIndex(name: 'idx_paymentTransactions_invoiceId', columns: {#invoiceId})
@TableIndex(
  name: 'idx_paymentTransactions_paymentModeId',
  columns: {#paymentModeId},
)
class PaymentTransactionsTable extends BaseTable {
  @override
  String get tableName => 'payment_transactions';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().nullable().references(
    InvoicesTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get paymentModeId =>
      integer().nullable().references(PaymentModesTable, #id)();
  TextColumn get paymentMethodName => text().nullable()();
  RealColumn get amount => real().nullable()();
  TextColumn get transactionReference => text().nullable()();
  TextColumn get paymentStatus => text().nullable()();
  TextColumn get createdDate => text().nullable()();
}

@DataClassName('Recipe')
@TableIndex(name: 'idx_recipes_id', columns: {#id})
@TableIndex(name: 'idx_recipes_original_name', columns: {#recipeOriginalName})
@TableIndex(name: 'idx_recipes_bookmark', columns: {#isBookmark})
@TableIndex(
  name: 'idx_recipes_translated_ingredient_list',
  columns: {#recipeTranslatedIngredientList},
)
class RecipesTable extends BaseTable {
  @override
  String get tableName => 'recipes';
  IntColumn get recipeId => integer().autoIncrement()();
  IntColumn get id => integer().nullable()();
  TextColumn get recipeOriginalName => text().nullable()();
  TextColumn get translatedRecipeName => text().nullable()();
  TextColumn get recipeOriginalIngredients => text().nullable()();
  TextColumn get recipeTranslatedIngredientList => text().nullable()();
  TextColumn get recipeTranslatedIngredients => text().nullable()();
  IntColumn get recipePreparationTimeInMins => integer().nullable()();
  IntColumn get recipeCookingTimeInMins => integer().nullable()();
  IntColumn get recipeTotalTimeInMins => integer().nullable()();
  IntColumn get recipeServings => integer().nullable()();
  TextColumn get recipeCuisine => text().nullable()();
  TextColumn get recipeCourse => text().nullable()();
  TextColumn get recipeDiet => text().nullable()();
  TextColumn get recipeOriginalInstructions => text().nullable()();
  TextColumn get recipeTranslatedInstructions => text().nullable()();
  TextColumn get recipeReferenceUrl => text().nullable()();
  BoolColumn get isBookmark => boolean().nullable()();
}

@DataClassName('RecipeImage')
class RecipeImagesTable extends BaseTable {
  @override
  String get tableName => 'recipe_images';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId => integer().nullable().references(
    RecipesTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get fileName => text()();
  TextColumn get base64Data => text()();
}

@DataClassName('Employee')
@TableIndex(name: 'idx_employee_name', columns: {#name})
@TableIndex(name: 'idx_employee_phone', columns: {#phoneNumber}, unique: true)
@TableIndex(name: 'idx_employee_position', columns: {#position})
@TableIndex(name: 'idx_employee_joining_date', columns: {#joiningDate})
@TableIndex(name: 'idx_employee_deleted', columns: {#isDeleted})
class EmployeesTable extends BaseTable {
  @override
  String get tableName => 'employees';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  TextColumn get position => text().nullable()();
  TextColumn get joiningDate => text().nullable()();
  TextColumn get leavingDate => text().nullable()();
  TextColumn get startWorkingTime => text().nullable()();
  TextColumn get endWorkingTime => text().nullable()();
  TextColumn get workingHours => text().nullable()();
  TextColumn get email => text().nullable()();
  RealColumn get salary => real().nullable()();
  TextColumn get addressLine1 => text().nullable()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get idProof => text().nullable()();
  TextColumn get idProofNumber => text().nullable()();
  IntColumn get totalLeaves => integer().nullable()();
  BoolColumn get isDeleted => boolean().nullable()();
}

@DataClassName('AttendanceRecord')
@TableIndex(name: 'idx_attendance_employee', columns: {#employeeId})
@TableIndex(name: 'idx_attendance_status', columns: {#currentStatus})
@TableIndex(name: 'idx_attendance_checkin', columns: {#checkIn})
@TableIndex(name: 'idx_attendance_deleted', columns: {#isDeleted})
@TableIndex(
  name: 'idx_attendance_employee_checkin',
  columns: {#employeeId, #checkIn},
)
class AttendanceTable extends BaseTable {
  @override
  String get tableName => 'attendance';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get employeeId =>
      integer().nullable().references(EmployeesTable, #id)();
  TextColumn get employeeName => text().nullable()();
  TextColumn get employeePosition => text().nullable()();
  IntColumn get currentStatus => integer().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
  TextColumn get checkIn => text().nullable()();
  TextColumn get checkOut => text().nullable()();
  TextColumn get employeeWorkingDurations => text().nullable()();
  TextColumn get workingTimeDurations => text().nullable()();
  BoolColumn get isDeleted => boolean().nullable()();
}

@DataClassName('LeaveRecord')
@TableIndex(name: 'idx_leave_employee', columns: {#employeeId})
@TableIndex(name: 'idx_leave_status', columns: {#currentStatus})
@TableIndex(name: 'idx_leave_start_date', columns: {#startDate})
@TableIndex(name: 'idx_leave_end_date', columns: {#endDate})
@TableIndex(name: 'idx_leave_deleted', columns: {#isDeleted})
@TableIndex(
  name: 'idx_leave_employee_date',
  columns: {#employeeId, #startDate, #endDate},
)
class LeavesTable extends BaseTable {
  @override
  String get tableName => 'leaves';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get employeeId =>
      integer().nullable().references(EmployeesTable, #id)();
  TextColumn get employeeName => text().nullable()();
  TextColumn get employeePosition => text().nullable()();
  IntColumn get currentStatus => integer().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get reason => text().nullable()();
  BoolColumn get isDeleted => boolean().nullable()();
}

@DataClassName('Reservation')
@TableIndex(name: 'idx_reservations_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_reservations_table_id', columns: {#tableId})
@TableIndex(name: 'idx_reservations_status', columns: {#status})
@TableIndex(name: 'idx_reservations_datetime', columns: {#reservationDateTime})
class ReservationsTable extends BaseTable {
  @override
  String get tableName => 'reservations';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get customerName => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  IntColumn get customerId => integer().nullable().references(
    CustomersTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get tableId => integer().nullable().references(
    TableInfoTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get tableReservedName => text().named('tableName').nullable()();
  TextColumn get reservationDateTime => text().nullable()();
  IntColumn get numberOfPeople => integer().nullable()();
  IntColumn get status => integer().nullable()();
  TextColumn get occasion => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get creationDate => text().nullable()();
  TextColumn get modificationDate => text().nullable()();
}

@DataClassName('UserRole')
@TableIndex(name: 'idx_roles_name', columns: {#name})
class RolesTable extends Table {
  @override
  String get tableName => 'roles';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
  TextColumn get updatedAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
}

@DataClassName('UserLogin')
@TableIndex(name: 'idx_user_logins_role_id', columns: {#roleId})
@TableIndex(name: 'idx_user_logins_username', columns: {#username})
@TableIndex(name: 'idx_user_logins_email', columns: {#email})
class UserLoginsTable extends Table {
  @override
  String get tableName => 'user_logins';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get username => text().unique()();
  TextColumn get email => text().unique()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get isoCode => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  IntColumn get roleId => integer().nullable().references(
    RolesTable,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
  TextColumn get updatedAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
}

@DataClassName('UserPermission')
@TableIndex(name: 'idx_permissions_name', columns: {#name})
class PermissionsTable extends Table {
  @override
  String get tableName => 'permissions';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
}

@DataClassName('RolePermission')
@TableIndex(name: 'idx_role_permissions_role_id', columns: {#roleId})
@TableIndex(
  name: 'idx_role_permissions_permission_id',
  columns: {#permissionId},
)
class RolePermissionsTable extends Table {
  @override
  String get tableName => 'role_permissions';
  IntColumn get id => integer().autoIncrement()();
  IntColumn get roleId =>
      integer().references(RolesTable, #id, onDelete: KeyAction.cascade)();
  IntColumn get permissionId => integer().references(
    PermissionsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get createdAt =>
      text().clientDefault(() => DateTime.now().toUtc().toIso8601String())();
}

@DataClassName('TaxTableData')
@TableIndex(name: 'idx_taxes_name', columns: {#name})
class TaxesTable extends BaseTable {
  @override
  String get tableName => 'taxes';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text()();
  RealColumn get ratePercent => real()();
  BoolColumn get isDefaultAdd => boolean().withDefault(const Constant(false))();
}

@DataClassName('DiscountTableData')
@TableIndex(name: 'idx_discounts_name', columns: {#name})
class DiscountsTable extends BaseTable {
  @override
  String get tableName => 'discounts';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text()();
  RealColumn get value => real()();
  BoolColumn get isPercentage => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefaultAdd => boolean().withDefault(const Constant(false))();
}

@DataClassName('ExtraChargeTableData')
@TableIndex(name: 'idx_extra_charges_name', columns: {#name})
class ExtraChargesTable extends BaseTable {
  @override
  String get tableName => 'extra_charges';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text()();
  RealColumn get value => real()();
  BoolColumn get isPercentage => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefaultAdd => boolean().withDefault(const Constant(false))();
}

@DataClassName('PaymentMethodTableData')
@TableIndex(name: 'idx_payment_methods_name', columns: {#name})
class PaymentMethodsTable extends BaseTable {
  @override
  String get tableName => 'payment_methods';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hashId =>
      text().unique().clientDefault(() => const Uuid().v8())();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily => text().nullable()();
  TextColumn get iconFontPackage => text().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
}

