import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';

/// 头像选择器组件
///
/// 用于显示和选择用户头像，支持从相机或相册选择图片
///
/// 示例:
/// ```dart
/// AvatarPicker(
///   avatarUrl: user.avatarUrl,
///   onAvatarChanged: (file) async {
///     // 上传头像文件
///     final url = await uploadAvatar(file);
///     // 更新用户头像
///     await updateUserAvatar(url);
///   },
/// )
/// ```
class AvatarPicker extends StatefulWidget {
  /// 当前头像URL
  final String? avatarUrl;
  
  /// 头像大小
  final double size;
  
  /// 头像边框宽度
  final double borderWidth;
  
  /// 头像边框颜色
  final Color? borderColor;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 占位图标
  final IconData placeholderIcon;
  
  /// 占位图标颜色
  final Color? placeholderIconColor;
  
  /// 占位图标大小
  final double? placeholderIconSize;
  
  /// 编辑图标
  final IconData editIcon;
  
  /// 编辑图标颜色
  final Color? editIconColor;
  
  /// 编辑图标背景颜色
  final Color? editIconBackgroundColor;
  
  /// 头像更改回调，返回选择的图片文件
  final Function(File file)? onAvatarChanged;
  
  /// 是否可编辑
  final bool editable;

  /// 创建头像选择器组件
  const AvatarPicker({
    Key? key,
    this.avatarUrl,
    this.size = 100.0,
    this.borderWidth = 2.0,
    this.borderColor,
    this.backgroundColor,
    this.placeholderIcon = Icons.person,
    this.placeholderIconColor,
    this.placeholderIconSize,
    this.editIcon = Icons.camera_alt,
    this.editIconColor,
    this.editIconBackgroundColor,
    this.onAvatarChanged,
    this.editable = true,
  }) : super(key: key);

  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.borderColor ?? Theme.of(context).primaryColor;
    final effectiveBackgroundColor = widget.backgroundColor ?? Colors.grey[200];
    final effectivePlaceholderIconColor = widget.placeholderIconColor ?? Colors.grey[400];
    final effectiveEditIconColor = widget.editIconColor ?? Colors.white;
    final effectiveEditIconBackgroundColor = widget.editIconBackgroundColor ?? AppColors.primary;
    
    return GestureDetector(
      onTap: widget.editable ? _showImageSourceOptions : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveBackgroundColor,
          border: Border.all(
            color: effectiveBorderColor,
            width: widget.borderWidth,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 头像图片或占位符
            Center(
              child: _isLoading
                  ? CircularProgressIndicator(strokeWidth: 2.0)
                  : _buildAvatarImage(effectivePlaceholderIconColor),
            ),
            
            // 编辑图标
            if (widget.editable)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: effectiveEditIconBackgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.editIcon,
                    color: effectiveEditIconColor,
                    size: widget.size / 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 构建头像图片
  Widget _buildAvatarImage(Color? placeholderColor) {
    final effectivePlaceholderIconSize = widget.placeholderIconSize ?? widget.size / 2;
    
    if (_selectedImage != null) {
      // 显示本地选择的图片
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      // 显示网络图片
      return ClipOval(
        child: Image.network(
          widget.avatarUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.0,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              widget.placeholderIcon,
              size: effectivePlaceholderIconSize,
              color: placeholderColor,
            );
          },
        ),
      );
    } else {
      // 显示占位图标
      return Icon(
        widget.placeholderIcon,
        size: effectivePlaceholderIconSize,
        color: placeholderColor,
      );
    }
  }

  // 显示图片源选择对话框
  Future<void> _showImageSourceOptions() async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '选择头像',
                  style: textTheme.titleLarge,
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null || (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)) ...[
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        // 简单处理，没有裁剪功能
        final imageFile = File(pickedFile.path);
        
        setState(() {
          _selectedImage = imageFile;
          _isLoading = false;
        });
        
        // 调用头像更改回调
        if (widget.onAvatarChanged != null) {
          widget.onAvatarChanged!(imageFile);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 删除头像
  void _removeAvatar() {
    setState(() {
      _selectedImage = null;
    });
    
    // 调用头像更改回调，传递null表示删除头像
    if (widget.onAvatarChanged != null) {
      // 这里可能需要根据具体业务逻辑来处理删除头像的情况
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('头像已删除')),
    );
  }
} 