import '../intelligence/adaptive_trading_brain.dart';
import 'agent_duke_adaptive_weights.dart';
import 'agent_duke_multitimeframe.dart';
import 'agent_duke_signal_memory.dart';
import 'agent_duke_trade_gate.dart';

class DukeMasterInput {
  final String symbol;
  final double currentPrice;
  final DukeTimeframeInput oneMinute;
  final DukeTimeframeInput fiveMinute;
  final DukeTimeframeInput fifteenMinute;
  final double spreadQuality;
  final double structureQuality;
  final double trendStrength;
  final double volatility;

  const DukeMasterInput({
    required this.symbol,
    required this.currentPrice,
    required this.oneMinute,
    required this.fiveMinute,
    required this.fifteenMinute,
    required this.spreadQuality,
    required this.structureQuality,
    required this.trendStrength,
    required this.volatility,
  });
}

class DukeMasterResult {
  final String symbol;
  final String decision;
  final double confidence;
  final double qualityScore;
  final bool tradeApproved;
  final String explanation;
  final DukeSignalRecord? signalRecord;

  const DukeMasterResult({
    required this.symbol,
    required this.decision,
    required this.confidence,
    required this.qualityScore,
    required this.tradeApproved,
    required this.explanation,
    required this.signalRecord,
  });
}

class AgentDukeMasterEngine {
  final AgentDukeMultiTimeframe multiTimeframe;
  final AgentDukeTradeGate tradeGate;
  final AgentDukeSignalMemory signalMemory;
  final DukeAdaptiveWeights adaptiveWeights;

  AgentDukeMasterEngine({
    AgentDukeMultiTimeframe? multiTimeframe,
    AgentDukeTradeGate? tradeGate,
    AgentDukeSignalMemory? signalMemory,
    DukeAdaptiveWeights? adaptiveWeights,
  })  : multiTimeframe = multiTimeframe ?? const AgentDukeMultiTimeframe(),
        tradeGate = tradeGate ?? const AgentDukeTradeGate(),
        signalMemory = signalMemory ?? AgentDukeSignalMemory(),
        adaptiveWeights = adaptiveWeights ?? DukeAdaptiveWeights();

  DukeMasterResult analyze(DukeMasterInput input) {
    final timeframeResult = multiTimeframe.analyze(
      symbol: input.symbol,
      oneMinute: input.oneMinute,
      fiveMinute: input.fiveMinute,
      fifteenMinute: input.fifteenMinute,
    );

    final aligned = timeframeResult.bullishTimeframes >= 2 ||
        timeframeResult.bearishTimeframes >= 2;

    final gateResult = tradeGate.evaluate(
      DukeTradeGateInput(
        symbol: input.symbol,
        proposedDecision: timeframeResult.decision,
        confidence: timeframeResult.confidence,
        trendStrength: input.trendStrength,
        volatility: input.volatility,
        spreadQuality: input.spreadQuality,
        structureQuality: input.structureQuality,
        multiTimeframeAligned: aligned,
      ),
    );

    double conflictScore;
    if (timeframeResult.bullishTimeframes == 3 ||
        timeframeResult.bearishTimeframes == 3) {
      conflictScore = 8;
    } else if (aligned) {
      conflictScore = 22;
    } else {
      conflictScore = 55;
    }

    final performance = signalMemory.performance();

    final historicalEdge = performance.closedSignals >= 10
        ? performance.winRate.clamp(25.0, 85.0).toDouble()
        : 50.0;

    final learningAdjustment = performance.closedSignals >= 10
        ? ((performance.winRate - 50.0) * 0.10).clamp(-5.0, 5.0).toDouble()
        : 0.0;

    final adaptiveDecision = AdaptiveTradingBrain.evaluate(
      confidence: timeframeResult.confidence,
      trend: input.trendStrength.abs(),
      momentum: input.oneMinute.momentum.abs(),
      structure: input.structureQuality,
      volatility: input.volatility,
      timeframeAlignment: aligned ? 92.0 : 58.0,
      historicalEdge: historicalEdge,
      conflict: conflictScore,
      learningAdjustment: learningAdjustment,
    );

    final finalApproved =
        gateResult.tradeApproved && adaptiveDecision.qualified;

    final finalDecision = finalApproved ? gateResult.finalDecision : 'WAIT';

    DukeSignalRecord? record;

    if (finalApproved) {
      record = signalMemory.recordSignal(
        symbol: input.symbol,
        decision: finalDecision,
        confidence: adaptiveDecision.adaptiveScore,
        entryPrice: input.currentPrice,
      );
    }

    final explanation = finalApproved
        ? '999 Trading AI Brain 3.0 approved $finalDecision on '
            '${input.symbol}. Tier ${adaptiveDecision.tier}. '
            'Adaptive score ${adaptiveDecision.adaptiveScore.toStringAsFixed(1)}.'
        : '999 Trading AI Brain 3.0 placed ${input.symbol} on WAIT. '
            'Tier ${adaptiveDecision.tier}. '
            'Adaptive score ${adaptiveDecision.adaptiveScore.toStringAsFixed(1)}.';

    return DukeMasterResult(
      symbol: input.symbol,
      decision: finalDecision,
      confidence: timeframeResult.confidence,
      qualityScore: adaptiveDecision.adaptiveScore,
      tradeApproved: finalApproved,
      explanation: explanation,
      signalRecord: record,
    );
  }

  DukeSignalRecord? closeSignal({
    required String id,
    required double exitPrice,
  }) {
    return signalMemory.closeSignal(
      id: id,
      exitPrice: exitPrice,
    );
  }

  DukePerformanceSummary performance() {
    return signalMemory.performance();
  }

  Map<String, double> learningWeights() {
    return adaptiveWeights.snapshot();
  }
}
