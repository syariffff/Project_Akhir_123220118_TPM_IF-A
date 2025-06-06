import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:ionicons/ionicons.dart';

class ReviewBody extends StatefulWidget {
  const ReviewBody({super.key});

  @override
  State<ReviewBody> createState() => _ReviewBodyState();
}

class _ReviewBodyState extends State<ReviewBody> {
  double rating = 0;
  final TextEditingController reviewController = TextEditingController();

  Widget _buildDoctorCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        width: double.maxFinite,
        height: 150,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: lightColorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/doctor_2.jpg',
                width: 45,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. Ruben Dorwart",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Dental Specialist",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Ionicons.calendar_outline,
                        size: 18,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6, right: 14),
                        child: Text(
                          "Today",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Ionicons.time_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "14:30 - 15:30 AM",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 40,
        unratedColor: Colors.grey.shade300,
        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: (value) {
          setState(() {
            rating = value;
          });
        },
      ),
    );
  }

  Widget _buildReviewForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: reviewController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Tulis ulasan Anda di sini...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightColorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ulasan tidak boleh kosong")),
                  );
                  return;
                }
                // Simulasi simpan ulasan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Terima kasih atas ulasannya!")),
                );
                reviewController.clear();
                setState(() {
                  rating = 0;
                });
              },
              child: const Text(
                "Kirim Ulasan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [_buildDoctorCard(), _buildRatingBar(), _buildReviewForm()],
      ),
    );
  }
}

class _ScheduleInfo extends StatelessWidget {
  const _ScheduleInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Ionicons.calendar_outline, size: 18, color: Colors.black45),
          SizedBox(width: 6),
          Text("15/07/2025", style: TextStyle(color: Colors.black45)),
          SizedBox(width: 14),
          Icon(Ionicons.time_outline, size: 18, color: Colors.black45),
          SizedBox(width: 6),
          Text("14:30 - 15:30 AM", style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}
