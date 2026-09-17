enum TrancheStatus { pending, processing, success, failed }

class Tranche {
  final String id;
  final double amount;
  final int order;
  TrancheStatus status;
  String? rrn;
  String? utr;
  DateTime? timestamp;
  String? error;
  String? sourceAccountId;
  int? latencyMs;

  Tranche({
    required this.id,
    required this.amount,
    required this.order,
    this.status = TrancheStatus.pending,
    this.rrn,
    this.utr,
    this.timestamp,
    this.error,
    this.sourceAccountId,
    this.latencyMs,
  });

  Tranche copyWith({
    TrancheStatus? status,
    String? rrn,
    String? utr,
    DateTime? timestamp,
    String? error,
    String? sourceAccountId,
    int? latencyMs,
  }) {
    return Tranche(
      id: id,
      amount: amount,
      order: order,
      status: status ?? this.status,
      rrn: rrn ?? this.rrn,
      utr: utr ?? this.utr,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}
