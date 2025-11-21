import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // Wrap the entire skeleton in the Shimmer widget
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. Eng yaqin uchrashuv (Next Appointment) Section ---
            const SizedBox(height: 16.0),
            _buildSectionTitle(),
            const SizedBox(height: 8.0),
            _buildAppointmentCard(),

            const SizedBox(height: 32.0),

            // --- 2. Bugungi statistika (Today's Statistics) Section ---
            _buildSectionTitle(),
            const SizedBox(height: 8.0),
            _buildStatisticsRow(),

            const SizedBox(height: 32.0),

            // --- 3. Bugungi uchrashuvlar (Today's Appointments) List ---
            _buildSectionTitle(),
            const SizedBox(height: 8.0),
            _buildAppointmentList(),
          ],
        ),
      ),
    );
  }

  // Helper widget to simulate a section title (e.g., "Eng yaqin uchrashuv")
  Widget _buildSectionTitle() {
    return Container(
      height: 20.0,
      width: 150.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  // Helper widget to simulate a single appointment card (e.g., Murod Nazarov)
  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon/Avatar placeholder
          const _ShimmerBox(
            width: 36.0,
            height: 36.0,
            borderRadius: 18.0, // Circular
          ),
          const SizedBox(width: 12.0),

          // Name and service placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // Name (Murod Nazarov)
                _ShimmerBox(width: 120.0, height: 16.0),
                SizedBox(height: 4.0),
                // Time and Service (09:00 • Soch kesish)
                _ShimmerBox(width: 150.0, height: 14.0),
              ],
            ),
          ),

          // Time/Price placeholder (30 daqiqadan so'ng / $12)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _ShimmerBox(width: 80.0, height: 16.0),
              SizedBox(height: 4.0),
              _ShimmerBox(width: 40.0, height: 16.0),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to simulate the statistics row
  Widget _buildStatisticsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        // Card 1 (Zakazlar)
        Expanded(child: _StatisticCardSkeleton()),
        SizedBox(width: 10.0),
        // Card 2 (Daromad)
        Expanded(child: _StatisticCardSkeleton()),
        SizedBox(width: 10.0),
        // Card 3 (Vaqt)
        Expanded(child: _StatisticCardSkeleton()),
      ],
    );
  }

  // Helper widget to simulate the list of appointments
  Widget _buildAppointmentList() {
    return Column(
      children: List.generate(
        3, // Generate a few items to simulate the list
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildAppointmentCard(),
        ),
      ),
    );
  }
}

// Reusable widget for drawing a shimmering box
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Reusable widget for the statistics cards
class _StatisticCardSkeleton extends StatelessWidget {
  const _StatisticCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // Approximate height
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _ShimmerBox(width: 30.0, height: 18.0), // The number/value
          SizedBox(height: 4.0),
          _ShimmerBox(width: 50.0, height: 14.0), // The label
        ],
      ),
    );
  }
}
