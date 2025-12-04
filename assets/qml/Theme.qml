import QtQuick 2.15

// Sublime Text 4 Inspired Theme System
// Dark theme with modern enhancements and high contrast
pragma Singleton

QtObject {
    id: theme
    
    // Theme metadata
    property string themeName: "Sublime Dark Pro"
    property string themeVersion: "1.0.0"
    property bool isDark: true
    
    // Base colors
    property color backgroundColor: "#1a1a1a"
    property color surfaceColor: "#2d2d30"
    property color elevatedSurfaceColor: "#383838"
    property color borderColor: "#404040"
    
    // Text colors
    property color textColor: "#cccccc"
    property color textSecondaryColor: "#969696"
    property color textDisabledColor: "#656565"
    property color textAccentColor: "#4ec9b0"
    
    // Accent colors
    property color accentColor: "#569cd6"
    property color accentHoverColor: "#6bb6ff"
    property color accentPressedColor: "#3d8bcc"
    
    // Success/warning/error colors
    property color successColor: "#4ec9b0"
    property color warningColor: "#dcdcaa"
    property color errorColor: "#f44747"
    property color infoColor: "#9cdcfe"
    
    // Editor specific colors
    property color editorBackgroundColor: "#1e1e1e"
    property color editorForegroundColor: "#d4d4d4"
    property color editorLineNumberColor: "#858585"
    property color editorCurrentLineBackgroundColor: "#2a2a2a"
    property color editorSelectionBackgroundColor: "#264f78"
    property color editorSelectionForegroundColor: "#ffffff"
    property color editorFindMatchBackgroundColor: "#515c6a"
    property color editorFindMatchHighlightColor: "#4b5632"
    
    // Syntax highlighting colors
    property color keywordColor: "#569cd6"
    property color stringColor: "#ce9178"
    property color numberColor: "#b5cea8"
    property color commentColor: "#6a9955"
    property color functionColor: "#dcdcaa"
    property color variableColor: "#9cdcfe"
    property color typeColor: "#4ec9b0"
    property color operatorColor: "#d4d4d4"
    property color punctuationColor: "#d4d4d4"
    property color tagColor: "#569cd6"
    property color attributeColor: "#9cdcfe"
    property color attributeValueColor: "#ce9178"
    
    // UI Component specific colors
    
    // Title Bar
    property color titleBarColor: "#2d2d30"
    property color titleBarTextColor: "#cccccc"
    property color titleBarButtonCloseColor: "#ff5f56"
    property color titleBarButtonMinimizeColor: "#ffbd2e"
    property color titleBarButtonMaximizeColor: "#27ca3f"
    
    // Tab Bar
    property color tabBarBackgroundColor: "#2d2d30"
    property color tabActiveBackgroundColor: "#1e1e1e"
    property color tabActiveTextColor: "#ffffff"
    property color tabActiveBorderColor: "#569cd6"
    property color tabInactiveBackgroundColor: "#2d2d30"
    property color tabInactiveTextColor: "#969696"
    property color tabInactiveBorderColor: "#404040"
    property color tabDragBackgroundColor: "#383838"
    property color tabCloseButtonColor: "#969696"
    property color tabCloseButtonHoverColor: "#ffffff"
    property color tabCloseButtonHoverBackground: "#f44747"
    property color tabNewButtonBackgroundColor: "#2d2d30"
    property color tabNewButtonHoverBackgroundColor: "#383838"
    property color tabNewButtonColor: "#969696"
    property color tabModifiedIconColor: "#ffcc00"
    property color tabIconColor: "#969696"
    
    // Sidebar
    property color sidebarBackgroundColor: "#252526"
    property color sidebarHeaderBackgroundColor: "#2d2d30"
    property color sidebarHeaderTextColor: "#cccccc"
    property color sidebarHeaderIconColor: "#969696"
    property color sidebarSettingsIconColor: "#969696"
    property color sidebarSettingsHoverBackground: "#383838"
    property color sidebarTextColor: "#cccccc"
    property color sidebarSelectedTextColor: "#ffffff"
    property color sidebarSelectedBackgroundColor: "#094771"
    property color sidebarAlternateBackgroundColor: "#2a2a2a"
    property color sidebarFolderIconColor: "#d4d4d4"
    property color sidebarFolderOpenIconColor: "#569cd6"
    property color sidebarFileIconColor: "#9cdcfe"
    property color sidebarExpandedIconColor: "#969696"
    property color sidebarCollapsedIconColor: "#969696"
    
    // Editor
    property int editorFontSize: 14
    property string editorFontFamily: "JetBrains Mono"
    property real editorLineHeight: 1.5
    
    // Minimap
    property color minimapBackgroundColor: "#252526"
    property color minimapTextColor: "#4a4a4a"
    property color minimapViewportColor: "#569cd6"
    property color minimapViewportBorderColor: "#6bb6ff"
    
    // Command Palette
    property color commandPaletteBackgroundColor: "#2d2d30"
    property color commandPaletteBorderColor: "#404040"
    property color commandPaletteSearchBackgroundColor: "#1e1e1e"
    property color commandPaletteSearchBorderColor: "#404040"
    property color commandPaletteTextColor: "#cccccc"
    property color commandPaletteSelectedBackgroundColor: "#094771"
    property color commandPaletteSelectedTextColor: "#ffffff"
    property color commandPaletteItemBackgroundColor: "#2d2d30"
    property color commandPaletteCategoryColor: "#569cd6"
    property color commandPaletteKeybindingColor: "#969696"
    property color commandPaletteFooterColor: "#969696"
    
    // Status Bar
    property color statusBarBackgroundColor: "#007acc"
    property color statusBarTextColor: "#ffffff"
    property color statusBarGitBackgroundColor: "#16825d"
    property color statusBarGitBorderColor: "#1e9e6f"
    property color statusBarGitTextColor: "#ffffff"
    property color statusBarFileInfoBackgroundColor: "#16825d"
    property color statusBarFileInfoBorderColor: "#1e9e6f"
    property color statusBarFileInfoTextColor: "#ffffff"
    property color statusBarCursorBackgroundColor: "#16825d"
    property color statusBarCursorBorderColor: "#1e9e6f"
    property color statusBarCursorTextColor: "#ffffff"
    property color statusBarLanguageBackgroundColor: "#16825d"
    property color statusBarLanguageBorderColor: "#1e9e6f"
    property color statusBarLanguageTextColor: "#ffffff"
    property color statusBarZoomBackgroundColor: "#16825d"
    property color statusBarZoomBorderColor: "#1e9e6f"
    property color statusBarZoomTextColor: "#ffffff"
    property color statusBarNotificationBackgroundColor: "#f44747"
    property color statusBarNotificationBorderColor: "#ff6b6b"
    property color statusBarNotificationTextColor: "#ffffff"
    property color statusBarToggleBackgroundColor: "#16825d"
    property color statusBarToggleBorderColor: "#1e9e6f"
    property color statusBarToggleActiveBorderColor: "#4ec9b0"
    
    // Terminal
    property color terminalBackgroundColor: "#1e1e1e"
    property color terminalForegroundColor: "#d4d4d4"
    
    // Scroll bars
    property color scrollBarBackgroundColor: "#2d2d30"
    property color scrollBarHandleColor: "#686868"
    property color scrollBarHandleHoverColor: "#9d9d9d"
    
    // Notifications
    property color notificationBackgroundColor: "#2d2d30"
    property color notificationBorderColor: "#569cd6"
    property color notificationTextColor: "#ffffff"
    property color notificationSuccessColor: "#4ec9b0"
    property color notificationWarningColor: "#dcdcaa"
    property color notificationErrorColor: "#f44747"
    property color notificationInfoColor: "#9cdcfe"
    
    // Tooltips
    property color tooltipBackgroundColor: "#2d2d30"
    property color tooltipBorderColor: "#404040"
    property color tooltipTextColor: "#cccccc"
    
    // Context menus
    property color contextMenuBackgroundColor: "#2d2d30"
    property color contextMenuBorderColor: "#404040"
    property color contextMenuTextColor: "#cccccc"
    property color contextMenuHoverBackgroundColor: "#094771"
    property color contextMenuSeparatorColor: "#404040"
    
    // Dialogs
    property color dialogBackgroundColor: "#2d2d30"
    property color dialogBorderColor: "#404040"
    property color dialogTextColor: "#cccccc"
    property color dialogButtonBackgroundColor: "#16825d"
    property color dialogButtonHoverBackgroundColor: "#1e9e6f"
    property color dialogButtonTextColor: "#ffffff"
    
    // Progress indicators
    property color progressBackgroundColor: "#2d2d30"
    property color progressFillColor: "#569cd6"
    property color progressTextColor: "#cccccc"
    
    // Shadows and effects
    property color shadowColor: "#000000"
    property real shadowOpacity: 0.3
    property int shadowRadius: 8
    property color overlayColor: "#80000000"
    
    // Animation durations
    property int animationDurationFast: 100
    property int animationDurationNormal: 200
    property int animationDurationSlow: 300
    
    // Easing curves
    property var easingDefault: Easing.OutCubic
    property var easingBounce: Easing.OutBack
    property var easingElastic: Easing.OutElastic
    
    // Font weights
    property int fontWeightLight: Font.Light
    property int fontWeightNormal: Font.Normal
    property int fontWeightMedium: Font.Medium
    property int fontWeightBold: Font.Bold
    
    // Component initialization
    Component.onCompleted: {
        // Apply theme to application
        applyTheme()
    }
    
    // Function to apply theme colors
    function applyTheme() {
        // This would typically update application-wide styling
        // For now, properties are used directly in components
    }
    
    // Function to get color with opacity
    function getColorWithOpacity(baseColor, opacity) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, opacity)
    }
    
    // Function to blend colors
    function blendColors(color1, color2, ratio) {
        return Qt.rgba(
            color1.r * (1 - ratio) + color2.r * ratio,
            color1.g * (1 - ratio) + color2.g * ratio,
            color1.b * (1 - ratio) + color2.b * ratio,
            color1.a * (1 - ratio) + color2.a * ratio
        )
    }
    
    // Function to lighten color
    function lightenColor(color, amount) {
        return Qt.rgba(
            Math.min(1, color.r + amount),
            Math.min(1, color.g + amount),
            Math.min(1, color.b + amount),
            color.a
        )
    }
    
    // Function to darken color
    function darkenColor(color, amount) {
        return Qt.rgba(
            Math.max(0, color.r - amount),
            Math.max(0, color.g - amount),
            Math.max(0, color.b - amount),
            color.a
        )
    }
}