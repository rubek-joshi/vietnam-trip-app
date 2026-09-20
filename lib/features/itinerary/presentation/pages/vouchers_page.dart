import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/voucher_data.dart';

class VouchersPage extends StatelessWidget {
  const VouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vouchers')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ShadCard(
            title: const Text('Tour voucher'),
            description: Text(
              'Issued ${VoucherMeta.issued} · ${VoucherMeta.paxLabel}',
              style: theme.textTheme.muted,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  _kv(
                    context,
                    'Client',
                    '${VoucherMeta.clientName} · ${VoucherMeta.adults} adults',
                  ),
                  _kv(
                    context,
                    'Tour code',
                    VoucherMeta.tourCode,
                    copyable: true,
                  ),
                  _kv(context, 'Company', VoucherMeta.company),
                  _kv(context, 'Rooms', VoucherMeta.occupancy),
                  _kv(
                    context,
                    'Handled by',
                    '${VoucherMeta.handledBy} · ${VoucherMeta.handledByPhone}',
                    copyable: true,
                    copyValue: VoucherMeta.handledByPhone,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Flights', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...voucherFlights.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadCard(
                leading: const Icon(LucideIcons.plane),
                title: Text('${f.flightNo}  ${f.from} → ${f.to}'),
                description: Text('${f.date} · ${f.depart}–${f.arrive}'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Accommodation', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...voucherStays.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _showConfirmCodeDialog(context, s),
                borderRadius: BorderRadius.circular(12),
                child: ShadCard(
                  title: Text(s.property),
                  description: Text(
                    '${s.from} → ${s.to} · ${s.nights} night${s.nights == 1 ? '' : 's'}',
                  ),
                  trailing: const Icon(LucideIcons.chevronRight),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${s.room} · ${s.meals} · ${VoucherMeta.occupancy}',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Confirmed services', style: theme.textTheme.h4),
          const SizedBox(height: 8),
          ...voucherServices.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ShadCard(
                title: Text(s.date),
                description: Text(s.name),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.flight != null) ...[
                        Text(s.flight!, style: theme.textTheme.p),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        'Meals ${s.meals} · Guide ${s.guide} · ${s.transfer}',
                        style: theme.textTheme.muted,
                      ),
                      if (s.confirmed) ...[
                        const SizedBox(height: 8),
                        const ShadBadge(child: Text('Confirmed')),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ShadCard(
            title: Text(VoucherMeta.operatorName),
            description: Text(
              VoucherMeta.operatorOffice,
              style: theme.textTheme.muted,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  _kv(
                    context,
                    'Hotline',
                    VoucherMeta.operatorHotline,
                    copyable: true,
                  ),
                  _kv(
                    context,
                    'Email',
                    VoucherMeta.operatorEmail,
                    copyable: true,
                  ),
                  _kv(context, 'Web', VoucherMeta.operatorWebsite),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
    String? copyValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
          if (copyable)
            ShadIconButton.ghost(
              icon: const Icon(LucideIcons.copy, size: 16),
              onPressed: () => _copy(context, copyValue ?? value),
            ),
        ],
      ),
    );
  }
}

void _showConfirmCodeDialog(BuildContext context, VoucherStay stay) {
  final theme = ShadTheme.of(context);
  final dialogWidth = MediaQuery.sizeOf(context).width - 48;

  showShadDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return ShadDialog(
        closeIconData: LucideIcons.x,
        useSafeArea: false,
        scrollable: false,
        alignment: Alignment.center,
        constraints: BoxConstraints.tightFor(width: dialogWidth),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: Text(stay.property),
        description: Text('${stay.from} → ${stay.to}'),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Confirmation code', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  stay.confirmCode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.h1.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 44,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Copied')));
}
