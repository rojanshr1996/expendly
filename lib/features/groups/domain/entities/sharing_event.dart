import 'package:equatable/equatable.dart';
import 'event_participant.dart';

class SharingEvent extends Equatable {
  final int id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String category;
  final String status;
  final DateTime createdAt;
  final List<EventParticipant> participants;
  final double totalSpent;
  final double userShare;

  const SharingEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.participants,
    required this.totalSpent,
    required this.userShare,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        startDate,
        endDate,
        category,
        status,
        createdAt,
        participants,
        totalSpent,
        userShare,
      ];
}
