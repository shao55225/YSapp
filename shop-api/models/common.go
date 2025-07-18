package models

// Pagination 分页信息
type Pagination struct {
	Page  int   `json:"page"`
	Limit int   `json:"limit"`
	Total int64 `json:"total"`
	Pages int   `json:"pages"`
}

// Response 通用响应结构
type Response struct {
	Status  int         `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Errors  interface{} `json:"errors,omitempty"`
}

// NewSuccessResponse 创建成功响应
func NewSuccessResponse(data interface{}, message string, code int) Response {
	if message == "" {
		message = "success"
	}
	if code == 0 {
		code = 200
	}
	return Response{
		Status:  code,
		Message: message,
		Data:    data,
	}
}

// NewErrorResponse 创建错误响应
func NewErrorResponse(code int, message string, errors interface{}) Response {
	return Response{
		Status:  code,
		Message: message,
		Errors:  errors,
	}
} 