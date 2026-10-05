import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:tennis_ai_app/pages/result_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  File? videoFile;
  bool loading = false;
  VideoPlayerController? controller;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  Future<void> pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      videoFile = File(picked.path);
      controller = VideoPlayerController.file(videoFile!)
        ..initialize().then((_) {
          setState(() {});
          controller!.play();
        });
    }
  }

  Future<void> uploadVideo() async {
    if (videoFile == null) return;
    setState(() => loading = true);
    try {
      final uri = Uri.http("172.20.10.3:8000", "/analyze");
      final request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("video", videoFile!.path),
      );
      final response = await request.send();
      final responseText = await response.stream.bytesToString();
      print("SERVER RESPONSE: $responseText");

      final action =
          RegExp(r'"action":"(.*?)"').firstMatch(responseText)?.group(1) ??
              "unknown";
      final confidence = double.tryParse(RegExp(r'"confidence":([0-9.]+)')
                  .firstMatch(responseText)
                  ?.group(1) ??
              "0") ??
          0;

      setState(() => loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            action: action,
            confidence: confidence,
            timestamp: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: const Color(0xFFFF4757),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF060612),
      body: Stack(
        children: [
          // ── Background glow top-right ──────────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF7C3AED).withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // ── Background glow bottom-left ────────────────────────










    
          Positioned(
            bottom: 80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF00C566).withOpacity(0.20),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // ── Scrollable section ─────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),

                            const SizedBox(height: 12),

                            // ── Big Hero Title ─────────────────────
                            const Text(
                              "Analyze Your\nTennis Shot",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                height: 1.08,
                                letterSpacing: -1.2,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Upload a clip · Get instant AI feedback",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.42),
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 26),

                            // ── Video preview card ─────────────────
                            GestureDetector(
                              onTap: pickVideo,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                height: screenH * 0.27,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10102A),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: videoFile != null
                                        ? const Color(0xFF00C566)
                                            .withOpacity(0.6)
                                        : Colors.white.withOpacity(0.08),
                                    width: 1.5,
                                  ),
                                  boxShadow: videoFile != null
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF00C566)
                                                .withOpacity(0.15),
                                            blurRadius: 32,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                                child: controller != null &&
                                        controller!.value.isInitialized
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: AspectRatio(
                                          aspectRatio:
                                              controller!.value.aspectRatio,
                                          child: VideoPlayer(controller!),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF00C566)
                                                      .withOpacity(0.22),
                                                  const Color(0xFF7C3AED)
                                                      .withOpacity(0.18),
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.play_circle_fill_rounded,
                                              color: Color(0xFF00C566),
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          const Text(
                                            "Tap to select a video",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "MP4 · MOV · AVI",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.28),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Stat chips ─────────────────────────
                            Row(
                              children: [
                                _statChip(
                                    Icons.bolt_rounded, "Instant", "Results"),
                                const SizedBox(width: 10),
                                _statChip(Icons.track_changes_rounded, "High",
                                    "Accuracy"),
                                const SizedBox(width: 10),
                                _statChip(Icons.sports_tennis_rounded, "Shot",
                                    "Detection"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── PINNED BOTTOM BUTTONS — always visible ─────
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF060612),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Loading state
                          if (loading) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00C566),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Analyzing your shot...",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Pick Video button
                          _buildButton(
                            label: "Pick Video",
                            icon: Icons.video_library_rounded,
                            isPrimary: false,
                            onTap: pickVideo,
                            enabled: true,
                          ),

                          const SizedBox(height: 12),

                          // Analyze Shot button — always rendered, never hidden
                          _buildButton(
                            label: loading ? "Analyzing..." : "Analyze Shot",
                            icon: Icons.auto_awesome_rounded,
                            isPrimary: true,
                            onTap: loading ? null : uploadVideo,
                            enabled: videoFile != null && !loading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String top, String bottom) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF10102A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00C566), size: 18),
            const SizedBox(height: 6),
            Text(top,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            Text(bottom,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final Color bg = isPrimary
        ? (enabled
            ? const Color(0xFF00C566)
            : const Color(0xFF00C566).withOpacity(0.28))
        : const Color(0xFF10102A);

    final Color fg = isPrimary
        ? (enabled ? Colors.white : Colors.white.withOpacity(0.35))
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.11), width: 1),
          boxShadow: isPrimary && enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C566).withOpacity(0.38),
                    blurRadius: 26,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
