package models

import (
	"time"

	"gorm.io/gorm"
)

// Product 商品模型
type Product struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	Name         string    `json:"name" gorm:"not null"`
	Description  string    `json:"description" gorm:"type:text"`
	Price        float64   `json:"price" gorm:"not null"`
	GoldPrice    int       `json:"gold_price" gorm:"not null"`
	Stock        int       `json:"stock" gorm:"not null;default:0"`
	CategoryID   uint      `json:"category_id" gorm:"not null;index"`
	ImageURL     string    `json:"image_url" gorm:"type:varchar(255)"`
	DetailImages string    `json:"detail_images" gorm:"type:text"`
	Status       int       `json:"status" gorm:"not null;default:1;index"` // 0=下架,1=上架
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
	Category     Category  `json:"category" gorm:"foreignKey:CategoryID"`
}

// ProductList 商品列表响应
type ProductList struct {
	Items      []Product `json:"items"`
	Pagination Pagination `json:"pagination"`
}

// TableName 指定表名
func (Product) TableName() string {
	return "shop_products"
}

// FindAll 获取商品列表
func (p *Product) FindAll(db *gorm.DB, page, limit int, categoryID uint, keyword string, sort string, status int) (ProductList, error) {
	var products []Product
	var total int64
	
	query := db.Model(&Product{})
	
	// 应用筛选条件
	if categoryID > 0 {
		query = query.Where("category_id = ?", categoryID)
	}
	
	if keyword != "" {
		query = query.Where("name LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")
	}
	
	if status >= 0 {
		query = query.Where("status = ?", status)
	}
	
	// 计算总数
	if err := query.Count(&total).Error; err != nil {
		return ProductList{}, err
	}
	
	// 应用排序
	switch sort {
	case "price_asc":
		query = query.Order("price ASC")
	case "price_desc":
		query = query.Order("price DESC")
	default:
		query = query.Order("id DESC")
	}
	
	// 应用分页
	offset := (page - 1) * limit
	if err := query.Preload("Category").Offset(offset).Limit(limit).Find(&products).Error; err != nil {
		return ProductList{}, err
	}
	
	// 构建响应
	return ProductList{
		Items: products,
		Pagination: Pagination{
			Page:  page,
			Limit: limit,
			Total: total,
			Pages: (int(total) + limit - 1) / limit,
		},
	}, nil
}

// FindByID 根据ID获取商品详情
func (p *Product) FindByID(db *gorm.DB, id uint) (Product, error) {
	var product Product
	if err := db.Preload("Category").First(&product, id).Error; err != nil {
		return Product{}, err
	}
	return product, nil
}

// Create 创建商品
func (p *Product) Create(db *gorm.DB) error {
	return db.Create(p).Error
}

// Update 更新商品
func (p *Product) Update(db *gorm.DB) error {
	return db.Save(p).Error
}

// Delete 删除商品
func (p *Product) Delete(db *gorm.DB, id uint) error {
	return db.Delete(&Product{}, id).Error
} 