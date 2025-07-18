import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';

import '../../api/services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/loading_indicator.dart';

// 编辑表单状态提供者
final editProfileFormProvider = StateNotifierProvider.autoDispose<EditProfileFormNotifier, EditProfileFormState>((ref) {
  return EditProfileFormNotifier(ref);
});

// 编辑表单状态
class EditProfileFormState {
  final String? nickname;
  final int? sex;
  final String? headImg;
  final File? imageFile;
  final bool isLoading;
  final String? errorMessage;

  EditProfileFormState({
    this.nickname,
    this.sex,
    this.headImg,
    this.imageFile,
    this.isLoading = false,
    this.errorMessage,
  });

  EditProfileFormState copyWith({
    String? nickname,
    int? sex,
    String? headImg,
    File? imageFile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EditProfileFormState(
      nickname: nickname ?? this.nickname,
      sex: sex ?? this.sex,
      headImg: headImg ?? this.headImg,
      imageFile: imageFile ?? this.imageFile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// 编辑表单状态管理
class EditProfileFormNotifier extends StateNotifier<EditProfileFormState> {
  final Ref _ref;
  
  EditProfileFormNotifier(this._ref) : super(EditProfileFormState()) {
    _initUserInfo();
  }

  Future<void> _initUserInfo() async {
    try {
      final userService = _ref.read(userServiceProvider);
      final userInfo = await userService.getUserInfo();
      
      state = state.copyWith(
        nickname: userInfo.nickname,
        sex: userInfo.sex,
        headImg: userInfo.headImg,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '加载用户信息失败');
    }
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void setSex(int sex) {
    state = state.copyWith(sex: sex);
  }

  void setImageFile(File imageFile) {
    state = state.copyWith(imageFile: imageFile);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setErrorMessage(String? errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }
  
  // 上传头像
  Future<String?> _uploadAvatar(File imageFile) async {
    // TODO: 实现头像上传功能
    // 暂时返回一个假的URL
    return 'https://example.com/avatar.jpg';
  }
  
  // 保存个人资料
  Future<bool> saveProfile() async {
    setLoading(true);
    setErrorMessage(null);
    
    try {
      final userService = _ref.read(userServiceProvider);
      
      String? headImg = state.headImg;
      
      // 如果有新头像，先上传
      if (state.imageFile != null) {
        headImg = await _uploadAvatar(state.imageFile!);
        if (headImg == null) {
          setErrorMessage('上传头像失败');
          setLoading(false);
          return false;
        }
      }
      
      // 更新用户信息
      await userService.editUserInfo(
        nickname: state.nickname,
        sex: state.sex,
        headImg: headImg,
      );
      
      // 刷新用户信息
      _ref.refresh(userInfoProvider);
      
      setLoading(false);
      return true;
    } catch (e) {
      setErrorMessage('保存失败: $e');
      setLoading(false);
      return false;
    }
  }
}

class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(editProfileFormProvider);
    final formNotifier = ref.read(editProfileFormProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        actions: [
          TextButton(
            onPressed: formState.isLoading
                ? null
                : () async {
                    final success = await formNotifier.saveProfile();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('保存成功')),
                      );
                      context.pop();
                    }
                  },
            child: formState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: formState.isLoading && formState.nickname == null
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 头像
                  _buildAvatarSection(context, formState, formNotifier),
                  const SizedBox(height: 32.0),
                  
                  // 昵称
                  TextField(
                    controller: TextEditingController(text: formState.nickname),
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      hintText: '请输入昵称',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      formNotifier.setNickname(value);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // 性别
                  _buildGenderSelector(context, formState, formNotifier),
                  const SizedBox(height: 16.0),
                  
                  // 错误信息
                  if (formState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        formState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
  
  // 构建头像部分
  Widget _buildAvatarSection(
    BuildContext context,
    EditProfileFormState formState,
    EditProfileFormNotifier formNotifier,
  ) {
    return Center(
      child: Stack(
        children: [
          // 头像
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _getAvatarImage(formState),
            child: _getAvatarImage(formState) == null
                ? const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          
          // 编辑按钮
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceDialog(context, formNotifier),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 获取头像图片
  ImageProvider? _getAvatarImage(EditProfileFormState formState) {
    if (formState.imageFile != null) {
      return FileImage(formState.imageFile!);
    } else if (formState.headImg != null) {
      return NetworkImage(formState.headImg!);
    }
    return null;
  }
  
  // 构建性别选择器
  Widget _buildGenderSelector(
    BuildContext context,
    EditProfileFormState formState,
    EditProfileFormNotifier formNotifier,
  ) {
    return Row(
      children: [
        const Text('性别：'),
        const SizedBox(width: 16.0),
        Radio<int>(
          value: 1,
          groupValue: formState.sex,
          onChanged: (value) {
            if (value != null) {
              formNotifier.setSex(value);
            }
          },
        ),
        const Text('男'),
        const SizedBox(width: 16.0),
        Radio<int>(
          value: 2,
          groupValue: formState.sex,
          onChanged: (value) {
            if (value != null) {
              formNotifier.setSex(value);
            }
          },
        ),
        const Text('女'),
        const SizedBox(width: 16.0),
        Radio<int>(
          value: 0,
          groupValue: formState.sex,
          onChanged: (value) {
            if (value != null) {
              formNotifier.setSex(value);
            }
          },
        ),
        const Text('保密'),
      ],
    );
  }
  
  // 显示图片来源选择对话框
  Future<void> _showImageSourceDialog(
    BuildContext context,
    EditProfileFormNotifier formNotifier,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('拍照'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.camera, formNotifier);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('从相册选择'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.gallery, formNotifier);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 选择图片
  Future<void> _pickImage(
    ImageSource source,
    EditProfileFormNotifier formNotifier,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile != null) {
        // 裁剪图片
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          formNotifier.setImageFile(croppedFile);
        }
      }
    } catch (e) {
      formNotifier.setErrorMessage('选择图片失败: $e');
    }
  }
  
  // 裁剪图片
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪图片',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '裁剪图片',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // 忽略错误
    }
    
    return null;
  }
} 