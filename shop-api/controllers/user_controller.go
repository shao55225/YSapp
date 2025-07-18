package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/iying-cms/shop-api/database"
	"github.com/iying-cms/shop-api/middleware"
	"github.com/iying-cms/shop-api/models"
	"golang.org/x/crypto/bcrypt"
)

// UserController 用户控制器
type UserController struct{}

// Login 用户登录
// @Summary 用户登录
// @Description 用户登录并获取令牌
// @Tags 用户
// @Accept json
// @Produce json
// @Param login body models.LoginRequest true "登录信息"
// @Success 200 {object} models.Response
// @Router /api/v1/users/login [post]
func (uc *UserController) Login(c *gin.Context) {
	// 解析请求参数
	var request models.LoginRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 查询用户
	var user models.User
	userInfo, err := user.FindByUsername(database.DB, request.Username)
	if err != nil {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "用户名或密码错误", nil))
		return
	}
	
	// 验证密码
	if err := bcrypt.CompareHashAndPassword([]byte(userInfo.Password), []byte(request.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "用户名或密码错误", nil))
		return
	}
	
	// 生成令牌
	token, expire, err := middleware.GenerateToken(userInfo)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "生成令牌失败: "+err.Error(), nil))
		return
	}
	
	// 构建响应
	response := models.LoginResponse{
		Token:  token,
		User:   userInfo,
		Expire: expire,
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(response, "登录成功", http.StatusOK))
}

// Register 用户注册
// @Summary 用户注册
// @Description 注册新用户
// @Tags 用户
// @Accept json
// @Produce json
// @Param register body models.User true "注册信息"
// @Success 201 {object} models.Response
// @Router /api/v1/users/register [post]
func (uc *UserController) Register(c *gin.Context) {
	// 解析请求参数
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 检查用户名是否已存在
	var existingUser models.User
	_, err := existingUser.FindByUsername(database.DB, user.Username)
	if err == nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "用户名已存在", nil))
		return
	}
	
	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "加密密码失败: "+err.Error(), nil))
		return
	}
	
	// 设置用户信息
	user.Password = string(hashedPassword)
	user.IsAdmin = 0
	user.Status = 1
	
	// 创建用户
	if err := database.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "创建用户失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusCreated, models.NewSuccessResponse(map[string]interface{}{"id": user.ID}, "注册成功", http.StatusCreated))
}

// GetProfile 获取用户资料
// @Summary 获取用户资料
// @Description 获取当前用户的资料
// @Tags 用户
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Success 200 {object} models.Response
// @Router /api/v1/users/profile [get]
func (uc *UserController) GetProfile(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 查询用户
	var user models.User
	userInfo, err := user.FindByID(database.DB, userID.(uint))
	if err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "用户不存在", nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(userInfo, "获取用户资料成功", http.StatusOK))
}

// UpdateProfile 更新用户资料
// @Summary 更新用户资料
// @Description 更新当前用户的资料
// @Tags 用户
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param profile body models.User true "用户资料"
// @Success 200 {object} models.Response
// @Router /api/v1/users/profile [put]
func (uc *UserController) UpdateProfile(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 解析请求参数
	var updateData struct {
		Nickname string `json:"nickname"`
		Avatar   string `json:"avatar"`
		Email    string `json:"email"`
		Mobile   string `json:"mobile"`
	}
	
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 更新用户资料
	if err := database.DB.Model(&models.User{}).Where("id = ?", userID).Updates(map[string]interface{}{
		"nickname": updateData.Nickname,
		"avatar":   updateData.Avatar,
		"email":    updateData.Email,
		"mobile":   updateData.Mobile,
	}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新用户资料失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "更新用户资料成功", http.StatusOK))
}

// ChangePassword 修改密码
// @Summary 修改密码
// @Description 修改当前用户的密码
// @Tags 用户
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param password body object true "密码信息"
// @Success 200 {object} models.Response
// @Router /api/v1/users/password [put]
func (uc *UserController) ChangePassword(c *gin.Context) {
	// 获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.NewErrorResponse(http.StatusUnauthorized, "未授权，请先登录", nil))
		return
	}
	
	// 解析请求参数
	var request struct {
		OldPassword string `json:"old_password" binding:"required"`
		NewPassword string `json:"new_password" binding:"required,min=6"`
	}
	
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "无效的请求参数: "+err.Error(), nil))
		return
	}
	
	// 查询用户
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.NewErrorResponse(http.StatusNotFound, "用户不存在", nil))
		return
	}
	
	// 验证旧密码
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(request.OldPassword)); err != nil {
		c.JSON(http.StatusBadRequest, models.NewErrorResponse(http.StatusBadRequest, "旧密码错误", nil))
		return
	}
	
	// 加密新密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(request.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "加密密码失败: "+err.Error(), nil))
		return
	}
	
	// 更新密码
	if err := database.DB.Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.NewErrorResponse(http.StatusInternalServerError, "更新密码失败: "+err.Error(), nil))
		return
	}
	
	c.JSON(http.StatusOK, models.NewSuccessResponse(nil, "修改密码成功", http.StatusOK))
} 