import '../../common/common.dart';

class Operators {
  static List<OperatorDefinition> all = [];

  static void init(List<OperatorDefinition> metadata) {
    final Map<String, OperatorDefinition> engineMap = {
      for (var op in _rawDefinitions) op.name: op,
    };

    all = metadata.map((m) {
      final engine = engineMap[m.name];
      return m.copyWith(
        executor: engine?.executor ?? (inputs) => inputs.first,
        defaultInputs:
            engine?.defaultInputs ??
            [const MarbleStream(items: [], isComplete: false)],
      );
    }).toList();
  }

  static List<OperatorDefinition> get _rawDefinitions => [
    ...creation,
    ...transformation,
    ...filtering,
    ...combination,
    ...errorHandling,
    ...utility,
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
      'debounceTime',
      'throttleTime',
      'take',
      'skip',
      'distinctUntilChanged',
      'merge',
      'concat',
      'combineLatest',
      'zip',
      'startWith',
      'tap',
      'delay',
      'catchError',
      'retry',
    };
    return all.where((op) => essentialNames.contains(op.name)).toList();
  }

  static final List<OperatorDefinition> creation = [
    OperatorDefinition(
      name: 'just',
      executor: (inputs) => MarbleStream(
        items: [MarbleItem(value: 42, time: 0.5)],
        isComplete: true,
      ),
    ),
    OperatorDefinition(
      name: 'from',
      executor: (inputs) => MarbleStream.fromValues([1, 2, 3, 4, 5]),
    ),
    OperatorDefinition(
      name: 'interval',
      executor: (inputs) => MarbleStream.fromValues([0, 1, 2, 3, 4, 5]),
    ),
    OperatorDefinition(
      name: 'timer',
      executor: (inputs) => MarbleStream(
        items: [MarbleItem(value: 0, time: 0.7)],
        isComplete: true,
      ),
    ),
    OperatorDefinition(
      name: 'range',
      executor: (inputs) {
        final items = List.generate(
          5,
          (i) => MarbleItem(value: i + 1, time: (i + 1) / 6),
        );
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'empty',
      executor: (inputs) => const MarbleStream(items: [], isComplete: true),
    ),
    OperatorDefinition(
      name: 'error',
      executor: (inputs) =>
          const MarbleStream(items: [], isComplete: true, hasError: true),
    ),
  ];

  static final List<OperatorDefinition> transformation = [
    OperatorDefinition(
      name: 'map',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final mapped = input.items
            .map((m) => m.copyWith(value: (m.value as int) * 10))
            .toList();
        return input.copyWith(items: mapped);
      },
    ),
    OperatorDefinition(
      name: 'scan',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        int accumulator = 0;
        final scanned = input.items.map((m) {
          accumulator += m.value as int;
          return m.copyWith(value: accumulator);
        }).toList();
        return input.copyWith(items: scanned);
      },
    ),
    OperatorDefinition(
      name: 'buffer',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 6]),
      ],
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
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = <MarbleItem>[];
        for (final m in input.items) {
          final val = m.value as int;
          items.add(m.copyWith(value: '${val}a', time: m.time));
          items.add(m.copyWith(value: '${val}b', time: m.time + 0.05));
        }
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'switchMap',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = <MarbleItem>[];
        for (int i = 0; i < input.items.length; i++) {
          final m = input.items[i];
          final val = m.value as int;
          items.add(m.copyWith(value: '${val}a', time: m.time));

          if (i == input.items.length - 1 ||
              input.items[i + 1].time > m.time + 0.1) {
            items.add(m.copyWith(value: '${val}b', time: m.time + 0.1));
          }
        }
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'groupBy',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 6]),
      ],
      executor: (inputs) {
        final items = inputs.first.items;
        final evens = <dynamic>[];
        final odds = <dynamic>[];
        for (final m in items) {
          if ((m.value as int) % 2 == 0) {
            evens.add(m.value);
          } else {
            odds.add(m.value);
          }
        }
        return MarbleStream(
          items: [
            MarbleItem(value: 'Even: $evens', time: 0.5),
            MarbleItem(value: 'Odd: $odds', time: 0.8),
          ],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'window',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 6]),
      ],
      executor: (inputs) {
        final items = inputs.first.sortedItems;
        final windowed = <MarbleItem>[];
        for (int i = 0; i < items.length; i += 3) {
          final chunk = items.skip(i).take(3).toList();
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
    OperatorDefinition(
      name: 'reduce',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        int sumValue = 0;
        for (final m in input.items) {
          sumValue += m.value as int;
        }
        return MarbleStream(
          items: [MarbleItem(value: sumValue, time: 0.9)],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'count',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        return MarbleStream(
          items: [MarbleItem(value: inputs.first.items.length, time: 0.9)],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'sum',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4]),
      ],
      executor: (inputs) {
        final sumValue = inputs.first.items
            .map((m) => m.value as int)
            .fold(0, (a, b) => a + b);
        return MarbleStream(
          items: [MarbleItem(value: sumValue, time: 0.9)],
          isComplete: true,
        );
      },
    ),
  ];

  static final List<OperatorDefinition> filtering = [
    OperatorDefinition(
      name: 'filter',
      defaultInputs: [
        MarbleStream.fromValues([1, 10, 2, 20, 3, 30]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final filtered = input.items
            .where((m) => (m.value as int) > 5)
            .toList();
        return input.copyWith(items: filtered);
      },
    ),
    OperatorDefinition(
      name: 'take',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        return MarbleStream(items: input.sortedItems.take(3).toList());
      },
    ),
    OperatorDefinition(
      name: 'skip',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        return MarbleStream(items: input.sortedItems.skip(2).toList());
      },
    ),
    OperatorDefinition(
      name: 'distinct',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 2, 1, 3, 3, 2]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final result = <MarbleItem>[];
        dynamic lastVal;
        for (final m in input.sortedItems) {
          if (m.value != lastVal) {
            result.add(m);
            lastVal = m.value;
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'debounce',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.1),
          MapEntry(2, 0.15),
          MapEntry(3, 0.4),
          MapEntry(4, 0.7),
          MapEntry(5, 0.75),
        ]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.sortedItems;
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
      name: 'throttle',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.1),
          MapEntry(2, 0.15),
          MapEntry(3, 0.2),
          MapEntry(4, 0.5),
          MapEntry(5, 0.55),
        ]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.sortedItems;
        final result = <MarbleItem>[];
        double lastEmitTime = -1.0;
        for (final m in items) {
          if (m.time > lastEmitTime + 0.3) {
            result.add(m);
            lastEmitTime = m.time;
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'first',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        if (input.items.isEmpty) return const MarbleStream(isComplete: true);
        return MarbleStream(
          items: [input.sortedItems.first.copyWith(time: 0.2)],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'last',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        if (input.items.isEmpty) return const MarbleStream(isComplete: true);
        return MarbleStream(
          items: [input.sortedItems.last.copyWith(time: 0.9)],
          isComplete: true,
        );
      },
    ),
    OperatorDefinition(
      name: 'sample',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.1),
          MapEntry(2, 0.25),
          MapEntry(3, 0.45),
          MapEntry(4, 0.7),
          MapEntry(5, 0.9),
        ]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final result = <MarbleItem>[];

        for (double samplerTime in [0.3, 0.6, 0.9]) {
          final lastItemBefore =
              input.sortedItems.where((m) => m.time <= samplerTime).toList()
                ..sort((a, b) => b.time.compareTo(a.time));
          if (lastItemBefore.isNotEmpty) {
            result.add(lastItemBefore.first.copyWith(time: samplerTime));
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'takeUntil',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 6, 7]),
        MarbleStream.withTimes([MapEntry('STOP', 0.5)]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final stopAt = inputs.length > 1 && inputs[1].items.isNotEmpty
            ? inputs[1].items.first.time
            : 1.0;
        final taken = input.items.where((m) => m.time < stopAt).toList();
        return MarbleStream(items: taken, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'takeWhile',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 6, 7]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final taken = <MarbleItem>[];
        for (final m in input.sortedItems) {
          if ((m.value as int) <= 4) {
            taken.add(m);
          } else {
            break;
          }
        }
        return MarbleStream(items: taken, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'elementAt',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        if (input.items.length < 3) {
          return const MarbleStream(items: [], isComplete: true);
        }
        final element = input.sortedItems[2];
        return MarbleStream(items: [element], isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'skipWhile',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5, 2, 1]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        bool foundFalse = false;
        final result = input.sortedItems.where((m) {
          if (!foundFalse && (m.value as int) < 4) {
            return false;
          }
          foundFalse = true;
          return true;
        }).toList();
        return MarbleStream(items: result, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'ignoreElements',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4, 5]),
      ],
      executor: (inputs) => const MarbleStream(items: [], isComplete: true),
    ),
  ];

  static final List<OperatorDefinition> combination = [
    OperatorDefinition(
      name: 'merge',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.2),
          MapEntry(3, 0.5),
          MapEntry(5, 0.8),
        ]),
        MarbleStream.withTimes([MapEntry(2, 0.3), MapEntry(4, 0.6)]),
      ],
      executor: (inputs) {
        final merged = <MarbleItem>[];
        for (final stream in inputs) {
          merged.addAll(stream.items);
        }
        merged.sort((a, b) => a.time.compareTo(b.time));
        return MarbleStream(items: merged, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'combineLatest',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry('A', 0.1),
          MapEntry('B', 0.4),
          MapEntry('C', 0.7),
        ]),
        MarbleStream.withTimes([
          MapEntry(1, 0.2),
          MapEntry(2, 0.5),
          MapEntry(3, 0.8),
        ]),
      ],
      executor: (inputs) {
        if (inputs.length < 2) return inputs.first;
        final stream1 = inputs[0].sortedItems;
        final stream2 = inputs[1].sortedItems;

        final combined = <MarbleItem>[];
        dynamic lastVal1;
        dynamic lastVal2;

        int i = 0, j = 0;
        while (i < stream1.length || j < stream2.length) {
          if (i >= stream1.length) {
            lastVal2 = stream2[j].value;
            if (lastVal1 != null) {
              combined.add(
                MarbleItem(value: '$lastVal1$lastVal2', time: stream2[j].time),
              );
            }
            j++;
          } else if (j >= stream2.length) {
            lastVal1 = stream1[i].value;
            if (lastVal2 != null) {
              combined.add(
                MarbleItem(value: '$lastVal1$lastVal2', time: stream1[i].time),
              );
            }
            i++;
          } else if (stream1[i].time <= stream2[j].time) {
            lastVal1 = stream1[i].value;
            if (lastVal2 != null) {
              combined.add(
                MarbleItem(value: '$lastVal1$lastVal2', time: stream1[i].time),
              );
            }
            i++;
          } else {
            lastVal2 = stream2[j].value;
            if (lastVal1 != null) {
              combined.add(
                MarbleItem(value: '$lastVal1$lastVal2', time: stream2[j].time),
              );
            }
            j++;
          }
        }
        return MarbleStream(items: combined, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'zip',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry('A', 0.1),
          MapEntry('B', 0.3),
          MapEntry('C', 0.6),
        ]),
        MarbleStream.withTimes([
          MapEntry(1, 0.2),
          MapEntry(2, 0.5),
          MapEntry(3, 0.9),
        ]),
      ],
      executor: (inputs) {
        if (inputs.length < 2) return inputs.first;
        final stream1 = inputs[0].sortedItems;
        final stream2 = inputs[1].sortedItems;
        final zipped = <MarbleItem>[];
        final length = stream1.length < stream2.length
            ? stream1.length
            : stream2.length;

        for (int i = 0; i < length; i++) {
          final time = stream1[i].time > stream2[i].time
              ? stream1[i].time
              : stream2[i].time;
          zipped.add(
            MarbleItem(
              value: '${stream1[i].value}${stream2[i].value}',
              time: time,
            ),
          );
        }
        return MarbleStream(items: zipped, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'concat',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.1),
          MapEntry(2, 0.2),
          MapEntry(3, 0.3),
        ]),
        MarbleStream.withTimes([MapEntry(4, 0.1), MapEntry(5, 0.2)]),
      ],
      executor: (inputs) {
        final concatenated = <MarbleItem>[];
        double offset = 0;
        for (final stream in inputs) {
          for (final item in stream.sortedItems) {
            concatenated.add(item.copyWith(time: offset + (item.time * 0.4)));
          }
          offset += 0.45;
        }
        return MarbleStream(items: concatenated, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'startWith',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = [
          MarbleItem(value: 0, time: 0.05),
          ...input.items.map((m) => m.copyWith(time: m.time * 0.8 + 0.15)),
        ];
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'withLatestFrom',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry('A', 0.3),
          MapEntry('B', 0.6),
          MapEntry('C', 0.9),
        ]),
        MarbleStream.withTimes([
          MapEntry(1, 0.1),
          MapEntry(2, 0.4),
          MapEntry(3, 0.7),
        ]),
      ],
      executor: (inputs) {
        if (inputs.length < 2) return inputs.first;
        final source = inputs[0].sortedItems;
        final other = inputs[1].sortedItems;
        final result = <MarbleItem>[];
        dynamic latestOther;
        int j = 0;
        for (final item in source) {
          while (j < other.length && other[j].time < item.time) {
            latestOther = other[j].value;
            j++;
          }
          if (latestOther != null) {
            result.add(
              MarbleItem(value: '${item.value}$latestOther', time: item.time),
            );
          }
        }
        return MarbleStream(items: result, isComplete: true);
      },
    ),
  ];

  static final List<OperatorDefinition> utility = [
    OperatorDefinition(
      name: 'delay',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3, 4]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final delayed = input.items
            .map((m) => m.copyWith(time: (m.time + 0.15).clamp(0.0, 0.95)))
            .toList();
        return input.copyWith(items: delayed);
      },
    ),
    OperatorDefinition(
      name: 'tap',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) => inputs.first,
    ),
    OperatorDefinition(
      name: 'materialize',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.items
            .map((m) => m.copyWith(value: 'N(${m.value})'))
            .toList();
        items.add(MarbleItem(value: 'C', time: 0.95));
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'timestamp',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.items
            .map(
              (m) => m.copyWith(value: '${m.value}@${(m.time * 100).toInt()}'),
            )
            .toList();
        return input.copyWith(items: items);
      },
    ),
    OperatorDefinition(
      name: 'share',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) => inputs.first,
    ),
    OperatorDefinition(
      name: 'shareReplay',
      defaultInputs: [
        MarbleStream.fromValues([1, 2, 3]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        return input.copyWith(
          items: input.items
              .map((m) => m.copyWith(value: '${m.value} (cached)'))
              .toList(),
        );
      },
    ),
  ];

  static final List<OperatorDefinition> errorHandling = [
    OperatorDefinition(
      name: 'catchError',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.2),
          MapEntry(2, 0.4),
          MapEntry('ERR', 0.6),
        ]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.items.where((m) => m.value != 'ERR').toList();
        items.add(MarbleItem(value: 0, time: 0.6));
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'retry',
      defaultInputs: [
        MarbleStream.withTimes([MapEntry(1, 0.3), MapEntry('X', 0.6)]),
      ],
      executor: (inputs) => MarbleStream.withTimes([
        MapEntry(1, 0.15),
        MapEntry('X', 0.3),
        MapEntry(1, 0.45),
        MapEntry(2, 0.6),
      ]),
    ),
    OperatorDefinition(
      name: 'onErrorReturn',
      defaultInputs: [
        MarbleStream.withTimes([
          MapEntry(1, 0.2),
          MapEntry(2, 0.4),
          MapEntry('ERR', 0.6),
        ]),
      ],
      executor: (inputs) {
        final input = inputs.first;
        final items = input.items.map((m) {
          if (m.value == 'ERR') {
            return m.copyWith(value: -1);
          }
          return m;
        }).toList();
        return MarbleStream(items: items, isComplete: true);
      },
    ),
    OperatorDefinition(
      name: 'retryWhen',
      defaultInputs: [
        MarbleStream.withTimes([MapEntry('X', 0.2)]),
      ],
      executor: (inputs) => MarbleStream.withTimes([
        MapEntry('X', 0.1),
        MapEntry('X', 0.3),
        MapEntry('X', 0.6),
        MapEntry(1, 0.9),
      ]),
    ),
  ];
}
