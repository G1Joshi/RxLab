import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/common.dart';
import 'playground.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.surfaceGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _SingleStreamTab(),
                  _ChainTab(),
                  _CombineStreamsTab(),
                  _SubjectsTab(),
                  LabScreen(showHeader: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 28,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RxLab Playground',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Experiment with reactive streams in real-time',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(text: 'Single'),
          Tab(text: 'Chain'),
          Tab(text: 'Combine'),
          Tab(text: 'Subjects'),
          Tab(text: 'Lab'),
        ],
      ),
    );
  }
}

class _SingleStreamTab extends StatefulWidget {
  const _SingleStreamTab();

  @override
  State<_SingleStreamTab> createState() => _SingleStreamTabState();
}

class _SingleStreamTabState extends State<_SingleStreamTab> {
  final _inputController = TextEditingController();
  final _subject = PublishSubject<String>();
  final _outputEvents = <PlaygroundStreamEvent>[];
  StreamSubscription? _subscription;

  String _selectedOperator = 'none';
  bool _isRunning = false;

  static const _operators = [
    (id: 'none', name: 'None', desc: 'Pass through'),
    (id: 'map_upper', name: 'map(upper)', desc: 'To uppercase'),
    (id: 'map_length', name: 'map(length)', desc: 'String length'),
    (id: 'filter_long', name: 'filter(>3)', desc: 'Length > 3'),
    (id: 'take_3', name: 'take(3)', desc: 'First 3 only'),
    (id: 'skip_2', name: 'skip(2)', desc: 'Skip first 2'),
    (id: 'distinct', name: 'distinct', desc: 'No duplicates'),
    (id: 'debounce', name: 'debounce', desc: 'Wait 500ms'),
    (id: 'throttle', name: 'throttle', desc: 'Rate limit 1s'),
    (id: 'delay', name: 'delay', desc: 'Delay 500ms'),
    (id: 'scan', name: 'scan', desc: 'Accumulate'),
    (
      id: 'distinct_until_changed',
      name: 'distinctUntilChanged',
      desc: 'No consecutive duplicates',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription?.cancel();

    Stream<dynamic> stream = _subject.stream;

    switch (_selectedOperator) {
      case 'map_upper':
        stream = stream.map((s) => s.toUpperCase());
      case 'map_length':
        stream = stream.map((s) => '${s.length} chars');
      case 'filter_long':
        stream = stream.where((s) => s.length > 3);
      case 'take_3':
        stream = stream.take(3);
      case 'skip_2':
        stream = stream.skip(2);
      case 'distinct':
        stream = stream.distinct();
      case 'debounce':
        stream = stream.debounceTime(const Duration(milliseconds: 500));
      case 'throttle':
        stream = stream.throttleTime(const Duration(seconds: 1));
      case 'delay':
        stream = stream.delay(const Duration(milliseconds: 500));
      case 'scan':
        stream = stream.scan((acc, val, _) => '$acc$val', '');
      case 'distinct_until_changed':
        stream = stream.distinct();
    }

    _subscription = stream.listen(
      (value) => _addEvent(value.toString(), PlaygroundEventType.next),
      onError: (e) => _addEvent(e.toString(), PlaygroundEventType.error),
      onDone: () => _addEvent('Complete', PlaygroundEventType.complete),
    );

    setState(() => _isRunning = true);
  }

  void _addEvent(String value, PlaygroundEventType type) {
    if (mounted) {
      setState(() {
        _outputEvents.add(
          PlaygroundStreamEvent(value: value, time: DateTime.now(), type: type),
        );
      });
    }
  }

  void _emit(String value) {
    if (value.isNotEmpty) {
      _subject.add(value);
      _inputController.clear();
    }
  }

  void _clearOutput() => setState(() => _outputEvents.clear());

  void _reset() {
    _outputEvents.clear();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subject.close();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOperatorSelector(),
          const SizedBox(height: 12),
          _buildInputSection(),
          const SizedBox(height: 12),
          Expanded(child: _buildOutputSection()),
        ],
      ),
    );
  }

  Widget _buildOperatorSelector() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, color: AppTheme.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Operator',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _operators.map((op) {
                  final isSelected = _selectedOperator == op.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedOperator = op.id);
                      _reset();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        op.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (_selectedOperator != 'none') ...[
          const SizedBox(height: 12),
          OperatorInfoCard(
            name: _operators.firstWhere((o) => o.id == _selectedOperator).name,
            description: _operators
                .firstWhere((o) => o.id == _selectedOperator)
                .desc,
            icon: Icons.functions,
          ),
        ],
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.input, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                'Emit Values',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isRunning ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isRunning ? 'Active' : 'Stopped',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...[
                  ' 1 ',
                  ' 2 ',
                  ' 3 ',
                  ' A ',
                  ' B ',
                  'Hi',
                  'Hello',
                  'World',
                ].map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => _emit(v.trim()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          v.trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _emit('${Random().nextInt(100)}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Random',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  onSubmitted: _emit,
                  decoration: InputDecoration(
                    hintText: 'Custom value...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _emit(_inputController.text),
                icon: const Icon(Icons.send, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection() {
    return PlaygroundTimeline(events: _outputEvents, onClear: _clearOutput);
  }
}

class _CombineStreamsTab extends StatefulWidget {
  const _CombineStreamsTab();

  @override
  State<_CombineStreamsTab> createState() => _CombineStreamsTabState();
}

class _CombineStreamsTabState extends State<_CombineStreamsTab> {
  final _subject1 = PublishSubject<String>();
  final _subject2 = PublishSubject<String>();
  final _outputEvents = <PlaygroundStreamEvent>[];
  StreamSubscription? _subscription;

  String _combineOperator = 'merge';

  static const _operators = [
    (id: 'merge', name: 'merge', desc: 'Interleave emissions'),
    (id: 'combineLatest', name: 'combineLatest', desc: 'Combine latest'),
    (id: 'zip', name: 'zip', desc: 'Pair by index'),
    (id: 'concat', name: 'concat', desc: 'Sequential'),
    (
      id: 'withLatestFrom',
      name: 'withLatestFrom',
      desc: 'Stream 1 with latest Stream 2',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _subscription?.cancel();
    _outputEvents.clear();

    Stream<dynamic> combined;
    switch (_combineOperator) {
      case 'merge':
        combined = Rx.merge([_subject1.stream, _subject2.stream]);
      case 'combineLatest':
        combined = Rx.combineLatest2(
          _subject1.stream,
          _subject2.stream,
          (a, b) => '$a+$b',
        );
      case 'zip':
        combined = Rx.zip2(
          _subject1.stream,
          _subject2.stream,
          (a, b) => '($a,$b)',
        );
      case 'concat':
        combined = _subject1.stream.concatWith([_subject2.stream]);
      case 'withLatestFrom':
        combined = _subject1.stream.withLatestFrom(
          _subject2.stream,
          (a, b) => '$a ($b)',
        );
      default:
        combined = Rx.merge([_subject1.stream, _subject2.stream]);
    }

    _subscription = combined.listen(
      (val) => setState(
        () => _outputEvents.add(
          PlaygroundStreamEvent(
            value: val.toString(),
            time: DateTime.now(),
            type: PlaygroundEventType.next,
          ),
        ),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subject1.close();
    _subject2.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Combine Operator',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _operators.map((op) {
                    final isSelected = _combineOperator == op.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _combineOperator = op.id);
                        _setupStream();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          op.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StreamInputCard(
                  label: 'Stream 1',
                  color: Colors.blue,
                  onEmit: _subject1.add,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreamInputCard(
                  label: 'Stream 2',
                  color: Colors.orange,
                  onEmit: _subject2.add,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PlaygroundTimeline(
              events: _outputEvents,
              onClear: () => setState(() => _outputEvents.clear()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamInputCard extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<String> onEmit;

  const _StreamInputCard({
    required this.label,
    required this.color,
    required this.onEmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['A', 'B', 'C', '1', '2', '3']
                .map(
                  (v) => GestureDetector(
                    onTap: () => onEmit(v),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        v,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SubjectsTab extends StatefulWidget {
  const _SubjectsTab();

  @override
  State<_SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<_SubjectsTab> {
  String _subjectType = 'publish';
  final _events = <PlaygroundStreamEvent>[];

  Subject<String>? _subject;
  final _subscriptions = <String, StreamSubscription>{};
  int _subscriberCount = 0;

  @override
  void initState() {
    super.initState();
    _createSubject();
  }

  void _createSubject() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _subscriberCount = 0;
    _events.clear();
    _subject?.close();

    switch (_subjectType) {
      case 'publish':
        _subject = PublishSubject<String>();
      case 'behavior':
        _subject = BehaviorSubject<String>.seeded('Initial');
      case 'replay':
        _subject = ReplaySubject<String>(maxSize: 3);
    }
    setState(() {});
  }

  void _addSubscriber() {
    _subscriberCount++;
    final name = 'Sub $_subscriberCount';
    final sub = _subject!.stream.listen((v) {
      setState(
        () => _events.add(
          PlaygroundStreamEvent(
            value: '[$name] $v',
            time: DateTime.now(),
            type: PlaygroundEventType.next,
          ),
        ),
      );
    });
    _subscriptions[name] = sub;

    if (_subjectType == 'behavior') {
      _events.add(
        PlaygroundStreamEvent(
          value: '[$name joined, got: ${(_subject as BehaviorSubject).value}]',
          time: DateTime.now(),
          type: PlaygroundEventType.next,
        ),
      );
    }
    setState(() {});
  }

  void _emit(String value) => _subject?.add(value);

  @override
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subject?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject Type',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _SubjectBtn(
                      name: 'Publish',
                      desc: 'No replay',
                      isSelected: _subjectType == 'publish',
                      onTap: () {
                        setState(() => _subjectType = 'publish');
                        _createSubject();
                      },
                    ),
                    const SizedBox(width: 8),
                    _SubjectBtn(
                      name: 'Behavior',
                      desc: 'Replay latest',
                      isSelected: _subjectType == 'behavior',
                      onTap: () {
                        setState(() => _subjectType = 'behavior');
                        _createSubject();
                      },
                    ),
                    const SizedBox(width: 8),
                    _SubjectBtn(
                      name: 'Replay',
                      desc: 'Replay last 3',
                      isSelected: _subjectType == 'replay',
                      onTap: () {
                        setState(() => _subjectType = 'replay');
                        _createSubject();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addSubscriber,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: Text('Add Subscriber (${_subscriptions.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['1', '2', '3', 'A', 'B', 'C']
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () => _emit(v),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Emit $v'),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: PlaygroundTimeline(
              events: _events,
              onClear: () => setState(() => _events.clear()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBtn extends StatelessWidget {
  final String name, desc;
  final bool isSelected;
  final VoidCallback onTap;
  const _SubjectBtn({
    required this.name,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : AppTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChainTab extends StatefulWidget {
  const _ChainTab();

  @override
  State<_ChainTab> createState() => _ChainTabState();
}

class _ChainTabState extends State<_ChainTab> {
  final _subject = PublishSubject<String>();
  final _outputEvents = <PlaygroundStreamEvent>[];
  final _chain = <String>[];
  StreamSubscription? _subscription;

  static const _availableOps = [
    (id: 'map_upper', name: 'map(upper)', icon: Icons.text_format),
    (id: 'map_length', name: 'map(length)', icon: Icons.straighten),
    (id: 'filter_long', name: 'filter(>2)', icon: Icons.filter_alt),
    (id: 'distinct', name: 'distinct', icon: Icons.difference),
    (id: 'debounce', name: 'debounce', icon: Icons.timer),
    (id: 'take_5', name: 'take(5)', icon: Icons.looks_5),
    (id: 'skip_1', name: 'skip(1)', icon: Icons.skip_next),
    (id: 'delay', name: 'delay', icon: Icons.schedule),
    (id: 'scan', name: 'scan', icon: Icons.functions),
    (id: 'throttle', name: 'throttle', icon: Icons.speed),
  ];

  @override
  void initState() {
    super.initState();
    _rebuildStream();
  }

  void _rebuildStream() {
    _subscription?.cancel();
    _outputEvents.clear();

    Stream<dynamic> stream = _subject.stream;

    for (final op in _chain) {
      switch (op) {
        case 'map_upper':
          stream = stream.map((s) => s.toString().toUpperCase());
        case 'map_length':
          stream = stream.map((s) => '${s.toString().length}');
        case 'filter_long':
          stream = stream.where((s) => s.toString().length > 2);
        case 'distinct':
          stream = stream.distinct();
        case 'debounce':
          stream = stream.debounceTime(const Duration(milliseconds: 300));
        case 'take_5':
          stream = stream.take(5);
        case 'skip_1':
          stream = stream.skip(1);
        case 'delay':
          stream = stream.delay(const Duration(milliseconds: 300));
        case 'scan':
          stream = stream.scan((acc, val, _) => '$acc$val', '');
        case 'throttle':
          stream = stream.throttleTime(const Duration(seconds: 1));
      }
    }

    _subscription = stream.listen(
      (value) => setState(
        () => _outputEvents.add(
          PlaygroundStreamEvent(
            value: value.toString(),
            time: DateTime.now(),
            type: PlaygroundEventType.next,
          ),
        ),
      ),
      onError: (e) => setState(
        () => _outputEvents.add(
          PlaygroundStreamEvent(
            value: e.toString(),
            time: DateTime.now(),
            type: PlaygroundEventType.error,
          ),
        ),
      ),
    );
    setState(() {});
  }

  void _addOperator(String op) {
    HapticFeedback.lightImpact();
    setState(() => _chain.add(op));
    _rebuildStream();
  }

  void _removeOperator(int index) {
    HapticFeedback.lightImpact();
    setState(() => _chain.removeAt(index));
    _rebuildStream();
  }

  void _emit(String value) {
    _subject.add(value);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.glassDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_tree, color: AppTheme.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Build Pipeline',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_chain.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() => _chain.clear());
                          _rebuildStream();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _chain.isEmpty
                      ? Text(
                          'Tap operators below to build chain...',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'input',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            ..._chain.asMap().entries.expand(
                              (entry) => [
                                Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                                GestureDetector(
                                  onTap: () => _removeOperator(entry.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _availableOps
                                              .firstWhere(
                                                (o) => o.id == entry.value,
                                              )
                                              .name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white70,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            Text(
                              'output',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableOps
                      .map(
                        (op) => GestureDetector(
                          onTap: () => _addOperator(op.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withAlpha(60),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  op.icon,
                                  size: 14,
                                  color: AppTheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  op.name,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.add,
                                  size: 12,
                                  color: AppTheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['A', 'B', 'C', 'Hi', 'Hello', 'World', '1', '2', '3']
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => _emit(v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            v,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: PlaygroundTimeline(
              events: _outputEvents,
              onClear: () => setState(() => _outputEvents.clear()),
            ),
          ),
        ],
      ),
    );
  }
}
