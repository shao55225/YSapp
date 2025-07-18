// API常量定义
class ApiConstants {
  // 基础URL - 修改为实际地址
  static const String baseUrl = 'http://heigeweiwu.cn';
  
  // ========== 站点信息 ==========
  
  // 基础配置
  static const String siteInfo = '/openapi/template/site_info';
  static const String siteAds = '/openapi/template/site_ads';
  static const String constant = '/openapi/constant';
  static const String shareConfig = '/openapi/siteConfig/share';
  static const String seoConfig = '/openapi/siteConfig/seo';
  static const String payConfig = '/openapi/siteConfig/pay';
  static const String goldRate = '/openapi/siteConfig/goldRate';
  static const String camiShopUrl = '/openapi/siteConfig/camiShopUrl';
  static const String customer = '/openapi/template/customer';
  
  // ========== 第三方站点系统 ==========
  
  // 第三方站点
  static const String thirdPartySites = '/openapi/third-party/sites';
  static const String thirdPartyCheck = '/openapi/third-party/check';
  static const String thirdPartyRecommend = '/openapi/third-party/recommend';

  // ========== 影视系统 ==========
  
  // 视频内容
  static const String vodList = '/openapi/template/vod/list';
  static const String vodDetail = '/openapi/template/vod/detail';
  static const String vodPlay = '/openapi/template/vod/play';
  static const String vodSearch = '/openapi/template/vod/search';
  static const String vodCategory = '/openapi/template/vod/category';
  static const String vodHot = '/openapi/template/vod/hot';
  static const String vodRecommend = '/openapi/template/vod/recommend';
  static const String vodBanner = '/openapi/template/vod/banner';
  
  // ========== 用户认证系统 ==========
  
  // 用户认证
  static const String login = '/openapi/member/login';
  static const String register = '/openapi/member/register';
  static const String verifyLogin = '/openapi/member/verify/login';
  static const String verifyRegister = '/openapi/member/verify/register';
  static const String touristsRegister = '/openapi/member/tourists/register';
  static const String captcha = '/openapi/auth/captcha';
  static const String sendSms = '/openapi/sms/send_sms';
  static const String sendEmail = '/openapi/sms/send_email';
  static const String logout = '/api/v1/sso/web/logout';
  
  // ========== 会员系统 ==========
  
  // 会员信息
  static const String memberInfo = '/openapi/member/info';
  static const String editMember = '/openapi/member/edit';
  static const String changeName = '/openapi/member/change_name';
  static const String upload = '/openapi/upload';
  
  // 账号安全
  static const String bindPhone = '/openapi/member/bind_phone';
  static const String bindEmail = '/openapi/member/bind_email';
  static const String changePassword = '/openapi/member/change_password';
  static const String fundPassword = '/openapi/member/fund_password';
  
  // 会员互动
  static const String commentsPage = '/openapi/member/comments/page';
  static const String deleteComment = '/openapi/comments/'; // 后接id
  static const String notifyComments = '/openapi/comments/notify';
  
  // 浏览记录
  static const String browseHistory = '/openapi/browse/page';
  static const String mobileBrowseHistory = '/openapi/browse/mobile/page';
  static const String recordBrowse = '/openapi/browse/record';
  
  // ========== 支付充值系统 ==========
  
  // 支付流程
  static const String createOrder = '/openapi/pay/create_order';
  static const String payStatus = '/openapi/pay/order/pay_status/'; // 后接orderId
  static const String orderStatus = '/openapi/pay/order/status';
  static const String closeWechatOrder = '/openapi/pay/wechat/close_order';
  static const String closeAntOrder = '/openapi/pay/ant/close_order';
  
  // 套餐管理
  static const String allPackages = '/openapi/pck/all';
  static const String packageGroups = '/openapi/pck/group/all';
  static const String exchangePackage = '/openapi/pck/exchange/'; // 后接id
  
  // 金币系统
  static const String goldPage = '/openapi/gold/page';
  static const String goldInfo = '/openapi/gold/info';
  static const String activeCard = '/openapi/cami/v3/active';
  
  // ========== 收藏评论系统 ==========
  
  // 收藏
  static const String collect = '/openapi/collect';
  static const String cancelCollect = '/openapi/collect/cancel';
  static const String collectPage = '/openapi/collect/page';
  
  // 评论
  static const String comments = '/openapi/comments';
  static const String commentsResourcesPage = '/openapi/comments/resources/page';
  
  // ========== 订单系统 ==========
  
  // 订单管理
  static const String orderPage = '/openapi/order/page';
  static const String orderDetail = '/openapi/order/'; // 后接id
  static const String deleteOrder = '/openapi/order/del';
  
  // ========== 代理系统 ==========
  
  // 代理信息
  static const String agentOpen = '/openapi/member/agent/open';
  static const String agentInfo = '/openapi/member/agent/info/pc';
  static const String becomeAgent = '/openapi/member/become_agent';
  static const String inviteCode = '/openapi/member/invite_code';
  
  // ========== 签到任务系统 ==========
  
  // 签到
  static const String sign = '/openapi/sign';
  static const String signList = '/openapi/sign/list';
  static const String taskList = '/openapi/task/list';
  
  // ========== 反馈系统 ==========
  
  // 反馈
  static const String feedbacks = '/openapi/feedbacks';
  static const String feedbacksPage = '/openapi/feedbacks/page';
  
  // ========== 通知系统 ==========
  
  // 通知
  static const String noticesPage = '/openapi/notices/page';
  
  // ========== 商城系统 ==========
  
  // 商品管理
  static const String shopProducts = '/openapi/shop/products';
  static const String shopProductDetail = '/openapi/shop/product/';  // 后接id
  static const String shopCategories = '/openapi/shop/categories';
  
  // 购物车
  static const String shopCart = '/openapi/shop/cart';
  static const String shopCartAdd = '/openapi/shop/cart/add';
  static const String shopCartUpdate = '/openapi/shop/cart/update';
  static const String shopCartDelete = '/openapi/shop/cart/delete';
  
  // 订单
  static const String shopOrderCreate = '/openapi/shop/order/create';
  static const String shopOrderList = '/openapi/shop/order/list';
  static const String shopOrderDetail = '/openapi/shop/order/'; // 后接id
  static const String shopOrderCancel = '/openapi/shop/order/cancel/'; // 后接id
  // 用户收藏相关
  static const String userCollect = '/openapi/u/collect'; // 收藏
  static const String userIsCollect = '/openapi/u/isCollect'; // 是否已收藏
  static const String userCancelCollect = '/openapi/u/cancelCollect'; // 取消收藏
  static const String userCollectList = '/openapi/u/collectList'; // 收藏列表

  // 商城相关
  static const String shopCategories = '/openapi/shop/categories'; // 商品分类
  static const String shopProducts = '/openapi/shop/products'; // 商品列表
  static const String shopProductDetail = '/openapi/shop/product/'; // 商品详情，需要附加商品ID
  static const String shopCart = '/openapi/shop/cart'; // 购物车
  static const String shopCartAdd = '/openapi/shop/cart/add'; // 添加购物车
  static const String shopCartUpdate = '/openapi/shop/cart/update'; // 更新购物车
  static const String shopCartDelete = '/openapi/shop/cart/delete'; // 删除购物车
  static const String shopOrderCreate = '/openapi/shop/order/create'; // 创建订单
  static const String shopOrderList = '/openapi/shop/orders'; // 订单列表
  static const String shopOrderDetail = '/openapi/shop/order/'; // 订单详情，需要附加订单ID
  static const String shopOrderCancel = '/openapi/shop/order/cancel/'; // 取消订单，需要附加订单ID
  static const String userAddress = '/openapi/user/address'; // 用户地址列表
  static const String userAddressAdd = '/openapi/user/address/add'; // 添加地址
  static const String userAddressUpdate = '/openapi/user/address/update'; // 更新地址
  static const String userAddressDelete = '/openapi/user/address/delete'; // 删除地址
  static const String userAddressDefault = '/openapi/user/address/default'; // 设置默认地址
}
