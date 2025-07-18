  // 处理响应
  dynamic _handleResponse(Response response) {
    // 爱影CMS API的响应格式为 { code: 200, message: "操作成功", data: {...} }
    if (response.statusCode == 200) {
      final data = response.data;
      
      // 添加更详细的日志以便调试
      print('API响应: ${response.realUri}, 状态: ${response.statusCode}, 数据: ${response.data}');
      
      // 处理各种可能的响应格式
      if (data is Map<String, dynamic>) {
        if (data.containsKey('code')) {
          if (data['code'] == 200) {
            return data['data'];
          } else {
            throw ApiException(data['message'] ?? '未知错误', data['code'] ?? -1);
          }
        } else if (data.containsKey('statusCode')) {
          // 处理另一种可能的错误格式
          throw ApiException(data['message'] ?? '服务器错误', data['statusCode'] ?? -1);
        } else {
          // 某些API可能直接返回数据而不是标准格式
          return data;
        }
      } else {
        // 如果响应不是Map，直接返回
        return data;
      }
    } else {
      throw ApiException('服务器错误', response.statusCode ?? -1);
    }
  }
