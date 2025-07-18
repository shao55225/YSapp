package models

import (
	"time"

	"gorm.io/gorm"
)

// Cart 购物车模型
type Cart struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"not null;index:idx_user_product,priority:1"`
	ProductID uint      `json:"product_id" gorm:"not null;index:idx_user_product,priority:2"`
	Quantity  int       `json:"quantity" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Product   Product   `json:"product" gorm:"foreignKey:ProductID"`
}

// CartItem 购物车项目（包含商品信息）
type CartItem struct {
	ID          uint    `json:"id"`
	ProductID   uint    `json:"product_id"`
	ProductName string  `json:"product_name"`
	ProductImage string `json:"product_image"`
	Price       float64 `json:"price"`
	GoldPrice   int     `json:"gold_price"`
	Quantity    int     `json:"quantity"`
	Stock       int     `json:"stock"`
}

// CartResponse 购物车响应
type CartResponse struct {
	Items       []CartItem `json:"items"`
	TotalAmount float64    `json:"total_amount"`
	TotalGold   int        `json:"total_gold"`
}

// CartAddRequest 添加购物车请求
type CartAddRequest struct {
	ProductID uint `json:"product_id" binding:"required"`
	Quantity  int  `json:"quantity" binding:"required,min=1"`
}

// CartUpdateRequest 更新购物车请求
type CartUpdateRequest struct {
	Quantity int `json:"quantity" binding:"required,min=1"`
}

// TableName 指定表名
func (Cart) TableName() string {
	return "shop_carts"
}

// GetUserCart 获取用户购物车
func (c *Cart) GetUserCart(db *gorm.DB, userID uint) (CartResponse, error) {
	var cartItems []CartItem
	var totalAmount float64
	var totalGold int
	
	// 查询购物车项目
	rows, err := db.Table("shop_carts as c").
		Select("c.id, c.product_id, p.name as product_name, p.image_url as product_image, p.price, p.gold_price, c.quantity, p.stock").
		Joins("left join shop_products as p on c.product_id = p.id").
		Where("c.user_id = ? AND p.status = 1", userID).
		Order("c.id DESC").
		Rows()
	
	if err != nil {
		return CartResponse{}, err
	}
	defer rows.Close()
	
	// 遍历结果
	for rows.Next() {
		var item CartItem
		if err := db.ScanRows(rows, &item); err != nil {
			return CartResponse{}, err
		}
		
		// 计算总价
		totalAmount += item.Price * float64(item.Quantity)
		totalGold += item.GoldPrice * item.Quantity
		
		cartItems = append(cartItems, item)
	}
	
	return CartResponse{
		Items:       cartItems,
		TotalAmount: totalAmount,
		TotalGold:   totalGold,
	}, nil
}

// AddToCart 添加商品到购物车
func (c *Cart) AddToCart(db *gorm.DB, userID uint, productID uint, quantity int) error {
	// 检查商品是否存在且上架
	var count int64
	if err := db.Model(&Product{}).Where("id = ? AND status = 1", productID).Count(&count).Error; err != nil {
		return err
	}
	
	if count == 0 {
		return gorm.ErrRecordNotFound
	}
	
	// 检查购物车中是否已存在该商品
	var existingCart Cart
	result := db.Where("user_id = ? AND product_id = ?", userID, productID).First(&existingCart)
	
	if result.Error == nil {
		// 已存在，更新数量
		return db.Model(&existingCart).Update("quantity", existingCart.Quantity+quantity).Error
	} else if result.Error == gorm.ErrRecordNotFound {
		// 不存在，创建新记录
		newCart := Cart{
			UserID:    userID,
			ProductID: productID,
			Quantity:  quantity,
		}
		return db.Create(&newCart).Error
	}
	
	return result.Error
}

// UpdateCartQuantity 更新购物车商品数量
func (c *Cart) UpdateCartQuantity(db *gorm.DB, id uint, userID uint, quantity int) error {
	return db.Model(&Cart{}).Where("id = ? AND user_id = ?", id, userID).Update("quantity", quantity).Error
}

// RemoveFromCart 从购物车移除商品
func (c *Cart) RemoveFromCart(db *gorm.DB, id uint, userID uint) error {
	return db.Where("id = ? AND user_id = ?", id, userID).Delete(&Cart{}).Error
}

// ClearCart 清空购物车
func (c *Cart) ClearCart(db *gorm.DB, userID uint) error {
	return db.Where("user_id = ?", userID).Delete(&Cart{}).Error
} 