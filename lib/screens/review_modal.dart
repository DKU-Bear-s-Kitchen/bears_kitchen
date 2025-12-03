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

  // 🔥 리뷰 업로드 + [식당 평점] + [메뉴 평점] 동시 계산 함수
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
      // 📝 트랜잭션 시작: 식당과 메뉴의 점수를 동시에 수정합니다.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. 참조(Reference) 준비
        final storeRef = FirebaseFirestore.instance.collection('stores').doc(widget.storeId);
        final menuRef = storeRef.collection('menus').doc(widget.menuId);
        final newReviewRef = menuRef.collection('reviews').doc(); // 새 리뷰 문서

        // 2. 데이터 읽기 (Read) - 식당과 메뉴 정보를 모두 가져옵니다.
        final storeSnapshot = await transaction.get(storeRef);
        final menuSnapshot = await transaction.get(menuRef);

        if (!storeSnapshot.exists || !menuSnapshot.exists) {
          throw Exception("식당이나 메뉴 정보를 찾을 수 없습니다.");
        }

        // 3. [식당] 평균 계산 🧮
        final double storeAvg = (storeSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int storeCount = (storeSnapshot.data()?['reviewCount'] as num?)?.toInt() ?? 0;

        final int newStoreCount = storeCount + 1;
        final double newStoreAvg = ((storeAvg * storeCount) + _rating) / newStoreCount;

        // 4. [메뉴] 평균 계산 🧮
        final double menuAvg = (menuSnapshot.data()?['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int menuCount = (menuSnapshot.data()?['reviewCount'] as num?)?.toInt() ?? 0;

        final int newMenuCount = menuCount + 1;
        final double newMenuAvg = ((menuAvg * menuCount) + _rating) / newMenuCount;

        // 5. 데이터 쓰기 (Write) - 3가지를 한꺼번에 처리

        // (1) 리뷰 저장
        transaction.set(newReviewRef, {
          'rating': _rating,
          'content': _reviewController.text.trim(),
          'author': '익명 곰',
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'menuName': widget.menuName,
          'storeId': widget.storeId,
        });

        // (2) 식당 정보 업데이트 (홈 화면용) 🔥
        transaction.update(storeRef, {
          'averageRating': newStoreAvg,
          'reviewCount': newStoreCount,
        });

        // (3) 메뉴 정보 업데이트 (메뉴 리스트용) 🔥
        transaction.update(menuRef, {
          'averageRating': newMenuAvg,
          'reviewCount': newMenuCount,
        });
      });

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("리뷰 등록 완료! (식당 및 메뉴 평점 반영됨) 🐻")),
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