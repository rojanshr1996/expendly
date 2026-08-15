import 'package:equatable/equatable.dart';

class EventParticipant extends Equatable {
  final int id;
  final int eventId;
  final String name;
  final String? email;
  final bool isOwner;
  final int colorIndex;

  const EventParticipant({
    required this.id,
    required this.eventId,
    required this.name,
    this.email,
    required this.isOwner,
    required this.colorIndex,
  });

  @override
  List<Object?> get props => [id, eventId, name, email, isOwner, colorIndex];
}
