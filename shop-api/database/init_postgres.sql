-- 商城系统和第三方站点表结构 - PostgreSQL版本 - 适用于已有数据库
-- 注意：此脚本只创建新表，不会创建数据库或影响现有表

-- 商品分类表
CREATE TABLE IF NOT EXISTS shop_categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  icon VARCHAR(255),
  sort_order INTEGER NOT NULL DEFAULT 0,
  status SMALLINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE shop_categories IS '商品分类表';
COMMENT ON COLUMN shop_categories.name IS '分类名称';
COMMENT ON COLUMN shop_categories.icon IS '分类图标';
COMMENT ON COLUMN shop_categories.sort_order IS '排序';
COMMENT ON COLUMN shop_categories.status IS '状态: 0=禁用,1=启用';

-- 商品表
CREATE TABLE IF NOT EXISTS shop_products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  gold_price INTEGER NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  category_id INTEGER NOT NULL,
  image_url VARCHAR(255),
  detail_images TEXT,
  status SMALLINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_category ON shop_products(category_id);
CREATE INDEX IF NOT EXISTS idx_status ON shop_products(status);
COMMENT ON TABLE shop_products IS '商品表';
COMMENT ON COLUMN shop_products.name IS '商品名称';
COMMENT ON COLUMN shop_products.description IS '商品描述';
COMMENT ON COLUMN shop_products.price IS '商品价格';
COMMENT ON COLUMN shop_products.gold_price IS '金币价格';
COMMENT ON COLUMN shop_products.stock IS '库存';
COMMENT ON COLUMN shop_products.category_id IS '分类ID';
COMMENT ON COLUMN shop_products.image_url IS '主图';
COMMENT ON COLUMN shop_products.detail_images IS '详情图片JSON';
COMMENT ON COLUMN shop_products.status IS '状态: 0=下架,1=上架';

-- 订单表
CREATE TABLE IF NOT EXISTS shop_orders (
  id SERIAL PRIMARY KEY,
  order_no VARCHAR(32) NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  total_gold INTEGER NOT NULL,
  status SMALLINT NOT NULL DEFAULT 0,
  pay_method VARCHAR(20),
  pay_time TIMESTAMP,
  address_id INTEGER,
  consignee VARCHAR(50),
  mobile VARCHAR(20),
  address VARCHAR(255),
  remark VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_user_id ON shop_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_status ON shop_orders(status);
COMMENT ON TABLE shop_orders IS '订单表';
COMMENT ON COLUMN shop_orders.order_no IS '订单号';
COMMENT ON COLUMN shop_orders.user_id IS '用户ID';
COMMENT ON COLUMN shop_orders.total_amount IS '总金额';
COMMENT ON COLUMN shop_orders.total_gold IS '总金币';
COMMENT ON COLUMN shop_orders.status IS '状态: 0=待支付,1=已支付,2=已发货,3=已完成,4=已取消';
COMMENT ON COLUMN shop_orders.pay_method IS '支付方式';
COMMENT ON COLUMN shop_orders.pay_time IS '支付时间';
COMMENT ON COLUMN shop_orders.address_id IS '收货地址ID';
COMMENT ON COLUMN shop_orders.consignee IS '收货人';
COMMENT ON COLUMN shop_orders.mobile IS '手机号';
COMMENT ON COLUMN shop_orders.address IS '收货地址';
COMMENT ON COLUMN shop_orders.remark IS '备注';

-- 订单商品表
CREATE TABLE IF NOT EXISTS shop_order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  product_image VARCHAR(255),
  price DECIMAL(10,2) NOT NULL,
  gold_price INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_order_id ON shop_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_product_id ON shop_order_items(product_id);
COMMENT ON TABLE shop_order_items IS '订单商品表';
COMMENT ON COLUMN shop_order_items.order_id IS '订单ID';
COMMENT ON COLUMN shop_order_items.product_id IS '商品ID';
COMMENT ON COLUMN shop_order_items.product_name IS '商品名称';
COMMENT ON COLUMN shop_order_items.product_image IS '商品图片';
COMMENT ON COLUMN shop_order_items.price IS '价格';
COMMENT ON COLUMN shop_order_items.gold_price IS '金币价格';
COMMENT ON COLUMN shop_order_items.quantity IS '数量';

-- 购物车表
CREATE TABLE IF NOT EXISTS shop_carts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, product_id)
);
COMMENT ON TABLE shop_carts IS '购物车表';
COMMENT ON COLUMN shop_carts.user_id IS '用户ID';
COMMENT ON COLUMN shop_carts.product_id IS '商品ID';
COMMENT ON COLUMN shop_carts.quantity IS '数量';

-- 用户地址表
CREATE TABLE IF NOT EXISTS shop_addresses (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  consignee VARCHAR(50) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  province VARCHAR(50) NOT NULL,
  city VARCHAR(50) NOT NULL,
  district VARCHAR(50) NOT NULL,
  address VARCHAR(255) NOT NULL,
  is_default SMALLINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_user_id_addr ON shop_addresses(user_id);
COMMENT ON TABLE shop_addresses IS '用户地址表';
COMMENT ON COLUMN shop_addresses.user_id IS '用户ID';
COMMENT ON COLUMN shop_addresses.consignee IS '收货人';
COMMENT ON COLUMN shop_addresses.mobile IS '手机号';
COMMENT ON COLUMN shop_addresses.province IS '省份';
COMMENT ON COLUMN shop_addresses.city IS '城市';
COMMENT ON COLUMN shop_addresses.district IS '区县';
COMMENT ON COLUMN shop_addresses.address IS '详细地址';
COMMENT ON COLUMN shop_addresses.is_default IS '是否默认地址: 0=否,1=是';

-- 第三方站点表
CREATE TABLE IF NOT EXISTS third_party_sites (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  url VARCHAR(255) NOT NULL,
  priority INTEGER NOT NULL DEFAULT 0,
  status SMALLINT NOT NULL DEFAULT 1,
  last_check TIMESTAMP,
  is_alive SMALLINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_status_alive ON third_party_sites(status, is_alive);
COMMENT ON TABLE third_party_sites IS '第三方站点表';
COMMENT ON COLUMN third_party_sites.name IS '站点名称';
COMMENT ON COLUMN third_party_sites.url IS '站点链接';
COMMENT ON COLUMN third_party_sites.priority IS '优先级';
COMMENT ON COLUMN third_party_sites.status IS '状态: 0=禁用,1=启用';
COMMENT ON COLUMN third_party_sites.last_check IS '最后检测时间';
COMMENT ON COLUMN third_party_sites.is_alive IS '是否可用: 0=不可用,1=可用';

-- 站点健康检测记录表
CREATE TABLE IF NOT EXISTS site_health_checks (
  id SERIAL PRIMARY KEY,
  site_id INTEGER NOT NULL,
  check_time TIMESTAMP NOT NULL,
  status_code INTEGER,
  response_time INTEGER,
  is_alive SMALLINT NOT NULL DEFAULT 0,
  error_message TEXT
);
CREATE INDEX IF NOT EXISTS idx_site_id ON site_health_checks(site_id);
CREATE INDEX IF NOT EXISTS idx_check_time ON site_health_checks(check_time);
COMMENT ON TABLE site_health_checks IS '站点健康检测记录表';
COMMENT ON COLUMN site_health_checks.site_id IS '站点ID';
COMMENT ON COLUMN site_health_checks.check_time IS '检测时间';
COMMENT ON COLUMN site_health_checks.status_code IS 'HTTP状态码';
COMMENT ON COLUMN site_health_checks.response_time IS '响应时间(毫秒)';
COMMENT ON COLUMN site_health_checks.is_alive IS '是否可用: 0=不可用,1=可用';
COMMENT ON COLUMN site_health_checks.error_message IS '错误信息';

-- 插入第三方站点数据
INSERT INTO third_party_sites (name, url, priority, status, is_alive, created_at, updated_at)
VALUES 
('YZ9999站点', 'https://yz9999.co', 200, 1, 1, NOW(), NOW()),
('YZ8888站点', 'https://yz8888.co', 190, 1, 1, NOW(), NOW());