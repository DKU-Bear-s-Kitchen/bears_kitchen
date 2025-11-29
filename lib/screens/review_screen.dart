import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dku_bears_kitchen/screens/review_modal.dart';
// ✅ Google 공식 Firebase AI 패키지
import 'package:firebase_ai/firebase_ai.dart';
import 'package:intl/intl.dart';

class ReviewScreen extends StatefulWidget {
  final String storeId;
  final String menuId;
  final String menuName;
  final String menuPrice;

  const ReviewScreen({
    super.key,
    required this.storeId,
    required this.menuId,
    required this.menuName,
    required this.menuPrice,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _aiSummaryText = "리뷰가 쌓이면 요약 버튼을 눌러보세요!";
  bool _isGenerating = false;

  // 🔥 Firebase AI Logic (Gemini Developer API) 요약 함수
  Future<void> _generateAiSummary(List<String> reviews) async {
    if (reviews.isEmpty) {
      setState(() => _aiSummaryText = "요약할 리뷰가 부족해요.");
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // ✅ 1. 모델 생성 (여기서 바로 만듭니다!)
      // FirebaseAI.googleAI() -> 무료 Developer API 사용
      // 모델명: 문서에 나온 2.5가 안 되면 'gemini-1.5-flash'로 바꿔보세요.
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemin'
            'i-2.5-flash',
      );

      // ✅ 2. 글자 수 제한 (비용 절약 및 에러 방지)
      // 리뷰를 최대 10개, 각각 100자까지만 잘라서 보냅니다.
      List<String> safeReviews = reviews.take(10).map((r) {
         return r.length > 100 ? r.substring(0, 100) : r;
      }).toList();

      final prompt = '''
      다음은 메뉴 "${widget.menuName}"의 리뷰야. "맛, 양, 가격"을 중심으로 한 문장으로 요약해줘. "~해요"체 사용.
      [리뷰 목록]
      ${safeReviews.join('\n')}
      ''';

      // ✅ 3. 요청 보내기
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiSummaryText = response.text ?? "요약 실패";
      });

    } catch (e) {
      print("Firebase AI Error: $e");
      String errorMsg = "오류가 발생했습니다.";

      if (e.toString().contains('quota')) {
        errorMsg = "사용량이 많아 잠시 쉬고 있어요. 나중에 다시 시도해주세요.";
      } else if (e.toString().contains('not found')) {
        errorMsg = "모델을 찾을 수 없습니다. (모델명을 gemini-1.5-flash로 바꿔보세요)";
      }

      setState(() {
        _aiSummaryText = errorMsg;
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ReviewModal(storeId: widget.storeId, menuId: widget.menuId, menuName: widget.menuName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text("메뉴 상세", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220, width: double.infinity, color: const Color(0xFFE5E7EB),
                  child: const Center(child: Icon(Icons.fastfood, size: 80, color: Colors.white)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.menuName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(widget.menuPrice, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                    ],
                  ),
                ),

                // ✨ AI 요약 표시 영역
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                                  child: const Text("AI 요약", style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                const Text("한줄 요약", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            // 새로고침 버튼
                            IconButton(
                              icon: _isGenerating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.refresh, size: 20, color: Colors.grey),
                              onPressed: () async {
                                final snapshot = await FirebaseFirestore.instance
                                    .collection('stores').doc(widget.storeId)
                                    .collection('menus').doc(widget.menuId)
                                    .collection('reviews')
                                    .orderBy('createdAt', descending: true)
                                    .limit(10)
                                    .get();

                                final texts = snapshot.docs.map((doc) => doc['content'] as String).toList();
                                _generateAiSummary(texts);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_aiSummaryText, style: const TextStyle(color: Color(0xFF4B5563), height: 1.4)),
                      ],
                    ),
                  ),
                ),

                const Padding(padding: EdgeInsets.all(20), child: Text("사용자 리뷰", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stores').doc(widget.storeId)
                      .collection('menus').doc(widget.menuId)
                      .collection('reviews').orderBy('createdAt', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final reviews = snapshot.data!.docs;
                    if (reviews.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("아직 리뷰가 없어요."));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final r = reviews[index].data() as Map<String, dynamic>;
                        String dateStr = "";
                        if (r['createdAt'] != null) {
                          final Timestamp ts = r['createdAt'];
                          dateStr = DateFormat('yyyy-MM-dd').format(ts.toDate());
                        }

                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD1D5DB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r['author'] ?? '익명', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < (r['rating'] ?? 0) ? Colors.amber : Colors.grey[300]))),
                              const SizedBox(height: 8),
                              Text(r['content'] ?? ''),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20, left: 16, right: 16,
            child: ElevatedButton(
              onPressed: () => _showReviewModal(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("리뷰 작성하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}