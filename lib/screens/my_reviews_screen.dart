import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 인증 패키지 추가
import 'package:intl/intl.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 [수정] 현재 로그인한 유저 정보 가져오기
    final user = FirebaseAuth.instance.currentUser;

    // 만약 로그인이 안 된 상태라면 (예외 처리)
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("로그인이 필요한 서비스입니다.")),
      );
    }

    final String myUserId = user.uid; // ✅ 실제 내 UID 사용

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "내가 쓴 리뷰",
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔥 Collection Group Query: 앱 전체 'reviews' 중 내 UID로 쓴 것만 검색
        stream: FirebaseFirestore.instance
            .collectionGroup('reviews')
            .where('userId', isEqualTo: myUserId) // 👈 여기서 진짜 ID로 필터링
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. 에러가 났을 때 (주로 인덱스 설정 안 해서 발생)
          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }

          // 3. 데이터가 없을 때
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "아직 작성한 리뷰가 없습니다.\n학식을 먹고 첫 리뷰를 남겨보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final data = reviews[index].data() as Map<String, dynamic>;

              // 날짜 변환 (Timestamp -> String)
              String dateStr = "";
              if (data['createdAt'] != null) {
                final Timestamp ts = data['createdAt'];
                dateStr = DateFormat('yyyy-MM-dd').format(ts.toDate());
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 메뉴 이름 표시
                        Text(
                          data['menuName'] ?? '메뉴 정보 없음',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 별점 표시
                    Row(
                      children: List.generate(5, (i) => Icon(
                        Icons.star,
                        size: 16,
                        color: i < (data['rating'] ?? 0) ? const Color(0xFFFACC15) : Colors.grey[300]
                      )),
                    ),
                    const SizedBox(height: 10),
                    // 리뷰 내용
                    Text(
                      data['content'] ?? '',
                      style: const TextStyle(color: Color(0xFF374151)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}