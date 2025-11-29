import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dku_bears_kitchen/screens/my_reviews_screen.dart';
import 'package:dku_bears_kitchen/screens/login_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("로그인이 필요한 서비스입니다.")),
      );
    }

    final String myUserId = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "내 정보",
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔥 1. 프로필 카드 (Firestore 'users' 컬렉션에서 데이터 가져오기)
              StreamBuilder<DocumentSnapshot>(
                // users 컬렉션에서 내 UID에 해당하는 문서 실시간 구독
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(myUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  // 데이터 로딩 중일 때 표시할 기본값
                  String nickname = "로딩 중...";
                  String department = "단국대학교";
                  String studentId = "";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    // Firestore에 저장된 필드명 그대로 가져오기
                    nickname = data['nickname'] ?? "이름 없음";
                    department = data['department'] ?? "학과 미정";
                    studentId = data['studentId'] ?? "";
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFE5E5E5),
                            shape: OvalBorder(),
                          ),
                          child: const Icon(Icons.person, color: Colors.grey, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 닉네임 (예: 김승현)
                            Text(
                              nickname,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF111111)),
                            ),
                            const SizedBox(height: 4),
                            // 학과 + 학번 (예: 컴퓨터공학과 32210821)
                            Text(
                              "$department $studentId",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF666666)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 2. 통계 카드 (내가 쓴 리뷰 수 / 평균 별점)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collectionGroup('reviews')
                    .where('userId', isEqualTo: myUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  int reviewCount = 0;
                  double avgRating = 0.0;

                  if (snapshot.hasData) {
                    final docs = snapshot.data!.docs;
                    reviewCount = docs.length;
                    if (reviewCount > 0) {
                      double total = 0;
                      for (var doc in docs) {
                        total += (doc['rating'] ?? 0);
                      }
                      avgRating = total / reviewCount;
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(reviewCount.toString(), "총 리뷰"),
                        Container(width: 1, height: 40, color: const Color(0xFFF3F4F6)),
                        _buildStatItem(avgRating.toStringAsFixed(1), "평균 별점"),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 3. 메뉴 리스트
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(context, "내가 쓴 리뷰", isTop: true, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyReviewsScreen()),
                      );
                    }),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _buildMenuItem(context, "공지사항"),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    _buildMenuItem(context, "설정"),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),

                    // 로그아웃
                    _buildMenuItem(context, "로그아웃", isBottom: true, isDestructive: true, onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, {bool isTop = false, bool isBottom = false, bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(16) : Radius.zero,
        bottom: isBottom ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF373737),
          ),
        ),
      ),
    );
  }
}