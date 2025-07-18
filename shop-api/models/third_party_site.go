package models

import (
	"time"

	"gorm.io/gorm"
)

// ThirdPartySite 第三方站点模型
type ThirdPartySite struct {
	ID        uint       `json:"id" gorm:"primaryKey"`
	Name      string     `json:"name" gorm:"not null"`
	URL       string     `json:"url" gorm:"not null"`
	Priority  int        `json:"priority" gorm:"not null;default:0"`
	Status    int        `json:"status" gorm:"not null;default:1"` // 0=禁用,1=启用
	LastCheck *time.Time `json:"last_check"`
	IsAlive   int        `json:"is_alive" gorm:"not null;default:1"` // 0=不可用,1=可用
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
}

// SiteHealthCheck 站点健康检测记录
type SiteHealthCheck struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	SiteID       uint      `json:"site_id" gorm:"not null;index"`
	CheckTime    time.Time `json:"check_time" gorm:"not null;index"`
	StatusCode   *int      `json:"status_code"`
	ResponseTime *int      `json:"response_time"` // 毫秒
	IsAlive      int       `json:"is_alive" gorm:"not null;default:0"` // 0=不可用,1=可用
	ErrorMessage string    `json:"error_message"`
}

// SiteList 站点列表响应
type SiteList struct {
	Items      []ThirdPartySite `json:"items"`
	Pagination Pagination       `json:"pagination"`
}

// SiteResponse 站点响应
type SiteResponse struct {
	ID       uint   `json:"id"`
	Name     string `json:"name"`
	URL      string `json:"url"`
	Priority int    `json:"priority"`
	IsAlive  int    `json:"is_alive"`
}

// TableName 指定表名
func (ThirdPartySite) TableName() string {
	return "third_party_sites"
}

// TableName 指定表名
func (SiteHealthCheck) TableName() string {
	return "site_health_checks"
}

// FindAll 获取站点列表
func (s *ThirdPartySite) FindAll(db *gorm.DB, page, limit int) (SiteList, error) {
	var sites []ThirdPartySite
	var total int64
	
	query := db.Model(&ThirdPartySite{})
	
	// 计算总数
	if err := query.Count(&total).Error; err != nil {
		return SiteList{}, err
	}
	
	// 应用排序和分页
	offset := (page - 1) * limit
	if err := query.Order("priority DESC").Offset(offset).Limit(limit).Find(&sites).Error; err != nil {
		return SiteList{}, err
	}
	
	// 构建响应
	return SiteList{
		Items: sites,
		Pagination: Pagination{
			Page:  page,
			Limit: limit,
			Total: total,
			Pages: (int(total) + limit - 1) / limit,
		},
	}, nil
}

// FindAvailableSites 获取可用站点列表
func (s *ThirdPartySite) FindAvailableSites(db *gorm.DB) ([]SiteResponse, error) {
	var sites []SiteResponse
	
	if err := db.Model(&ThirdPartySite{}).
		Select("id, name, url, priority, is_alive").
		Where("status = ? AND is_alive = ?", 1, 1).
		Order("priority DESC").
		Find(&sites).Error; err != nil {
		return nil, err
	}
	
	return sites, nil
}

// FindByID 根据ID获取站点详情
func (s *ThirdPartySite) FindByID(db *gorm.DB, id uint) (ThirdPartySite, error) {
	var site ThirdPartySite
	if err := db.First(&site, id).Error; err != nil {
		return ThirdPartySite{}, err
	}
	return site, nil
}

// Create 创建站点
func (s *ThirdPartySite) Create(db *gorm.DB) error {
	return db.Create(s).Error
}

// Update 更新站点
func (s *ThirdPartySite) Update(db *gorm.DB) error {
	return db.Save(s).Error
}

// Delete 删除站点
func (s *ThirdPartySite) Delete(db *gorm.DB, id uint) error {
	return db.Delete(&ThirdPartySite{}, id).Error
}

// UpdateStatus 更新站点状态
func (s *ThirdPartySite) UpdateStatus(db *gorm.DB, id uint, status int) error {
	return db.Model(&ThirdPartySite{}).Where("id = ?", id).Update("status", status).Error
}

// UpdateHealthStatus 更新站点健康状态
func (s *ThirdPartySite) UpdateHealthStatus(db *gorm.DB, id uint, isAlive int) error {
	now := time.Now()
	return db.Model(&ThirdPartySite{}).Where("id = ?", id).Updates(map[string]interface{}{
		"is_alive":    isAlive,
		"last_check": now,
	}).Error
}

// RecordHealthCheck 记录健康检测结果
func (s *SiteHealthCheck) RecordHealthCheck(db *gorm.DB) error {
	return db.Create(s).Error
} 