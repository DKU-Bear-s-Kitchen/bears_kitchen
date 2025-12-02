import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dku_bears_kitchen/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // 📝 입력 컨트롤러 (내 정보 수정용)
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  bool _isLoading = true;
  bool _isNotificationOn = true; // 알림 스위치 (임시)

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 들어오자마자 내 정보 불러오기
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  // 🔥 1. Firestore에서 내 정보 불러오기
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nicknameController.text = data['nickname'] ?? '';
            _departmentController.text = data['department'] ?? '';
            _studentIdController.text = data['studentId'] ?? '';
          });
        }
      } catch (e) {
        print("데이터 불러오기 오류: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  // 🔥 2. 수정된 정보 저장하기
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus(); // 키보드 내리기

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'nickname': _nicknameController.text.trim(),
        'department': _departmentController.text.trim(),
        'studentId': _studentIdController.text.trim(),
      });

      // Firebase Auth 프로필 이름도 동기화
      await user.updateDisplayName(_nicknameController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("정보가 성공적으로 수정되었습니다! ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("저장에 실패했습니다.")),
      );
    }
  }

  // 🔥 3. 로그아웃
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // 🔥 4. 회원 탈퇴 (경고 팝업 후 삭제)
  void _deleteAccountConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("정말 탈퇴하시겠습니까?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("계정 정보가 즉시 삭제되며 복구할 수 없습니다.\n작성한 리뷰는 '알 수 없음'으로 남습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 팝업 닫고 진행
              _processDeleteAccount();
            },
            child: const Text("탈퇴하기", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _processDeleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // DB 정보 삭제 -> 계정 삭제 -> 로그인 화면 이동
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("탈퇴가 완료되었습니다.")));
    } catch (e) {
      // 보안상 재로그인 필요 시
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("오류가 발생했습니다. 로그아웃 후 다시 로그인해서 시도해주세요.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("설정", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. 개인정보 수정 섹션 ---
                    _buildSectionTitle("개인정보 수정"),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          _buildTextField("닉네임", _nicknameController),
                          const SizedBox(height: 16),
                          _buildTextField("학과", _departmentController),
                          const SizedBox(height: 16),
                          _buildTextField("학번", _studentIdController, isNumber: true),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F2937),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("변경사항 저장", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 2. 앱 설정 섹션 ---
                    _buildSectionTitle("앱 설정"),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("알림 설정", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            value: _isNotificationOn,
                            activeColor: const Color(0xFF1F2937),
                            onChanged: (val) => setState(() => _isNotificationOn = val),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text("앱 버전", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            trailing: const Text("v1.0.0", style: TextStyle(color: Colors.grey)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text("문의하기", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 3. 계정 관리 섹션 ---
                    _buildSectionTitle("계정 관리"),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text("로그아웃", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            onTap: _logout,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text("회원 탈퇴", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red)),
                            onTap: _deleteAccountConfirm,
                          ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (val) => val!.isEmpty ? "입력해주세요" : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
          ),
        ),
      ],
    );
  }
}