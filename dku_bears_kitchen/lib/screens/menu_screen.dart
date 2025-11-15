import 'package:flutter/material.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';

class MenuScreen extends StatelessWidget {
  // '가게 이름'을 받는 변수
  final String storeName;

  MenuScreen({
    super.key,
    required this.storeName,
  });

  // (가짜 데이터)
  final List<Map<String, String>> dummyMenuList = [
    { 'name': '우삼겹 덮밥', 'price': '3,500원' },
    { 'name': '참치마요 덮밥', 'price': '3,500원' },
    { 'name': '치킨데리야끼 덮밥', 'price': '3,500원' },
    { 'name': '불쭈꾸미 덮밥', 'price': '3,500원' },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Color(0xFF1F2937),
        ),
        // '받아온' 가게 이름 사용
        title: Text(
          storeName,
          style: TextStyle(
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
            Container(
              height: 220,
              width: double.infinity,
              color: Color(0xFFE5E7EB),
            ),
            Container(
              height: 102,
              width: double.infinity,
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // '받아온' 가게 이름 사용
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                      SizedBox(width: 4),
                      Text(
                        "4.5 (120)", // (가짜 데이터)
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: List.generate(dummyMenuList.length, (index) {
                  // (⭐추가!⭐) 'menu' 변수를 여기서 선언
                  final menu = dummyMenuList[index];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // 2. 'ReviewScreen'으로 '메뉴 이름'과 '가격'을 전달!
                          builder: (context) => ReviewScreen(
                            menuName: menu['name']!, // 예: "우삼겹 덮밥"
                            menuPrice: menu['price']!, // 예: "3,500원"
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                menu['price']!,
                                style: TextStyle(
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
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}