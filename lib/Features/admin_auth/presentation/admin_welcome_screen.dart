import 'package:catalyst_flutter_app/Core/Components/html_preview_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/cookie_storage.dart';
import 'package:flutter/material.dart';

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({super.key});

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen> {
  int _selectedMenuIndex = 1;
  int _selectedMailingPageIndex = 0;
  int _selectedSqlTableIndex = 0;
  bool _loadingMailingPages = false;
  bool _loadingMailingPageHtml = false;
  bool _savingMailingPageHtml = false;
  bool _removingMailingPageHtml = false;
  bool _loadingRestrictions = false;
  bool _savingRestrictions = false;
  bool _loadingSqlTables = false;
  bool _loadingSqlColumns = false;
  bool _loadingSqlData = false;
  String? _mailingPagesError;
  String? _mailingPageHtmlError;
  String? _sqlTablesError;
  String? _sqlColumnsError;
  String? _sqlDataError;
  String? _restrictionsError;
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
  String _sendMode = 'now';
  DateTime _sendScheduleDate = DateUtils.dateOnly(DateTime.now());
  String _sendRepeat = 'none';
  final TextEditingController _htmlEditorCtrl = TextEditingController();
  final TextEditingController _restrictionsCtrl = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

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

    if (index == 0) {
      await _loadMailingPages();
    } else if (index == 1) {
      await _loadRestrictions();
    } else if (index == 2) {
      await _loadSqlTables();
    }
  }

  Future<void> _loadRestrictions() async {
    setState(() {
      _loadingRestrictions = true;
      _restrictionsError = null;
    });

    final text = await _authService.getAdminRestrictionsText();
    if (!mounted) return;

    if (text == null) {
      setState(() {
        _loadingRestrictions = false;
        _restrictionsError = 'Could not load registration restrictions.';
      });
      return;
    }

    setState(() {
      _loadingRestrictions = false;
      _restrictionsCtrl.text = text;
    });
  }

  Future<void> _saveRestrictions() async {
    setState(() {
      _savingRestrictions = true;
    });

    final success =
        await _authService.saveAdminRestrictionsText(_restrictionsCtrl.text);
    if (!mounted) return;

    setState(() {
      _savingRestrictions = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Registration restrictions saved.'
              : 'Failed to save registration restrictions.',
        ),
      ),
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
      _sqlColumnsError = null;
      _sqlColumns = const [];
      _sqlRowsData = const [];
      _sqlDataError = null;
    });

    try {
      final columns = await _authService.getAdminSqlColumns(tableName);
      if (!mounted) return;
      setState(() {
        _sqlColumns = columns;
      });
      if (columns.isNotEmpty) {
        await _loadSqlData(tableName, columns);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sqlColumns = const [];
        _sqlColumnsError = 'Could not load SQL columns.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingSqlColumns = false;
      });
    }
  }

  Future<void> _loadSqlData(String tableName, List<String> columns) async {
    setState(() {
      _loadingSqlData = true;
      _sqlDataError = null;
      _sqlRowsData = const [];
    });

    try {
      final List<List<String>> columnData = [];
      for (final column in columns) {
        final data = await _authService.getAdminSqlColumnData(
          tableName: tableName,
          columnName: column,
        );
        columnData.add(data);
      }

      if (!mounted) return;

      int maxRows = 0;
      for (final values in columnData) {
        if (values.length > maxRows) {
          maxRows = values.length;
        }
      }

      final rows = List.generate(maxRows, (rowIndex) {
        return List.generate(columns.length, (colIndex) {
          final values = columnData[colIndex];
          return rowIndex < values.length ? values[rowIndex] : '';
        });
      });

      setState(() {
        _sqlRowsData = rows;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sqlRowsData = const [];
        _sqlDataError = 'Could not load SQL data.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
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

    setState(() {
      _loadingMailingPageHtml = false;
      final hasContent = html != null && html.isNotEmpty;
      _selectedMailingPageHtml = html ?? '';
      _htmlEditorCtrl.text = html ?? '';
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
      success = await _authService.sendAdminMailingPageNow(
        htmlName: htmlName,
        groups: groups,
      );
      successMessage = 'Page "$htmlName" sent.';
      failureMessage = 'Failed to send "$htmlName".';
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
    _restrictionsCtrl.dispose();
    super.dispose();
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
            onChanged: _sendingMailingPage
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _sendMode = value;
                    });
                  },
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
      'Registration Restrictions',
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
            child: _selectedMenuIndex == 0
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
                : _selectedMenuIndex == 2
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
                    : _selectedMenuIndex == 1
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registration Restrictions',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: _loadingRestrictions
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _restrictionsError != null
                                          ? Center(
                                              child: Text(
                                                _restrictionsError!,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                            )
                                          : TextField(
                                              controller: _restrictionsCtrl,
                                              expands: true,
                                              maxLines: null,
                                              minLines: null,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _loadingRestrictions ||
                                            _savingRestrictions
                                        ? null
                                        : _saveRestrictions,
                                    child: _savingRestrictions
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          )
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
