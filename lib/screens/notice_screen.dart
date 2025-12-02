import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷용

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "공지사항",
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 'notices' 컬렉션을 날짜 내림차순(최신순)으로 가져옴
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("공지사항을 불러오지 못했습니다."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("등록된 공지사항이 없습니다.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = notices[index].data() as Map<String, dynamic>;

              // 날짜 변환
              String dateStr = "";
              if (data['date'] != null) {
                final Timestamp ts = data['date'];
                dateStr = DateFormat('yyyy.MM.dd').format(ts.toDate());
              }

              // ✅ 접이식 리스트 아이템 (ExpansionTile)
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Theme(
                  // 펼쳤을 때 위아래 구분선 없애기 위한 테마 설정
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      data['title'] ?? '제목 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dateStr,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                      ),
                    ),
                    children: [
                      // 펼쳐졌을 때 나오는 내용
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Text(
                          data['content'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4B5563),
                            height: 1.6, // 줄 간격
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}