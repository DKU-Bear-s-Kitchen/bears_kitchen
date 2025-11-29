import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModal extends StatefulWidget {
  final String storeId;
  final String menuId;
  final String menuName;

  const ReviewModal({
    super.key,
    required this.storeId,
    required this.menuId,
    required this.menuName,
  });

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // 🔥 리뷰 업로드 함수
  Future<void> _submitReview() async {
    // 1. 유효성 검사
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("별점을 선택해주세요!")),
      );
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 내용을 입력해주세요!")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 2. Firestore 저장
      // 경로: stores -> {storeId} -> menus -> {menuId} -> reviews
      await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .collection('menus')
          .doc(widget.menuId)
          .collection('reviews')
          .add({
        'rating': _rating,
        'content': _reviewController.text.trim(),
        'author': '김단국', // 마이페이지 디자인에 맞춰 이름 설정
        'createdAt': FieldValue.serverTimestamp(),

        // 🔥 [중요] 내 정보(마이페이지) 연동을 위한 필수 데이터
        'userId': 'user_01', // 현재 로그인한 유저 ID (임시)
        'menuName': widget.menuName, // 어떤 메뉴인지 (리스트에 표시용)
        'storeId': widget.storeId,   // 어떤 식당인지
      });

      if (!mounted) return;

      Navigator.pop(context); // 모달 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰가 등록되었습니다! 🐻")),
      );
    } catch (e) {
      print("리뷰 저장 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류가 발생했습니다. 다시 시도해주세요.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 키보드가 올라왔을 때 화면 가림 방지
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
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
            const SizedBox(height: 20),
            Center(
              child: Text(
                "${widget.menuName} 어떠셨나요?",
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 별점 선택 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border_outlined,
                    color: index < _rating ? const Color(0xFFFACC15) : const Color(0xFFD1D5DB),
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),

            // 리뷰 내용 입력창
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "솔직한 맛 평가를 남겨주세요",
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF3F4F6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "등록",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}