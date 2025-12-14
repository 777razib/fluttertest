import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Signaling {
  final String wsUrl; // e.g. ws://YOUR_SERVER:8080
  final String selfId; // e.g. "u1"
  WebSocketChannel? _channel;

  RTCPeerConnection? _pc;
  MediaStream? _localStream;

  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  String? _remoteId;
  final _uuid = const Uuid();

  Signaling({
    required this.wsUrl,
    required this.selfId,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  Future<void> connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // AUTH (server side: receive type: auth)
    _send({
      "v": 1,
      "type": "auth",
      "id": _uuid.v4(),
      "from": selfId,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "data": {"userId": selfId}
    });

    _channel!.stream.listen((event) async {
      final msg = jsonDecode(event as String) as Map<String, dynamic>;
      final type = msg["type"];

      if (type == "rtc_offer") {
        _remoteId = msg["from"];
        await _ensurePeerConnection(_remoteId!);
        final offer = msg["data"]["offer"];
        await _pc!.setRemoteDescription(
          RTCSessionDescription(offer["sdp"], offer["type"]),
        );
        final answer = await _pc!.createAnswer();
        await _pc!.setLocalDescription(answer);

        _send({
          "v": 1,
          "type": "rtc_answer",
          "id": _uuid.v4(),
          "from": selfId,
          "to": _remoteId,
          "ts": DateTime.now().millisecondsSinceEpoch,
          "data": {
            "answer": {"sdp": answer.sdp, "type": answer.type}
          }
        });
      }

      if (type == "rtc_answer") {
        final answer = msg["data"]["answer"];
        await _pc?.setRemoteDescription(
          RTCSessionDescription(answer["sdp"], answer["type"]),
        );
      }

      if (type == "rtc_ice") {
        final c = msg["data"]["candidate"];
        await _pc?.addCandidate(
          RTCIceCandidate(c["candidate"], c["sdpMid"], c["sdpMLineIndex"]),
        );
      }

      // CHAT examples
      // type: text / link / file_meta
      // handle them in UI by exposing a callback (add later)
    });
  }

  Future<void> _ensurePeerConnection(String remoteId) async {
    if (_pc != null) return;

    // STUN (TURN add in production)
    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _pc = await createPeerConnection(config);

    // Local media
    _localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": true,
    });

    localRenderer.srcObject = _localStream;

    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }

    _pc!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    _pc!.onIceCandidate = (RTCIceCandidate candidate) {
      _send({
        "v": 1,
        "type": "rtc_ice",
        "id": _uuid.v4(),
        "from": selfId,
        "to": remoteId,
        "ts": DateTime.now().millisecondsSinceEpoch,
        "data": {
          "candidate": {
            "candidate": candidate.candidate,
            "sdpMid": candidate.sdpMid,
            "sdpMLineIndex": candidate.sdpMLineIndex
          }
        }
      });
    };
  }

  Future<void> startCall(String remoteId) async {
    _remoteId = remoteId;
    await _ensurePeerConnection(remoteId);

    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);

    _send({
      "v": 1,
      "type": "rtc_offer",
      "id": _uuid.v4(),
      "from": selfId,
      "to": remoteId,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "data": {
        "offer": {"sdp": offer.sdp, "type": offer.type}
      }
    });
  }

  // Chat helpers
  void sendText(String to, String text) {
    _send({
      "v": 1,
      "type": "text",
      "id": _uuid.v4(),
      "from": selfId,
      "to": to,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "data": {"text": text}
    });
  }

  void sendLink(String to, String url) {
    _send({
      "v": 1,
      "type": "link",
      "id": _uuid.v4(),
      "from": selfId,
      "to": to,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "data": {"url": url}
    });
  }

  // For files in production: upload via HTTP -> then notify via WS
  void sendFileMeta(String to, {required String name, required String mime, required int size, required String url}) {
    _send({
      "v": 1,
      "type": "file_meta",
      "id": _uuid.v4(),
      "from": selfId,
      "to": to,
      "ts": DateTime.now().millisecondsSinceEpoch,
      "meta": {"name": name, "mime": mime, "size": size},
      "data": {"url": url}
    });
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> hangUp() async {
    await _localStream?.dispose();
    await _pc?.close();
    _pc = null;
    _localStream = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  Future<void> dispose() async {
    await hangUp();
    await _channel?.sink.close();
  }
}
