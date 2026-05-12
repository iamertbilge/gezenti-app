import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'add_place_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gezenti'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Posts')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerList();
            }

            if (snapshot.hasError) {
              return _buildErrorState(context);
            }

            final posts =
                snapshot.data?.docs
                    .map(_PlacePost.fromFirestore)
                    .toList(growable: false) ??
                <_PlacePost>[];

            if (posts.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final place = posts[index];
                return _buildPlaceCard(context, place);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, _PlacePost place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPostImage(place.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  place.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildImageFallback();
    }

    return SizedBox(
      height: 200,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 200,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.landscape, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildImageLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(height: 200, color: Colors.white),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 200, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: 180, height: 22),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildShimmerLine(width: 120, height: 14),
                      const Spacer(),
                      _buildShimmerLine(width: 88, height: 14),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildShimmerLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _buildShimmerLine(width: 240, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(Icons.travel_explore, size: 72, color: Colors.grey.shade500),
        const SizedBox(height: 16),
        Text(
          'Henüz mekan paylaşılmadı',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'İlk mekanı ekleyerek akışı başlat.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
        const SizedBox(height: 16),
        Text(
          'Akış yüklenirken bir sorun oluştu.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Lütfen bağlantını kontrol edip tekrar dene.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _PlacePost {
  final String name;
  final String description;
  final String location;
  final String date;
  final String imageUrl;
  final String userId;
  final String userEmail;

  _PlacePost({
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.userId,
    required this.userEmail,
  });

  factory _PlacePost.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return _PlacePost(
      name: _readText(data['name'], 'İsimsiz Mekan'),
      description: _readText(data['description'], 'Açıklama eklenmemiş.'),
      location: _readText(data['location'], 'Konum belirtilmedi'),
      date: _formatDate(data['date']),
      imageUrl: _readText(data['imageUrl'], ''),
      userId: _readText(data['userId'], ''),
      userEmail: _readText(data['userEmail'], ''),
    );
  }
}

String _readText(dynamic value, String fallback) {
  if (value == null) return fallback;

  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _formatDate(dynamic value) {
  DateTime? date;

  if (value is Timestamp) {
    date = value.toDate();
  } else if (value is DateTime) {
    date = value;
  } else if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return 'Tarih yok';

    date = DateTime.tryParse(text);
    if (date == null) {
      return 'Tarih yok';
    }
  }

  if (date == null) {
    return 'Tarih yok';
  }

  return '${_twoDigits(date.day)}.${_twoDigits(date.month)}.${date.year}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
