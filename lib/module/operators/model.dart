import '../../common/common.dart';

class Operators {
  static List<OperatorDefinition> all = [];

  static void init(List<OperatorDefinition> metadata) {
    final Map<String, OperatorDefinition> engineMap = {
      for (var op in _rawDefinitions) op.name.toLowerCase(): op,
    };

    all = metadata.map((m) {
      final lowerName = m.name.toLowerCase();
      final engine = engineMap[lowerName];

      final defaultInputs = (engine != null && engine.defaultInputs.isNotEmpty)
          ? engine.defaultInputs
          : _getDefaultInputsFor(m.name);

      return m.copyWith(
        executor:
            engine?.executor ??
            (inputs) => inputs.isNotEmpty ? inputs.first : const MarbleStream(),
        defaultInputs: defaultInputs,
      );
    }).toList();
  }

  static List<MarbleStream> _getDefaultInputsFor(String name) {
    final lowerName = name.toLowerCase();

    if (const {
      'merge',
      'zip',
      'combinelatest',
      'concat',
      'withlatestfrom',
      'amb',
      'sequenceequal',
      'skipuntil',
      'takeuntil',
      'race',
    }.contains(lowerName)) {
      return [
        MarbleStream.withTimes([
          const MapEntry(1, 0.2),
          const MapEntry(2, 0.4),
          const MapEntry(3, 0.6),
        ], label: 'Stream A'),
        MarbleStream.withTimes([
          const MapEntry('A', 0.3),
          const MapEntry('B', 0.5),
          const MapEntry('C', 0.7),
        ], label: 'Stream B'),
      ];
    }

    return [
      MarbleStream.fromValues([1, 2, 3, 4, 5], label: 'Input'),
    ];
  }

  static List<OperatorDefinition> get _rawDefinitions => [
    ...creation,
    ...transformation,
    ...filtering,
    ...combination,
    ...errorHandling,
    ...utility,
    ...conditional,
    ...aggregate,
    ...connectable,
    ...conversion,
  ];

  static List<OperatorDefinition> byCategory(OperatorCategory category) {
    return all.where((op) => op.category == category).toList();
  }

  static List<OperatorDefinition> search(String query) {
    final lowercaseQuery = query.toLowerCase();
    return all
        .where(
          (op) =>
              op.name.toLowerCase().contains(lowercaseQuery) ||
              op.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  static List<OperatorDefinition> get essential {
    const essentialNames = {
      'map',
      'filter',
      'debounce',
      'throttle',
      'take',
      'skip',
      'distinct',
      'merge',
      'concat',
      'combinelatest',
      'zip',
      'startwith',
      'tap',
      'delay',
      'catcherror',
      'retry',
    };
    return all
        .where((op) => essentialNames.contains(op.name.toLowerCase()))
        .toList();
  }

  static final List<OperatorDefinition> creation = [
    OperatorDefinition(
      name: 'create',
      executor: (inputs) => MarbleStream.fromValues([1, 2, 3]),
    ),
    OperatorDefinition(
      name: 'defer',
      executor: (inputs) => MarbleStream.fromValues(['A', 'B']),
    ),
    OperatorDefinition(
      name: 'empty',
      executor: (inputs) => const MarbleStream(items: [], isComplete: true),
    ),
    OperatorDefinition(
      name: 'never',
      executor: (inputs) => const MarbleStream(items: [], isComplete: false),
    ),
    OperatorDefinition(
      name: 'throw',
      executor: (inputs) =>
          const MarbleStream(items: [], isComplete: false, hasError: true),
    ),
    OperatorDefinition(
      name: 'from',
      executor: (inputs) => MarbleStream.fromValues([1, 2, 3, 4, 5]),
    ),
    OperatorDefinition(
      name: 'interval',
      executor: (inputs) =>
          MarbleStream.fromValues([0, 1, 2, 3, 4], label: '1s'),
    ),
    OperatorDefinition(
      name: 'just',
      executor: (inputs) => MarbleStream(
        items: [const MarbleItem(value: 42, time: 0.5)],
        isComplete: true,
      ),
    ),
    OperatorDefinition(
      name: 'range',
      executor: (inputs) => MarbleStream.fromValues([1, 2, 3, 4, 5]),
    ),
    OperatorDefinition(
      name: 'repeat',
      executor: (inputs) => MarbleStream.fromValues([1, 1, 1]),
    ),
    OperatorDefinition(
      name: 'start',
      executor: (inputs) =>
          MarbleStream(items: [const MarbleItem(value: 'GO', time: 0.1)]),
    ),
    OperatorDefinition(
      name: 'timer',
      executor: (inputs) => MarbleStream(
        items: [const MarbleItem(value: 0, time: 0.7)],
        isComplete: true,
      ),
    ),
  ];

  static final List<OperatorDefinition> transformation = [
    OperatorDefinition(
      name: 'buffer',
      executor: (inputs) {
        final input = inputs.first;
        final items = input.sortedItems;
        final buffered = <MarbleItem>[];
        for (int i = 0; i < items.length; i += 3) {
          final chunk = items.skip(i).take(3).toList();
          if (chunk.isNotEmpty) {
            buffered.add(
              MarbleItem(
                value: '[${chunk.map((m) => m.value).join(",")}]',
                time: chunk.last.time,
              ),
            );
          }
        }
        return MarbleStream(items: buffered, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'flatMap',
      executor: (inputs) {
        final input = inputs.first;
        final items = <MarbleItem>[];
        for (final m in input.items) {
          final val = m.value;
          items.add(m.copyWith(value: '${val}a', time: m.time));
          items.add(m.copyWith(value: '${val}b', time: m.time + 0.05));
        }
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'groupBy',
      executor: (inputs) {
        final items = inputs.first.items;
        final evens = items
            .where((m) => m.value is int && m.value % 2 == 0)
            .map((m) => m.value)
            .toList();
        final odds = items
            .where((m) => m.value is int && m.value % 2 != 0)
            .map((m) => m.value)
            .toList();
        return MarbleStream(
          items: [
            if (evens.isNotEmpty) MarbleItem(value: 'Even: $evens', time: 0.4),
            if (odds.isNotEmpty) MarbleItem(value: 'Odd: $odds', time: 0.8),
          ],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'map',
      executor: (inputs) {
        final input = inputs.first;
        final mapped = input.items.map((m) {
          if (m.value is int) {
            return m.copyWith(value: (m.value as int) * 10);
          }
          return m.copyWith(value: '${m.value}*');
        }).toList();
        return input.copyWith(items: mapped);
      },
    ),
    OperatorDefinition(
      name: 'scan',
      executor: (inputs) {
        final input = inputs.first;
        dynamic acc;
        final scanned = input.items.map((m) {
          if (acc == null) {
            acc = m.value;
          } else if (m.value is int && acc is int) {
            acc = (acc as int) + (m.value as int);
          } else {
            acc = '$acc${m.value}';
          }
          return m.copyWith(value: acc);
        }).toList();
        return input.copyWith(items: scanned);
      },
    ),
    OperatorDefinition(
      name: 'window',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        final windowed = <MarbleItem>[];
        for (int i = 0; i < items.length; i += 2) {
          final chunk = items.skip(i).take(2).toList();
          windowed.add(
            MarbleItem(
              value: 'Obs(${chunk.map((m) => m.value).join(",")})',
              time: items[i].time,
            ),
          );
        }
        return MarbleStream(items: windowed, isComplete: true);
      },
    ),
  ];

  static final List<OperatorDefinition> filtering = [
    OperatorDefinition(
      name: 'debounce',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        final result = <MarbleItem>[];
        for (int i = 0; i < items.length; i++) {
          if (i == items.length - 1 ||
              items[i + 1].time > items[i].time + 0.2) {
            result.add(items[i].copyWith(time: items[i].time + 0.1));
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'distinct',
      executor: (inputs) {
        final result = <MarbleItem>[];
        final seen = <dynamic>{};
        for (final m in inputs.first.items) {
          if (seen.add(m.value)) {
            result.add(m);
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'elementAt',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        if (items.length > 2) {
          return MarbleStream(items: [items[2].copyWith(time: 0.5)]);
        }
        return const MarbleStream(isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'filter',
      executor: (inputs) {
        final filtered = inputs.first.items.where((m) {
          if (m.value is int) return m.value > 2;
          return true;
        }).toList();
        return inputs.first.copyWith(items: filtered);
      },
    ),
    OperatorDefinition(
      name: 'first',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        if (items.isEmpty) return const MarbleStream(isComplete: true);
        return MarbleStream(items: [items.first.copyWith(time: 0.3)]);
      },
    ),
    OperatorDefinition(
      name: 'ignoreElements',
      executor: (inputs) => const MarbleStream(items: [], isComplete: true),
    ),
    OperatorDefinition(
      name: 'last',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        if (items.isEmpty) return const MarbleStream(isComplete: true);
        return MarbleStream(items: [items.last.copyWith(time: 0.7)]);
      },
    ),
    OperatorDefinition(
      name: 'sample',
      executor: (inputs) {
        final source = inputs.first.sortedItems;
        final result = <MarbleItem>[];
        for (double t in [0.3, 0.6, 0.9]) {
          final last = source.where((m) => m.time <= t).toList();
          if (last.isNotEmpty) {
            result.add(last.last.copyWith(time: t));
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'skip',
      executor: (inputs) =>
          MarbleStream(items: inputs.first.sortedItems.skip(2).toList()),
    ),
    OperatorDefinition(
      name: 'skipLast',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        if (items.length <= 1) return const MarbleStream(isComplete: true);
        return MarbleStream(items: items.take(items.length - 1).toList());
      },
    ),
    OperatorDefinition(
      name: 'take',
      executor: (inputs) =>
          MarbleStream(items: inputs.first.sortedItems.take(2).toList()),
    ),
    OperatorDefinition(
      name: 'takeLast',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        return MarbleStream(items: items.skip(items.length - 2).toList());
      },
    ),
  ];

  static final List<OperatorDefinition> combination = [
    OperatorDefinition(name: 'and', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'then', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'when', executor: (inputs) => inputs.first),
    OperatorDefinition(
      name: 'combineLatest',
      executor: (inputs) {
        if (inputs.length < 2) return inputs.first;
        final s1 = inputs[0].sortedItems;
        final s2 = inputs[1].sortedItems;
        final result = <MarbleItem>[];
        dynamic v1, v2;
        int i = 0, j = 0;
        while (i < s1.length || j < s2.length) {
          if (i < s1.length && (j == s2.length || s1[i].time < s2[j].time)) {
            v1 = s1[i].value;
            if (v2 != null) {
              result.add(MarbleItem(value: '$v1$v2', time: s1[i].time));
            }
            i++;
          } else {
            v2 = s2[j].value;
            if (v1 != null) {
              result.add(MarbleItem(value: '$v1$v2', time: s2[j].time));
            }
            j++;
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'concat',
      executor: (inputs) {
        final result = <MarbleItem>[];
        double offset = 0;
        for (final s in inputs) {
          result.addAll(
            s.sortedItems.map((m) => m.copyWith(time: offset + (m.time * 0.4))),
          );
          offset += 0.5;
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'join',
      executor: (inputs) {
        final result = <MarbleItem>[];
        if (inputs.length < 2) return inputs.first;
        for (final m1 in inputs[0].items) {
          for (final m2 in inputs[1].items) {
            if ((m1.time - m2.time).abs() < 0.2) {
              result.add(
                MarbleItem(
                  value: '${m1.value}${m2.value}',
                  time: (m1.time + m2.time) / 2,
                ),
              );
            }
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'merge',
      executor: (inputs) {
        if (inputs.isEmpty) return const MarbleStream();
        final merged = inputs.expand((s) => s.items).toList()
          ..sort((a, b) => a.time.compareTo(b.time));
        return MarbleStream(items: merged, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'startWith',
      executor: (inputs) => MarbleStream(
        items: [
          const MarbleItem(value: 0, time: 0.1),
          ...inputs.first.items.map(
            (m) => m.copyWith(time: m.time * 0.8 + 0.2),
          ),
        ],
        isComplete: true,
      ),
    ),
    OperatorDefinition(
      name: 'switch',
      executor: (inputs) {
        if (inputs.isEmpty) return const MarbleStream();
        if (inputs.length < 2) return inputs.first;
        final result = <MarbleItem>[];
        result.addAll(inputs[0].items.where((m) => m.time < 0.4));
        result.addAll(inputs[1].items.where((m) => m.time >= 0.4));
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'zip',
      executor: (inputs) {
        if (inputs.length < 2) return inputs.first;
        final s1 = inputs[0].sortedItems;
        final s2 = inputs[1].sortedItems;
        final count = s1.length < s2.length ? s1.length : s2.length;
        return MarbleStream(
          items: List.generate(
            count,
            (i) => MarbleItem(
              value: '${s1[i].value}${s2[i].value}',
              time: s1[i].time > s2[i].time ? s1[i].time : s2[i].time,
            ),
          ),
          isComplete: true,
        );
      },
    ),
  ];

  static final List<OperatorDefinition> errorHandling = [
    OperatorDefinition(
      name: 'catch',
      executor: (inputs) {
        final items = inputs.first.items.where((m) => !m.isError).toList();
        if (inputs.first.hasError) {
          items.add(const MarbleItem(value: 'RECOVER', time: 0.8));
        }
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'retry',
      executor: (inputs) {
        if (!inputs.first.hasError) return inputs.first;
        final items = [...inputs.first.items.where((m) => !m.isError)];
        items.addAll(
          inputs.first.items
              .where((m) => !m.isError)
              .map((m) => m.copyWith(time: m.time + 0.4)),
        );
        return MarbleStream(items: items, isComplete: true);
      },
    ),
  ];

  static final List<OperatorDefinition> utility = [
    OperatorDefinition(
      name: 'delay',
      executor: (inputs) => inputs.first.copyWith(
        items: inputs.first.items
            .map((m) => m.copyWith(time: (m.time + 0.2).clamp(0, 0.95)))
            .toList(),
      ),
    ),
    OperatorDefinition(name: 'do', executor: (inputs) => inputs.first),
    OperatorDefinition(
      name: 'materialize',
      executor: (inputs) => MarbleStream(
        items:
            inputs.first.items
                .map((m) => m.copyWith(value: 'N(${m.value})'))
                .toList()
              ..add(const MarbleItem(value: 'C', time: 0.95)),
      ),
    ),
    OperatorDefinition(
      name: 'dematerialize',
      executor: (inputs) => MarbleStream(
        items: inputs.first.items
            .where((m) => m.value.toString().startsWith('N('))
            .map(
              (m) => m.copyWith(
                value: m.value.toString().substring(
                  2,
                  m.value.toString().length - 1,
                ),
              ),
            )
            .toList(),
      ),
    ),
    OperatorDefinition(name: 'observeOn', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'serialize', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'subscribe', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'subscribeOn', executor: (inputs) => inputs.first),
    OperatorDefinition(
      name: 'timeInterval',
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        final result = <MarbleItem>[];
        double last = 0;
        for (final m in items) {
          result.add(
            m.copyWith(value: 'Δ${((m.time - last) * 100).toInt()}ms'),
          );
          last = m.time;
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'timeout',
      executor: (inputs) {
        final items = inputs.first.items.where((m) => m.time < 0.4).toList();
        return MarbleStream(
          items: items,
          hasError: inputs.first.items.any((m) => m.time >= 0.4),
        );
      },
    ),
    OperatorDefinition(
      name: 'timestamp',
      executor: (inputs) => inputs.first.copyWith(
        items: inputs.first.items
            .map(
              (m) => m.copyWith(value: '${m.value}@${(m.time * 1000).toInt()}'),
            )
            .toList(),
      ),
    ),
    OperatorDefinition(name: 'using', executor: (inputs) => inputs.first),
  ];

  static final List<OperatorDefinition> conditional = [
    OperatorDefinition(
      name: 'all',
      executor: (inputs) => MarbleStream(
        items: [
          MarbleItem(
            value: inputs.first.items.every(
              (m) => m.value is int && m.value < 10,
            ),
            time: 0.9,
          ),
        ],
      ),
    ),
    OperatorDefinition(
      name: 'amb',
      executor: (inputs) {
        if (inputs.isEmpty) return const MarbleStream();
        return inputs.length > 1 ? inputs[0] : inputs.first;
      },
    ),
    OperatorDefinition(
      name: 'contains',
      executor: (inputs) => MarbleStream(
        items: [
          MarbleItem(
            value: inputs.first.items.any((m) => m.value == 3),
            time: 0.9,
          ),
        ],
      ),
    ),
    OperatorDefinition(
      name: 'defaultIfEmpty',
      executor: (inputs) => inputs.first.items.isEmpty
          ? const MarbleStream(items: [MarbleItem(value: 'DEFAULT', time: 0.5)])
          : inputs.first,
    ),
    OperatorDefinition(
      name: 'sequenceEqual',
      executor: (inputs) =>
          MarbleStream(items: [const MarbleItem(value: true, time: 0.9)]),
    ),
    OperatorDefinition(
      name: 'skipUntil',
      executor: (inputs) => MarbleStream(
        items: inputs.first.items.where((m) => m.time > 0.5).toList(),
      ),
    ),
    OperatorDefinition(
      name: 'skipWhile',
      executor: (inputs) => MarbleStream(
        items: inputs.first.items
            .where((m) => m.value is int && m.value > 2)
            .toList(),
      ),
    ),
    OperatorDefinition(
      name: 'takeUntil',
      executor: (inputs) => MarbleStream(
        items: inputs.first.items.where((m) => m.time < 0.5).toList(),
      ),
    ),
    OperatorDefinition(
      name: 'takeWhile',
      executor: (inputs) => MarbleStream(
        items: inputs.first.items
            .takeWhile((m) => m.value is int && m.value < 4)
            .toList(),
      ),
    ),
  ];

  static final List<OperatorDefinition> aggregate = [
    OperatorDefinition(
      name: 'average',
      executor: (inputs) {
        final vals = inputs.first.items
            .where((m) => m.value is num)
            .map((m) => m.value as num);
        return MarbleStream(
          items: [
            MarbleItem(
              value: vals.isEmpty
                  ? 0
                  : vals.reduce((a, b) => a + b) / vals.length,
              time: 0.9,
            ),
          ],
        );
      },
    ),
    OperatorDefinition(
      name: 'count',
      executor: (inputs) => MarbleStream(
        items: [MarbleItem(value: inputs.first.items.length, time: 0.9)],
      ),
    ),
    OperatorDefinition(
      name: 'max',
      executor: (inputs) {
        final vals = inputs.first.items
            .where((m) => m.value is num)
            .map((m) => m.value as num);
        return MarbleStream(
          items: [
            MarbleItem(
              value: vals.isEmpty ? 0 : vals.reduce((a, b) => a > b ? a : b),
              time: 0.9,
            ),
          ],
        );
      },
    ),
    OperatorDefinition(
      name: 'min',
      executor: (inputs) {
        final vals = inputs.first.items
            .where((m) => m.value is num)
            .map((m) => m.value as num);
        return MarbleStream(
          items: [
            MarbleItem(
              value: vals.isEmpty ? 0 : vals.reduce((a, b) => a < b ? a : b),
              time: 0.9,
            ),
          ],
        );
      },
    ),
    OperatorDefinition(
      name: 'reduce',
      executor: (inputs) {
        final vals = inputs.first.items
            .where((m) => m.value is int)
            .map((m) => m.value as int);
        return MarbleStream(
          items: [
            MarbleItem(
              value: vals.isEmpty ? 0 : vals.reduce((a, b) => a + b),
              time: 0.9,
            ),
          ],
        );
      },
    ),
    OperatorDefinition(
      name: 'sum',
      executor: (inputs) {
        final vals = inputs.first.items
            .where((m) => m.value is int)
            .map((m) => m.value as int);
        return MarbleStream(
          items: [
            MarbleItem(
              value: vals.isEmpty ? 0 : vals.reduce((a, b) => a + b),
              time: 0.9,
            ),
          ],
        );
      },
    ),
  ];

  static final List<OperatorDefinition> connectable = [
    OperatorDefinition(name: 'connect', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'publish', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'refCount', executor: (inputs) => inputs.first),
    OperatorDefinition(name: 'replay', executor: (inputs) => inputs.first),
  ];

  static final List<OperatorDefinition> conversion = [
    OperatorDefinition(
      name: 'to',
      executor: (inputs) {
        if (inputs.isEmpty) return const MarbleStream();
        return MarbleStream(
          items: [
            MarbleItem(
              value: '[${inputs.first.items.map((m) => m.value).join(",")}]',
              time: 0.9,
            ),
          ],
        );
      },
    ),
  ];
}
