class DukeTradeGateInput {
  final String symbol;
  final String proposedDecision;
  final double confidence;
  final double trendStrength;
  final double volatility;
  final double spreadQuality;
  final double structureQuality;
  final bool multiTimeframeAligned;

  const DukeTradeGateInput({
    required this.symbol,
    required this.proposedDecision,
    required this.confidence,
    required this.trendStrength,
    required this.volatility,
    required this.spreadQuality,
    required this.structureQuality,
    required this.multiTimeframeAligned,
  });
}

class DukeTradeGateResult {
  final String symbol;
  final String finalDecision;
  final bool tradeApproved;
  final double qualityScore;
  final List<String> reasons;

  const DukeTradeGateResult({
    required this.symbol,
    required this.finalDecision,
    required this.tradeApproved,
    required this.qualityScore,
    required this.reasons,
  });
}

class AgentDukeTradeGate {
  const AgentDukeTradeGate();

  DukeTradeGateResult evaluate(DukeTradeGateInput input) {
    final reasons = <String>[];

    final volatilityQuality =
        (100.0 - (input.volatility - 65.0).abs()).clamp(0.0, 100.0).toDouble();

    final qualityScore = ((input.confidence * 0.30) +
            (input.trendStrength.abs() * 0.18) +
            (input.spreadQuality * 0.12) +
            (input.structureQuality * 0.18) +
            (volatilityQuality * 0.10) +
            ((input.multiTimeframeAligned ? 100.0 : 55.0) * 0.12))
        .clamp(0.0, 100.0)
        .toDouble();

    if (input.proposedDecision == 'WAIT') {
      reasons.add('No directional setup is currently active.');
    }

    if (input.confidence < 52) {
      reasons.add('Combined confidence is still too weak.');
    }

    if (!input.multiTimeframeAligned) {
      reasons.add('Timeframe alignment is partial.');
    }

    if (input.trendStrength.abs() < 25) {
      reasons.add('Trend contribution is weak.');
    }

    if (input.structureQuality < 45) {
      reasons.add('Structure contribution is weak.');
    }

    if (input.spreadQuality < 35) {
      reasons.add('Execution quality is unacceptable.');
    }

    if (input.volatility > 95) {
      reasons.add('Volatility is abnormally high.');
    }

    if (qualityScore < 56) {
      reasons.add('Combined quality score is below baseline.');
    }

    final approved = input.proposedDecision != 'WAIT' &&
        input.confidence >= 52 &&
        input.spreadQuality >= 35 &&
        input.volatility <= 95 &&
        qualityScore >= 56;

    return DukeTradeGateResult(
      symbol: input.symbol,
      finalDecision: approved ? input.proposedDecision : 'WAIT',
      tradeApproved: approved,
      qualityScore: qualityScore,
      reasons: reasons,
    );
  }
}
