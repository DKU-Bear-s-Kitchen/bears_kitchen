import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // 🔥 리뷰 업로드 + [식당 평점]만 계산하는 함수
  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인이 필요한 서비스입니다.")),
      );
      return;
    }

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
      // 📝 트랜잭션: 식당 점수만 업데이트합니다.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. 참조(Reference) 준비
        final storeRef = FirebaseFirestore.instance.collection('stores').doc(widget.storeId);

        // 리뷰는 여전히 메뉴 하위에 저장됩니다 (구조 유지)
        final reviewRef = storeRef
            .collection('menus')
            .doc(widget.menuId)
            .collection('reviews')
            .doc();

        // 2. [식당] 데이터 읽기 (Read)
        final storeSnapshot = await transaction.get(storeRef);

        if (!storeSnapshot.exists) {
          throw Exception("식당 정보를 찾을 수 없습니다.");
        }

        // 3. [식당] 평균 평점 재계산 🧮
        final double currentAvg = (storeSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int currentCount = (storeSnapshot.data()?['reviewCount'] as num?)?.toInt() ?? 0;

        final int newCount = currentCount + 1;
        // 새로운 평균 = ((기존평균 * 기존개수) + 내점수) / 새개수
        final double newAvg = ((currentAvg * currentCount) + _rating) / newCount;

        // 4. 데이터 쓰기 (Write)

        // (1) 리뷰 저장 (메뉴 하위에)
        transaction.set(reviewRef, {
          'rating': _rating,
          'content': _reviewController.text.trim(),
          'author': '익명 곰',
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'menuName': widget.menuName,
          'storeId': widget.storeId,
        });

        // (2) 식당 문서 업데이트 (별점, 리뷰 개수) 🔥 메뉴 업데이트는 제외됨!
        transaction.update(storeRef, {
          'averageRating': newAvg,
          'reviewCount': newCount,
        });
      });

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 등록 완료! (식당 평점에 반영됨) 🐻")),
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