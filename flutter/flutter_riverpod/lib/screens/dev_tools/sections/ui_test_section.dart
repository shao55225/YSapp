import 'package:flutter/material.dart';
import '../widgets/test_card.dart';

class UiTestSection extends StatefulWidget {
  const UiTestSection({Key? key}) : super(key: key);

  @override
  State<UiTestSection> createState() => _UiTestSectionState();
}

class _UiTestSectionState extends State<UiTestSection> {
  double _sliderValue = 0.5;
  bool _switchValue = false;
  int _radioValue = 0;
  bool _checkboxValue = false;
  final _textController = TextEditingController();
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  
  final List<Map<String, dynamic>> _mockData = List.generate(
    20,
    (index) => {
      'id': index,
      'title': '项目 ${index + 1}',
      'subtitle': '这是项目 ${index + 1} 的描述',
      'isActive': index % 3 == 0,
    },
  );

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TestCard(
          title: '基础输入组件',
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '文本输入',
                hintText: '请输入文本',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('输入的文本: ${_textController.text}')),
                      );
                    },
                    child: const Text('提交'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _textController.clear();
                    },
                    child: const Text('清除'),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        TestCard(
          title: '选择组件',
          children: [
            Row(
              children: [
                const Text('开关:'),
                const Spacer(),
                Switch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ],
            ),
            
            Row(
              children: [
                const Text('复选框:'),
                const Spacer(),
                Checkbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value ?? false;
                    });
                  },
                ),
              ],
            ),
            
            const Text('单选按钮:'),
            Row(
              children: [0, 1, 2].map((value) {
                return Expanded(
                  child: RadioListTile<int>(
                    title: Text('选项 ${value + 1}'),
                    value: value,
                    groupValue: _radioValue,
                    onChanged: (newValue) {
                      setState(() {
                        _radioValue = newValue!;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            
            const Text('滑块:'),
            Slider(
              value: _sliderValue,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
              divisions: 10,
              label: (_sliderValue * 100).toStringAsFixed(0),
            ),
            
            Text('当前值: ${(_sliderValue * 100).toStringAsFixed(0)}%'),
          ],
        ),
        
        TestCard(
          title: '列表和网格',
          children: [
            const Text('列表视图:'),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _mockData.length,
                itemBuilder: (context, index) {
                  final item = _mockData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: item['isActive'] ? Colors.blue : Colors.grey,
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['subtitle']),
                    trailing: item['isActive']
                        ? const Icon(Icons.star, color: Colors.amber)
                        : null,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('点击了 ${item['title']}')),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('网格视图:'),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('点击了网格项 ${index + 1}')),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.primaries[index % Colors.primaries.length],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        TestCard(
          title: '标签页',
          children: [
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.home), text: '首页'),
                      Tab(icon: Icon(Icons.star), text: '收藏'),
                      Tab(icon: Icon(Icons.person), text: '我的'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                  ),
                  Container(
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    child: TabBarView(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.home, size: 48),
                              SizedBox(height: 8),
                              Text('首页内容'),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star, size: 48),
                              SizedBox(height: 8),
                              Text('收藏内容'),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person, size: 48),
                              SizedBox(height: 8),
                              Text('个人中心'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        TestCard(
          title: '底部导航栏',
          children: [
            BottomNavigationBar(
              currentIndex: _selectedTabIndex,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '搜索',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '当前选中: ${['首页', '搜索', '我的'][_selectedTabIndex]}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        
        TestCard(
          title: '对话框和弹出窗口',
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('提示'),
                          content: const Text('这是一个提示对话框'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('显示对话框'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          height: 200,
                          child: Column(
                            children: [
                              const Text(
                                '底部菜单',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListTile(
                                leading: const Icon(Icons.share),
                                title: const Text('分享'),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              ListTile(
                                leading: const Icon(Icons.download),
                                title: const Text('下载'),
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('底部菜单'),
                  ),
                ),
              ],
            ),
            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('这是一个提示消息'),
                    action: SnackBarAction(
                      label: '确定',
                      onPressed: () {},
                    ),
                  ),
                );
              },
              child: const Text('显示Snackbar'),
            ),
          ],
        ),
        
        TestCard(
          title: '搜索组件',
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('搜索: $value')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              children: [
                '热门电影',
                '最新上线',
                '动作片',
                '喜剧片',
                '科幻片',
              ].map((tag) {
                return ActionChip(
                  label: Text(tag),
                  onPressed: () {
                    _searchController.text = tag;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('选择了: $tag')),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
} 