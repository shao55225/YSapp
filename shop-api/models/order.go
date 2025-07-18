package models

import (
	"time"

	"gorm.io/gorm"
)

// Order 订单模型
type Order struct {
	ID          uint        `json:"id" gorm:"primaryKey"`
	OrderNo     string      `json:"order_no" gorm:"type:varchar(32);not null;uniqueIndex"`
	UserID      uint        `json:"user_id" gorm:"not null;index"`
	TotalAmount float64     `json:"total_amount" gorm:"not null"`
	TotalGold   int         `json:"total_gold" gorm:"not null"`
	Status      int         `json:"status" gorm:"not null;default:0;index"` // 0=待支付,1=已支付,2=已发货,3=已完成,4=已取消
	PayMethod   string      `json:"pay_method" gorm:"type:varchar(20)"`
	PayTime     *time.Time  `json:"pay_time"`
	AddressID   *uint       `json:"address_id"`
	Consignee   string      `json:"consignee" gorm:"type:varchar(50)"`
	Mobile      string      `json:"mobile" gorm:"type:varchar(20)"`
	Address     string      `json:"address" gorm:"type:varchar(255)"`
	Remark      string      `json:"remark" gorm:"type:varchar(255)"`
	CreatedAt   time.Time   `json:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at"`
	Items       []OrderItem `json:"items" gorm:"foreignKey:OrderID"`
}

// OrderItem 订单商品模型
type OrderItem struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	OrderID     uint      `json:"order_id" gorm:"not null;index"`
	ProductID   uint      `json:"product_id" gorm:"not null;index"`
	ProductName string    `json:"product_name" gorm:"not null"`
	ProductImage string   `json:"product_image"`
	Price       float64   `json:"price" gorm:"not null"`
	GoldPrice   int       `json:"gold_price" gorm:"not null"`
	Quantity    int       `json:"quantity" gorm:"not null"`
	CreatedAt   time.Time `json:"created_at"`
}

// OrderList 订单列表响应
type OrderList struct {
	Items      []Order    `json:"items"`
	Pagination Pagination `json:"pagination"`
}

// OrderCreateRequest 创建订单请求
type OrderCreateRequest struct {
	Products  []OrderProductRequest `json:"products" binding:"required,min=1"`
	AddressID uint                  `json:"address_id" binding:"required"`
	Remark    string                `json:"remark"`
}

// OrderProductRequest 订单商品请求
type OrderProductRequest struct {
	ProductID uint `json:"product_id" binding:"required"`
	Quantity  int  `json:"quantity" binding:"required,min=1"`
	UseGold   bool `json:"use_gold"`
}

// OrderCreateResponse 创建订单响应
type OrderCreateResponse struct {
	OrderID     uint    `json:"order_id"`
	OrderNo     string  `json:"order_no"`
	TotalAmount float64 `json:"total_amount"`
	TotalGold   int     `json:"total_gold"`
	PayURL      string  `json:"pay_url"`
}

// OrderStatusUpdateRequest 更新订单状态请求
type OrderStatusUpdateRequest struct {
	Status int    `json:"status" binding:"required"`
	Remark string `json:"remark"`
}

// TableName 指定表名
func (Order) TableName() string {
	return "shop_orders"
}

// TableName 指定表名
func (OrderItem) TableName() string {
	return "shop_order_items"
}

// FindAll 获取订单列表
func (o *Order) FindAll(db *gorm.DB, userID uint, page, limit int, status int, startDate, endDate string) (OrderList, error) {
	var orders []Order
	var total int64
	
	query := db.Model(&Order{})
	
	// 应用筛选条件
	if userID > 0 {
		query = query.Where("user_id = ?", userID)
	}
	
	if status >= 0 {
		query = query.Where("status = ?", status)
	}
	
	if startDate != "" {
		query = query.Where("created_at >= ?", startDate)
	}
	
	if endDate != "" {
		query = query.Where("created_at <= ?", endDate)
	}
	
	// 计算总数
	if err := query.Count(&total).Error; err != nil {
		return OrderList{}, err
	}
	
	// 应用排序和分页
	offset := (page - 1) * limit
	if err := query.Order("id DESC").Offset(offset).Limit(limit).Find(&orders).Error; err != nil {
		return OrderList{}, err
	}
	
	// 构建响应
	return OrderList{
		Items: orders,
		Pagination: Pagination{
			Page:  page,
			Limit: limit,
			Total: total,
			Pages: (int(total) + limit - 1) / limit,
		},
	}, nil
}

// FindByID 根据ID获取订单详情
func (o *Order) FindByID(db *gorm.DB, id uint, userID uint) (Order, error) {
	var order Order
	query := db.Preload("Items")
	
	if userID > 0 {
		query = query.Where("user_id = ?", userID)
	}
	
	if err := query.First(&order, id).Error; err != nil {
		return Order{}, err
	}
	
	return order, nil
}

// FindByOrderNo 根据订单号获取订单详情
func (o *Order) FindByOrderNo(db *gorm.DB, orderNo string) (Order, error) {
	var order Order
	if err := db.Preload("Items").Where("order_no = ?", orderNo).First(&order).Error; err != nil {
		return Order{}, err
	}
	return order, nil
}

// Create 创建订单
func (o *Order) Create(db *gorm.DB) error {
	return db.Create(o).Error
}

// Update 更新订单
func (o *Order) Update(db *gorm.DB) error {
	return db.Save(o).Error
}

// UpdateStatus 更新订单状态
func (o *Order) UpdateStatus(db *gorm.DB, id uint, status int, remark string) error {
	updates := map[string]interface{}{
		"status": status,
	}
	
	if remark != "" {
		updates["remark"] = remark
	}
	
	if status == 1 { // 已支付
		now := time.Now()
		updates["pay_time"] = now
	}
	
	return db.Model(&Order{}).Where("id = ?", id).Updates(updates).Error
}

// CreateWithItems 创建订单及订单商品
func (o *Order) CreateWithItems(db *gorm.DB, items []OrderItem) error {
	return db.Transaction(func(tx *gorm.DB) error {
		// 创建订单
		if err := tx.Create(o).Error; err != nil {
			return err
		}
		
		// 创建订单商品
		for i := range items {
			items[i].OrderID = o.ID
			if err := tx.Create(&items[i]).Error; err != nil {
				return err
			}
			
			// 减少商品库存
			if err := tx.Model(&Product{}).Where("id = ?", items[i].ProductID).
				UpdateColumn("stock", gorm.Expr("stock - ?", items[i].Quantity)).Error; err != nil {
				return err
			}
		}
		
		return nil
	})
} 