import 'dart:convert';

// ignore: implementation_imports
import 'package:parse_server_sdk/src/network/parse_websocket.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum RusSemLiveQueryState { Idle, Connecting, Connected }

class RusSemLiveQuery {
  RusSemLiveQuery(
      {bool? debug, ParseHTTPClient? client, bool? autoSendSessionId}) {
    _state = RusSemLiveQueryState.Idle;
    _client = client ??
        ParseHTTPClient(
            sendSessionId:
                autoSendSessionId ?? ParseCoreData().autoSendSessionId,
            securityContext: ParseCoreData().securityContext);

    _debug = isDebugEnabled(objectLevelDebug: debug);
    _sendSessionId = autoSendSessionId ?? ParseCoreData().autoSendSessionId;
  }

  late RusSemLiveQueryState _state;
  RusSemLiveQueryState get state => _state;
  int? get webSocketStatus => _webSocket?.readyState;

  WebSocket? _webSocket;
  late ParseHTTPClient _client;
  late bool _debug;
  late bool _sendSessionId;
  WebSocketChannel? _channel;
  Map<String, dynamic>? _connectMessage;
  Map<String, dynamic>? _subscribeMessage;
  Map<String, dynamic>? _unsubscribeMessage;
  Map<String, Function> eventCallbacks = <String, Function>{};
  int _requestIdCount = 1;
  final List<String> _liveQueryEvent = <String>[
    'create',
    'enter',
    'update',
    'leave',
    'delete',
    'error'
  ];
  final String _printConstLiveQuery = 'LiveQuery: ';

  int _requestIdGenerator() {
    return _requestIdCount++;
  }

  // ignore: always_specify_types
  Future subscribe(QueryBuilder query) async {
    _state = RusSemLiveQueryState.Connecting;
    String _liveQueryURL = _client.data.liveQueryURL!;
    if (_liveQueryURL.contains('https')) {
      _liveQueryURL = _liveQueryURL.replaceAll('https', 'wss');
    } else if (_liveQueryURL.contains('http')) {
      _liveQueryURL = _liveQueryURL.replaceAll('http', 'ws');
    }

    final String _className = query.object.parseClassName;
    final List<String>? keysToReturn = query.limiters['keys']?.split(',');
    query.limiters.clear(); //Remove limits in LiveQuery
    final String _where = query.buildQuery().replaceAll('where=', '');

    //Convert where condition to Map
    Map<String, dynamic> _whereMap = <String, dynamic>{};
    if (_where != '') {
      _whereMap = json.decode(_where);
    }

    final int requestId = _requestIdGenerator();

    try {
      _webSocket = await WebSocket.connect(_liveQueryURL);

      if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
        if (_debug) {
          print('$_printConstLiveQuery: Socket opened');
        }
      } else {
        if (_debug) {
          print('$_printConstLiveQuery: Error when connection client');
          return Future<void>.value(null);
        }
      }

      _channel = _webSocket!.createWebSocketChannel();
      // WebSocketChannel(_webSocket!);
      _channel!.stream.listen((dynamic message) {
        if (_debug) {
          print('$_printConstLiveQuery: Listen: $message');
        }

        final Map<String, dynamic> actionData = jsonDecode(message);

        if (eventCallbacks.containsKey(actionData['op'])) {
          if (actionData.containsKey('object')) {
            final Map<String, dynamic> map = actionData['object'];
            final String className = map['className'];
            if (className == '_User') {
              eventCallbacks[actionData['op']]!(
                  ParseUser(null, null, null).fromJson(map));
            } else {
              eventCallbacks[actionData['op']]!(
                  ParseObject(className).fromJson(map));
            }
          } else {
            eventCallbacks[actionData['op']]!(actionData);
          }
        }
      }, onDone: () {
        if (_debug) {
          print('$_printConstLiveQuery: Done');
        }
        _state = RusSemLiveQueryState.Idle;
      }, onError: (error) {
        if (_debug) {
          print(
              '$_printConstLiveQuery: Error: ${error.runtimeType.toString()}');
        }
        return Future<ParseResponse>.value(handleException(
            Exception(error), ParseApiRQ.liveQuery, _debug, _className));
      });

      //The connect message is sent from a client to the LiveQuery server.
      //It should be the first message sent from a client after the WebSocket connection is established.
      _connectMessage = <String, String>{
        'op': 'connect',
        'applicationId': _client.data.applicationId
      };
      if (_sendSessionId && _client.data.sessionId != null) {
        _connectMessage!['sessionToken'] = _client.data.sessionId;
      }

      if (_client.data.clientKey != null) {
        _connectMessage!['clientKey'] = _client.data.clientKey;
      }
      if (_client.data.masterKey != null) {
        _connectMessage!['masterKey'] = _client.data.masterKey;
      }

      if (_debug) {
        print('$_printConstLiveQuery: ConnectMessage: $_connectMessage');
      }
      _channel!.sink.add(jsonEncode(_connectMessage));

      //After a client connects to the LiveQuery server,
      //it can send a subscribe message to subscribe a ParseQuery.
      _subscribeMessage = <String, dynamic>{
        'op': 'subscribe',
        'requestId': requestId,
        'query': <String, dynamic>{
          'className': _className,
          'where': _whereMap,
          if (keysToReturn != null && keysToReturn.isNotEmpty)
            'fields': keysToReturn
        }
      };
      if (_sendSessionId && _client.data.sessionId != null) {
        _subscribeMessage!['sessionToken'] = _client.data.sessionId;
      }

      if (_debug) {
        print('$_printConstLiveQuery: SubscribeMessage: $_subscribeMessage');
      }

      _channel!.sink.add(jsonEncode(_subscribeMessage));

      //Mount message for Unsubscribe
      _unsubscribeMessage = <String, dynamic>{
        'op': 'unsubscribe',
        'requestId': requestId,
      };
      _state = RusSemLiveQueryState.Connected;
    } on Exception catch (e) {
      if (_debug) {
        print('$_printConstLiveQuery: Error: ${e.toString()}');
      }
      _state = RusSemLiveQueryState.Idle;
      return handleException(e, ParseApiRQ.liveQuery, _debug, _className);
    }
  }

  void on(LiveQueryEvent op, Function callback) {
    eventCallbacks[_liveQueryEvent[op.index]] = callback;
  }

  Future<void> unSubscribe() async {
    if (_channel != null) {
      if (_debug) {
        print(
            '$_printConstLiveQuery: UnsubscribeMessage: $_unsubscribeMessage');
      }
      _channel!.sink.add(jsonEncode(_unsubscribeMessage));
      await _channel!.sink.close();
    }
    if (_webSocket != null && _webSocket!.readyState == WebSocket.open) {
      if (_debug) {
        print('$_printConstLiveQuery: Socket closed');
      }
      await _webSocket!.close();
    }
  }
}
