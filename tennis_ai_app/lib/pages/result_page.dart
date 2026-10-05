import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResultPage extends StatefulWidget {
  final String action;
  final double confidence;
  final DateTime timestamp;
  final String? videoThumbnail; // Optional: path to video thumbnail

  const ResultPage({
    super.key,
    required this.action,
    required this.confidence,
    required this.timestamp,
    this.videoThumbnail,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late AnimationController _confidenceController;
  late AnimationController _fadeController;
  late Animation<double> _confidenceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _confidenceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _confidenceAnimation = Tween<double>(
      begin: 0,
      end: widget.confidence,
    ).animate(CurvedAnimation(
      parent: _confidenceController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _confidenceController.forward();
    });
  }

  @override
  void dispose() {
    _confidenceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF00E676);
    if (confidence >= 0.6) return const Color(0xFFFFEB3B);
    return const Color(0xFFFF5252);
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.9) return "Excellent";
    if (confidence >= 0.8) return "Very High";
    if (confidence >= 0.7) return "High";
    if (confidence >= 0.6) return "Moderate";
    return "Low";
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'forehand':
        return Icons.sports_tennis;
      case 'backhand':
        return Icons.sports_tennis;
      case 'serve':
        return Icons.arrow_upward_rounded;
      case 'volley':
        return Icons.flash_on_rounded;
      case 'smash':
        return Icons.bolt_rounded;
      case 'lob':
        return Icons.trending_up_rounded;
      case 'drop shot':
        return Icons.trending_down_rounded;
      default:
        return Icons.sports_tennis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(widget.confidence);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              
              // Main Content
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Action Card
                      _buildActionCard(confidenceColor),
                      
                      const SizedBox(height: 24),
                      
                      // Confidence Meter
                      _buildConfidenceMeter(confidenceColor),
                      
                      const SizedBox(height: 24),
                      
                      // Stats Row
                      _buildStatsRow(confidenceColor),
                      
                      const Spacer(),
                      
                      // Action Buttons
                      _buildActionButtons(context),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Expanded(
            child: Text(
              "Analysis Result",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share_rounded),
            color: Colors.white,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F38),
            const Color(0xFF141728),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with glow effect
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.0),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.15),
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                _getActionIcon(widget.action),
                size: 40,
                color: accentColor,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Detected label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "SHOT DETECTED",
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action name
          Text(
            widget.action.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceMeter(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Confidence Score",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getConfidenceLabel(widget.confidence),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Circular progress indicator
          Center(
            child: AnimatedBuilder(
              animation: _confidenceAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CustomPaint(
                        painter: _CircularProgressPainter(
                          progress: _confidenceAnimation.value,
                          color: accentColor,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(_confidenceAnimation.value * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "accuracy",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_rounded,
            label: "Timestamp",
            value: _formatTimestamp(widget.timestamp),
            color: const Color(0xFF64B5F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.analytics_rounded,
            label: "Model",
            value: "TensorFlow",
            color: const Color(0xFFFFB74D),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Analyze Another",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              // Save to history
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Save to History",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return "$hour:$minute:$second";
  }
}

// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
