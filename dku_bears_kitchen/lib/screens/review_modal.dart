import 'package:flutter/material.dart';

// '리뷰 작성' 팝업 전용 위젯
// (⭐'StatefulWidget'이어야 함! -> '별점'을 '기억'해야 하므로)
class ReviewModal extends StatefulWidget {
  const ReviewModal({super.key});

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  // --- (⭐ 1. '기억' 변수가 여기로 이사옴 ⭐) ---
  int _rating = 0; // "사용자가 선택한 별점을 '기억'"

  @override
  Widget build(BuildContext context) {
    // 팝업이 키보드에 가려지지 않도록 패딩을 줌
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 컨텐츠 높이만큼만
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                "리뷰 작성",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "이 메뉴의 경험은 어떠셨나요?",
                style: TextStyle(
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    // (⭐ 2. '기억' 변수 _rating 사용 ⭐)
                    index < _rating ? Icons.star : Icons.star_border_outlined,
                    color: index < _rating ? Color(0xFFFACC15) : Color(0xFFD1D5DB),
                    size: 36,
                  ),
                  onPressed: () {
                    // (⭐ 3. '기억' 업데이트 및 화면 새로고침 ⭐)
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "이 메뉴에 대한 리뷰를 남겨주세요",
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFF3F4F6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFF3F4F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // DB연결: 13. 여기서 _rating, 텍스트를 Firebase DB에 저장
                  Navigator.pop(context); // 모달 닫기
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
                  "등록",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}