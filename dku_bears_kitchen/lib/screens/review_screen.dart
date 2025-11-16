import 'package:flutter/material.dart';
import 'package:dku_bears_kitchen/screens/review_modal.dart';

class ReviewScreen extends StatelessWidget {
  final String menuName;
  final String menuPrice;

  ReviewScreen({
    super.key,
    required this.menuName,
    required this.menuPrice,
  });

  //가짜 데이터
  final List<Map<String, String>> dummyReviewList = [
    { 'user': '김학생', 'comment': '정말 맛있어요! 양도 충분히 든든합니다.', 'date': '2025-09-27' },
    { 'user': '이학생', 'comment': '가격 대비 만족스러워요.', 'date': '2025-09-27' },
    { 'user': '박학생', 'comment': '적당히 맛있습니다.', 'date': '2025-09-23' },
    { 'user': '장학생', 'comment': '다음번에도 우삼겹 덮밥 먹을 것 같습니다.', 'date': '2025-09-18' },
    { 'user': '정학생', 'comment': '매일 먹어도 질리지 않을 것 같아요.', 'date': '2025-09-17' },
  ];
  //리뷰 작성 팝업 띄움
  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ReviewModal();
      },
    );
  }

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
        title: Text(
          "메뉴 상세",
          style: TextStyle(
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: Color(0xFFE5E7EB),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menuName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      //가짜 별점 표시
                      Row(
                        children: [
                          Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                          SizedBox(width: 4),
                          Text(
                            "4.5 (26)",
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFD1D5DB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "AI 요약",
                                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "한줄 요약",
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        //가짜 AI 요약 텍스트
                        Text(
                          "AI 리뷰 요약",
                          style: TextStyle(color: Color(0xFF6B6280)),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(
                    "사용자 리뷰",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dummyReviewList.length,
                  itemBuilder: (context, index) {
                    final review = dummyReviewList[index];
                    return Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFD1D5DB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                review['user']!,
                                style: TextStyle(
                                  color: Color(0xFF373737),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                review['date']!,
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                              Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                              Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                              Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                              Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            review['comment']!,
                            style: TextStyle(color: Color(0xFF374151)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                _showReviewModal(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F2937),
                foregroundColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                "리뷰 작성하기",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}