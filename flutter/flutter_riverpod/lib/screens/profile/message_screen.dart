import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

final messagesProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getMessages();
});

final readMessageProvider = FutureProvider.autoDispose.family<bool, int>((ref, messageId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.markMessageAsRead(messageId);
});

final deleteMessageProvider = FutureProvider.autoDispose.family<bool, int>((ref, messageId) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.deleteMessage(messageId);
});

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAllSelected = false;
  Set<int> _selectedMessageIds = {};
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead(List<int> messageIds) async {
    setState(() {
      _isActionInProgress = true;
    });

    try {
      for (final id in messageIds) {
        await ref.read(readMessageProvider(id).future);
      }
      
      // 刷新消息列表
      ref.refresh(messagesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标记已读成功')),
        );
        
        // 清空选择
        setState(() {
          _selectedMessageIds = {};
          _isAllSelected = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败：${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _deleteMessages(List<int> messageIds) async {
    setState(() {
      _isActionInProgress = true;
    });

    try {
      for (final id in messageIds) {
        await ref.read(deleteMessageProvider(id).future);
      }
      
      // 刷新消息列表
      ref.refresh(messagesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
        
        // 清空选择
        setState(() {
          _selectedMessageIds = {};
          _isAllSelected = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败：${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  void _toggleSelectAll(List<Map<String, dynamic>> messages) {
    if (_isAllSelected) {
      setState(() {
        _selectedMessageIds = {};
        _isAllSelected = false;
      });
    } else {
      final Set<int> allIds = messages
          .map((msg) => msg['id'] as int? ?? 0)
          .where((id) => id != 0)
          .toSet();
      
      setState(() {
        _selectedMessageIds = allIds;
        _isAllSelected = true;
      });
    }
  }

  void _toggleMessageSelection(int messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        _isAllSelected = false;
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息中心'),
        backgroundColor: AppColors.primaryColor,
        actions: [
          TextButton(
            onPressed: () {
              final data = ref.read(messagesProvider).valueOrNull;
              if (data != null) {
                final List<Map<String, dynamic>> currentTabMessages = _getCurrentTabMessages(data);
                _toggleSelectAll(currentTabMessages);
              }
            },
            child: Text(
              _isAllSelected ? '取消全选' : '全选',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '系统通知'),
            Tab(text: '活动消息'),
          ],
          onTap: (_) {
            // 切换标签时清空选择
            setState(() {
              _selectedMessageIds = {};
              _isAllSelected = false;
            });
          },
        ),
      ),
      body: ref.watch(messagesProvider).when(
        data: (data) => _buildMessageContent(data),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorView(
          message: '加载消息失败',
          onRetry: () => ref.refresh(messagesProvider),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> data) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMessageList(data['all'] ?? []),
        _buildMessageList(data['system'] ?? []),
        _buildMessageList(data['activity'] ?? []),
      ],
    );
  }

  List<Map<String, dynamic>> _getCurrentTabMessages(Map<String, dynamic> data) {
    switch (_tabController.index) {
      case 0:
        return List<Map<String, dynamic>>.from(data['all'] ?? []);
      case 1:
        return List<Map<String, dynamic>>.from(data['system'] ?? []);
      case 2:
        return List<Map<String, dynamic>>.from(data['activity'] ?? []);
      default:
        return [];
    }
  }

  Widget _buildMessageList(List<dynamic> messages) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('暂无消息'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index] as Map<String, dynamic>;
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final int id = message['id'] ?? 0;
    final String title = message['title'] ?? '';
    final String content = message['content'] ?? '';
    final String time = message['time'] ?? '';
    final bool isRead = message['isRead'] ?? false;
    final String type = message['type'] ?? 'system';
    final bool isSelected = _selectedMessageIds.contains(id);

    IconData messageIcon;
    Color iconColor;
    
    switch (type) {
      case 'activity':
        messageIcon = Icons.celebration;
        iconColor = Colors.orange;
        break;
      case 'system':
        messageIcon = Icons.notifications;
        iconColor = Colors.blue;
        break;
      default:
        messageIcon = Icons.mail;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_selectedMessageIds.isNotEmpty) {
            _toggleMessageSelection(id);
          } else {
            _showMessageDetail(message);
          }
        },
        onLongPress: () {
          _toggleMessageSelection(id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedMessageIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleMessageSelection(id);
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  messageIcon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
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

  Widget _buildBottomActionBar() {
    if (_selectedMessageIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '已选择 ${_selectedMessageIds.length} 条消息',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isActionInProgress
                      ? null
                      : () => _markAsRead(_selectedMessageIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('标记已读'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isActionInProgress
                      ? null
                      : () => _deleteMessages(_selectedMessageIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageDetail(Map<String, dynamic> message) {
    final int id = message['id'] ?? 0;
    final String title = message['title'] ?? '';
    final String content = message['content'] ?? '';
    final String time = message['time'] ?? '';
    final bool isRead = message['isRead'] ?? false;
    
    if (!isRead) {
      // 标记为已读
      ref.read(readMessageProvider(id));
      ref.refresh(messagesProvider);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 