import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';

class MenuScreen extends StatelessWidget {
  final String storeId;
  final String storeName;

  const MenuScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF1F2937),
        ),
        title: Text(
          storeName,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 식당 이미지 영역 (임시 회색 박스)
            Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              child: const Center(
                child: Icon(Icons.store, size: 80, color: Colors.grey),
              ),
            ),

            // 2. 🔥 [핵심 변경] 식당 정보 영역 (실시간 별점 연동)
            StreamBuilder<DocumentSnapshot>(
              // stores 컬렉션의 해당 식당 문서 구독
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .snapshots(),
              builder: (context, snapshot) {
                // 기본값 설정 (데이터 로딩 전이나 없을 때)
                double avgRating = 0.0;
                int reviewCount = 0;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  // 데이터베이스에서 값 가져오기 (숫자 변환 안전하게 처리)
                  avgRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
                  reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
                }

                return Container(
                  width: double.infinity,
                  color: const Color(0xFFFFFFFF),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                          const SizedBox(width: 4),
                          // 🔥 실제 데이터 표시 (소수점 1자리)
                          Text(
                            "${avgRating.toStringAsFixed(1)} ($reviewCount)",
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // 3. 메뉴 리스트 타이틀
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "메뉴",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            // 4. 메뉴 리스트 (기존 코드 유지)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('menus')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("데이터를 불러오는데 실패했습니다."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("등록된 메뉴가 없습니다.")),
                  );
                }

                final menuDocs = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuDocs.length,
                    itemBuilder: (context, index) {
                      final menuData = menuDocs[index].data() as Map<String, dynamic>;
                      final String name = menuData['name'] ?? '이름 없음';
                      final String price = "${menuData['price'] ?? 0}원";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                storeId: storeId,
                                menuId: menuDocs[index].id,
                                menuName: name,
                                menuPrice: price,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fastfood, color: Colors.grey),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    price,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}