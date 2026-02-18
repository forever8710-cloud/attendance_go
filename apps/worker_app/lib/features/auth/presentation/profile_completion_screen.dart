import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/address_service.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _ssnFrontController = TextEditingController();
  final _ssnBackController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  final _accountController = TextEditingController();

  String? _selectedSite;
  String? _selectedBank;

  static const _banks = [
    '국민은행', '신한은행', '우리은행', '하나은행',
    'NH농협', 'IBK기업', '카카오뱅크', '토스뱅크',
    'SC제일', '대구은행', '부산은행', '경남은행',
    '광주은행', '전북은행', '제주은행', '우체국',
    '새마을금고', '신협', '수협', '케이뱅크',
  ];

  @override
  void dispose() {
    _ssnFrontController.dispose();
    _ssnBackController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final workerName = authState.worker?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('추가정보 입력'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(authProvider.notifier).signOut(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$workerName님, 환영합니다!',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '최초 로그인 시 아래 정보를 입력해주세요.\n급여 지급 및 인사관리에 사용됩니다.',
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 28),

            // ── 소속 센터 ──
            const Text('소속 센터',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final sitesAsync = ref.watch(workerSiteNamesProvider);
                final sites = sitesAsync.valueOrNull ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _selectedSite,
                  decoration: InputDecoration(
                    hintText: sites.isEmpty ? '로딩 중...' : '센터 선택',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: sites
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSite = v),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── 주민등록번호 ──
            const Text('주민등록번호',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ssnFrontController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      hintText: '앞 6자리',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('-', style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: TextField(
                    controller: _ssnBackController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7),
                    ],
                    decoration: const InputDecoration(
                      hintText: '뒤 7자리',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 주소 ──
            const Text('주소',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: '주소 검색',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showAddressSearch(context),
                ),
              ),
              onTap: () => _showAddressSearch(context),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailAddressController,
              decoration: const InputDecoration(
                hintText: '상세주소 입력',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // ── 급여 계좌 ──
            const Text('급여 계좌',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedBank,
              decoration: const InputDecoration(
                hintText: '은행 선택',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              items: _banks
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBank = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '계좌번호 입력 (숫자만)',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),

            if (authState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(authState.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isLoading ? null : _onSave,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('저장하고 시작하기',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (_selectedSite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('소속 센터를 선택해주세요.')),
      );
      return;
    }
    if (_ssnFrontController.text.length != 6 ||
        _ssnBackController.text.length != 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주민등록번호를 정확히 입력해주세요.')),
      );
      return;
    }
    // 주민번호 뒷자리 첫 숫자 검증 (1~4만 유효)
    final firstDigit = int.tryParse(_ssnBackController.text[0]);
    if (firstDigit == null || firstDigit < 1 || firstDigit > 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주민등록번호가 올바르지 않습니다.')),
      );
      return;
    }
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 검색해주세요.')),
      );
      return;
    }
    if (_selectedBank == null || _accountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('급여 계좌 정보를 입력해주세요.')),
      );
      return;
    }

    final ssn =
        '${_ssnFrontController.text}-${_ssnBackController.text}';
    ref.read(authProvider.notifier).saveProfile(
          site: _selectedSite!,
          ssn: ssn,
          address: _addressController.text,
          detailAddress: _detailAddressController.text,
          bank: _selectedBank!,
          accountNumber: _accountController.text,
        );
  }

  void _showAddressSearch(BuildContext context) {
    final confmKey = dotenv.env['JUSO_CONFIRM_KEY'] ?? '';
    if (confmKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소 검색 API가 설정되지 않았습니다. 관리자에게 문의하세요.')),
      );
      return;
    }
    final service = AddressService(confmKey);

    List<AddressResult> results = [];
    bool isSearching = false;
    String lastQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> doSearch(String query) async {
              if (query.trim().length < 2) {
                setSheetState(() {
                  results = [];
                  lastQuery = query;
                });
                return;
              }
              setSheetState(() {
                isSearching = true;
                lastQuery = query;
              });
              final found = await service.search(query);
              // 결과 반영 전 쿼리가 변경되었으면 무시
              if (lastQuery == query) {
                setSheetState(() {
                  results = found;
                  isSearching = false;
                });
              }
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('주소 검색',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      confmKey.isEmpty
                          ? '(JUSO_CONFIRM_KEY 미설정 — juso.go.kr에서 발급)'
                          : '도로명, 지번, 건물명으로 검색하세요',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      onChanged: doSearch,
                      decoration: InputDecoration(
                        hintText: '예: 이천시 호법면',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                            child:
                                CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (results.isEmpty &&
                        lastQuery.trim().length >= 2)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: AppColors.textHint),
                              const SizedBox(height: 8),
                              Text(
                                confmKey.isEmpty
                                    ? 'API 키가 설정되지 않았습니다'
                                    : '검색 결과가 없습니다',
                                style: TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final addr = results[i];
                            return ListTile(
                              leading: const Icon(Icons.location_on,
                                  color: Colors.indigo),
                              title: Text(
                                addr.roadAddr,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                '[${addr.zipNo}] ${addr.jibunAddr}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint),
                              ),
                              onTap: () {
                                _addressController.text = addr.roadAddr;
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
