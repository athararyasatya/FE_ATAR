import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(20),

                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                        colors: [
                          Color(0xFFF3E8FF),
                          Color(0xFFEDE9FE),
                        ],
                      ),
                    ),

                    child: const Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 60,
                        color:
                            Color(0xFF7132F5),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    30),
                      ),
                      child: Text(
                        "Popular",
                        style:
                            GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  GoogleFonts.poppins(
                fontWeight:
                    FontWeight.w700,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              price,
              style:
                  GoogleFonts.poppins(
                color:
                    const Color(0xFF7132F5),
                fontWeight:
                    FontWeight.w700,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 42,

              child: ElevatedButton.icon(
                onPressed: () {},

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xFF7132F5),

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                ),

                icon: const Icon(
                  Icons.add_shopping_cart,
                  size: 18,
                ),

                label: const Text(
                  "Tambah",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}