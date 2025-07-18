package controllers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/models"
)

// CategoryController 分类控制器
type CategoryController struct{}

// GetCategories 获取分类列表
// @Summary 获取分类列表
// @Description 获取分类列表，支持分页
// @Tags 分类
// @Accept json
// @Produce json
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页记录数，默认20"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories [get]
func (cc *CategoryController) GetCategories(c *gin.Context) {
	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	
	// 查询分类
	var category models.Category
	categoryList, err := category.FindAll(database.DB, page, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取分类列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(categoryList, "获取分类列表成功", http.StatusOK))
}

// GetAllCategories 获取所有分类（不分页）
// @Summary 获取所有分类
// @Description 获取所有分类，不分页
// @Tags 分类
// @Accept json
// @Produce json
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories/all [get]
func (cc *CategoryController) GetAllCategories(c *gin.Context) {
	// 查询所有分类
	var category models.Category
	categories, err := category.FindAllNoPage(database.DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取分类列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(categories, "获取分类列表成功", http.StatusOK))
}

// GetCategory 获取分类详情
// @Summary 获取分类详情
// @Description 根据ID获取分类详情
// @Tags 分类
// @Accept json
// @Produce json
// @Param id path int true "分类ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories/{id} [get]
func (cc *CategoryController) GetCategory(c *gin.Context) {
	// 获取分类ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的分类ID", nil))
		return
	}
	
	// 查询分类
	var category models.Category
	categoryInfo, err := category.FindByID(database.DB, uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "分类不存在", nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(categoryInfo, "获取分类详情成功", http.StatusOK))
}

// GetCategoryProducts 获取分类下的商品
// @Summary 获取分类下的商品
// @Description 获取指定分类下的商品列表
// @Tags 分类
// @Accept json
// @Produce json
// @Param id path int true "分类ID"
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页记录数，默认20"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories/{id}/products [get]
func (cc *CategoryController) GetCategoryProducts(c *gin.Context) {
	// 获取分类ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的分类ID", nil))
		return
	}
	
	// 获取查询参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	
	// 查询商品
	var product models.Product
	productList, err := product.FindAll(database.DB, page, limit, uint(id), "", "", 1) // 只查询上架商品
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取商品列表失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(productList, "获取分类商品成功", http.StatusOK))
}

// CreateCategory 创建分类
// @Summary 创建分类
// @Description 创建新分类
// @Tags 分类
// @Accept json
// @Produce json
// @Param category body models.Category true "分类信息"
// @Success 201 {object} models.Response
// @Router /api/v1/shop/categories [post]
func (cc *CategoryController) CreateCategory(c *gin.Context) {
	// 解析请求参数
	var category models.Category
	if err := c.ShouldBindJSON(&category); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 创建分类
	if err := category.Create(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建分类失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusCreated, models.NewSuccessResponse(map[string]interface{}{"id": category.ID}, "创建分类成功", http.StatusCreated))
}

// UpdateCategory 更新分类
// @Summary 更新分类
// @Description 更新分类信息
// @Tags 分类
// @Accept json
// @Produce json
// @Param id path int true "分类ID"
// @Param category body models.Category true "分类信息"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories/{id} [put]
func (cc *CategoryController) UpdateCategory(c *gin.Context) {
	// 获取分类ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的分类ID", nil))
		return
	}
	
	// 检查分类是否存在
	var existingCategory models.Category
	existingCategory, err = existingCategory.FindByID(database.DB, uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "分类不存在", nil))
		return
	}
	
	// 解析请求参数
	var category models.Category
	if err := c.ShouldBindJSON(&category); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 设置分类ID
	category.ID = uint(id)
	
	// 更新分类
	if err := category.Update(database.DB); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新分类失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(map[string]interface{}{"id": id}, "更新分类成功", http.StatusOK))
}

// DeleteCategory 删除分类
// @Summary 删除分类
// @Description 删除分类
// @Tags 分类
// @Accept json
// @Produce json
// @Param id path int true "分类ID"
// @Success 200 {object} models.Response
// @Router /api/v1/shop/categories/{id} [delete]
func (cc *CategoryController) DeleteCategory(c *gin.Context) {
	// 获取分类ID
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的分类ID", nil))
		return
	}
	
	// 检查是否有商品使用该分类
	var count int64
	if err := database.DB.Model(&models.Product{}).Where("category_id = ?", id).Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "检查分类使用情况失败: "+err.Error(), nil))
		return
	}
	
	if count > 0 {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "该分类下有商品，无法删除", nil))
		return
	}
	
	// 删除分类
	var category models.Category
	if err := category.Delete(database.DB, uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "删除分类失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "删除分类成功", http.StatusOK))
} 