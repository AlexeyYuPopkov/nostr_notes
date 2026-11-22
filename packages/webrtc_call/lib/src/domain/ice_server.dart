import 'package:equatable/equatable.dart';

/// One entry of `RTCConfiguration.iceServers`.
final class IceServer extends Equatable {
  final List<String> urls;
  final String? username;
  final String? credential;

  const IceServer({required this.urls, this.username, this.credential});

  Map<String, Object> toConfiguration() => {
    'urls': urls,
    'username': ?username,
    'credential': ?credential,
  };

  @override
  List<Object?> get props => [urls, username, credential];
}
