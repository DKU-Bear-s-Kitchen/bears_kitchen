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

            // 2. 식당 정보 영역 (이름, 별점)
            Container(
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
                    children: const [
                      Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                      SizedBox(width: 4),
                      Text(
                        "4.5 (120)", // 별점 기능은 아직 구현되지 않아 고정값 유지
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

            // 4. 🔥 [핵심 변경] Firestore 실시간 데이터 연동
            StreamBuilder<QuerySnapshot>(
              // 현재 식당(storeId)의 'menus' 컬렉션을 구독
              stream: FirebaseFirestore.instance
                  .collection('stores')
                  .doc(storeId)
                  .collection('menus')
                  .orderBy('name') // 이름순 정렬 (원하면 price 등으로 변경 가능)
                  .snapshots(),
              builder: (context, snapshot) {
                // 데이터 로딩 중일 때
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 에러 났을 때
                if (snapshot.hasError) {
                  return const Center(child: Text("데이터를 불러오는데 실패했습니다."));
                }
                // 데이터가 없을 때
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text("등록된 메뉴가 없습니다.")),
                  );
                }

                // 데이터가 있을 때 리스트 생성
                final menuDocs = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    // SingleChildScrollView 안에서 ListView를 쓰려면 아래 두 설정 필수
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: menuDocs.length,
                    itemBuilder: (context, index) {
                      final menuData = menuDocs[index].data() as Map<String, dynamic>;

                      // 데이터 가져오기 (없을 경우 기본값 처리)
                      final String name = menuData['name'] ?? '이름 없음';
                      final String price = "${menuData['price'] ?? 0}원";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                storeId: storeId, // 이미 클래스 변수로 가지고 있음
                                menuId: menuDocs[index].id, // Firestore 문서 ID
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
                              // 메뉴 이미지 (임시)
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
                              // 메뉴 정보 텍스트
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