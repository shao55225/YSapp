package models

import (
	"time"

	"gorm.io/gorm"
)

// Category 分类模型
type Category struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Name      string    `json:"name" gorm:"not null"`
	Icon      string    `json:"icon" gorm:"type:varchar(255)"`
	SortOrder int       `json:"sort_order" gorm:"not null;default:0"`
	Status    int       `json:"status" gorm:"not null;default:1"` // 0=禁用,1=启用
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// CategoryList 分类列表响应
type CategoryList struct {
	Items      []Category `json:"items"`
	Pagination Pagination `json:"pagination"`
}

// TableName 指定表名
func (Category) TableName() string {
	return "shop_categories"
}

// FindAll 获取分类列表
func (c *Category) FindAll(db *gorm.DB, page, limit int) (CategoryList, error) {
	var categories []Category
	var total int64
	
	query := db.Model(&Category{}).Where("status = ?", 1)
	
	// 计算总数
	if err := query.Count(&total).Error; err != nil {
		return CategoryList{}, err
	}
	
	// 应用排序和分页
	offset := (page - 1) * limit
	if err := query.Order("sort_order ASC").Offset(offset).Limit(limit).Find(&categories).Error; err != nil {
		return CategoryList{}, err
	}
	
	// 构建响应
	return CategoryList{
		Items: categories,
		Pagination: Pagination{
			Page:  page,
			Limit: limit,
			Total: total,
			Pages: (int(total) + limit - 1) / limit,
		},
	}, nil
}

// FindAllNoPage 获取所有分类（不分页）
func (c *Category) FindAllNoPage(db *gorm.DB) ([]Category, error) {
	var categories []Category
	
	if err := db.Where("status = ?", 1).Order("sort_order ASC").Find(&categories).Error; err != nil {
		return nil, err
	}
	
	return categories, nil
}

// FindByID 根据ID获取分类详情
func (c *Category) FindByID(db *gorm.DB, id uint) (Category, error) {
	var category Category
	if err := db.First(&category, id).Error; err != nil {
		return Category{}, err
	}
	return category, nil
}

// Create 创建分类
func (c *Category) Create(db *gorm.DB) error {
	return db.Create(c).Error
}

// Update 更新分类
func (c *Category) Update(db *gorm.DB) error {
	return db.Save(c).Error
}

// Delete 删除分类
func (c *Category) Delete(db *gorm.DB, id uint) error {
	return db.Delete(&Category{}, id).Error
} 