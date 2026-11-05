import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_utils_ext.dart';
import '../../core/widgets/brutalist_confirm_dialog.dart';
import '../../models/hangout_session_model.dart';
import '../../providers/hangouts_provider.dart';
import '../../providers/records_provider.dart';
import '../../providers/settings_provider.dart';
import 'who_owes_whom_card.dart';

class HangoutsView extends ConsumerStatefulWidget {
  const HangoutsView({super.key});

  @override
  ConsumerState<HangoutsView> createState() => _HangoutsViewState();
}

class _HangoutsViewState extends ConsumerState<HangoutsView> {
  String? _selectedSessionId;
  bool _isCreatingSession = false;
  bool _isAddingExpense = false;

  // Create Session State
  final TextEditingController _createTitleController = TextEditingController();
  String _createDate = DateUtilsExt.formatIsoDate(DateTime.now());
  final TextEditingController _newParticipantController = TextEditingController();
  final List<String> _participants = ['You'];
  String? _createError;

  // Add Expense State
  final TextEditingController _expTitleController = TextEditingController();
  final TextEditingController _expAmountController = TextEditingController();
  String _expPaidBy = 'You';
  String _expSplitType = 'equal'; // 'equal' | 'custom'
  final Set<String> _expSpecificParticipants = {};
  String? _expError;

  @override
  void dispose() {
    _createTitleController.dispose();
    _newParticipantController.dispose();
    _expTitleController.dispose();
    _expAmountController.dispose();
    super.dispose();
  }

  void _resetCreateForm() {
    _createTitleController.clear();
    _createDate = DateUtilsExt.formatIsoDate(DateTime.now());
    _newParticipantController.clear();
    _participants.clear();
    _participants.add('You');
    _createError = null;
  }

  void _resetExpenseForm(HangoutSessionModel session) {
    _expTitleController.clear();
    _expAmountController.clear();
    _expPaidBy = 'You';
    _expSplitType = 'equal';
    _expSpecificParticipants.clear();
    _expSpecificParticipants.addAll(session.people);
    _expError = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sessions = ref.watch(hangoutsProvider);

    if (_isCreatingSession) {
      return _buildCreateView(colors);
    }

    if (_selectedSessionId != null) {
      final session = sessions.where((s) => s.id == _selectedSessionId).firstOrNull;
      if (session != null) {
        if (_isAddingExpense) {
          return _buildAddExpenseView(session, colors);
        }
        return _buildDetailView(session, colors);
      } else {
        _selectedSessionId = null;
      }
    }

    return _buildListView(sessions, colors);
  }

  // 1. List View
  Widget _buildListView(List<HangoutSessionModel> sessions, AppColors colors) {
    final settings = ref.watch(settingsProvider);
    final recordsMap = ref.watch(recordsProvider);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hangouts & Split',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Group expense tracker & zero-sum settlement',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      key: const Key('create_hangout_button'),
                      onPressed: () {
                        _resetCreateForm();
                        setState(() => _isCreatingSession = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: const Text(
                        '+ New',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (sessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: Text(
                      'No hangout sessions yet.\nTap "+ New" to create your first session.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final dateRecord = recordsMap[session.date];
                    final isLogged = dateRecord != null &&
                        !dateRecord.isDeleted &&
                        dateRecord.expenses.any((e) => e.id.startsWith('hangout-${session.id}-'));

                    return InkWell(
                      key: Key('hangout_card_${session.id}'),
                      onTap: () {
                        setState(() {
                          _selectedSessionId = session.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.bgCard,
                          border: Border.all(color: colors.borderColor, width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    session.title,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isLogged)
                                  Container(
                                    key: Key('calendar_badge_${session.id}'),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: colors.bgSecondary,
                                      border: Border.all(color: colors.colorSuccess, width: 1),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: Text(
                                      'Calendar',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: colors.colorSuccess,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  DateUtilsExt.formatDisplayDate(session.date),
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${session.people.length} people',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${session.expenses.length} expenses',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Participant Avatars (Squares)
                                Row(
                                  children: session.people.take(5).map((p) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: colors.bgSecondary,
                                        border: Border.all(color: colors.borderColor, width: 1),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        p.isNotEmpty ? p[0].toUpperCase() : '?',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                Text(
                                  CurrencyFormatter.formatFromCents(
                                    session.totalSpent,
                                    settings.currencySymbol,
                                    privacyMode: settings.privacyMode,
                                  ),
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Create Hangout View
  Widget _buildCreateView(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () => setState(() => _isCreatingSession = false),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'New Hangout Session',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hangout Title',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('hangout_title_input'),
                      controller: _createTitleController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'e.g. Dinner & Karaoke',
                        counterText: '',
                        fillColor: colors.bgSecondary,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: colors.borderColor, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Date',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateUtilsExt.formatDisplayDate(_createDate),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          key: const Key('hangout_date_picker_button'),
                          onPressed: () async {
                            final parsed = DateUtilsExt.parseIsoDate(_createDate);
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: parsed,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setState(() {
                                _createDate = DateUtilsExt.formatIsoDate(picked);
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.borderColor, width: 1),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text('Change Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Participants',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Participant chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _participants.map((person) {
                        final isYou = person == 'You';
                        return Container(
                          key: Key('participant_chip_$person'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.bgSecondary,
                            border: Border.all(color: colors.borderColor, width: 1),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                person,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (!isYou) ...[
                                const SizedBox(width: 4),
                                InkWell(
                                  key: Key('remove_participant_$person'),
                                  onTap: () {
                                    setState(() => _participants.remove(person));
                                  },
                                  child: Icon(Icons.close, size: 14, color: colors.colorDanger),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('participant_name_input'),
                            controller: _newParticipantController,
                            decoration: InputDecoration(
                              hintText: 'Add friend name',
                              fillColor: colors.bgSecondary,
                              filled: true,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(color: colors.borderColor, width: 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          key: const Key('add_participant_button'),
                          onPressed: () {
                            final name = _newParticipantController.text.trim();
                            if (name.isEmpty) return;
                            if (_participants.any((p) => p.toLowerCase() == name.toLowerCase())) {
                              setState(() {
                                _createError = 'Duplicate participant name "$name".';
                              });
                              return;
                            }
                            setState(() {
                              _participants.add(name);
                              _newParticipantController.clear();
                              _createError = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.textPrimary,
                            foregroundColor: colors.bgPrimary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    if (_createError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _createError!,
                        key: const Key('create_hangout_error_text'),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.colorDanger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      key: const Key('submit_create_hangout_button'),
                      onPressed: () async {
                        final title = _createTitleController.text.trim();
                        if (title.isEmpty || title.length > 100) {
                          setState(() => _createError = 'Title must be 1–100 characters.');
                          return;
                        }

                        final newSession = await ref
                            .read(hangoutsProvider.notifier)
                            .createSession(title: title, date: _createDate, people: _participants);

                        setState(() {
                          _isCreatingSession = false;
                          _selectedSessionId = newSession.id;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Create Hangout',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Detail View
  Widget _buildDetailView(HangoutSessionModel session, AppColors colors) {
    final settings = ref.watch(settingsProvider);
    final recordsMap = ref.watch(recordsProvider);
    final dateRecord = recordsMap[session.date];
    final isLogged = dateRecord != null &&
        !dateRecord.isDeleted &&
        dateRecord.expenses.any((e) => e.id.startsWith('hangout-${session.id}-'));

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () => setState(() => _selectedSessionId = null),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          DateUtilsExt.formatDisplayDate(session.date),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    key: const Key('log_to_calendar_button'),
                    onPressed: () => _showLogToCalendarModal(session),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isLogged ? colors.colorSuccess : colors.borderColor,
                        width: 1,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: Text(
                      isLogged ? 'Update Calendar' : 'Log to Calendar',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isLogged ? colors.colorSuccess : colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: const Key('delete_hangout_button'),
                    icon: Icon(Icons.delete_outline, color: colors.colorDanger),
                    onPressed: () async {
                      final confirmed = await BrutalistConfirmDialog.show(
                        context: context,
                        title: 'Delete Hangout',
                        message: 'Permanently delete this hangout session?',
                        confirmText: 'Delete',
                        isDanger: true,
                      );
                      if (confirmed && mounted) {
                        await ref.read(hangoutsProvider.notifier).deleteSession(session.id);
                        setState(() => _selectedSessionId = null);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Spent Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Spent',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatFromCents(
                        session.totalSpent,
                        settings.currencySymbol,
                        privacyMode: settings.privacyMode,
                      ),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Per Person Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per Person Summary',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...session.people.map((person) {
                      final personShare = session.expenses.fold<int>(
                        0,
                        (sum, exp) => sum + HangoutsNotifier.exactShareForPerson(person, exp),
                      );
                      final shareRatio =
                          session.totalSpent > 0 ? (personShare / session.totalSpent) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  person,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: person == 'You' ? FontWeight.w700 : FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatFromCents(
                                    personShare,
                                    settings.currencySymbol,
                                    privacyMode: settings.privacyMode,
                                  ),
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 4,
                              color: colors.bgSecondary,
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: shareRatio.clamp(0.0, 1.0),
                                child: Container(color: colors.colorInfo),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Who Owes Whom Settlement Card
              WhoOwesWhomCard(session: session),
              const SizedBox(height: 16),

              // Itemized Expenses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Itemized Expenses (${session.expenses.length})',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const Key('add_hangout_expense_button'),
                    onPressed: () {
                      _resetExpenseForm(session);
                      setState(() => _isAddingExpense = true);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.borderColor, width: 1),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      'Add Expense',
                      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (session.expenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    border: Border.all(color: colors.borderColor, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Center(
                    child: Text(
                      'No expenses added to this session yet.',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: session.expenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final exp = session.expenses[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        border: Border.all(color: colors.borderColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exp.title,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Paid by ${exp.paidBy} • Split among ${exp.participants.length} people',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatFromCents(
                              exp.totalAmount,
                              settings.currencySymbol,
                              privacyMode: settings.privacyMode,
                            ),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 16, color: colors.colorDanger),
                            onPressed: () => ref
                                .read(hangoutsProvider.notifier)
                                .deleteExpenseFromSession(exp.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Add Expense View
  Widget _buildAddExpenseView(HangoutSessionModel session, AppColors colors) {
    final settings = ref.watch(settingsProvider);
    final parsedAmount = double.tryParse(_expAmountController.text.trim()) ?? 0.0;
    final parsedCents = CurrencyFormatter.pesosToCents(parsedAmount);

    final activeParticipants = _expSplitType == 'equal'
        ? session.people
        : session.people.where((p) => _expSpecificParticipants.contains(p)).toList();

    final liveShares = HangoutsNotifier.splitExpense(
      totalAmount: parsedCents,
      participants: activeParticipants,
      paidBy: _expPaidBy,
    );

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () => setState(() => _isAddingExpense = false),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Expense to "${session.title}"',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  border: Border.all(color: colors.borderColor, width: 1),
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Expense Title',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('hangout_exp_title_input'),
                      controller: _expTitleController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: 'e.g. Pizza & Drinks',
                        counterText: '',
                        fillColor: colors.bgSecondary,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: colors.borderColor, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Amount (${settings.currencySymbol})',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('hangout_exp_amount_input'),
                      controller: _expAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        fillColor: colors.bgSecondary,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: colors.borderColor, width: 1),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    // Paid By Selector (Strictly from session.people)
                    Text(
                      'Paid By',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: session.people.map((person) {
                        final isSelected = _expPaidBy == person;
                        return ChoiceChip(
                          key: Key('paid_by_chip_$person'),
                          label: Text(person),
                          selected: isSelected,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _expPaidBy = person);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Split Selector: Split Equally vs Specific People
                    Text(
                      'Split Type',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('split_equally_button'),
                            onPressed: () => setState(() => _expSplitType = 'equal'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _expSplitType == 'equal'
                                  ? colors.textPrimary
                                  : Colors.transparent,
                              foregroundColor: _expSplitType == 'equal'
                                  ? colors.bgPrimary
                                  : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Split Equally'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('split_specific_button'),
                            onPressed: () => setState(() => _expSplitType = 'custom'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _expSplitType == 'custom'
                                  ? colors.textPrimary
                                  : Colors.transparent,
                              foregroundColor: _expSplitType == 'custom'
                                  ? colors.bgPrimary
                                  : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Specific People'),
                          ),
                        ),
                      ],
                    ),
                    if (_expSplitType == 'custom') ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: session.people.map((person) {
                          final isIncluded = _expSpecificParticipants.contains(person);
                          return FilterChip(
                            key: Key('specific_person_chip_$person'),
                            label: Text(person),
                            selected: isIncluded,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _expSpecificParticipants.add(person);
                                } else {
                                  _expSpecificParticipants.remove(person);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Live Per-Person Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.bgSecondary,
                        border: Border.all(color: colors.borderColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Split Preview:',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (activeParticipants.isEmpty)
                            Text(
                              'Please select at least 1 participant.',
                              style: TextStyle(color: colors.colorDanger, fontSize: 12),
                            )
                          else
                            ...activeParticipants.map((p) {
                              final share = liveShares[p] ?? 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      p,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatFromCents(
                                        share,
                                        settings.currencySymbol,
                                        privacyMode: settings.privacyMode,
                                      ),
                                      key: Key('live_share_$p'),
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    if (_expError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _expError!,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.colorDanger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: const Key('submit_hangout_expense_button'),
                      onPressed: () async {
                        final title = _expTitleController.text.trim();
                        if (title.isEmpty || title.length > 100) {
                          setState(() => _expError = 'Title must be 1–100 characters.');
                          return;
                        }
                        if (parsedCents <= 0) {
                          setState(() => _expError = 'Enter a valid amount greater than zero.');
                          return;
                        }
                        if (activeParticipants.isEmpty) {
                          setState(() => _expError = 'At least 1 participant must be selected.');
                          return;
                        }

                        await ref.read(hangoutsProvider.notifier).addExpenseToSession(
                              sessionId: session.id,
                              title: title,
                              totalAmount: parsedCents,
                              paidBy: _expPaidBy,
                              participants: activeParticipants,
                              splitType: _expSplitType,
                            );

                        setState(() => _isAddingExpense = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Save Expense',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Log to Calendar Modal
  Future<void> _showLogToCalendarModal(HangoutSessionModel session) async {
    String mode = 'merge'; // 'merge' | 'overwrite'
    String deductFrom = 'allowance'; // 'allowance' | 'balance'
    bool isAllowanceDay = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = context.appColors;
            return Container(
              color: colors.bgCard,
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log Hangout to Calendar',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: colors.textSecondary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Merge Mode',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('mode_merge_button'),
                            onPressed: () => setModalState(() => mode = 'merge'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  mode == 'merge' ? colors.textPrimary : Colors.transparent,
                              foregroundColor:
                                  mode == 'merge' ? colors.bgPrimary : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Merge'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('mode_overwrite_button'),
                            onPressed: () => setModalState(() => mode = 'overwrite'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  mode == 'overwrite' ? colors.textPrimary : Colors.transparent,
                              foregroundColor:
                                  mode == 'overwrite' ? colors.bgPrimary : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Overwrite'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Deduct Hangout Expenses From',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('deduct_allowance_log_button'),
                            onPressed: () => setModalState(() => deductFrom = 'allowance'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  deductFrom == 'allowance' ? colors.textPrimary : Colors.transparent,
                              foregroundColor:
                                  deductFrom == 'allowance' ? colors.bgPrimary : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Allowance'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('deduct_wallet_log_button'),
                            onPressed: () => setModalState(() => deductFrom = 'balance'),
                            style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  deductFrom == 'balance' ? colors.textPrimary : Colors.transparent,
                              foregroundColor:
                                  deductFrom == 'balance' ? colors.bgPrimary : colors.textPrimary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text('Wallet'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Treat as Allowance Day',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                        ),
                        Switch(
                          key: const Key('allowance_day_toggle'),
                          value: isAllowanceDay,
                          onChanged: (val) => setModalState(() => isAllowanceDay = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      key: const Key('confirm_log_to_calendar_button'),
                      onPressed: () async {
                        final recordsMap = ref.read(recordsProvider);
                        final dateRecord = recordsMap[session.date];
                        final isOccupied = dateRecord != null && !dateRecord.isDeleted;

                        if (mode == 'overwrite' && isOccupied) {
                          final confirmed = await BrutalistConfirmDialog.show(
                            context: context,
                            title: 'Overwrite Day',
                            message:
                                'This date already has recorded expenses. Overwrite will replace all expenses on this date. Continue?',
                            confirmText: 'Overwrite',
                            isDanger: true,
                          );
                          if (!confirmed) return;
                        }

                        final settings = ref.read(settingsProvider);
                        await ref.read(hangoutsProvider.notifier).logHangoutToCalendar(
                              session: session,
                              mode: mode,
                              modalDeductFrom: deductFrom,
                              modalIsAllowance: isAllowanceDay,
                              allowanceCents: settings.defaultAllowance,
                            );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.bgPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Confirm & Log',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
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
    );
  }
}
