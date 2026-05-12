import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceDetailScreen extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final String date;
  final String imageUrl;
  final String heroTag;
  final String? userEmail;

  const PlaceDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.heroTag,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A1A2E),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildHeroImage(),
            _buildGradientOverlay(),
            _buildHeaderInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: heroTag,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildFallbackImage();
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildFallbackImage(),
            )
          : _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFBDBDBD),
      child: const Center(
        child: Icon(Icons.landscape, size: 80, color: Colors.white70),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Color(0xCC000000),
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                date,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionSection(context),
          const SizedBox(height: 24),
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final hasDescription = description.isNotEmpty &&
        description != 'Açıklama eklenmemiş.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mekan Notu',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasDescription ? description : 'Açıklama eklenmemiş.',
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: hasDescription
                  ? const Color(0xFF424242)
                  : const Color(0xFF9E9E9E),
              height: 1.6,
              fontStyle:
                  hasDescription ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final displayEmail = (userEmail != null && userEmail!.trim().isNotEmpty)
        ? userEmail!
        : 'Gezenti kullanıcısı';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Detaylar',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_outlined, 'Konum', location),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildInfoRow(Icons.calendar_today_outlined, 'Tarih', date),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildInfoRow(Icons.person_outline_rounded, 'Paylaşan', displayEmail),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF757575)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
