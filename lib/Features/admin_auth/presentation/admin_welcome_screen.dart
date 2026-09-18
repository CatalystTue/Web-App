import 'dart:async';

import 'package:catalyst_flutter_app/Core/Components/html_preview_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/cookie_storage.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/admin_mail_plan.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({super.key});

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen> {
  static const int _menuMailing = 0;
  static const int _menuMailPlans = 1;
  static const int _menuRestrictions = 2;
  static const int _menuUserLinks = 3;
  static const int _menuSql = 4;

  int _selectedMenuIndex = _menuRestrictions;
  int _selectedMailingPageIndex = 0;
  int _selectedSqlTableIndex = 0;
  bool _loadingMailingPages = false;
  bool _loadingMailingPageHtml = false;
  bool _savingMailingPageHtml = false;
  bool _removingMailingPageHtml = false;
  bool _loadingRestrictions = false;
  bool _mutatingRestrictions = false;
  bool _loadingSqlTables = false;
  bool _loadingSqlColumns = false;
  bool _loadingSqlData = false;
  bool _creatingLink = false;
  bool _deletingLink = false;
  bool _sendingLinks = false;
  bool _loadingDigestPlan = false;
  bool _loadingIntroPlan = false;
  bool _savingDigestPlan = false;
  bool _savingIntroPlan = false;
  String? _digestPlanError;
  String? _introPlanError;
  bool _digestEnabled = false;
  String _digestRepeat = 'daily';
  DateTime _digestNextAt = DateUtils.dateOnly(DateTime.now());
  int _digestCalendarEpoch = 0;
  bool _introEnabled = false;
  DateTime _introNextAt = DateUtils.dateOnly(DateTime.now());
  int _introCalendarEpoch = 0;
  String? _mailingPagesError;
  String? _mailingPageHtmlError;
  String? _sqlTablesError;
  String? _sqlColumnsError;
  String? _sqlDataError;
  String? _restrictionsError;
  List<String> _restrictionDomains = const [];
  final _userPicker = _AdminUserPicker();
  final _otherUserPicker = _AdminUserPicker();
  List<String> _mailingPages = const [];
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
    } else if (index == _menuMailPlans) {
      await _loadMailPlans();
    } else if (index == _menuRestrictions) {
      await _loadRestrictions();
    } else if (index == _menuSql) {
      await _loadSqlTables();
    }
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

  DateTime _fallbackMailPlanNextAt() =>
      DateTime.now().add(const Duration(hours: 1));

  Future<void> _loadMailPlans() async {
    setState(() {
      _loadingDigestPlan = true;
      _loadingIntroPlan = true;
      _digestPlanError = null;
      _introPlanError = null;
    });
    await Future.wait(<Future<void>>[
      _loadDigestPlan(),
      _loadIntroPlan(),
    ]);
  }

  Future<void> _loadDigestPlan() async {
    final json = await _authService.getAdminDigestPlan();
    if (!mounted) return;
    if (json == null) {
      setState(() {
        _loadingDigestPlan = false;
        _digestPlanError = 'Could not load digest plan.';
      });
      return;
    }
    final plan = AdminMailPlan.parse(json);
    setState(() {
      _loadingDigestPlan = false;
      _digestEnabled = plan.enabled;
      _digestRepeat = normalizeDigestRepeat(plan.repeat);
      _digestNextAt = DateUtils.dateOnly(
        plan.nextAt ?? _fallbackMailPlanNextAt(),
      );
      _digestCalendarEpoch++;
    });
  }

  Future<void> _loadIntroPlan() async {
    final json = await _authService.getAdminIntroPlan();
    if (!mounted) return;
    if (json == null) {
      setState(() {
        _loadingIntroPlan = false;
        _introPlanError = 'Could not load intro plan.';
      });
      return;
    }
    final plan = AdminMailPlan.parse(json);
    setState(() {
      _loadingIntroPlan = false;
      _introEnabled = plan.enabled;
      _introNextAt = DateUtils.dateOnly(
        plan.nextAt ?? _fallbackMailPlanNextAt(),
      );
      _introCalendarEpoch++;
    });
  }

  Future<void> _saveDigestPlan() async {
    if (_digestEnabled && !canPutEnabledMailDate(_digestNextAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('next_at must be in the future')),
      );
      return;
    }
    setState(() {
      _savingDigestPlan = true;
    });
    final ok = await _authService.putAdminDigestPlan(
      digestPlanBody(
        enabled: _digestEnabled,
        repeat: _digestRepeat,
        nextAt: _digestNextAt,
      ),
    );
    if (!mounted) return;
    setState(() {
      _savingDigestPlan = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Digest plan saved.' : 'Failed to save digest plan.'),
      ),
    );
    if (ok) await _loadDigestPlan();
  }

  Future<void> _saveIntroPlan() async {
    if (_introEnabled && !canPutEnabledMailDate(_introNextAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('next_at must be in the future')),
      );
      return;
    }
    setState(() {
      _savingIntroPlan = true;
    });
    final ok = await _authService.putAdminIntroPlan(
      introPlanBody(
        enabled: _introEnabled,
        nextAt: _introEnabled ? _introNextAt : null,
      ),
    );
    if (!mounted) return;
    setState(() {
      _savingIntroPlan = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Intro plan saved.' : 'Failed to save intro plan.'),
      ),
    );
    if (ok) await _loadIntroPlan();
  }

  Widget _buildMailPlanCalendar({
    required int epoch,
    required DateTime selected,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDay = DateUtils.dateOnly(selected);
    final first = selectedDay.isBefore(today) ? selectedDay : today;
    var last = DateTime(today.year + 5, today.month, today.day);
    if (selectedDay.isAfter(last)) last = selectedDay;
    return Container(
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
          key: ValueKey(epoch),
          initialDate: selectedDay,
          firstDate: first,
          lastDate: last,
          onDateChanged: onDateChanged,
        ),
      ),
    );
  }

  Widget _buildMailPlansPanel() {
    final theme = Theme.of(context);
    final loading = _loadingDigestPlan || _loadingIntroPlan;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mail Plans', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Send time is fixed on the server. Digest repeats from the chosen '
            'date. Intro fires once on that date then turns off. Send now mails '
            'remaining intros immediately.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Text('Interest digest', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_digestPlanError != null)
              Text(_digestPlanError!, style: theme.textTheme.titleMedium)
            else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enabled'),
                value: _digestEnabled,
                onChanged: _savingDigestPlan
                    ? null
                    : (value) {
                        setState(() {
                          _digestEnabled = value;
                        });
                      },
              ),
              DropdownButtonFormField<String>(
                value: _digestRepeat,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'biweekly', child: Text('Biweekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: _savingDigestPlan
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _digestRepeat = value;
                        });
                      },
              ),
              const SizedBox(height: 16),
              Text('Next at', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildMailPlanCalendar(
                epoch: _digestCalendarEpoch,
                selected: _digestNextAt,
                onDateChanged: (date) {
                  setState(() {
                    _digestNextAt = DateUtils.dateOnly(date);
                  });
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _savingDigestPlan ? null : _saveDigestPlan,
                  child: _busyButtonChild(_savingDigestPlan, 'Save'),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text('Intro mail', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_introPlanError != null)
              Text(_introPlanError!, style: theme.textTheme.titleMedium)
            else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enabled'),
                value: _introEnabled,
                onChanged: _savingIntroPlan
                    ? null
                    : (value) {
                        setState(() {
                          _introEnabled = value;
                        });
                      },
              ),
              Text('Next at', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildMailPlanCalendar(
                epoch: _introCalendarEpoch,
                selected: _introNextAt,
                onDateChanged: (date) {
                  setState(() {
                    _introNextAt = DateUtils.dateOnly(date);
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _sendingLinks || _savingIntroPlan
                        ? null
                        : _sendLinks,
                    child: _busyButtonChild(_sendingLinks, 'Send now'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _savingIntroPlan ? null : _saveIntroPlan,
                    child: _busyButtonChild(_savingIntroPlan, 'Save'),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
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
      'Mail Plans',
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
                : _selectedMenuIndex == _menuMailPlans
                    ? _buildMailPlansPanel()
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
