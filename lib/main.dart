import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

final AudioPlayer player = AudioPlayer();

void main() {
  runApp(const NaghomApp());
}

class NaghomApp extends StatefulWidget {
  const NaghomApp({super.key});

  @override
  State<NaghomApp> createState() => _NaghomAppState();
}

class _NaghomAppState extends State<NaghomApp> {
  int? currentIndex;
  bool isPlaying = false;

  final List<String> songs = [
    "song1.mp3",
    "song2.mp3",
    "song3.mp3",
    "song4.mp3",
    "song5.mp3",
    "song6.mp3",
    "song7.mp3",
  ];

  final List<String> songTitles = [
    "نغم القمر",
    "همس الحب",
    "حكاية روح",
    "أحلام الياسمين",
    "شموخ نجد",
    "سحر العيون",
    "ليالي الشوق",
  ];

  final List<Color> songColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFFFF8E53),
    const Color(0xFFFFD93D),
    const Color(0xFF6BCB77),
    const Color(0xFF4D96FF),
    const Color(0xFF9D65FF),
    const Color(0xFFFF6BCB),
  ];

  Future<void> playSong(int index) async {
    if (currentIndex == index && isPlaying) {
      await player.pause();
      setState(() => isPlaying = false);
      return;
    }

    await player.stop();
    await player.play(AssetSource('songs/${songs[index]}'));

    setState(() {
      currentIndex = index;
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A0B2E),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF4A2066)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 1.0, end: 1.1),
                        duration: const Duration(seconds: 2),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.pink, Colors.purple],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [
                                Colors.pink,
                                Colors.purple,
                                Colors.orange,
                              ],
                            ).createShader(bounds),
                        child: const Text(
                          "Naghom",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "♥ ♪ ألحان الروح ♪ ♥",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final active = currentIndex == index;
                      final songColor = songColors[index % songColors.length];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => playSong(index),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient:
                                    active && isPlaying
                                        ? LinearGradient(
                                          colors: [
                                            songColor,
                                            songColor.withValues(alpha: 0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                        : LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.1),
                                            Colors.white.withValues(
                                              alpha: 0.05,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      active && isPlaying
                                          ? songColor
                                          : Colors.white.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                                boxShadow:
                                    active && isPlaying
                                        ? [
                                          BoxShadow(
                                            color: songColor.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          songColor,
                                          songColor.withValues(alpha: 0.5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: songColor.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      active && isPlaying
                                          ? Icons.equalizer_rounded
                                          : Icons.music_note,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          songTitles[index],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                                active && isPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                            color:
                                                active && isPlaying
                                                    ? songColor
                                                    : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "اغنية ${index + 1}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient:
                                          active && isPlaying
                                              ? LinearGradient(
                                                colors: [
                                                  songColor,
                                                  songColor.withValues(
                                                    alpha: 0.7,
                                                  ),
                                                ],
                                              )
                                              : LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  Colors.white.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                ],
                                              ),
                                    ),
                                    child: Icon(
                                      active && isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "♪ لكل روح نغمها الخاص ♪",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
