package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/models"
)

// AddressController 地址控制器
type AddressController struct{}

// GetAddresses 获取地址列表
// @Summary 获取地址列表
// @Description 获取当前用户的地址列表
// @Tags 地址
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} models.Response
// @Router /api/v1/shop/addresses [get]
func (ac *AddressController) GetAddresses(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 查询地址列表
	var address models.UserAddress
	addresses, err := address.GetAddresses(database.DB, userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取地址列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(addresses, "获取地址列表成功", http.StatusOK))
}

// GetAddress 获取地址详情
// @Summary 获取地址详情
// @Description 根据ID获取地址详情
// @Tags 地址
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "地址ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/addresses/{id} [get]
func (ac *AddressController) GetAddress(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取地址ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的地址ID", nil))
		return
	}
	
	// 查询地址
	var address models.UserAddress
	addressInfo, err := address.GetAddressByID(database.DB, uint(id), userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "地址不存在", nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(addressInfo, "获取地址详情成功", http.StatusOK))
}

// CreateAddress 创建地址
// @Summary 创建地址
// @Description 创建新地址
// @Tags 地址
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param address body models.UserAddress true "地址信息"
// @Success 201 {object} models.Response
// @Router /api/v1/shop/addresses [post]
func (ac *AddressController) CreateAddress(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 解析请求参数
	var address models.UserAddress
	if err := c.ShouldBindJSON(&address); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 设置用户ID
	address.UserID = userID.(uint)
	
	// 创建地址
	if err := address.CreateAddress(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建地址失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusCreated, models.NewSuccessResponse(map[string]interface{}{"id": address.ID}, "创建地址成功", http.StatusCreated))
}

// UpdateAddress 更新地址
// @Summary 更新地址
// @Description 更新地址信息
// @Tags 地址
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "地址ID"
// @Param address body models.UserAddress true "地址信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/addresses/{id} [put]
func (ac *AddressController) UpdateAddress(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取地址ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的地址ID", nil))
		return
	}
	
	// 检查地址是否存在
	var address models.UserAddress
	_, err = address.GetAddressByID(database.DB, uint(id), userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "地址不存在", nil))
		return
	}
	
	// 解析请求参数
	if err := c.ShouldBindJSON(&address); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 设置ID和用户ID
	address.ID = uint(id)
	address.UserID = userID.(uint)
	
	// 更新地址
	if err := address.UpdateAddress(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新地址失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "更新地址成功", http.StatusOK))
}

// DeleteAddress 删除地址
// @Summary 删除地址
// @Description 删除地址
// @Tags 地址
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "地址ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/addresses/{id} [delete]
func (ac *AddressController) DeleteAddress(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取地址ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的地址ID", nil))
		return
	}
	
	// 删除地址
	var address models.UserAddress
	if err := address.DeleteAddress(database.DB, uint(id), userID.(uint)); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "删除地址失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "删除地址成功", http.StatusOK))
} 