import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Statik mekan verileri
    final List<_PlacePost> staticPlaces = [
      _PlacePost(
        name: 'Kapadokya Balon Vadisi',
        description: 'Gün doğumunda balonları izlemek harika bir deneyimdi.',
        location: 'Nevşehir, Türkiye',
        date: '15 Mayıs 2024',
        imageUrl:
            'https://images.unsplash.com/photo-1570939274717-7eda259b5052?q=80&w=600&auto=format&fit=crop',
      ),
      _PlacePost(
        name: 'Galata Kulesi',
        description:
            'İstanbul manzarasını izlemek için en güzel noktalardan biri.',
        location: 'İstanbul, Türkiye',
        date: '20 Haziran 2024',
        imageUrl:
            'https://images.unsplash.com/photo-1541432901042-2d8bd64b4a9b?q=80&w=600&auto=format&fit=crop',
      ),
      _PlacePost(
        name: 'Pamukkale Travertenleri',
        description: 'Doğal güzelliğiyle mutlaka görülmesi gereken bir rota.',
        location: 'Denizli, Türkiye',
        date: '10 Ağustos 2024',
        imageUrl:
            'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?q=80&w=600&auto=format&fit=crop',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gezenti'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: staticPlaces.length,
        itemBuilder: (context, index) {
          final place = staticPlaces[index];
          return _buildPlaceCard(context, place);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Yeni mekan ekleme ekranı Görev 5 kapsamında hazırlanacak.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
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
          // Görsel Alanı
          SizedBox(
            height: 200,
            child: Image.network(
              place.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.landscape, size: 64, color: Colors.grey),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          // İçerik Alanı
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
                    Text(
                      place.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
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
}

class _PlacePost {
  final String name;
  final String description;
  final String location;
  final String date;
  final String imageUrl;

  _PlacePost({
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
  });
}
