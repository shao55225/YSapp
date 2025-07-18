package controllers

import (
"net/http"
"strconv"
"time"

"github.com/gin-gonic/gin"
"github.com/iying-cms/shop-api/database"
"github.com/iying-cms/shop-api/models"
)

// ThirdPartySiteController 第三方站点控制器
type ThirdPartySiteController struct{}

// GetSites 获取站点列表
// @Summary 获取站点列表
// @Description 获取站点列表，支持分页
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param page query int false "页码，默认1"
// @Param limit query int false "每页记录数，默认20"
// @Success 200 {object} models.Response
// @Router /api/v1/sites [get]
func (sc *ThirdPartySiteController) GetSites(c *gin.Context) {
// 获取查询参数
page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))

// 查询站点
var site models.ThirdPartySite
siteList, err := site.FindAll(database.DB, page, limit)
if err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取站点列表失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(siteList, "获取站点列表成功", http.StatusOK))
}

// GetAvailableSites 获取可用站点列表
// @Summary 获取可用站点列表
// @Description 获取所有可用的站点列表
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Success 200 {object} models.Response
// @Router /api/v1/sites/available [get]
func (sc *ThirdPartySiteController) GetAvailableSites(c *gin.Context) {
// 查询可用站点
var site models.ThirdPartySite
sites, err := site.FindAvailableSites(database.DB)
if err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "获取可用站点列表失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(sites, "获取可用站点列表成功", http.StatusOK))
}

// GetSite 获取站点详情
// @Summary 获取站点详情
// @Description 根据ID获取站点详情
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param id path int true "站点ID"
// @Success 200 {object} models.Response
// @Router /api/v1/sites/{id} [get]
func (sc *ThirdPartySiteController) GetSite(c *gin.Context) {
// 获取站点ID
id, err := strconv.Atoi(c.Param("id"))
if err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的站点ID", nil))
return
}

// 查询站点
var site models.ThirdPartySite
siteInfo, err := site.FindByID(database.DB, uint(id))
if err != nil {
c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "站点不存在", nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(siteInfo, "获取站点详情成功", http.StatusOK))
}

// CreateSite 创建站点
// @Summary 创建站点
// @Description 创建新站点
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param site body models.ThirdPartySite true "站点信息"
// @Success 201 {object} models.Response
// @Router /api/v1/sites [post]
func (sc *ThirdPartySiteController) CreateSite(c *gin.Context) {
// 解析请求参数
var site models.ThirdPartySite
if err := c.ShouldBindJSON(&site); err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
return
}

// 创建站点
if err := site.Create(database.DB); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建站点失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusCreated, models.NewSuccessResponse(map[string]interface{}{"id": site.ID}, "创建站点成功", http.StatusCreated))
}

// UpdateSite 更新站点
// @Summary 更新站点
// @Description 更新站点信息
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param id path int true "站点ID"
// @Param site body models.ThirdPartySite true "站点信息"
// @Success 200 {object} models.Response
// @Router /api/v1/sites/{id} [put]
func (sc *ThirdPartySiteController) UpdateSite(c *gin.Context) {
// 获取站点ID
id, err := strconv.Atoi(c.Param("id"))
if err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的站点ID", nil))
return
}

// 检查站点是否存在
var existingSite models.ThirdPartySite
existingSite, err = existingSite.FindByID(database.DB, uint(id))
if err != nil {
c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "站点不存在", nil))
return
}

// 解析请求参数
var site models.ThirdPartySite
if err := c.ShouldBindJSON(&site); err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
return
}

// 设置站点ID
site.ID = uint(id)

// 更新站点
if err := site.Update(database.DB); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新站点失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(map[string]interface{}{"id": id}, "更新站点成功", http.StatusOK))
}

// DeleteSite 删除站点
// @Summary 删除站点
// @Description 删除站点
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param id path int true "站点ID"
// @Success 200 {object} models.Response
// @Router /api/v1/sites/{id} [delete]
func (sc *ThirdPartySiteController) DeleteSite(c *gin.Context) {
// 获取站点ID
id, err := strconv.Atoi(c.Param("id"))
if err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的站点ID", nil))
return
}

// 删除站点
var site models.ThirdPartySite
if err := site.Delete(database.DB, uint(id)); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "删除站点失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "删除站点成功", http.StatusOK))
}

// UpdateSiteStatus 更新站点状态
// @Summary 更新站点状态
// @Description 更新站点启用/禁用状态
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param id path int true "站点ID"
// @Param status body map[string]int true "状态信息，例如：{\"status\": 1}"
// @Success 200 {object} models.Response
// @Router /api/v1/sites/{id}/status [put]
func (sc *ThirdPartySiteController) UpdateSiteStatus(c *gin.Context) {
// 获取站点ID
id, err := strconv.Atoi(c.Param("id"))
if err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的站点ID", nil))
return
}

// 解析请求参数
var params struct {
Status int `json:"status" binding:"required,oneof=0 1"`
}

if err := c.ShouldBindJSON(&params); err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
return
}

// 更新站点状态
var site models.ThirdPartySite
if err := site.UpdateStatus(database.DB, uint(id), params.Status); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新站点状态失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "更新站点状态成功", http.StatusOK))
}

// CheckSiteHealth 检测站点健康状态
// @Summary 检测站点健康状态
// @Description 检测站点是否可访问
// @Tags 第三方站点
// @Accept json
// @Produce json
// @Param id path int true "站点ID"
// @Success 200 {object} models.Response
// @Router /api/v1/sites/{id}/check [post]
func (sc *ThirdPartySiteController) CheckSiteHealth(c *gin.Context) {
// 获取站点ID
id, err := strconv.Atoi(c.Param("id"))
if err != nil {
c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的站点ID", nil))
return
}

// 查询站点
var site models.ThirdPartySite
siteInfo, err := site.FindByID(database.DB, uint(id))
if err != nil {
c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "站点不存在", nil))
return
}

// 检测站点健康状态
client := http.Client{
Timeout: 5 * time.Second,
}

startTime := time.Now()
resp, err := client.Get(siteInfo.URL)
responseTime := int(time.Since(startTime).Milliseconds())

// 记录健康检测结果
healthCheck := models.SiteHealthCheck{
SiteID:       uint(id),
CheckTime:    time.Now(),
ResponseTime: &responseTime,
}

if err != nil {
healthCheck.IsAlive = 0
healthCheck.ErrorMessage = err.Error()

// 更新站点状态为不可用
if err := site.UpdateHealthStatus(database.DB, uint(id), 0); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新站点状态失败: "+err.Error(), nil))
return
}

// 记录健康检测结果
if err := healthCheck.RecordHealthCheck(database.DB); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "记录健康检测结果失败: "+err.Error(), nil))
return
}

c.JSON(http.StatusOK, models.NewSuccessResponse(map[string]interface{}{
"is_alive":      false,
"error_message": err.Error(),
"response_time": responseTime,
}, "站点不可用", http.StatusOK))
return
}
defer resp.Body.Close()

// 检查响应状态码
statusCode := resp.StatusCode
healthCheck.StatusCode = &statusCode

if statusCode >= 200 && statusCode < 400 {
healthCheck.IsAlive = 1

// 更新站点状态为可用
if err := site.UpdateHealthStatus(database.DB, uint(id), 1); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新站点状态失败: "+err.Error(), nil))
return
}
} else {
healthCheck.IsAlive = 0
healthCheck.ErrorMessage = "HTTP status code: " + strconv.Itoa(statusCode)

// 更新站点状态为不可用
if err := site.UpdateHealthStatus(database.DB, uint(id), 0); err != nil {
c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新站点状态失败: "+err.Error(), nil))
return
}
}

// 记录健康检测结果
    if err := healthCheck.RecordHealthCheck(database.DB); err != nil {
        c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "记录健康检测结果失败: "+err.Error(), nil))
        return
    }

    // 修复点：使用 if-else 替代三元运算符
    message := "站点可用"
    if healthCheck.IsAlive != 1 {
        message = "站点不可用"
    }

    c.JSON(http.StatusOK, models.NewSuccessResponse(map[string]interface{}{
        "is_alive":      healthCheck.IsAlive == 1,
        "status_code":   statusCode,
        "response_time": responseTime,
    }, message, http.StatusOK))
}