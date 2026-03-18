import 'package:flutter/material.dart';

class SearchArea extends StatelessWidget {
  final bool isVegOnly;
  final ValueChanged<bool> onVegToggle;
  final ValueChanged<String>? onSearchChanged;

  final VoidCallback? onTap;
  final VoidCallback? onMicTap;

  const SearchArea({
    super.key,
    required this.isVegOnly,
    required this.onVegToggle,
    this.onSearchChanged,
    this.onTap,
    this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Restaurant name or a dish...",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onMicTap,
                    child: Icon(
                      Icons.mic_none_outlined,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VEG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => onVegToggle(!isVegOnly),
                child: Container(
                  width: 38,
                  height: 22,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isVegOnly
                        ? Colors.green.shade700
                        : Colors.grey.shade400,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: isVegOnly
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
