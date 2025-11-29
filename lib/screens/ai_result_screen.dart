import 'package:flutter/material.dart';

class AiResultScreen extends StatelessWidget {
  // AI가 추천해준 데이터 리스트 (이름, 가격, 이유, 태그)
  final List<Map<String, dynamic>> recommendedMenus;

  const AiResultScreen({
    super.key,
    required this.recommendedMenus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "AI 추천 결과",
          style: TextStyle(color: Color(0xFF1F2937), fontSize: 17, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 결과 리스트 (여기에 카드들이 들어감)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: recommendedMenus.length,
              itemBuilder: (context, index) {
                return _buildResultCard(recommendedMenus[index]);
              },
            ),
          ),

          // 하단 '다시 요청 보내기' 버튼
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // 뒤로가기
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0x19000000),
                ),
                child: const Text(
                  '다시 요청 보내기',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 📦 메뉴 카드 디자인 (디자인 코드 완벽 구현)
  Widget _buildResultCard(Map<String, dynamic> menu) {
    // 태그 데이터 처리 (String 리스트로 변환)
    List<String> tags = [];
    if (menu['tags'] != null) {
      tags = List<String>.from(menu['tags']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 메뉴 이름과 가격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                menu['name'] ?? '메뉴명',
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 17, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
              Text(
                "${menu['price']}",
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. 추천 이유 (설명)
          Text(
            menu['reason'] ?? '설명 없음',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w400, height: 1.4),
          ),
          const SizedBox(height: 16),

          // 3. 태그들 (Wrap 사용)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag.startsWith('#') ? tag : '#$tag', // # 없으면 붙여줌
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}