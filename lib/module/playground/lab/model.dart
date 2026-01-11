import '../../../common/common.dart';

class ChainStep {
  final String id;
  final OperatorDefinition operator;
  final List<MarbleStream> inputs;

  ChainStep({required this.id, required this.operator, required this.inputs});

  MarbleStream get output => operator.execute(inputs);

  ChainStep copyWith({
    String? id,
    OperatorDefinition? operator,
    List<MarbleStream>? inputs,
  }) {
    return ChainStep(
      id: id ?? this.id,
      operator: operator ?? this.operator,
      inputs: inputs ?? this.inputs,
    );
  }
}

class StreamChain {
  final MarbleStream source;
  final List<ChainStep> steps;

  StreamChain({required this.source, this.steps = const []});

  List<MarbleStream> get allStreams {
    final results = <MarbleStream>[source];
    MarbleStream current = source;

    for (var step in steps) {
      final stepInputs = [current, ...step.inputs.skip(1)];
      current = step.operator.execute(stepInputs);
      results.add(current);
    }

    return results;
  }

  MarbleStream get finalOutput => allStreams.last;

  StreamChain addStep(OperatorDefinition op) {
    return StreamChain(
      source: source,
      steps: [
        ...steps,
        ChainStep(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operator: op,
          inputs: op.defaultInputs,
        ),
      ],
    );
  }

  StreamChain removeStep(int index) {
    final newSteps = List<ChainStep>.from(steps)..removeAt(index);
    return StreamChain(source: source, steps: newSteps);
  }
}
