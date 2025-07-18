import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../api/services/api_service.dart';
import '../../api/models/comment_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_view.dart';

// 获取用户评论的Provider
final userCommentsProvider = FutureProvider.autoDispose.family<List<CommentModel>, int>(
  (ref, page) async {
    final apiService = ref.read(apiServiceProvider);
    final data = await apiService.getMemberComments(page: page);
    
    final List<dynamic> comments = data['records'] ?? [];
    return comments.map((comment) => CommentModel.fromJson(comment)).toList();
  },
);

// 总页数Provider
final totalPagesProvider = StateProvider<int>((ref) => 1);

class CommentsPage extends ConsumerStatefulWidget {
  const CommentsPage({Key? key}) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  int _currentPage = 1;
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    // 设置中文时间文本
    timeago.setLocaleMessages('zh_CN', timeago.ZhCnMessages());
  }
  
  // 删除评论
  Future<void> _deleteComment(int commentId) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteComment(commentId);
      
      // 刷新评论列表
      ref.refresh(userCommentsProvider(_currentPage));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论删除成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除评论失败: $e')),
      );
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
  
  // 确认删除弹窗
  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条评论吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsyncValue = ref.watch(userCommentsProvider(_currentPage));
    final totalPages = ref.watch(totalPagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的评论'),
      ),
      body: Stack(
        children: [
          commentsAsyncValue.when(
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(
                  child: Text('暂无评论', style: TextStyle(color: Colors.grey)),
                );
              }
              
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(userCommentsProvider(_currentPage));
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment);
                        },
                      ),
                    ),
                  ),
                  
                  // 分页控制器
                  if (totalPages > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 1 
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.navigate_before),
                          ),
                          Text('$_currentPage / $totalPages'),
                          IconButton(
                            onPressed: _currentPage < totalPages 
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.navigate_next),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) => ErrorView(
              message: '加载评论失败: $e',
              onRetry: () => ref.refresh(userCommentsProvider(_currentPage)),
            ),
          ),
          
          // 删除中遮罩
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  // 构建评论项
  Widget _buildCommentItem(CommentModel comment) {
    // 计算相对时间
    final DateTime createTime = DateTime.parse(comment.createTime);
    final String timeAgo = timeago.format(createTime, locale: 'zh_CN');
    
    return InkWell(
      onTap: () {
        // 如果有资源URL，跳转到视频详情页
        if (comment.resourcesUrl != null && comment.resourcesUrl!.isNotEmpty) {
          Navigator.of(context).pushNamed(
            '/video/detail', 
            arguments: {'vodId': comment.resourcesId},
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 资源信息
            if (comment.resourcesName != null || comment.resourcesPic != null)
              Row(
                children: [
                  if (comment.resourcesPic != null && comment.resourcesPic!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        comment.resourcesPic!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 20),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.resourcesName ?? '未知资源',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 8),
            
            // 评论内容
            Text(comment.content),
            
            const SizedBox(height: 8),
            
            // 评论底部信息
            Row(
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                
                // 点赞数
                if (comment.likeCount != null && comment.likeCount! > 0)
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${comment.likeCount}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                
                // 删除按钮
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await _showDeleteConfirmDialog();
                    if (confirm == true) {
                      await _deleteComment(comment.id);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 