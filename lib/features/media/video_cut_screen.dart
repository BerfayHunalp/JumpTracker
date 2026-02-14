import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';

/// Video Auto-Cut screen: imports a video, aligns it with session timeline,
/// and auto-trims to jump moments.
///
/// NOTE: ffmpeg_kit_flutter is mobile-only. On web, we show instructions only.
class VideoCutScreen extends ConsumerStatefulWidget {
  final DateTime sessionStart;
  final List<Jump> jumps;

  const VideoCutScreen({
    super.key,
    required this.sessionStart,
    required this.jumps,
  });

  @override
  ConsumerState<VideoCutScreen> createState() => _VideoCutScreenState();
}

class _VideoCutScreenState extends ConsumerState<VideoCutScreen> {
  String? _videoPath;
  double _offsetSeconds = 0;
  bool _processing = false;
  List<_ClipInfo>? _clips;
  String? _error;

  List<_ClipInfo> _computeClips() {
    final sessionStartUs = widget.sessionStart.microsecondsSinceEpoch;
    const paddingSec = 3.0;

    return widget.jumps.map((jump) {
      final startSec =
          (jump.takeoffTimestampUs - sessionStartUs) / 1000000.0 +
              _offsetSeconds -
              paddingSec;
      final endSec =
          (jump.landingTimestampUs - sessionStartUs) / 1000000.0 +
              _offsetSeconds +
              paddingSec;

      return _ClipInfo(
        jumpId: jump.id,
        label: '${jump.airtimeMs}ms jump',
        startSec: startSec.clamp(0, double.infinity),
        endSec: endSec.clamp(0, double.infinity),
      );
    }).toList();
  }

  Future<void> _pickVideo() async {
    if (kIsWeb) {
      setState(() => _error = 'Video editing requires the mobile app.');
      return;
    }

    try {
      // Dynamic import for mobile-only packages
      final picker = await _getImagePicker();
      if (picker == null) {
        setState(() => _error = 'image_picker not available');
        return;
      }
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _videoPath = file.path;
          _clips = _computeClips();
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick video: $e');
    }
  }

  Future<void> _exportClips() async {
    if (_videoPath == null || _clips == null || _clips!.isEmpty) return;

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      for (final clip in _clips!) {
        final outputPath = _videoPath!.replaceAll(
          RegExp(r'\.[^.]+$'),
          '_clip_${clip.label.replaceAll(' ', '_')}.mp4',
        );

        // Use ffmpeg to trim: -ss start -to end -c copy
        final result = await Process.run('ffmpeg', [
          '-y',
          '-i', _videoPath!,
          '-ss', clip.startSec.toStringAsFixed(2),
          '-to', clip.endSec.toStringAsFixed(2),
          '-c', 'copy',
          outputPath,
        ]);

        if (result.exitCode != 0) {
          setState(() => _error = 'ffmpeg error: ${result.stderr}');
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_clips!.length} clips exported!'),
            backgroundColor: const Color(0xFF4FC3F7),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Auto-Cut Video'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high,
                      color: Color(0xFF4FC3F7), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto-Cut Video',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Import your GoPro/phone video and we\'ll trim it to your ${widget.jumps.length} jump(s) automatically.',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pick video button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _processing ? null : _pickVideo,
                icon: const Icon(Icons.video_library),
                label: Text(
                    _videoPath != null ? 'Change Video' : 'Import Video'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4FC3F7),
                  side: const BorderSide(color: Color(0xFF4FC3F7)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (_videoPath != null) ...[
              const SizedBox(height: 16),

              // Time offset slider
              const Text(
                'SYNC OFFSET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Adjust if recording started before/after session.',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
              Row(
                children: [
                  Text('${_offsetSeconds.toStringAsFixed(1)}s',
                      style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _offsetSeconds,
                      min: -60,
                      max: 60,
                      divisions: 240,
                      activeColor: const Color(0xFF4FC3F7),
                      onChanged: (v) {
                        setState(() {
                          _offsetSeconds = v;
                          _clips = _computeClips();
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Clip preview list
              const Text(
                'CLIPS TO EXPORT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              if (_clips != null)
                ...List.generate(_clips!.length, (i) {
                  final clip = _clips![i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4FC3F7)
                                  .withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4FC3F7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              clip.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${clip.startSec.toStringAsFixed(1)}s → ${clip.endSec.toStringAsFixed(1)}s',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // Export button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed:
                      _processing || kIsWeb ? null : _exportClips,
                  icon: _processing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.content_cut),
                  label: Text(_processing
                      ? 'Exporting...'
                      : 'Export ${_clips?.length ?? 0} Clips'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              if (kIsWeb) ...[
                const SizedBox(height: 8),
                const Text(
                  'Video export is only available on the mobile app.',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Dynamic import helper for image_picker (mobile-only)
  Future<dynamic> _getImagePicker() async {
    try {
      // This will be replaced with proper import when image_picker is added
      return null;
    } catch (_) {
      return null;
    }
  }
}

enum ImageSource { gallery, camera }

class _ClipInfo {
  final String jumpId;
  final String label;
  final double startSec;
  final double endSec;

  const _ClipInfo({
    required this.jumpId,
    required this.label,
    required this.startSec,
    required this.endSec,
  });
}
