class DukeTimeframeInput {
  final String timeframe;
  final double trend;
  final double momentum;
  final double structure;
  final double volatility;

  const DukeTimeframeInput({
    required this.timeframe,
    required this.trend,
    required this.momentum,
    required this.structure,
    required this.volatility,
  });

  double get score =>
      (trend * 0.35) +
      (momentum * 0.30) +
      (structure * 0.25) +
      (volatility * 0.10);
}

class DukeMultiTimeframeResult {
  final String symbol;
  final String decision;
  final double confidence;
  final double oneMinuteScore;
  final double fiveMinuteScore;
  final double fifteenMinuteScore;
  final int bullishTimeframes;
  final int bearishTimeframes;
  final String explanation;

  const DukeMultiTimeframeResult({
    required this.symbol,
    required this.decision,
    required this.confidence,
    required this.oneMinuteScore,
    required this.fiveMinuteScore,
    required this.fifteenMinuteScore,
    required this.bullishTimeframes,
    required this.bearishTimeframes,
    required this.explanation,
  });
}

class AgentDukeMultiTimeframe {
  const AgentDukeMultiTimeframe();

  DukeMultiTimeframeResult analyze({
    required String symbol,
    required DukeTimeframeInput oneMinute,
    required DukeTimeframeInput fiveMinute,
    required DukeTimeframeInput fifteenMinute,
  }) {
    final s1 = oneMinute.score;
    final s5 = fiveMinute.score;
    final s15 = fifteenMinute.score;

    final scores = [s1, s5, s15];

    final bullish = scores.where((score) => score >= 28).length;
    final bearish = scores.where((score) => score <= -28).length;

    final weightedScore = (s1 * 0.50) + (s5 * 0.30) + (s15 * 0.20);

    final strongM1Bull = s1 >= 50 && s5 >= 20;
    final strongM1Bear = s1 <= -50 && s5 <= -20;

    String decision = 'WAIT';

    if (weightedScore >= 38 && (bullish >= 2 || strongM1Bull)) {
      decision = 'BUY';
    } else if (weightedScore <= -38 && (bearish >= 2 || strongM1Bear)) {
      decision = 'SELL';
    }

    double alignmentBonus = 0;

    if (bullish == 3 || bearish == 3) {
      alignmentBonus = 10;
    } else if (bullish == 2 || bearish == 2) {
      alignmentBonus = 5;
    } else if (strongM1Bull || strongM1Bear) {
      alignmentBonus = 2;
    }

    final confidence =
        (weightedScore.abs() + alignmentBonus).clamp(0.0, 100.0).toDouble();

    return DukeMultiTimeframeResult(
      symbol: symbol,
      decision: decision,
      confidence: confidence,
      oneMinuteScore: s1,
      fiveMinuteScore: s5,
      fifteenMinuteScore: s15,
      bullishTimeframes: bullish,
      bearishTimeframes: bearish,
      explanation: 'Brain 3.0 M1-first analysis: '
          '1M ${s1.toStringAsFixed(1)}, '
          '5M ${s5.toStringAsFixed(1)}, '
          '15M ${s15.toStringAsFixed(1)}. '
          'Weighted score ${weightedScore.toStringAsFixed(1)}. '
          'Decision: $decision.',
    );
  }
}
