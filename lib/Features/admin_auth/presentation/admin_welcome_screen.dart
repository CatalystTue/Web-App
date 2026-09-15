import 'dart:async';

import 'package:catalyst_flutter_app/Core/Components/html_preview_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/cookie_storage.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/admin_asset_name.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({super.key});

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen> {
  static const int _menuMailing = 0;
  static const int _menuAssets = 1;
  static const int _menuRestrictions = 2;
  static const int _menuUserLinks = 3;
  static const int _menuSql = 4;

  int _selectedMenuIndex = _menuRestrictions;
  int _selectedMailingPageIndex = 0;
  int _selectedSqlTableIndex = 0;
  int _selectedAssetIndex = 0;
  bool _loadingMailingPages = false;
  bool _loadingMailingPageHtml = false;
  bool _savingMailingPageHtml = false;
  bool _removingMailingPageHtml = false;
  bool _loadingAssets = false;
  bool _loadingAssetBytes = false;
  bool _savingAsset = false;
  bool _renamingAsset = false;
  bool _removingAsset = false;
  bool _loadingRestrictions = false;
  bool _mutatingRestrictions = false;
  bool _loadingSqlTables = false;
  bool _loadingSqlColumns = false;
  bool _loadingSqlData = false;
  bool _creatingLink = false;
  bool _deletingLink = false;
  bool _sendingLinks = false;
  String? _mailingPagesError;
  String? _mailingPageHtmlError;
  String? _sqlTablesError;
  String? _sqlColumnsError;
  String? _sqlDataError;
  String? _restrictionsError;
  String? _assetsError;
  String? _assetBytesError;
  List<String> _restrictionDomains = const [];
  final _userPicker = _AdminUserPicker();
  final _otherUserPicker = _AdminUserPicker();
  List<String> _mailingPages = const [];
  List<String> _assets = const [];
  Uint8List? _selectedAssetBytes;
  List<String> _sqlTables = const [];
  List<String> _sqlColumns = const [];
  List<List<String>> _sqlRowsData = const [];
  String? _selectedMailingPageHtml;
  String _htmlViewMode = 'preview';
  bool _sendingMailingPage = false;
  bool _loadingSendSchedule = false;
  static const List<String> _availableSendGroups = <String>['All Users'];
  static const Set<String> _validRepeatValues = <String>{
    'none',
    'weekly',
    'biweekly',
    'monthly',
  };
  final Set<String> _selectedSendGroups = <String>{'All Users'};
  String _sendMode = 'schedule';
  DateTime _sendScheduleDate = DateUtils.dateOnly(DateTime.now());
  String _sendRepeat = 'none';
  final TextEditingController _htmlEditorCtrl = TextEditingController();
  final TextEditingController _linkIdCtrl = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_ensureAdminSession()) return;
      _loadRestrictions();
    });
  }

  bool _ensureAdminSession() {
    if (!AppRepo().hasAccessToken) {
      final cookieToken = CookieStorage.readToken()?.trim();
      if (cookieToken != null && cookieToken.isNotEmpty) {
        AppRepo().jwtToken = cookieToken;
      }
    }
    if (AppRepo().hasAccessToken && AppRepo().isAdminSession) {
      return true;
    }
    Get.offAllNamed(AppConfig().routes.admin);
    return false;
  }

  Future<void> _logout() async {
    await AppRepo().clearSession();
    Get.offAllNamed(AppConfig().routes.admin);
  }

  Future<void> _createNewMailingPage() async {
    final TextEditingController pageNameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New File'),
          content: TextField(
            controller: pageNameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'File name (e.g. welcome.html)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(pageNameCtrl.text.trim()),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    pageNameCtrl.dispose();

    if (!mounted) return;
    if (result == null || result.isEmpty) return;

    final success = await _authService.saveAdminMailingPage(
      htmlName: result,
      htmlContent: '',
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create new file.'),
        ),
      );
      return;
    }

    await _loadMailingPages();
    if (!mounted) return;

    final newIndex = _mailingPages.indexOf(result);
    if (newIndex != -1) {
      await _onMailingPageTap(newIndex);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File "$result" created successfully.'),
      ),
    );
  }

  Future<void> _onMainMenuTap(int index) async {
    setState(() {
      _selectedMenuIndex = index;
    });

    if (index == _menuMailing) {
      await _loadMailingPages();
    } else if (index == _menuAssets) {
      await _loadAssets();
    } else if (index == _menuRestrictions) {
      await _loadRestrictions();
    } else if (index == _menuSql) {
      await _loadSqlTables();
    }
  }

  Future<void> _loadAssets() async {
    setState(() {
      _loadingAssets = true;
      _assetsError = null;
      _selectedAssetIndex = 0;
      _selectedAssetBytes = null;
      _assetBytesError = null;
    });

    final names = await _authService.getAdminAssets();
    if (!mounted) return;

    if (names == null) {
      setState(() {
        _loadingAssets = false;
        _assets = const [];
        _assetsError = 'Could not load assets.';
      });
      return;
    }

    setState(() {
      _loadingAssets = false;
      _assets = names;
    });
  }

  Future<void> _onAssetTap(int index) async {
    if (index < 0 || index >= _assets.length) return;
    final name = _assets[index];
    setState(() {
      _selectedAssetIndex = index;
      _loadingAssetBytes = true;
      _assetBytesError = null;
      _selectedAssetBytes = null;
    });

    final bytes = await _authService.getAdminAssetBytes(name);
    if (!mounted) return;

    if (bytes == null) {
      setState(() {
        _loadingAssetBytes = false;
        _assetBytesError = 'Could not load asset.';
      });
      return;
    }

    setState(() {
      _loadingAssetBytes = false;
      _selectedAssetBytes = bytes;
    });
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _uploadAsset() async {
    final picked = await FilePicker.platform.pickFiles(withData: true);
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final name = file.name.trim();
    final bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) return;
      _snack('Failed to save asset.');
      return;
    }
    if (!isValidAdminAssetName(name)) {
      if (!mounted) return;
      _snack('Invalid asset name.');
      return;
    }

    setState(() => _savingAsset = true);
    final success = await _authService.saveAdminAsset(name: name, bytes: bytes);
    if (!mounted) return;
    setState(() => _savingAsset = false);

    if (!success) {
      _snack('Failed to save asset.');
      return;
    }

    await _loadAssets();
    if (!mounted) return;
    final newIndex = _assets.indexOf(name);
    if (newIndex != -1) {
      await _onAssetTap(newIndex);
    }
    if (!mounted) return;
    _snack('Asset "$name" saved.');
  }

  Future<void> _copyAssetName() async {
    if (_assets.isEmpty || _selectedAssetIndex >= _assets.length) return;
    final name = _assets[_selectedAssetIndex];
    await Clipboard.setData(ClipboardData(text: name));
    if (!mounted) return;
    _snack('Copied "$name".');
  }

  Future<void> _renameCurrentAsset() async {
    if (_assets.isEmpty || _selectedAssetIndex >= _assets.length) return;
    final oldName = _assets[_selectedAssetIndex];
    final nameCtrl = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename asset'),
          content: TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New file name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(nameCtrl.text.trim()),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    nameCtrl.dispose();
    if (!mounted || result == null) return;

    if (!isValidAdminAssetName(result)) {
      _snack('Invalid asset name.');
      return;
    }
    if (result == oldName) {
      _snack('Enter a new name.');
      return;
    }

    setState(() => _renamingAsset = true);
    var bytes = _selectedAssetBytes;
    bytes ??= await _authService.getAdminAssetBytes(oldName);
    if (!mounted) return;
    if (bytes == null) {
      setState(() => _renamingAsset = false);
      _snack('Failed to rename asset.');
      return;
    }

    final putOk =
        await _authService.saveAdminAsset(name: result, bytes: bytes);
    if (!mounted) return;
    if (!putOk) {
      setState(() => _renamingAsset = false);
      _snack('Failed to rename asset.');
      return;
    }

    final deleteOk = await _authService.removeAdminAsset(oldName);
    if (!mounted) return;
    setState(() => _renamingAsset = false);
    if (!deleteOk) {
      _snack('Failed to rename asset.');
      await _loadAssets();
      return;
    }

    await _loadAssets();
    if (!mounted) return;
    final newIndex = _assets.indexOf(result);
    if (newIndex != -1) {
      await _onAssetTap(newIndex);
    }
    if (!mounted) return;
    _snack('Asset renamed to "$result".');
  }

  Future<void> _removeCurrentAsset() async {
    if (_assets.isEmpty || _selectedAssetIndex >= _assets.length) return;
    final name = _assets[_selectedAssetIndex];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove asset'),
          content: Text('Are you sure you want to permanently remove "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) return;

    setState(() => _removingAsset = true);
    final success = await _authService.removeAdminAsset(name);
    if (!mounted) return;
    setState(() => _removingAsset = false);

    if (!success) {
      _snack('Failed to remove asset.');
      return;
    }

    await _loadAssets();
    if (!mounted) return;
    _snack('Asset "$name" removed.');
  }

  Widget _buildAssetsPanel() {
    final name = CookieStorage.readAdminName() ?? 'Admin';
    return Row(
      children: [
        Container(
          width: 280,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: AppConfig().colors.txtColor,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Assets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add asset',
                      onPressed: _loadingAssets || _savingAsset
                          ? null
                          : _uploadAsset,
                      icon: _savingAsset
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loadingAssets
                    ? const Center(child: CircularProgressIndicator())
                    : _assetsError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _assetsError!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _assets.isEmpty
                            ? const Center(child: Text('No assets found.'))
                            : ListView.builder(
                                itemCount: _assets.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_assets[index]),
                                    selected: _selectedAssetIndex == index,
                                    selectedTileColor: AppConfig()
                                        .colors
                                        .secondaryColor
                                        .withOpacity(0.15),
                                    onTap: () => _onAssetTap(index),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingAssetBytes
              ? const Center(child: CircularProgressIndicator())
              : _assetBytesError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _assetBytesError!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _assets.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Welcome $name',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _selectedAssetBytes == null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Select a file to preview.',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _assets[_selectedAssetIndex],
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Center(
                                      child: Image.memory(
                                        _selectedAssetBytes!,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Text(
                                            'No preview for this file.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: _copyAssetName,
                                        child: const Text('Copy name'),
                                      ),
                                      OutlinedButton(
                                        onPressed: _renamingAsset ||
                                                _removingAsset
                                            ? null
                                            : _renameCurrentAsset,
                                        child: _renamingAsset
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text('Rename'),
                                      ),
                                      ElevatedButton(
                                        onPressed: _renamingAsset ||
                                                _removingAsset
                                            ? null
                                            : _removeCurrentAsset,
                                        child: _removingAsset
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
        ),
      ],
    );
  }

  int? _parseId(String value) => int.tryParse(value.trim());

  int? _idFromUser(Map<String, dynamic>? user) {
    final raw = user?['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  String _userLabel(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    if (name.isNotEmpty && email.isNotEmpty) return '$name  $email';
    if (name.isNotEmpty) return name;
    if (email.isNotEmpty) return email;
    return user['id']?.toString() ?? '';
  }

  void _onPickerChanged(_AdminUserPicker picker, String value) {
    picker.debounce?.cancel();
    final query = value.trim();
    setState(() {
      picker.selected = null;
      picker.results = const [];
      picker.error = null;
      picker.loading = false;
    });
    if (query.isEmpty) return;

    picker.debounce = Timer(const Duration(milliseconds: 400), () {
      _searchPickerUsers(picker, query);
    });
  }

  Future<void> _searchPickerUsers(
    _AdminUserPicker picker,
    String query,
  ) async {
    setState(() {
      picker.loading = true;
      picker.error = null;
    });

    final users = await _authService.getAdminUsers(q: query);
    if (!mounted) return;
    if (picker.controller.text.trim() != query) return;

    setState(() {
      picker.loading = false;
      if (users == null) {
        picker.results = const [];
        picker.error = 'Could not load users.';
      } else {
        picker.results = users;
      }
    });
  }

  void _selectPickerUser(
    _AdminUserPicker picker,
    Map<String, dynamic> user,
  ) {
    picker.debounce?.cancel();
    picker.controller.text = _userLabel(user);
    setState(() {
      picker.selected = user;
      picker.results = const [];
      picker.error = null;
      picker.loading = false;
    });
  }

  Future<void> _createLink() async {
    final userId = _idFromUser(_userPicker.selected);
    final otherId = _idFromUser(_otherUserPicker.selected);
    if (userId == null || otherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select two users.')),
      );
      return;
    }

    setState(() {
      _creatingLink = true;
    });
    final created = await _authService.createAdminLink(
      userId: userId,
      otherId: otherId,
    );
    if (!mounted) return;
    setState(() {
      _creatingLink = false;
    });
    if (created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link created.')),
    );
  }

  Future<void> _deleteLink() async {
    final linkId = _parseId(_linkIdCtrl.text);
    if (linkId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a link id.')),
      );
      return;
    }

    setState(() {
      _deletingLink = true;
    });
    final success = await _authService.deleteAdminLink(linkId);
    if (!mounted) return;
    setState(() {
      _deletingLink = false;
    });
    if (!success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link deleted.')),
    );
  }

  Future<void> _sendLinks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _sendingLinks = true;
    });
    final sent = await _authService.sendAdminLinks();
    if (!mounted) return;
    setState(() {
      _sendingLinks = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent == null
              ? 'Failed to send intro mail.'
              : 'Sent $sent intro mail(s).',
        ),
      ),
    );
  }

  Future<void> _loadRestrictions() async {
    setState(() {
      _loadingRestrictions = true;
      _restrictionsError = null;
    });

    final domains = await _authService.getAdminRestrictionDomains();
    if (!mounted) return;

    if (domains == null) {
      setState(() {
        _loadingRestrictions = false;
        _restrictionDomains = const [];
        _restrictionsError = 'Could not load registration restrictions.';
      });
      return;
    }

    setState(() {
      _loadingRestrictions = false;
      _restrictionDomains = domains;
    });
  }

  Future<String?> _promptDomain({
    required String title,
    required String actionLabel,
    String initial = '',
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Domain (hostname, email, or URL)',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) =>
                Navigator.of(dialogContext).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || result.isEmpty) return null;
    return result;
  }

  Future<void> _addRestrictionDomain() async {
    final domain = await _promptDomain(
      title: 'Add domain',
      actionLabel: 'Add',
    );
    if (domain == null || !mounted) return;

    setState(() {
      _mutatingRestrictions = true;
    });
    final success = await _authService.addAdminRestrictionDomain(domain);
    if (!mounted) return;
    setState(() {
      _mutatingRestrictions = false;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save registration restrictions.'),
        ),
      );
      return;
    }
    await _loadRestrictions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Domain added.')),
    );
  }

  Future<void> _editRestrictionDomain(String current) async {
    final replacement = await _promptDomain(
      title: 'Edit domain',
      actionLabel: 'Save',
      initial: current,
    );
    if (replacement == null || !mounted) return;

    setState(() {
      _mutatingRestrictions = true;
    });
    final success = await _authService.replaceAdminRestrictionDomain(
      current: current,
      replacement: replacement,
    );
    if (!mounted) return;
    setState(() {
      _mutatingRestrictions = false;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save registration restrictions.'),
        ),
      );
      return;
    }
    await _loadRestrictions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Domain updated.')),
    );
  }

  Future<void> _removeRestrictionDomain(String domain) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove domain?'),
          content: Text('Remove $domain from registration restrictions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _mutatingRestrictions = true;
    });
    final success = await _authService.deleteAdminRestrictionDomain(domain);
    if (!mounted) return;
    setState(() {
      _mutatingRestrictions = false;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save registration restrictions.'),
        ),
      );
      return;
    }
    await _loadRestrictions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Domain removed.')),
    );
  }

  Future<void> _loadMailingPages() async {
    setState(() {
      _loadingMailingPages = true;
      _mailingPagesError = null;
      _selectedMailingPageIndex = 0;
      _selectedMailingPageHtml = null;
      _mailingPageHtmlError = null;
    });

    try {
      final pages = await _authService.getAdminMailingListPages();
      if (!mounted) return;
      setState(() {
        _mailingPages = pages;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mailingPages = const [];
        _mailingPagesError = 'Could not load mailing list pages.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingMailingPages = false;
      });
    }
  }

  Future<void> _loadSqlTables() async {
    setState(() {
      _loadingSqlTables = true;
      _sqlTablesError = null;
      _selectedSqlTableIndex = 0;
      _sqlColumns = const [];
      _sqlColumnsError = null;
      _sqlRowsData = const [];
      _sqlDataError = null;
    });

    try {
      final tables = await _authService.getAdminSqlTables();
      if (!mounted) return;
      setState(() {
        _sqlTables = tables;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sqlTables = const [];
        _sqlTablesError = 'Could not load SQL tables.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingSqlTables = false;
      });
    }
  }

  Future<void> _onSqlTableTap(int index) async {
    final tableName = _sqlTables[index];
    setState(() {
      _selectedSqlTableIndex = index;
      _loadingSqlColumns = true;
      _loadingSqlData = true;
      _sqlColumnsError = null;
      _sqlColumns = const [];
      _sqlRowsData = const [];
      _sqlDataError = null;
    });

    try {
      final data = await _authService.getAdminSqlTableData(tableName);
      if (!mounted) return;
      if (data == null) {
        setState(() {
          _sqlColumns = const [];
          _sqlRowsData = const [];
          _sqlColumnsError = 'Could not load SQL table.';
        });
        return;
      }
      setState(() {
        _sqlColumns = data.columns;
        _sqlRowsData = data.rows;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sqlColumns = const [];
        _sqlRowsData = const [];
        _sqlColumnsError = 'Could not load SQL table.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingSqlColumns = false;
        _loadingSqlData = false;
      });
    }
  }

  Future<void> _onMailingPageTap(int index) async {
    final pageName = _mailingPages[index];
    setState(() {
      _selectedMailingPageIndex = index;
      _loadingMailingPageHtml = true;
      _mailingPageHtmlError = null;
      _selectedMailingPageHtml = null;
    });

    final html = await _authService.getAdminMailingPageHtml(pageName);
    if (!mounted) return;

    if (html == null) {
      setState(() {
        _loadingMailingPageHtml = false;
        _mailingPageHtmlError = 'Could not load page HTML.';
      });
      return;
    }

    setState(() {
      _loadingMailingPageHtml = false;
      final hasContent = html.isNotEmpty;
      _selectedMailingPageHtml = html;
      _htmlEditorCtrl.text = html;
      _htmlViewMode = hasContent ? 'preview' : 'text';
      _selectedSendGroups
        ..clear()
        ..add('All Users');
      _sendMode = 'now';
      _sendScheduleDate = DateUtils.dateOnly(DateTime.now());
      _sendRepeat = 'none';
    });
  }

  Future<void> _saveCurrentMailingPage() async {
    if (_mailingPages.isEmpty ||
        _selectedMailingPageIndex >= _mailingPages.length) {
      return;
    }

    final htmlName = _mailingPages[_selectedMailingPageIndex];
    final htmlContent = _htmlEditorCtrl.text;

    setState(() {
      _savingMailingPageHtml = true;
    });

    final success = await _authService.saveAdminMailingPage(
      htmlName: htmlName,
      htmlContent: htmlContent,
    );

    if (!mounted) return;

    setState(() {
      _savingMailingPageHtml = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Page "$htmlName" saved successfully.'
              : 'Failed to save "$htmlName".',
        ),
      ),
    );
  }

  Future<void> _removeCurrentMailingPage() async {
    if (_mailingPages.isEmpty ||
        _selectedMailingPageIndex >= _mailingPages.length) {
      return;
    }

    final htmlName = _mailingPages[_selectedMailingPageIndex];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove file'),
          content: Text(
            'Are you sure you want to permanently remove "$htmlName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;

    setState(() {
      _removingMailingPageHtml = true;
    });

    final success = await _authService.removeAdminMailingPage(htmlName);

    if (!mounted) return;

    setState(() {
      _removingMailingPageHtml = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Page "$htmlName" removed.'
              : 'Failed to remove "$htmlName".',
        ),
      ),
    );

    if (!success) return;

    await _loadMailingPages();
    if (!mounted) return;

    if (_mailingPages.isNotEmpty) {
      await _onMailingPageTap(0);
    } else {
      setState(() {
        _selectedMailingPageHtml = null;
        _htmlEditorCtrl.clear();
        _mailingPageHtmlError = null;
      });
    }
  }

  Future<void> _loadSendSchedule() async {
    if (_mailingPages.isEmpty ||
        _selectedMailingPageIndex >= _mailingPages.length) {
      return;
    }
    final htmlName = _mailingPages[_selectedMailingPageIndex];

    setState(() {
      _loadingSendSchedule = true;
    });

    final config = await _authService.getAdminMailingPageSchedule(htmlName);

    if (!mounted) return;
    if (_htmlViewMode != 'send' ||
        _selectedMailingPageIndex >= _mailingPages.length ||
        _mailingPages[_selectedMailingPageIndex] != htmlName) {
      setState(() {
        _loadingSendSchedule = false;
      });
      return;
    }

    setState(() {
      _loadingSendSchedule = false;
      if (config == null) {
        return;
      }

      final groupsAny = config['groups'] ?? config['Groups'];
      if (groupsAny is List) {
        final loaded = groupsAny
            .map((e) => e?.toString())
            .whereType<String>()
            .where((g) => g.isNotEmpty)
            .toSet();
        if (loaded.isNotEmpty) {
          _selectedSendGroups
            ..clear()
            ..addAll(loaded);
        }
      }

      DateTime? parsedDate;
      final dateAny = config['date'] ?? config['Date'];
      if (dateAny is String && dateAny.isNotEmpty) {
        parsedDate = DateTime.tryParse(dateAny);
      }
      if (parsedDate != null) {
        final today = DateUtils.dateOnly(DateTime.now());
        final dateOnly = DateUtils.dateOnly(parsedDate);
        _sendScheduleDate = dateOnly.isBefore(today) ? today : dateOnly;
      }

      final repeatAny = config['repeat'] ?? config['Repeat'];
      if (repeatAny is String && _validRepeatValues.contains(repeatAny)) {
        _sendRepeat = repeatAny;
      }

      _sendMode = 'schedule';
    });
  }

  Future<void> _sendMailingPage() async {
    if (_mailingPages.isEmpty ||
        _selectedMailingPageIndex >= _mailingPages.length) {
      return;
    }
    if (_selectedSendGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one recipient group.'),
        ),
      );
      return;
    }

    final htmlName = _mailingPages[_selectedMailingPageIndex];
    final groups = _selectedSendGroups.toList();

    setState(() {
      _sendingMailingPage = true;
    });

    bool success;
    String successMessage;
    String failureMessage;

    if (_sendMode == 'now') {
      success = false;
      successMessage = '';
      failureMessage = 'Send now is not available yet.';
    } else {
      success = await _authService.scheduleAdminMailingPage(
        htmlName: htmlName,
        groups: groups,
        date: _sendScheduleDate,
        repeat: _sendRepeat,
      );
      successMessage = 'Scheduled "$htmlName" for '
          '${_sendScheduleDate.year}-'
          '${_sendScheduleDate.month.toString().padLeft(2, '0')}-'
          '${_sendScheduleDate.day.toString().padLeft(2, '0')}.';
      failureMessage = 'Failed to schedule "$htmlName".';
    }

    if (!mounted) return;

    setState(() {
      _sendingMailingPage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : failureMessage),
      ),
    );
  }

  @override
  void dispose() {
    _htmlEditorCtrl.dispose();
    _userPicker.dispose();
    _otherUserPicker.dispose();
    _linkIdCtrl.dispose();
    super.dispose();
  }

  Widget _busyButtonChild(bool busy, String label) {
    if (!busy) return Text(label);
    return const SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildRestrictionsPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Registration Restrictions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _loadingRestrictions || _mutatingRestrictions
                    ? null
                    : _addRestrictionDomain,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingRestrictions
                ? const Center(child: CircularProgressIndicator())
                : _restrictionsError != null
                    ? Center(
                        child: Text(
                          _restrictionsError!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : _restrictionDomains.isEmpty
                        ? const Center(
                            child: Text('No registration domains.'),
                          )
                        : ListView.separated(
                            itemCount: _restrictionDomains.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final domain = _restrictionDomains[index];
                              return ListTile(
                                title: Text(domain),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed: _mutatingRestrictions
                                          ? null
                                          : () =>
                                              _editRestrictionDomain(domain),
                                      icon: const Icon(Icons.edit_outlined),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove',
                                      onPressed: _mutatingRestrictions
                                          ? null
                                          : () =>
                                              _removeRestrictionDomain(domain),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserLinksPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Links', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildUserPickerField(
            label: 'User',
            picker: _userPicker,
          ),
          const SizedBox(height: 16),
          _buildUserPickerField(
            label: 'Other user',
            picker: _otherUserPicker,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _creatingLink ? null : _createLink,
              child: _busyButtonChild(_creatingLink, 'Create link'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _linkIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Link id',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _deletingLink ? null : _deleteLink,
                child: _busyButtonChild(_deletingLink, 'Delete link'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _sendingLinks ? null : _sendLinks,
              child: _busyButtonChild(_sendingLinks, 'Send intros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPickerField({
    required String label,
    required _AdminUserPicker picker,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: picker.controller,
          onChanged: (value) => _onPickerChanged(picker, value),
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Search affiliation, name, or email',
            border: const OutlineInputBorder(),
          ),
        ),
        if (picker.loading)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: LinearProgressIndicator(),
          ),
        if (picker.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(picker.error!),
          )
        else if (picker.controller.text.trim().isNotEmpty &&
            picker.selected == null &&
            !picker.loading &&
            picker.results.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('No users found.'),
          )
        else if (picker.results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConfig().colors.backGroundColor,
                width: 0.6,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: picker.results.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppConfig().colors.backGroundColor,
              ),
              itemBuilder: (context, index) {
                final user = picker.results[index];
                final id = user['id']?.toString() ?? '';
                final name = user['name']?.toString() ?? '';
                final affiliation = user['affiliation']?.toString() ?? '';
                final email = user['email']?.toString() ?? '';
                return ListTile(
                  dense: true,
                  title: Text('$id  $name'),
                  subtitle: Text('$affiliation  $email'),
                  onTap: () => _selectPickerUser(picker, user),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSendForm() {
    if (_loadingSendSchedule) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final firstDate = DateUtils.dateOnly(DateTime.now());
    final lastDate =
        DateTime(firstDate.year + 5, firstDate.month, firstDate.day);
    if (_sendScheduleDate.isBefore(firstDate)) {
      _sendScheduleDate = firstDate;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recipients', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final group in _availableSendGroups)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(group),
              value: _selectedSendGroups.contains(group),
              onChanged: _sendingMailingPage
                  ? null
                  : (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedSendGroups.add(group);
                        } else {
                          _selectedSendGroups.remove(group);
                        }
                      });
                    },
            ),
          const SizedBox(height: 24),
          Text('When to send', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: 'now',
            groupValue: _sendMode,
            title: const Text('Send Now'),
            subtitle: const Text('Not available yet'),
            onChanged: null,
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: 'schedule',
            groupValue: _sendMode,
            title: const Text('Schedule for later'),
            onChanged: _sendingMailingPage
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _sendMode = value;
                    });
                  },
          ),
          if (_sendMode == 'schedule') ...[
            const SizedBox(height: 16),
            Text('Pick a date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppConfig().colors.lightGrayColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 320,
                child: CalendarDatePicker(
                  initialDate: _sendScheduleDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) {
                    setState(() {
                      _sendScheduleDate = DateUtils.dateOnly(date);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Repeat', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final entry in const [
              MapEntry('none', "Don't repeat"),
              MapEntry('weekly', 'Every Week'),
              MapEntry('biweekly', 'Every Two Weeks'),
              MapEntry('monthly', 'Every Month'),
            ])
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: entry.key,
                groupValue: _sendRepeat,
                title: Text(entry.value),
                onChanged: _sendingMailingPage
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _sendRepeat = value;
                        });
                      },
              ),
          ],
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _sendingMailingPage || _selectedSendGroups.isEmpty
                  ? null
                  : _sendMailingPage,
              child: _sendingMailingPage
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_sendMode == 'now' ? 'Send Now' : 'Schedule'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = CookieStorage.readAdminName() ?? 'Admin';
    final menuItems = const [
      'Mailing List',
      'Assets',
      'Registration Restrictions',
      'User Links',
      'SQL Tables',
    ];
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Welcome',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 260,
            color: AppConfig().colors.darkYellow.withOpacity(0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (int i = 0; i < menuItems.length; i++)
                  ListTile(
                    title: Text(menuItems[i]),
                    selected: _selectedMenuIndex == i,
                    selectedTileColor:
                        AppConfig().colors.secondaryColor.withOpacity(0.15),
                    onTap: () => _onMainMenuTap(i),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _selectedMenuIndex == _menuMailing
                ? Row(
                    children: [
                      Container(
                        width: 280,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: AppConfig().colors.txtColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Email files',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Add new file',
                                    onPressed: _loadingMailingPages
                                        ? null
                                        : _createNewMailingPage,
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: _loadingMailingPages
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _mailingPagesError != null
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              _mailingPagesError!,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : _mailingPages.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  'No mailing list pages found.'),
                                            )
                                          : ListView.builder(
                                              itemCount: _mailingPages.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(
                                                      _mailingPages[index]),
                                                  selected:
                                                      _selectedMailingPageIndex ==
                                                          index,
                                                  selectedTileColor: AppConfig()
                                                      .colors
                                                      .secondaryColor
                                                      .withOpacity(0.15),
                                                  onTap: () {
                                                    _onMailingPageTap(index);
                                                  },
                                                );
                                              },
                                            ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _loadingMailingPageHtml
                            ? const Center(child: CircularProgressIndicator())
                            : _mailingPageHtmlError != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        _mailingPageHtmlError!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : _selectedMailingPageHtml == null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Text(
                                            _mailingPages.isEmpty
                                                ? 'Welcome $name'
                                                : 'Select a page to load its HTML content.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: AppConfig()
                                                        .colors
                                                        .txtColor,
                                                    width: 0.5,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _htmlViewMode = 'text';
                                                      });
                                                    },
                                                    child: Text(
                                                      'Text Only',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            _htmlViewMode ==
                                                                    'text'
                                                                ? FontWeight
                                                                    .w700
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _htmlViewMode =
                                                            'preview';
                                                      });
                                                    },
                                                    child: Text(
                                                      'Preview',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            _htmlViewMode ==
                                                                    'preview'
                                                                ? FontWeight
                                                                    .w700
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    onPressed: () {
                                                      final wasAlreadySend =
                                                          _htmlViewMode ==
                                                              'send';
                                                      setState(() {
                                                        _htmlViewMode = 'send';
                                                      });
                                                      if (!wasAlreadySend) {
                                                        _loadSendSchedule();
                                                      }
                                                    },
                                                    child: Text(
                                                      'Send',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            _htmlViewMode ==
                                                                    'send'
                                                                ? FontWeight
                                                                    .w700
                                                                : FontWeight
                                                                    .w400,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: _htmlViewMode == 'text'
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: TextField(
                                                              controller:
                                                                  _htmlEditorCtrl,
                                                              expands: true,
                                                              maxLines: null,
                                                              minLines: null,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .multiline,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyMedium
                                                                  ?.copyWith(
                                                                    fontFamily:
                                                                        'monospace',
                                                                  ),
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                _selectedMailingPageHtml =
                                                                    value;
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 12),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              ElevatedButton
                                                                  .icon(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                                onPressed: _removingMailingPageHtml ||
                                                                        _savingMailingPageHtml
                                                                    ? null
                                                                    : _removeCurrentMailingPage,
                                                                icon: _removingMailingPageHtml
                                                                    ? const SizedBox(
                                                                        height:
                                                                            16,
                                                                        width:
                                                                            16,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(
                                                                            Colors.white,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : const Icon(Icons.delete_outline),
                                                                label: const Text(
                                                                    'Remove'),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              ElevatedButton(
                                                                onPressed: _savingMailingPageHtml ||
                                                                        _removingMailingPageHtml
                                                                    ? null
                                                                    : _saveCurrentMailingPage,
                                                                child: _savingMailingPageHtml
                                                                    ? const SizedBox(
                                                                        height:
                                                                            16,
                                                                        width:
                                                                            16,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                      )
                                                                    : const Text('Save'),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : _htmlViewMode == 'send'
                                                      ? _buildSendForm()
                                                      : buildHtmlPreview(
                                                          _selectedMailingPageHtml!,
                                                        ),
                                            ),
                                          ],
                                        ),
                                      ),
                      ),
                    ],
                  )
                : _selectedMenuIndex == _menuAssets
                    ? _buildAssetsPanel()
                    : _selectedMenuIndex == _menuSql
                    ? Row(
                        children: [
                          Container(
                            width: 280,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: AppConfig().colors.lightGrayColor,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: _loadingSqlTables
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _sqlTablesError != null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            _sqlTablesError!,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : _sqlTables.isEmpty
                                        ? const Center(
                                            child: Text('No SQL tables found.'),
                                          )
                                        : ListView.builder(
                                            itemCount: _sqlTables.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                title: Text(_sqlTables[index]),
                                                selected:
                                                    _selectedSqlTableIndex ==
                                                        index,
                                                selectedTileColor: AppConfig()
                                                    .colors
                                                    .secondaryColor
                                                    .withOpacity(0.15),
                                                onTap: () {
                                                  _onSqlTableTap(index);
                                                },
                                              );
                                            },
                                          ),
                          ),
                          Expanded(
                            child: _loadingSqlColumns || _loadingSqlData
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : _sqlColumnsError != null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Text(
                                            _sqlColumnsError!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : _sqlDataError != null
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Text(
                                                _sqlDataError!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : _sqlColumns.isEmpty
                                            ? Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(24),
                                                  child: Text(
                                                    _sqlTables.isEmpty
                                                        ? 'Welcome $name'
                                                        : 'Select a SQL table to load columns.',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Table: ${_sqlTables[_selectedSqlTableIndex]}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child:
                                                            SingleChildScrollView(
                                                          child: DataTable(
                                                            columns: _sqlColumns
                                                                .map(
                                                                  (column) =>
                                                                      DataColumn(
                                                                    label: Text(
                                                                        column),
                                                                  ),
                                                                )
                                                                .toList(),
                                                            rows: _sqlRowsData
                                                                .map(
                                                                  (row) =>
                                                                      DataRow(
                                                                    cells: row
                                                                        .map(
                                                                          (cell) =>
                                                                              DataCell(
                                                                            Text(cell),
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                  ),
                                                                )
                                                                .toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                          ),
                        ],
                      )
                    : _selectedMenuIndex == _menuRestrictions
                        ? _buildRestrictionsPanel()
                        : _selectedMenuIndex == _menuUserLinks
                            ? _buildUserLinksPanel()
                            : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Welcome $name\n\nSelected: ${menuItems[_selectedMenuIndex]}',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _AdminUserPicker {
  final controller = TextEditingController();
  Timer? debounce;
  List<Map<String, dynamic>> results = const [];
  bool loading = false;
  String? error;
  Map<String, dynamic>? selected;

  void dispose() {
    debounce?.cancel();
    controller.dispose();
  }
}
