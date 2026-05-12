import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';

class OfflineSyncService {
  OfflineSyncService._();

  static final OfflineSyncService instance = OfflineSyncService._();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;
  bool _started = false;

  GlobalKey<NavigatorState>? _navigatorKey;
  void Function(int syncedCount)? _onSyncComplete;

  void start({
    required GlobalKey<NavigatorState> navigatorKey,
    void Function(int syncedCount)? onSyncComplete,
  }) {
    if (_started) return;
    _started = true;
    _navigatorKey = navigatorKey;
    _onSyncComplete = onSyncComplete;

    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (_hasConnection(results)) {
      syncPendingPlaces();
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) return false;
    if (results.isEmpty) return false;
    return true;
  }

  Future<int> syncPendingPlaces() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int syncedCount = 0;

    try {
      final places = await DbHelper.instance.getPlaces();
      if (places.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';
      final userEmail = user?.email ?? '';

      for (final place in places) {
        try {
          final data = _placeToFirestoreMap(place, userId, userEmail);
          await FirebaseFirestore.instance.collection('Posts').add(data);

          if (place.id != null) {
            await DbHelper.instance.deletePlace(place.id!);
          }
          syncedCount++;
        } catch (e) {
          debugPrint('OfflineSyncService: Kayıt gönderilemedi (id=${place.id}): $e');
        }
      }

      if (syncedCount > 0) {
        _onSyncComplete?.call(syncedCount);
        _showSyncNotification(syncedCount);
      }
    } catch (e) {
      debugPrint('OfflineSyncService: Senkronizasyon hatası: $e');
    } finally {
      _isSyncing = false;
    }

    return syncedCount;
  }

  Map<String, dynamic> _placeToFirestoreMap(
    Place place,
    String userId,
    String userEmail,
  ) {
    Timestamp dateTimestamp;
    final parsed = DateTime.tryParse(place.date);
    if (parsed != null) {
      dateTimestamp = Timestamp.fromDate(parsed);
    } else {
      dateTimestamp = Timestamp.now();
    }

    return {
      'name': place.name,
      'description': place.description,
      'location': 'Konum belirtilmedi',
      'date': dateTimestamp,
      'imageUrl': '',
      'localImagePath': place.imagePath,
      'source': 'offline_sqlite',
      'syncedAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'userEmail': userEmail,
    };
  }

  void _showSyncNotification(int count) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _SyncNotificationWidget(
        count: count,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _SyncNotificationWidget extends StatefulWidget {
  const _SyncNotificationWidget({
    required this.count,
    required this.onDismiss,
  });

  final int count;
  final VoidCallback onDismiss;

  @override
  State<_SyncNotificationWidget> createState() =>
      _SyncNotificationWidgetState();
}

class _SyncNotificationWidgetState extends State<_SyncNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3316A34A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.count == 1
                            ? 'Çevrimdışı kaydınız başarıyla buluta eşitlendi.'
                            : '${widget.count} çevrimdışı kaydınız başarıyla buluta eşitlendi.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _controller.reverse().then((_) {
                          widget.onDismiss();
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
