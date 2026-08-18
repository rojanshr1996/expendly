import 'package:flutter/material.dart';

import '../../domain/entities/event_participant.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/entities/sharing_event.dart';
import 'balances_view.dart';

/// BalancesTabView widget for displaying participant settlements and balances.
class BalancesTabView extends StatelessWidget {
  final List<Settlement> settlements;
  final List<EventParticipant> participants;
  final SharingEvent event;

  const BalancesTabView({
    super.key,
    required this.settlements,
    required this.participants,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return BalancesView(
      settlements: settlements,
      participants: participants,
      event: event,
    );
  }
}
