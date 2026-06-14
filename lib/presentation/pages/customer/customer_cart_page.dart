import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({super.key});

  @override
  State<CustomerCartPage> createState() =>
      _CustomerCartPageState();
}

class _CustomerCartPageState
    extends State<CustomerCartPage> {
  final List<Map<String, dynamic>>
      cartItems = [
    {
      "name": "Indomie Goreng",
      "price": 3500,
      "qty": 2,
    },
    {
      "name": "Teh Botol Sosro",
      "price": 6000,
      "qty": 1,
    },
    {
      "name": "Coca Cola",
      "price": 12000,
      "qty": 3,
    },
  ];

  int get subtotal {
    return cartItems.fold(
      0,
      (sum, item) =>
          sum +
          ((item["price"] as int) *
              (item["qty"] as int)),
    );
  }

  int get shipping => 10000;

  int get total =>
      subtotal + shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      body: SafeArea(
        child: Column(
          children: [
            //------------------------------------------------
            // HEADER
            //------------------------------------------------

            Container(
              margin:
                  const EdgeInsets.all(20),
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                        30),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                          context);
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.15,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                                    14),
                      ),
                      child: const Icon(
                        Icons
                            .arrow_back_ios_new,
                        color:
                            Colors.white,
                        size: 18,
                      ),
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
                          "My Cart",
                          style:
                              GoogleFonts.poppins(
                            color: Colors
                                .white,
                            fontWeight:
                                FontWeight
                                    .w700,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          "${cartItems.length} Produk",
                          style:
                              GoogleFonts.inter(
                            color: Colors
                                .white70,
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
                      color: Colors
                          .white
                          .withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                    child: const Icon(
                      Icons
                          .shopping_cart_outlined,
                      color:
                          Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            //------------------------------------------------
            // CART LIST
            //------------------------------------------------

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                ),
                itemCount:
                    cartItems.length,
                itemBuilder:
                    (context, index) {
                  final item =
                      cartItems[index];

                  return Container(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 16,
                    ),
                    padding:
                        const EdgeInsets
                            .all(14),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha: 0.04,
                          ),
                          blurRadius:
                              20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(
                                    0xFFF3E8FF),
                                Color(
                                    0xFFEDE9FE),
                              ],
                            ),
                          ),
                          child:
                              const Icon(
                            Icons
                                .inventory_2_outlined,
                            size: 40,
                            color:
                                Color(
                              0xFF7132F5,
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 14),

                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                item[
                                    "name"],
                                style:
                                    GoogleFonts.poppins(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  fontSize:
                                      15,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      6),

                              Text(
                                "Rp ${item["price"]}",
                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      const Color(
                                    0xFF7132F5,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      10),

                              Row(
                                children: [
                                  GestureDetector(
                                    onTap:
                                        () {
                                      setState(
                                          () {
                                        if (item["qty"] >
                                            1) {
                                          item["qty"]--;
                                        }
                                      });
                                    },
                                    child:
                                        _qtyButton(
                                      Icons
                                          .remove,
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal:
                                          14,
                                    ),
                                    child:
                                        Text(
                                      item["qty"]
                                          .toString(),
                                      style:
                                          GoogleFonts.poppins(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap:
                                        () {
                                      setState(
                                          () {
                                        item["qty"]++;
                                      });
                                    },
                                    child:
                                        _qtyButton(
                                      Icons
                                          .add,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            //------------------------------------------------
            // SUMMARY
            //------------------------------------------------

            Container(
              padding:
                  const EdgeInsets.all(
                      24),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(
                      30),
                ),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    "Subtotal",
                    "Rp $subtotal",
                  ),

                  const SizedBox(
                      height: 10),

                  _summaryRow(
                    "Ongkir",
                    "Rp $shipping",
                  ),

                  const Divider(
                    height: 30,
                  ),

                  _summaryRow(
                    "Total",
                    "Rp $total",
                    bold: true,
                  ),

                  const SizedBox(
                      height: 20),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed: () {},

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF7132F5,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                        ),
                      ),

                      child: Text(
                        "Checkout",
                        style:
                            GoogleFonts.poppins(
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
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(
      IconData icon) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color:
            const Color(0xFF7132F5),
        borderRadius:
            BorderRadius.circular(
                10),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
      children: [
        Text(
          title,
          style:
              GoogleFonts.inter(
            fontSize: 15,
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style:
              GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}