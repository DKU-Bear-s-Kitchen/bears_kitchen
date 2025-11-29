import 'dart:convert'; // JSON 파싱용
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart'; // ✅ Firebase AI 패키지
import 'package:dku_bears_kitchen/screens/ai_result_screen.dart'; // 결과 화면 import

class AiRecommendScreen extends StatefulWidget {
  const AiRecommendScreen({super.key});

  @override
  State<AiRecommendScreen> createState() => _AiRecommendScreenState();
}

class _AiRecommendScreenState extends State<AiRecommendScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isGenerating = false;

  // 추천 태그 리스트
  final List<String> _tags = ["#매운음식", "#가볍게", "#든든하게", "#해장", "#가성비"];

  /// 🔥 AI에게 추천 요청하는 함수
  Future<void> _recommendMenu() async {
    final userInput = _textController.text.trim();
    if (userInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("드시고 싶은 메뉴의 특징을 적어주세요!")),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 1. Firestore에서 메뉴 데이터 가져오기 (AI 참고용)
      // 비용 절약을 위해 필요한 필드만 문자열로 변환합니다.
      final menuSnapshot = await FirebaseFirestore.instance.collectionGroup('menus').get();

      // 메뉴 리스트를 문자열로 변환 (이름:가격)
      final menuListString = menuSnapshot.docs.map((doc) {
        final data = doc.data();
        return "${data['name']}:${data['price']}원";
      }).join(', ');

      // ✅ 2. 모델 준비 (ReviewScreen과 동일한 방식 적용)
      // 무료 Developer API 사용 (FirebaseAI.googleAI)
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash', // ⚠️ 오류 발생 시 'gemini-1.5-flash'로 변경하세요.
        // 중요: 결과 화면에 예쁘게 뿌려주기 위해 JSON 형식을 강제합니다.
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      // 3. 프롬프트 작성
      final promptText = '''
      너는 대학교 학식 메뉴 추천 전문가야.
      
      [사용자 요구] "$userInput"
      [판매 중인 메뉴 목록] $menuListString

      위 목록 중에서 사용자 요구에 가장 잘 맞는 메뉴 2~3개를 추천해줘.
      반드시 아래와 같은 JSON 배열 형식으로만 대답해. (이유는 1문장으로 친절하게)
      
      [
        {
          "name": "메뉴이름",
          "price": "가격(숫자와 ,포함)",
          "reason": "추천 이유 설명",
          "tags": ["#태그1", "#태그2"]
        }
      ]
      ''';

      // 4. 요청 및 응답 처리
      final content = [Content.text(promptText)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        // JSON 파싱 (AI가 준 텍스트를 앱에서 쓸 수 있는 리스트로 변환)
        final List<dynamic> jsonList = jsonDecode(response.text!);
        final List<Map<String, dynamic>> resultList = List<Map<String, dynamic>>.from(jsonList);

        if (!mounted) return;

        // ✅ 결과 화면으로 이동 (데이터 전달)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiResultScreen(recommendedMenus: resultList),
          ),
        );
      }

    } catch (e) {
      print("AI Error: $e");
      String errorMsg = "추천에 실패했습니다. 다시 시도해주세요.";

      if (e.toString().contains('not found')) {
        errorMsg = "모델을 찾을 수 없습니다. (모델명을 gemini-1.5-flash로 변경해보세요)";
      } else if (e.toString().contains('quota')) {
        errorMsg = "사용량이 많아 잠시 쉬고 있습니다. 1분 뒤 시도해주세요.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _addTag(String tag) {
    String cleanTag = tag.replaceAll('#', '');
    _textController.text = "${_textController.text} $cleanTag".trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("AI 메뉴 추천", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                '오늘 너에게\n맞는 학식은?',
                style: TextStyle(
                  color: Color(0xFF1F2937), fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '단국대학교 학생들을 위한 AI 학식 추천',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 30),

              // 입력창
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '오늘 너의 식사를 적어보세요.\n예: 얼큰한 국물이 땡겨!',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 태그 버튼들
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _tags.map((tag) {
                  return GestureDetector(
                    onTap: () => _addTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(tag, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      // 하단 버튼
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _recommendMenu,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: _isGenerating
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('AI에게 보내기', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}