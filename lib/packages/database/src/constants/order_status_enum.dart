enum OrderItemStatus {
  pending('pending'),
  preparing('preparing'),
  ready('ready'),
  served('served'),
  cancelled('cancelled');

  final String value;
  const OrderItemStatus(this.value);

  static OrderItemStatus fromString(String? status) {
    if (status == null) return OrderItemStatus.pending;
    switch (status.toLowerCase()) {
      case 'preparing':
      case 'cooking':
      case 'inpreparation':
      case 'in_progress':
        return OrderItemStatus.preparing;
      case 'ready':
        return OrderItemStatus.ready;
      case 'served':
      case 'completed':
        return OrderItemStatus.served;
      case 'cancelled':
      case 'canceled':
        return OrderItemStatus.cancelled;
      case 'pending':
      case 'placed':
      default:
        return OrderItemStatus.pending;
    }
  }
}

enum OrderStatus {
  placed('placed'),
  inProgress('inProgress'),
  ready('ready'),
  served('served'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String? status) {
    if (status == null) return OrderStatus.placed;
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'ready':
        return OrderStatus.ready;
      case 'served':
        return OrderStatus.served;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'placed':
      default:
        return OrderStatus.placed;
    }
  }
}
