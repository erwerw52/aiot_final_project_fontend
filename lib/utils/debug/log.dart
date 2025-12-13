import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

class Log {
  Log._();

  static final _levelPrefixes = {
    Level.FINEST: '👾',
    Level.FINER: '👀',
    Level.FINE: '🎾',
    Level.CONFIG: '🐶',
    Level.INFO: '👻',
    Level.WARNING: '⚠️',
    Level.SEVERE: '‼️',
    Level.SHOUT: '😡',
  };
  static Log? _instance;
  static Logger? _logger;

  static void _init() {
    _instance = Log._();
    _logger = Logger('');
    // memo: 需要看全部的 Log 就把這行註解打開
    // Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) async {
      await initializeDateFormatting("zh_TW", null);
      var matchTimeFormat = DateFormat("yyyy/MM/dd a hh:mm:ss", "zh_TW");
      var time = matchTimeFormat.format(record.time.toLocal());
      if (kDebugMode) {
        log("${_levelPrefixes[record.level] ?? ""}${record.level.name}: $time ${record.message}",
            time: record.time, level: record.level.value);
      }
    });
  }

  static Log get() {
    if (_instance == null) {
      _init();
    }
    return _instance!;
  }

  static Frame? _getCallerFrame() {
    const int level = 3;
    // Expensive
    final frames = Trace.current(level).frames;
    return frames.isEmpty ? null : frames.first;
  }

  void finest(String message) => _log(Level.FINEST, message);

  void finer(String message) => _log(Level.FINER, message);

  void fine(String message) => _log(Level.FINE, message);

  void config(String message) => _log(Level.CONFIG, message);

  void info(String message) => _log(Level.INFO, message);

  void warning(String message) => _log(Level.WARNING, message);

  void severe(String message) => _log(Level.SEVERE, message);

  void shout(String message) => _log(Level.SHOUT, message);

  void _log(Level level, String message) {
    if (kDebugMode) {
      _logger?.log(level, '${_getCallerFrame()}\n$message');
    } else {
      _logger?.log(level, message);
    }
  }
}

