package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	Username  string    `json:"username" gorm:"uniqueIndex;not null"`
	Password  string    `json:"-" gorm:"not null"`
	Nickname  string    `json:"nickname"`
	Avatar    string    `json:"avatar"`
	Email     string    `json:"email"`
	Mobile    string    `json:"mobile"`
	IsAdmin   int       `json:"is_admin" gorm:"default:0"` // 0=普通用户,1=管理员
	Status    int       `json:"status" gorm:"default:1"`   // 0=禁用,1=正常
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// UserAddress 用户收货地址模型
type UserAddress struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"not null;index"`
	Consignee string    `json:"consignee" gorm:"not null"`
	Mobile    string    `json:"mobile" gorm:"not null"`
	Province  string    `json:"province" gorm:"not null"`
	City      string    `json:"city" gorm:"not null"`
	District  string    `json:"district" gorm:"not null"`
	Address   string    `json:"address" gorm:"not null"`
	IsDefault int       `json:"is_default" gorm:"default:0"` // 0=非默认,1=默认
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token  string `json:"token"`
	User   User   `json:"user"`
	Expire string `json:"expire"`
}

// TableName 指定表名
func (User) TableName() string {
	return "users"
}

// TableName 指定表名
func (UserAddress) TableName() string {
	return "shop_addresses"
}

// FindByUsername 根据用户名查找用户
func (u *User) FindByUsername(db *gorm.DB, username string) (User, error) {
	var user User
	if err := db.Where("username = ?", username).First(&user).Error; err != nil {
		return User{}, err
	}
	return user, nil
}

// FindByID 根据ID查找用户
func (u *User) FindByID(db *gorm.DB, id uint) (User, error) {
	var user User
	if err := db.First(&user, id).Error; err != nil {
		return User{}, err
	}
	return user, nil
}

// GetAddresses 获取用户收货地址列表
func (u *UserAddress) GetAddresses(db *gorm.DB, userID uint) ([]UserAddress, error) {
	var addresses []UserAddress
	if err := db.Where("user_id = ?", userID).Order("is_default DESC, id DESC").Find(&addresses).Error; err != nil {
		return nil, err
	}
	return addresses, nil
}

// GetAddressByID 根据ID获取收货地址
func (u *UserAddress) GetAddressByID(db *gorm.DB, id uint, userID uint) (UserAddress, error) {
	var address UserAddress
	if err := db.Where("id = ? AND user_id = ?", id, userID).First(&address).Error; err != nil {
		return UserAddress{}, err
	}
	return address, nil
}

// CreateAddress 创建收货地址
func (u *UserAddress) CreateAddress(db *gorm.DB) error {
	// 如果设置为默认地址，先将其他地址设为非默认
	if u.IsDefault == 1 {
		if err := db.Model(&UserAddress{}).Where("user_id = ?", u.UserID).Update("is_default", 0).Error; err != nil {
			return err
		}
	}
	return db.Create(u).Error
}

// UpdateAddress 更新收货地址
func (u *UserAddress) UpdateAddress(db *gorm.DB) error {
	// 如果设置为默认地址，先将其他地址设为非默认
	if u.IsDefault == 1 {
		if err := db.Model(&UserAddress{}).Where("user_id = ? AND id != ?", u.UserID, u.ID).Update("is_default", 0).Error; err != nil {
			return err
		}
	}
	return db.Save(u).Error
}

// DeleteAddress 删除收货地址
func (u *UserAddress) DeleteAddress(db *gorm.DB, id uint, userID uint) error {
	return db.Where("id = ? AND user_id = ?", id, userID).Delete(&UserAddress{}).Error
} 