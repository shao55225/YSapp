package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/models"
)

// CartController 购物车控制器
type CartController struct{}

// GetCart 获取购物车
// @Summary 获取购物车
// @Description 获取当前用户的购物车
// @Tags 购物车
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} models.Response
// @Router /api/v1/shop/cart [get]
func (cc *CartController) GetCart(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 查询购物车
	var cart models.Cart
	cartResponse, err := cart.GetUserCart(database.DB, userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取购物车失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(cartResponse, "获取购物车成功", http.StatusOK))
}

// AddToCart 添加商品到购物车
// @Summary 添加商品到购物车
// @Description 添加商品到购物车
// @Tags 购物车
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param cart body models.CartAddRequest true "商品信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/cart [post]
func (cc *CartController) AddToCart(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 解析请求参数
	var request models.CartAddRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 添加商品到购物车
	var cart models.Cart
	if err := cart.AddToCart(database.DB, userID.(uint), request.ProductID, request.Quantity); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "添加商品到购物车失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "添加商品到购物车成功", http.StatusOK))
}

// UpdateCartItem 更新购物车商品数量
// @Summary 更新购物车商品数量
// @Description 更新购物车中商品的数量
// @Tags 购物车
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "购物车项ID"
// @Param cart body models.CartUpdateRequest true "更新信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/cart/{id} [put]
func (cc *CartController) UpdateCartItem(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取购物车项ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的购物车项ID", nil))
		return
	}
	
	// 解析请求参数
	var request models.CartUpdateRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 更新购物车商品数量
	var cart models.Cart
	if err := cart.UpdateCartQuantity(database.DB, uint(id), userID.(uint), request.Quantity); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新购物车商品数量失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "更新购物车商品数量成功", http.StatusOK))
}

// RemoveFromCart 从购物车移除商品
// @Summary 从购物车移除商品
// @Description 从购物车中移除商品
// @Tags 购物车
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "购物车项ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/cart/{id} [delete]
func (cc *CartController) RemoveFromCart(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取购物车项ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的购物车项ID", nil))
		return
	}
	
	// 从购物车移除商品
	var cart models.Cart
	if err := cart.RemoveFromCart(database.DB, uint(id), userID.(uint)); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "从购物车移除商品失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "从购物车移除商品成功", http.StatusOK))
}

// ClearCart 清空购物车
// @Summary 清空购物车
// @Description 清空当前用户的购物车
// @Tags 购物车
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} models.Response
// @Router /api/v1/shop/cart/clear [delete]
func (cc *CartController) ClearCart(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 清空购物车
	var cart models.Cart
	if err := cart.ClearCart(database.DB, userID.(uint)); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "清空购物车失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "清空购物车成功", http.StatusOK))
} 