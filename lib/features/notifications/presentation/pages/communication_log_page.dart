import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_tokens.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buttons/kc_primary_button.dart';
import '../../../../shared/widgets/cards/kc_card.dart';
import '../../../../shared/widgets/feedback/kc_toast.dart';
import '../../models/notification_models.dart';
import '../../providers/notification_providers.dart';

class CommunicationLogPage extends ConsumerWidget {
  const CommunicationLogPage({super.key});

  void _showPreviewDialog(BuildContext context, WidgetRef ref) {
    final commService = ref.read(communicationServiceProvider);
    final templates = commService.getTemplates();

    showDialog(
      context: context,
      builder: (ctx) => _CustomerCommunicationPreviewDialog(templates: templates),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(communicationLogsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(context.pageGutter),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Communication History & Templates',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simulated SMS, WhatsApp & Email dispatch logs, message template preview & delivery status',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              KcPrimaryButton(
                label: 'Preview Template Dispatch',
                icon: Icons.send_rounded,
                onPressed: () => _showPreviewDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Log List
          logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Text('Error loading communication logs: $err'),
            data: (logs) {
              if (logs.isEmpty) {
                return const KcCard(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No customer communication history logged yet.'),
                  ),
                );
              }

              return Column(
                children: logs.map((log) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KcCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: log.channel.icon == Icons.chat_bubble_outline_rounded
                                  ? const Color(0xFF059669).withValues(alpha: 0.12)
                                  : const Color(0xFF2563EB).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              log.channel.icon,
                              color: log.channel.icon == Icons.chat_bubble_outline_rounded
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Recipient: ${log.recipientName} (${log.recipientContact})',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: log.status.color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        log.status.label.toUpperCase(),
                                        style: TextStyle(
                                          color: log.status.color,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  log.bodyMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Channel: ${log.channel.label} • Template: ${log.templateId} • Sent: ${KcFormatters.dateTime(log.createdAt)}',
                                  style: const TextStyle(fontSize: 11, color: KcColors.slate400),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CustomerCommunicationPreviewDialog extends StatefulWidget {
  const _CustomerCommunicationPreviewDialog({required this.templates});

  final List<MessageTemplateModel> templates;

  @override
  State<_CustomerCommunicationPreviewDialog> createState() => _CustomerCommunicationPreviewDialogState();
}

class _CustomerCommunicationPreviewDialogState extends State<_CustomerCommunicationPreviewDialog> {
  MessageTemplateModel? _selectedTemplate;
  final _customerNameCtrl = TextEditingController(text: 'Rajesh Kumar');
  final _contactCtrl = TextEditingController(text: '+91 98200 12345');
  final _loanIdCtrl = TextEditingController(text: 'KC-LN-00124');
  final _amountCtrl = TextEditingController(text: '4,90,000');
  final _dueDateCtrl = TextEditingController(text: '18 Aug 2026');

  @override
  void initState() {
    super.initState();
    if (widget.templates.isNotEmpty) {
      _selectedTemplate = widget.templates.first;
    }
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _contactCtrl.dispose();
    _loanIdCtrl.dispose();
    _amountCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = {
      'customerName': _customerNameCtrl.text,
      'contact': _contactCtrl.text,
      'loanId': _loanIdCtrl.text,
      'amount': _amountCtrl.text,
      'dueDate': _dueDateCtrl.text,
      'receiptNumber': 'REC-2024-902',
      'trustLevel': 'Tier 1 Standard',
      'reason': 'Clearer photo required',
    };

    final renderedMessage = _selectedTemplate?.render(values) ?? 'Select template to preview message';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.mark_email_read_rounded, color: Color(0xFF7C3AED)),
          SizedBox(width: 10),
          Text('Customer Communication Preview', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Message Template:', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButton<MessageTemplateModel>(
              value: _selectedTemplate,
              isExpanded: true,
              items: widget.templates.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text('${t.title} (${t.channel.label})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTemplate = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerNameCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactCtrl,
              decoration: const InputDecoration(labelText: 'Contact (Mobile / WhatsApp)', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Text('Rendered Customer Message Preview:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF059669)),
              ),
              child: Text(
                renderedMessage,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4, color: Color(0xFF064E3B)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            KcToast.success(
              context,
              'Simulated communication queued & delivered to ${_customerNameCtrl.text}.',
              title: 'Dispatch Simulated',
            );
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Simulate Dispatch'),
        ),
      ],
    );
  }
}
