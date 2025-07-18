// 在routes.go中找到类似这样的代码
func SetupRoutes(router *gin.Engine) {
    // 公开路由组，不需要认证
    public := router.Group("/api/v1")
    {
        // 添加第三方站点API到公开路由
        public.GET("/sites/available", thirdPartySiteController.GetAvailableSites)
        
        // 其他公开API...
    }
    
    // 需要认证的路由组
    authenticated := router.Group("/api/v1")
    authenticated.Use(middleware.AuthMiddleware())
    {
        // 商城API
        shop := authenticated.Group("/shop")
        {
            shop.GET("/products", shopController.GetProducts)
            // 其他商城API...
        }
        
        // 其他需要认证的API...
    }
}
