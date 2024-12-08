import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidget.setAppGroupId('group.dev.rohanjsh.appWidgets');
  await HomeWidget.registerInteractivityCallback(backgroundCallback);
  runApp(const MainApp());
}

const _playingKey = 'isPlayig';

Future<bool> get _isPlayingValue async {
  final value = await HomeWidget.getWidgetData<bool>(
    _playingKey,
    defaultValue: false,
  );
  return value ?? false;
}

Future<void> _sendAndUpdate(bool isPlaying) async {
  await HomeWidget.saveWidgetData(_playingKey, isPlaying);
  await HomeWidget.updateWidget(
    androidName: 'MusicGlanceWidgetReceiver',
    iOSName: 'MusicGlanceWidget',
  );
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  await HomeWidget.setAppGroupId('group.dev.rohanjsh.appWidgets');

  if (uri?.host == 'toggleplay') {
    final isPlaying = await _isPlayingValue;
    // Toggle audio playback
    if (isPlaying) {
      await _MainAppState._player.pause();
    } else {
      await _MainAppState._player.play();
    }
    await _sendAndUpdate(!isPlaying);
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  static final AudioPlayer _player =
      AudioPlayer(); // Make static to access from callback
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _player.setAsset('assets/audio/sample_audio.mp3');
    _player.playerStateStream.listen((state) {
      _updateWidget(state.playing);
    });
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final playing = await _isPlayingValue;
    setState(() => _isPlaying = playing);
  }

  Future<void> _updateWidget(bool isPlaying) async {
    await _sendAndUpdate(isPlaying);
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      setState(() => _isPlaying = false);
      await _player.pause();
    } else {
      setState(() => _isPlaying = true);
      await _player.play();
    }
    await _updateWidget(_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F1F1F), Color(0xFF3B2349), Color(0xFF1F1F1F)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 64,
                  onPressed: togglePlayPause,
                ),
                const SizedBox(height: 16),
                Text(
                  _isPlaying ? 'Playing' : 'Paused',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadInitialState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }
}
