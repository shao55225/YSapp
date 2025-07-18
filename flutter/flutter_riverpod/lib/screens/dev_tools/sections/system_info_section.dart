import 'package:flutter/material.dart';
import '../../../utils/platform/platform.dart';

class SystemInfoSection extends StatelessWidget {
  const SystemInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('系统信息', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInfoRow('平台', PlatformUtils.operatingSystem),
            _buildInfoRow('版本', PlatformUtils.operatingSystemVersion),
            _buildInfoRow('是否Web平台', PlatformUtils.isWeb ? '是' : '否'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
