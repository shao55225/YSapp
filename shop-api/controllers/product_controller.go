package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/models"
)

// ProductController 商品控制器
type ProductController struct{}

// GetProducts 获取商品列表
// @Summary 获取商品列表
// @Description 获取商品列表，支持分页、分类筛选、关键字搜索和排序
// @Tags 商品
// @Accept json
// @Produce json
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页记录数，默认20"
// @Param category_id query int false "分类ID"
// @Param keyword query string false "搜索关键字"
// @Param sort query string false "排序方式，可选值：price_asc, price_desc"
// @Param status query int false "状态，0=下架,1=上架，默认全部"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/products [get]
func (pc *ProductController) GetProducts(c *gin.Context) {
	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	categoryID, _ := strconv.Atoi(c.DefaultQuery("category_id", "0"))
	keyword := c.DefaultQuery("keyword", "")
	sort := c.DefaultQuery("sort", "")
	status, _ := strconv.Atoi(c.DefaultQuery("status", "-1"))
	
	// 查询商品
	var product models.Product
	productList, err := product.FindAll(database.DB, page, limit, uint(categoryID), keyword, sort, status)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取商品列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(productList, "获取商品列表成功", http.StatusOK))
}

// GetProduct 获取商品详情
// @Summary 获取商品详情
// @Description 根据ID获取商品详情
// @Tags 商品
// @Accept json
// @Produce json
// @Param id path int true "商品ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/products/{id} [get]
func (pc *ProductController) GetProduct(c *gin.Context) {
	// 获取商品ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的商品ID", nil))
		return
	}
	
	// 查询商品
	var product models.Product
	productInfo, err := product.FindByID(database.DB, uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "商品不存在", nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(productInfo, "获取商品详情成功", http.StatusOK))
}

// CreateProduct 创建商品
// @Summary 创建商品
// @Description 创建新商品
// @Tags 商品
// @Accept json
// @Produce json
// @Param product body models.Product true "商品信息"
// @Success 201 {object} models.Response
// @Router /api/v1/shop/products [post]
func (pc *ProductController) CreateProduct(c *gin.Context) {
	// 解析请求参数
	var product models.Product
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 创建商品
	if err := product.Create(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建商品失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusCreated, models.NewSuccessResponse(map[string]interface{}{"id": product.ID}, "创建商品成功", http.StatusCreated))
}

// UpdateProduct 更新商品
// @Summary 更新商品
// @Description 更新商品信息
// @Tags 商品
// @Accept json
// @Produce json
// @Param id path int true "商品ID"
// @Param product body models.Product true "商品信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/products/{id} [put]
func (pc *ProductController) UpdateProduct(c *gin.Context) {
	// 获取商品ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的商品ID", nil))
		return
	}
	
	// 检查商品是否存在
	var existingProduct models.Product
	existingProduct, err = existingProduct.FindByID(database.DB, uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "商品不存在", nil))
		return
	}
	
	// 解析请求参数
	var product models.Product
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 设置商品ID
	product.ID = uint(id)
	
	// 更新商品
	if err := product.Update(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新商品失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(map[string]interface{}{"id": id}, "更新商品成功", http.StatusOK))
}

// DeleteProduct 删除商品
// @Summary 删除商品
// @Description 删除商品
// @Tags 商品
// @Accept json
// @Produce json
// @Param id path int true "商品ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/products/{id} [delete]
func (pc *ProductController) DeleteProduct(c *gin.Context) {
	// 获取商品ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的商品ID", nil))
		return
	}
	
	// 删除商品
	var product models.Product
	if err := product.Delete(database.DB, uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "删除商品失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "删除商品成功", http.StatusOK))
} 