enum RelayHealth {
  connected,
  connectedNoData,
  disconnected,
  error;

  bool canConnect() =>
      this == RelayHealth.connected || this == RelayHealth.connectedNoData;

  RelayStatus toStatus() {
    return switch (this) {
      RelayHealth.connected => RelayStatus.connected,
      RelayHealth.connectedNoData => RelayStatus.warning,
      RelayHealth.disconnected => RelayStatus.disconnected,
      RelayHealth.error => RelayStatus.disconnected,
    };
  }
}

enum RelayStatus { connected, warning, disconnected }
