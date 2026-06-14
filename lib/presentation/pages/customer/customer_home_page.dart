import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customer_cart_page.dart';
import '../../../widgets/product_card.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() =>
      _CustomerHomePageState();
}

class _CustomerHomePageState
    extends State<CustomerHomePage> {
  int currentIndex = 0;

  final categories = [
    "Semua",
    "Snack",
    "Minuman",
    "Frozen",
    "Sembako",
  ];

  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              //------------------------------------------------
              // HEADER
              //------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.all(24),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                          32),
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF5B21B6),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),
                      ),
                      child: const Icon(
                        Icons.person,
                        color:
                            Color(0xFF7132F5),
                        size: 30,
                      ),
                    ),

                    const SizedBox(
                        width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "Welcome Back 👋",
                            style:
                                GoogleFonts.inter(
                              color: Colors
                                  .white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            "Athar",
                            style:
                                GoogleFonts.poppins(
                              color: Colors
                                  .white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .all(10),
                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withValues(
                          alpha: .15,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),
                      child: const Icon(
                        Icons
                            .notifications_none,
                        color:
                            Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //------------------------------------------------
              // SEARCH
              //------------------------------------------------

              Container(
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: .03,
                      ),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: TextField(
                  decoration:
                      InputDecoration(
                    border:
                        InputBorder.none,
                    hintText:
                        "Cari produk...",
                    hintStyle:
                        GoogleFonts.inter(),
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              //------------------------------------------------
              // PROMO BANNER
              //------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                        24),
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                          28),
                  gradient:
                      const LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF5B21B6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      "Promo Spesial 🎉",
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    Text(
                      "Diskon hingga 30% untuk produk pilihan minggu ini.",
                      style:
                          GoogleFonts.inter(
                        color: Colors
                            .white70,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(
                        height: 18),

                    ElevatedButton(
                      onPressed: () {},
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.white,
                        foregroundColor:
                            const Color(
                          0xFF7132F5,
                        ),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),
                        ),
                      ),
                      child: const Text(
                        "Lihat Promo",
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              //------------------------------------------------
              // CATEGORY
              //------------------------------------------------

              Text(
                "Kategori",
                style:
                    GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      categories.length,
                  itemBuilder:
                      (context, index) {
                    final selected =
                        selectedCategory ==
                            index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory =
                              index;
                        });
                      },
                      child: Container(
                        margin:
                            const EdgeInsets
                                .only(
                          right: 10,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                        ),
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? const Color(
                                  0xFF7132F5)
                              : Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      14),
                        ),
                        alignment:
                            Alignment.center,
                        child: Text(
                          categories[index],
                          style:
                              GoogleFonts.inter(
                            color: selected
                                ? Colors
                                    .white
                                : Colors
                                    .black87,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              //------------------------------------------------
              // PRODUCT
              //------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Text(
                    "Produk Populer",
                    style:
                        GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                  Text(
                    "Lihat Semua",
                    style:
                        GoogleFonts.inter(
                      color:
                          const Color(
                              0xFF7132F5),
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing:
                      14,
                  mainAxisSpacing:
                      14,
                  childAspectRatio:
                      0.68,
                ),
                itemBuilder:
                    (context, index) {
                  return ProductCard(
                    name:
                        "Produk ${index + 1}",
                    price:
                        "Rp ${(index + 1) * 15000}",
                  );
                },
              ),
            ],
          ),
        ),
      ),

      //------------------------------------------------
      // BOTTOM NAVIGATION
      //------------------------------------------------

bottomNavigationBar: NavigationBar(
  height: 70,
  selectedIndex: currentIndex,

  onDestinationSelected: (index) {

    if (index == currentIndex) return;

    setState(() {
      currentIndex = index;
    });

    switch (index) {

      case 0:
        break;

      case 1:
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Halaman Order masih dibuat",
            ),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const CustomerCartPage(),
          ),
        );
        break;

      case 3:
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Halaman Profile masih dibuat",
            ),
          ),
        );
        break;
    }
  },

  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long),
      label: "Order",
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart),
      label: "Cart",
    ),
    NavigationDestination(
      icon: Icon(Icons.person),
      label: "Profile",
    ),
  ],
),
    );
  }
}