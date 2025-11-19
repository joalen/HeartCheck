import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;

typedef winSparkleInit = Void Function();
typedef winSparkleInitDart = void Function();

typedef winSparkleCheckUpdateWithUI = Void Function();
typedef winSparkleCheckUpdateWithUIDart = void Function();

class WindowsUpdater {
  static final DynamicLibrary _lib = Platform.isWindows
      ? DynamicLibrary.open(path.join(Directory.current.path, 'build\\windows\\x64\\runner\\WinSparkle.dll'))
      : throw UnsupportedError("Updates only supported on Windows");

  static final winSparkleInitDart _init =
      _lib.lookup<NativeFunction<winSparkleInit>>('win_sparkle_init').asFunction();

  static final winSparkleCheckUpdateWithUIDart _checkUpdates =
      _lib.lookup<NativeFunction<winSparkleCheckUpdateWithUI>>(
          'win_sparkle_check_update_with_ui')
      .asFunction();

  static void initialize() {
    _init();
  }

  static void checkForUpdates() {
    _checkUpdates();
  }
}