enum PlaygroundEventType { next, error, complete }

class PlaygroundStreamEvent {
  final String value;
  final DateTime time;
  final PlaygroundEventType type;

  PlaygroundStreamEvent({
    required this.value,
    required this.time,
    required this.type,
  });
}
