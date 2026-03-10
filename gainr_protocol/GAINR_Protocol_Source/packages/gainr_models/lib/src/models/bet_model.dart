import 'event_model.dart';

class Bet {
  final String id;
  final Event event;
  final String selection; // 'Home', 'Draw', 'Away'
  final String selectionName; // 'Lakers', 'Draw', 'Warriors'
  final double odd;
  final double stake;

  const Bet({
    required this.id,
    required this.event,
    required this.selection,
    required this.selectionName,
    required this.odd,
    this.stake = 0.0,
  });

  Bet copyWith({double? stake}) {
    return Bet(
      id: id,
      event: event,
      selection: selection,
      selectionName: selectionName,
      odd: odd,
      stake: stake ?? this.stake,
    );
  }

  double get potentialReturn => stake * odd;
}
