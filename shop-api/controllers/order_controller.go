package controllers

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/models"
)

// OrderController 订单控制器
type OrderController struct{}

// GetOrders 获取订单列表
// @Summary 获取订单列表
// @Description 获取当前用户的订单列表
// @Tags 订单
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页记录数，默认20"
// @Param status query int false "状态，默认全部"
// @Param start_date query string false "开始日期，格式：YYYY-MM-DD"
// @Param end_date query string false "结束日期，格式：YYYY-MM-DD"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/orders [get]
func (oc *OrderController) GetOrders(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	status, _ := strconv.Atoi(c.DefaultQuery("status", "-1"))
	startDate := c.DefaultQuery("start_date", "")
	endDate := c.DefaultQuery("end_date", "")
	
	// 查询订单
	var order models.Order
	orderList, err := order.FindAll(database.DB, userID.(uint), page, limit, status, startDate, endDate)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取订单列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(orderList, "获取订单列表成功", http.StatusOK))
}

// GetOrder 获取订单详情
// @Summary 获取订单详情
// @Description 根据ID获取订单详情
// @Tags 订单
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "订单ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/orders/{id} [get]
func (oc *OrderController) GetOrder(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取订单ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的订单ID", nil))
		return
	}
	
	// 查询订单
	var order models.Order
	orderInfo, err := order.FindByID(database.DB, uint(id), userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "订单不存在", nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(orderInfo, "获取订单详情成功", http.StatusOK))
}

// CreateOrder 创建订单
// @Summary 创建订单
// @Description 创建新订单
// @Tags 订单
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param order body models.OrderCreateRequest true "订单信息"
// @Success 201 {object} models.Response
// @Router /api/v1/shop/orders [post]
func (oc *OrderController) CreateOrder(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 解析请求参数
	var request models.OrderCreateRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 获取收货地址
	var address models.UserAddress
	addressInfo, err := address.GetAddressByID(database.DB, request.AddressID, userID.(uint))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的收货地址", nil))
		return
	}
	
	// 创建订单
	order := models.Order{
		UserID:    userID.(uint),
		OrderNo:   fmt.Sprintf("%s%d", time.Now().Format("20060102150405"), userID),
		Status:    0, // 待支付
		AddressID: &request.AddressID,
		Consignee: addressInfo.Consignee,
		Mobile:    addressInfo.Mobile,
		Address:   addressInfo.Province + addressInfo.City + addressInfo.District + addressInfo.Address,
		Remark:    request.Remark,
	}
	
	// 处理订单商品
	var orderItems []models.OrderItem
	var totalAmount float64
	var totalGold int
	
	for _, item := range request.Products {
		// 查询商品信息
		var product models.Product
		productInfo, err := product.FindByID(database.DB, item.ProductID)
		if err != nil {
			c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "商品不存在: "+err.Error(), nil))
			return
		}
		
		// 检查库存
		if productInfo.Stock < item.Quantity {
			c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "商品库存不足: "+productInfo.Name, nil))
			return
		}
		
		// 计算金额
		var price float64
		var goldPrice int
		
		if item.UseGold {
			price = 0
			goldPrice = productInfo.GoldPrice
			totalGold += productInfo.GoldPrice * item.Quantity
		} else {
			price = productInfo.Price
			goldPrice = 0
			totalAmount += productInfo.Price * float64(item.Quantity)
		}
		
		// 添加订单商品
		orderItem := models.OrderItem{
			ProductID:    item.ProductID,
			ProductName:  productInfo.Name,
			ProductImage: productInfo.ImageURL,
			Price:        price,
			GoldPrice:    goldPrice,
			Quantity:     item.Quantity,
		}
		
		orderItems = append(orderItems, orderItem)
	}
	
	// 设置订单总金额
	order.TotalAmount = totalAmount
	order.TotalGold = totalGold
	
	// 创建订单及订单商品
	if err := order.CreateWithItems(database.DB, orderItems); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建订单失败: "+err.Error(), nil))
		return
	}
	
	// 构建支付URL
	payURL := fmt.Sprintf("/api/v1/shop/orders/pay/%d", order.ID)
	
	// 构建响应
	response := models.OrderCreateResponse{
		OrderID:     order.ID,
		OrderNo:     order.OrderNo,
		TotalAmount: order.TotalAmount,
		TotalGold:   order.TotalGold,
		PayURL:      payURL,
	}
	
	c.JSON(http.StatusCreated, models.NewSuccessResponse(response, "创建订单成功", http.StatusCreated))
}

// UpdateOrderStatus 更新订单状态
// @Summary 更新订单状态
// @Description 更新订单状态
// @Tags 订单
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "订单ID"
// @Param status body models.OrderStatusUpdateRequest true "状态信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/orders/{id}/status [put]
func (oc *OrderController) UpdateOrderStatus(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取订单ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的订单ID", nil))
		return
	}
	
	// 检查订单是否存在
	var order models.Order
	orderInfo, err := order.FindByID(database.DB, uint(id), userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "订单不存在", nil))
		return
	}
	
	// 解析请求参数
	var request models.OrderStatusUpdateRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 检查状态变更是否合法
	if !isValidStatusChange(orderInfo.Status, request.Status) {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的状态变更", nil))
		return
	}
	
	// 更新订单状态
	if err := order.UpdateStatus(database.DB, uint(id), request.Status, request.Remark); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新订单状态失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "更新订单状态成功", http.StatusOK))
}

// PayOrder 支付订单
// @Summary 支付订单
// @Description 支付订单
// @Tags 订单
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param id path int true "订单ID"
// @Param payment body object true "支付信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/orders/pay/{id} [post]
func (oc *OrderController) PayOrder(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 获取订单ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的订单ID", nil))
		return
	}
	
	// 检查订单是否存在
	var order models.Order
	orderInfo, err := order.FindByID(database.DB, uint(id), userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "订单不存在", nil))
		return
	}
	
	// 检查订单状态
	if orderInfo.Status != 0 {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "订单状态不正确，无法支付", nil))
		return
	}
	
	// 解析请求参数
	var request struct {
		PayMethod string `json:"pay_method" binding:"required"`
	}
	
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 更新订单状态为已支付
	if err := database.DB.Model(&models.Order{}).Where("id = ?", id).Updates(map[string]interface{}{
		"status":     1,
		"pay_method": request.PayMethod,
		"pay_time":   time.Now(),
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "支付订单失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "支付订单成功", http.StatusOK))
}

// isValidStatusChange 检查状态变更是否合法
func isValidStatusChange(currentStatus, newStatus int) bool {
	// 状态定义：0=待支付,1=已支付,2=已发货,3=已完成,4=已取消
	
	switch currentStatus {
	case 0: // 待支付
		return newStatus == 1 || newStatus == 4 // 可变为已支付或已取消
	case 1: // 已支付
		return newStatus == 2 || newStatus == 4 // 可变为已发货或已取消
	case 2: // 已发货
		return newStatus == 3 // 可变为已完成
	default:
		return false // 已完成或已取消状态不可变更
	}
} 