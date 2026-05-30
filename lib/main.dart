import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telephony/telephony.dart';

final Telephony telephony = Telephony.instance;
final AudioPlayer player = AudioPlayer();

@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/sms_messages.json');
  
  List<Map<String, dynamic>> messages = [];
  if (await file.exists()) {
    String content = await file.readAsString();
    if (content.isNotEmpty) {
      messages = List<Map<String, dynamic>>.from(jsonDecode(content));
    }
  }
  
  messages.insert(0, {
    'address': message.address,
    'body': message.body,
    'time': DateTime.now().toIso8601String(),
  });
  
  await file.writeAsString(jsonEncode(messages));
}

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
  String status = "جاهز";
  int unreadCount = 0;

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

  @override
  void initState() {
    super.initState();
    startSmsListener();
    loadUnreadCount();
  }

  void loadUnreadCount() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sms_messages.json');
    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        List messages = jsonDecode(content);
        setState(() {
          unreadCount = messages.length;
        });
      }
    }
  }

  void startSmsListener() async {
    bool? granted = await telephony.requestSmsPermissions;

    if (granted == true) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('${dir.path}/sms_messages.json');
          
          List<Map<String, dynamic>> messages = [];
          if (await file.exists()) {
            String content = await file.readAsString();
            if (content.isNotEmpty) {
              messages = List<Map<String, dynamic>>.from(jsonDecode(content));
            }
          }
          
          messages.insert(0, {
            'address': message.address,
            'body': message.body,
            'time': DateTime.now().toIso8601String(),
          });
          
          await file.writeAsString(jsonEncode(messages));

          setState(() {
            status = "📨 رسالة جديدة";
            unreadCount = messages.length;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                status = "جاهز";
              });
            }
          });
        },
        onBackgroundMessage: backgroundMessageHandler,
        listenInBackground: true,
      );
    }
  }

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

  // دالة لعرض صفحة الرسائل
  void showMessagesPage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sms_messages.json');
    
    List<Map<String, dynamic>> messages = [];
    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        messages = List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    }
    
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesPage(messages: messages, onRefresh: () {
          loadUnreadCount();
          setState(() {});
        }),
      ),
    );
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
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.pink, Colors.purple, Colors.orange],
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
                      const SizedBox(height: 20),
                      // زر عرض الرسائل
                      GestureDetector(
                        onTap: showMessagesPage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.message,
                                color: Colors.pink.shade200,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                status,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "$unreadCount",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
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
                                gradient: active && isPlaying
                                    ? LinearGradient(
                                        colors: [songColor, songColor.withValues(alpha: 0.7)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active && isPlaying
                                      ? songColor
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                                boxShadow: active && isPlaying
                                    ? [
                                        BoxShadow(
                                          color: songColor.withValues(alpha: 0.3),
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
                                        colors: [songColor, songColor.withValues(alpha: 0.5)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: songColor.withValues(alpha: 0.3),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          songTitles[index],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: active && isPlaying
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: active && isPlaying
                                                ? songColor
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "اغنية ${index + 1}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.5),
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
                                      gradient: active && isPlaying
                                          ? LinearGradient(
                                              colors: [songColor, songColor.withValues(alpha: 0.7)],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Colors.white.withValues(alpha: 0.2),
                                                Colors.white.withValues(alpha: 0.1),
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

// صفحة عرض الرسائل المنفصلة
class MessagesPage extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final VoidCallback onRefresh;

  const MessagesPage({super.key, required this.messages, required this.onRefresh});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late List<Map<String, dynamic>> messages;

  @override
  void initState() {
    super.initState();
    messages = List.from(widget.messages);
  }

  Future<void> deleteMessage(int index) async {
    setState(() {
      messages.removeAt(index);
    });
    
    // حفظ التغييرات
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sms_messages.json');
    await file.writeAsString(jsonEncode(messages));
    
    widget.onRefresh();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الرسالة')),
      );
    }
  }

  Future<void> deleteAllMessages() async {
    setState(() {
      messages.clear();
    });
    
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sms_messages.json');
    await file.writeAsString(jsonEncode([]));
    
    widget.onRefresh();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف جميع الرسائل')),
      );
    }
  }

  String formatTime(String isoString) {
    DateTime time = DateTime.parse(isoString);
    return "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        title: const Text("الرسائل المستلمة"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D1B4E), Color(0xFF1A0B2E)],
            ),
          ),
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("حذف الكل"),
                    content: const Text("هل أنت متأكد من حذف جميع الرسائل؟"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("إلغاء"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          deleteAllMessages();
                        },
                        child: const Text("حذف", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "لا توجد رسائل بعد",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "عند استلام رسالة SMS ستظهر هنا",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Dismissible(
                    key: Key(message['time']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => deleteMessage(index),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink.shade200,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        message['address'] ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        message['body'] ?? 'No content',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        formatTime(message['time']),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF2D1B4E),
                            title: Text(
                              message['address'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              message['body'] ?? 'No content',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("إغلاق", style: TextStyle(color: Colors.pink)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}          });
        },
        onBackgroundMessage: backgroundMessageHandler,
        listenInBackground: true,
      );
    }
  }

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
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.contains("تم حفظ")
                                  ? Icons.message
                                  : Icons.music_note,
                              color: Colors.pink.shade200,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              status,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
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
