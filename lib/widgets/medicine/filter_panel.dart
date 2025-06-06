import 'package:flutter/material.dart';

class FilterPanel extends StatelessWidget {
  final VoidCallback onClose;

  const FilterPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Panel width
        color: Colors.white,
        child: Column(
          children: [
            // Header with a close button
            AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Filter'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose, // Close the filter panel
                ),
              ],
            ),
            // Customize this section with filter options (checkbox, dropdown, etc.)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Filter by category title
                  Text(
                    'Filter berdasarkan kategori:',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith( // Use bodyText1 or custom TextStyle
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add filter widgets here, like checkboxes or dropdowns
                  // Example of a filter option: a dropdown
                  DropdownButton<String>(
                    hint: const Text('Pilih Kategori'),
                    items: ['All', 'Health', 'Beauty']
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      // Handle the change of selected category
                    },
                  ),
                  const SizedBox(height: 20),
                  // Example of another filter option: a checkbox
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      const Text('Only Available Items'),
                    ],
                  ),
                  // Add more filters as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
