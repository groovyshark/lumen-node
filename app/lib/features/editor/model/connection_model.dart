class ConnectionModel {
  const ConnectionModel(
    this.fromNodeId,
    this.fromPin,
    this.toNodeId,
    this.toPin,
  );

  final String fromNodeId;
  final String fromPin;
  final String toNodeId;
  final String toPin;
}
