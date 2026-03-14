class Machine {
  final String id;
  final String machineId;
  final String hostel;
  final String? status;

  Machine({
    required this.id,
    required this.machineId,
    required this.hostel,
    this.status = 'available',
  });

  // Factory constructor to create from JSON
  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'] as String? ?? '',
      machineId: json['machineId'] as String? ?? 'Unknown',
      hostel: json['hostel'] as String? ?? 'Unknown Location',
      status: json['status'] as String? ?? 'available',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machineId': machineId,
      'hostel': hostel,
      'status': status,
    };
  }
}