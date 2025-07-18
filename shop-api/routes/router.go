package routes

import (
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"github.com/iying-cms/shop-api/config"
	"github.com/iying-cms/shop-api/controllers"
	"github.com/iying-cms/shop-api/middleware"
)

// SetupRouter 设置路由
func SetupRouter() *gin.Engine {
	// 设置gin模式
	gin.SetMode(config.AppConfig.Server.Mode)
	
	// 创建路由
	r := gin.Default()
	
	// 添加中间件
	r.Use(middleware.CORS())
	
	// API文档
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	
	// API路由
	api := r.Group("/api/v1")
	{
		// 第三方站点相关路由
		sites := api.Group("/sites")
		{
			siteController := controllers.ThirdPartySiteController{}
			sites.GET("", siteController.GetSites)
			sites.GET("/available", siteController.GetAvailableSites)
			sites.GET("/:id", siteController.GetSite)
			
			// 需要管理员权限的路由
			adminSites := sites.Group("")
			adminSites.Use(middleware.AdminAuth())
			{
				adminSites.POST("", siteController.CreateSite)
				adminSites.PUT("/:id", siteController.UpdateSite)
				adminSites.DELETE("/:id", siteController.DeleteSite)
				adminSites.PUT("/:id/status", siteController.UpdateSiteStatus)
				adminSites.POST("/:id/check", siteController.CheckSiteHealth)
			}
		}
		
		// 商城相关路由
		shop := api.Group("/shop")
		{
			// 分类相关路由
			categories := shop.Group("/categories")
			{
				categoryController := controllers.CategoryController{}
				categories.GET("", categoryController.GetCategories)
				categories.GET("/all", categoryController.GetAllCategories)
				categories.GET("/:id", categoryController.GetCategory)
				categories.GET("/:id/products", categoryController.GetCategoryProducts)
				
				// 需要管理员权限的路由
				adminCategories := categories.Group("")
				adminCategories.Use(middleware.AdminAuth())
				{
					adminCategories.POST("", categoryController.CreateCategory)
					adminCategories.PUT("/:id", categoryController.UpdateCategory)
					adminCategories.DELETE("/:id", categoryController.DeleteCategory)
				}
			}
			
			// 商品相关路由
			products := shop.Group("/products")
			{
				productController := controllers.ProductController{}
				products.GET("", productController.GetProducts)
				products.GET("/:id", productController.GetProduct)
				
				// 需要管理员权限的路由
				adminProducts := products.Group("")
				adminProducts.Use(middleware.AdminAuth())
				{
					adminProducts.POST("", productController.CreateProduct)
					adminProducts.PUT("/:id", productController.UpdateProduct)
					adminProducts.DELETE("/:id", productController.DeleteProduct)
				}
			}
			
			// 购物车相关路由（需要用户登录）
			cart := shop.Group("/cart")
			cart.Use(middleware.JWTAuth())
			{
				cartController := controllers.CartController{}
				cart.GET("", cartController.GetCart)
				cart.POST("", cartController.AddToCart)
				cart.PUT("/:id", cartController.UpdateCartItem)
				cart.DELETE("/:id", cartController.RemoveFromCart)
				cart.DELETE("/clear", cartController.ClearCart)
			}
			
			// 订单相关路由（需要用户登录）
			orders := shop.Group("/orders")
			orders.Use(middleware.JWTAuth())
			{
				orderController := controllers.OrderController{}
				orders.GET("", orderController.GetOrders)
				orders.GET("/:id", orderController.GetOrder)
				orders.POST("", orderController.CreateOrder)
				orders.PUT("/:id/status", orderController.UpdateOrderStatus)
				orders.POST("/pay/:id", orderController.PayOrder)
			}
			
			// 用户地址相关路由（需要用户登录）
			addresses := shop.Group("/addresses")
			addresses.Use(middleware.JWTAuth())
			{
				addressController := controllers.AddressController{}
				addresses.GET("", addressController.GetAddresses)
				addresses.GET("/:id", addressController.GetAddress)
				addresses.POST("", addressController.CreateAddress)
				addresses.PUT("/:id", addressController.UpdateAddress)
				addresses.DELETE("/:id", addressController.DeleteAddress)
			}
		}
		
		// 用户相关路由
		users := api.Group("/users")
		{
			userController := controllers.UserController{}
			users.POST("/login", userController.Login)
			users.POST("/register", userController.Register)
			
			// 需要用户登录的路由
			authUsers := users.Group("")
			authUsers.Use(middleware.JWTAuth())
			{
				authUsers.GET("/profile", userController.GetProfile)
				authUsers.PUT("/profile", userController.UpdateProfile)
				authUsers.PUT("/password", userController.ChangePassword)
			}
		}
	}
	
	return r
} 