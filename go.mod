module github.com/cottonable/lime-qt6

go 1.23

require (
	github.com/therecipe/qt v0.0.0-20251201000000-qt6.8.0
	github.com/cottonable/lime-backend v0.0.0-20251201000000-latest
)

replace (
	github.com/cottonable/lime-backend => ../lime-backend
)

// Qt6 specific requirements
require (
	github.com/go-gl/gl v0.0.0-20231021071112-cd05a28b17f0
	github.com/go-gl/glfw/v3.3/glfw v0.0.0-20240506162321-932f58a79a27
)

// Development dependencies
require (
	github.com/sirupsen/logrus v1.9.3
	github.com/spf13/cobra v1.8.0
	github.com/spf13/viper v1.18.2
)