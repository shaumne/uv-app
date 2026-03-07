import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../onboarding/presentation/widgets/fitzpatrick_card.dart';
import '../../../onboarding/presentation/widgets/spf_slider_widget.dart';
import '../providers/settings_provider.dart';

/// Settings screen — lets the user update their Fitzpatrick skin type and SPF
/// after the initial onboarding.
///
/// Design follows Premium_Cosmeceutical_UI_Designer:
/// - clinicalWhite background, generous spacing
/// - Section headers in labelSmall (spaced uppercase)
/// - Animated success banner on save
/// - Destructive reset action in a bottom sheet
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _saveCtrl;
  late final Animation<double> _saveFade;

  /// Fitzpatrick card data — labels and descriptions from l10n.
  List<_SkinTypeEntry> _skinTypes(AppLocalizations l10n) => [
        _SkinTypeEntry(1, l10n.onboarding_fitzpatrickType1_label,
            l10n.onboarding_fitzpatrickType1_desc),
        _SkinTypeEntry(2, l10n.onboarding_fitzpatrickType2_label,
            l10n.onboarding_fitzpatrickType2_desc),
        _SkinTypeEntry(3, l10n.onboarding_fitzpatrickType3_label,
            l10n.onboarding_fitzpatrickType3_desc),
        _SkinTypeEntry(4, l10n.onboarding_fitzpatrickType4_label,
            l10n.onboarding_fitzpatrickType4_desc),
        _SkinTypeEntry(5, l10n.onboarding_fitzpatrickType5_label,
            l10n.onboarding_fitzpatrickType5_desc),
        _SkinTypeEntry(6, l10n.onboarding_fitzpatrickType6_label,
            l10n.onboarding_fitzpatrickType6_desc),
      ];

  @override
  void initState() {
    super.initState();
    _saveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _saveFade = CurvedAnimation(parent: _saveCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    // Animate the success banner in/out.
    ref.listen<SettingsState>(settingsNotifierProvider, (_, next) {
      if (next.isSaved) {
        _saveCtrl.forward(from: 0);
      } else {
        _saveCtrl.reverse();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.uvDangerCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Semantics(
      label: l10n.settings_title,
      child: Scaffold(
        backgroundColor: AppColors.clinicalWhite,
        appBar: AppBar(
          title: Text(l10n.settings_title),
          leading: Semantics(
            button: true,
            label: l10n.result_backHome,
            child: IconButton(
              icon: PhosphorIcon(PhosphorIconsRegular.caretLeft, size: 18),
              onPressed: () => context.go(RouteNames.home),
            ),
          ),
          actions: [
          // Save button in app bar — visible but disabled while saving
          TextButton(
            onPressed: state.isSaving ? null : notifier.saveChanges,
            child: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.bihakuLavender,
                    ),
                  )
                : Text(
                    l10n.settings_save_button,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.bihakuLavender,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Success banner (animated) ─────────────────────────────────────
          FadeTransition(
            opacity: _saveFade,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: AppColors.uvSafeGreen.withValues(alpha: 0.12),
              child: Row(
                children: [
                  PhosphorIcon(PhosphorIconsRegular.checkCircle,
                      size: 18, color: AppColors.uvSafeGreen),
                  const SizedBox(width: 10),
                  Text(l10n.settings_saved_message,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.uvSafeGreen,
                        letterSpacing: 0.4,
                      )),
                ],
              ),
            ),
          ),

          // ── Scrollable content ───────────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 32),

                      // ── Section: Skin Profile ─────────────────────────────
                      _SectionHeader(label: l10n.settings_section_profile),
                      const SizedBox(height: 16),

                      // Fitzpatrick type cards
                      ..._skinTypes(l10n).map(
                        (e) => FitzpatrickCard(
                          type: e.type,
                          label: e.label,
                          description: e.desc,
                          swatchColor: fitzpatrickSwatchColors[e.type]!,
                          isSelected: state.selectedType == e.type,
                          onTap: () => notifier.selectSkinType(e.type),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const SizedBox(height: 32),

                      // SPF slider
                      SpfSliderWidget(
                        selectedSpf: state.selectedSpf,
                        onChanged: notifier.selectSpf,
                      ),

                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // SPF application time
                      _SpfTimeRow(
                        spfAppliedAt: state.spfAppliedAt,
                        selectedSpf: state.selectedSpf,
                        onMarkNow: () => notifier.markSpfAppliedNow(
                          notificationTitle: l10n.appName,
                          notificationBody: l10n.notification_spfExpired_body,
                        ),
                        onClear: notifier.clearSpfAppliedTime,
                        l10n: l10n,
                      ),

                      const SizedBox(height: 48),

                      // Save button (also in app bar — duplicated for long forms)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isSaving ? null : notifier.saveChanges,
                          child: state.isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(l10n.settings_save_button),
                        ),
                      ),

                      const SizedBox(height: 48),
                      const Divider(height: 1),
                      const SizedBox(height: 32),

                      // ── Section: Language ─────────────────────────────────
                      _SectionHeader(label: l10n.settings_section_language),
                      const SizedBox(height: 16),
                      _LanguagePicker(l10n: l10n),

                      const SizedBox(height: 48),
                      const Divider(height: 1),
                      const SizedBox(height: 32),

                      // ── Section: About ────────────────────────────────────
                      _SectionHeader(label: l10n.settings_section_app),
                      const SizedBox(height: 16),

                      _InfoRow(
                        label: l10n.settings_version_label,
                        value: state.appVersion.isEmpty ? '—' : state.appVersion,
                      ),
                      const SizedBox(height: 4),
                      _InfoRow(
                        label: l10n.settings_support_label,
                        value: l10n.settings_support_email,
                        valueColor: AppColors.bihakuLavender,
                      ),

                      const SizedBox(height: 32),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // ── Reset onboarding ──────────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: () => _confirmReset(context, l10n, notifier),
                          child: Text(
                            l10n.settings_reset_label,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.uvDangerCoral,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Shows a confirmation bottom sheet before resetting onboarding.
  Future<void> _confirmReset(
    BuildContext context,
    AppLocalizations l10n,
    SettingsNotifier notifier,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.clinicalWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtleDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.settings_reset_label,
                  style: AppTypography.headlineMed),
              const SizedBox(height: 12),
              Text(l10n.settings_reset_confirm,
                  style: AppTypography.bodyMedium),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.subtleDivider),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(l10n.settings_cancel_button,
                          style: AppTypography.bodyMedium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.uvDangerCoral,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(l10n.settings_reset_button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      await notifier.resetProfile();
      if (context.mounted) context.go(RouteNames.onboarding);
    }
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.labelSmall.copyWith(letterSpacing: 1.6),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: valueColor ?? AppColors.deepInk.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkinTypeEntry {
  const _SkinTypeEntry(this.type, this.label, this.desc);
  final int type;
  final String label;
  final String desc;
}

// ── SPF Time Row ──────────────────────────────────────────────────────────────

/// Displays when sunscreen was last applied and provides quick-tap to record.
///
/// Uses the bi-exponential SPF decay model (Dermatology_Math_Engine skill):
/// the timestamp drives `hours_since_application` in backend requests.
class _SpfTimeRow extends StatelessWidget {
  const _SpfTimeRow({
    required this.spfAppliedAt,
    required this.selectedSpf,
    required this.onMarkNow,
    required this.onClear,
    required this.l10n,
  });

  final DateTime? spfAppliedAt;
  final int selectedSpf;
  final VoidCallback onMarkNow;
  final VoidCallback onClear;
  final AppLocalizations l10n;

  String _elapsedLabel() {
    if (spfAppliedAt == null) return l10n.settings_spfApplied_notSet;
    final elapsed = DateTime.now().difference(spfAppliedAt!);
    if (elapsed.inMinutes < 2) return l10n.settings_spfApplied_justNow;
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    return l10n.settings_spfApplied_ago(h, m);
  }

  @override
  Widget build(BuildContext context) {
    // Hide if user selected SPF 1 (no sunscreen)
    if (selectedSpf <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings_spfApplied_label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(letterSpacing: 1.6),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtleDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.sun,
                    size: 18,
                    color: spfAppliedAt != null
                        ? AppColors.uvWarnAmber
                        : AppColors.deepInk.withValues(alpha: 0.35),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _elapsedLabel(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: spfAppliedAt != null
                          ? AppColors.deepInk
                          : AppColors.deepInk.withValues(alpha: 0.45),
                    ),
                  ),
                  const Spacer(),
                  if (spfAppliedAt != null)
                    GestureDetector(
                      onTap: onClear,
                      child: Text(
                        l10n.settings_spfApplied_clear,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.uvDangerCoral,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onMarkNow,
                  icon: PhosphorIcon(PhosphorIconsRegular.checkCircle, size: 16),
                  label: Text(l10n.settings_spfApplied_setNow),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.uvSafeGreen,
                    side: const BorderSide(color: AppColors.uvSafeGreen, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTypography.labelSmall.copyWith(
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settings_spfApplied_hint,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.deepInk.withValues(alpha: 0.45),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Language Picker ───────────────────────────────────────────────────────────

/// Three-button language selector.
///
/// Tapping a language takes effect immediately — the locale change is
/// written to SharedPreferences and the entire app rebuilds via
/// [localeNotifierProvider].
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);

    final langs = [
      (code: 'en', label: l10n.settings_language_en, flag: '🇬🇧'),
      (code: 'tr', label: l10n.settings_language_tr, flag: '🇹🇷'),
      (code: 'ja', label: l10n.settings_language_ja, flag: '🇯🇵'),
    ];

    return Row(
      children: langs.map((lang) {
        final isSelected = currentLocale.languageCode == lang.code;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.bihakuLavender.withValues(alpha: 0.10)
                    : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.bihakuLavender
                      : AppColors.subtleDivider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                onTap: () => localeNotifier.setLocale(Locale(lang.code)),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(lang.flag,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                      Text(
                        lang.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.bihakuLavender
                              : AppColors.deepInk
                                  .withValues(alpha: 0.65),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.bihakuLavender,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
