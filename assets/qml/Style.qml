import QtQuick 2.15
import QtGraphicalEffects 1.15

// Styling utilities and effects
pragma Singleton

QtObject {
    id: style
    
    // Common margins and paddings
    property real marginTiny: 4
    property real marginSmall: 8
    property real marginMedium: 12
    property real marginLarge: 16
    property real marginXLarge: 24
    
    // Common sizes
    property real sizeTiny: 16
    property real sizeSmall: 20
    property real sizeMedium: 24
    property real sizeLarge: 32
    property real sizeXLarge: 48
    
    // Border radius
    property real radiusSmall: 4
    property real radiusMedium: 6
    property real radiusLarge: 8
    property real radiusXLarge: 12
    property real radiusRound: 999
    
    // Animation durations
    property real durationFast: 100
    property real durationNormal: 200
    property real durationSlow: 300
    property real durationVerySlow: 500
    
    // Common effects
    
    // Drop shadow effect
    function dropShadowEffect(target, color, radius, offsetX, offsetY, opacity) {
        return DropShadow {
            anchors.fill: target
            horizontalOffset: offsetX || 0
            verticalOffset: offsetY || 2
            radius: radius || 8
            samples: radius * 2 || 16
            color: color || "#20000000"
            opacity: opacity || 1.0
            source: target
        }
    }
    
    // Inner shadow effect
    function innerShadowEffect(target, color, radius, offsetX, offsetY, opacity) {
        return InnerShadow {
            anchors.fill: target
            horizontalOffset: offsetX || 0
            verticalOffset: offsetY || 1
            radius: radius || 4
            samples: radius * 2 || 8
            color: color || "#40000000"
            opacity: opacity || 1.0
            source: target
        }
    }
    
    // Glow effect
    function glowEffect(target, color, radius, opacity) {
        return Glow {
            anchors.fill: target
            radius: radius || 8
            samples: radius * 2 || 16
            color: color || Theme.accentColor
            opacity: opacity || 0.5
            source: target
        }
    }
    
    // Blur effect
    function blurEffect(target, radius) {
        return GaussianBlur {
            anchors.fill: target
            radius: radius || 8
            samples: radius * 2 || 16
            source: target
        }
    }
    
    // Colorize effect
    function colorizeEffect(target, color, intensity) {
        return Colorize {
            anchors.fill: target
            hue: 0.0
            saturation: 0.0
            lightness: 0.0
            color: color || Theme.accentColor
            intensity: intensity || 1.0
            source: target
        }
    }
    
    // Opacity mask effect
    function opacityMaskEffect(target, maskSource) {
        return OpacityMask {
            anchors.fill: target
            maskSource: maskSource
            source: target
        }
    }
    
    // Common animations
    
    // Fade in animation
    function fadeInAnimation(target, duration) {
        return NumberAnimation {
            target: target
            property: "opacity"
            from: 0
            to: 1
            duration: duration || style.durationNormal
            easing.type: Easing.OutCubic
        }
    }
    
    // Fade out animation
    function fadeOutAnimation(target, duration) {
        return NumberAnimation {
            target: target
            property: "opacity"
            from: 1
            to: 0
            duration: duration || style.durationNormal
            easing.type: Easing.InCubic
        }
    }
    
    // Scale animation
    function scaleAnimation(target, fromScale, toScale, duration) {
        return NumberAnimation {
            target: target
            property: "scale"
            from: fromScale
            to: toScale
            duration: duration || style.durationNormal
            easing.type: Easing.OutBack
        }
    }
    
    // Position animation
    function positionAnimation(target, property, fromValue, toValue, duration) {
        return NumberAnimation {
            target: target
            property: property
            from: fromValue
            to: toValue
            duration: duration || style.durationNormal
            easing.type: Easing.OutCubic
        }
    }
    
    // Color animation
    function colorAnimation(target, property, fromColor, toColor, duration) {
        return ColorAnimation {
            target: target
            property: property
            from: fromColor
            to: toColor
            duration: duration || style.durationNormal
        }
    }
    
    // Rotation animation
    function rotationAnimation(target, fromAngle, toAngle, duration) {
        return NumberAnimation {
            target: target
            property: "rotation"
            from: fromAngle
            to: toAngle
            duration: duration || style.durationNormal
            easing.type: Easing.OutCubic
        }
    }
    
    // Sequential animation
    function sequentialAnimation(animations) {
        var seq = SequentialAnimation {}
        for (var i = 0; i < animations.length; i++) {
            seq.animations.push(animations[i])
        }
        return seq
    }
    
    // Parallel animation
    function parallelAnimation(animations) {
        var par = ParallelAnimation {}
        for (var i = 0; i < animations.length; i++) {
            par.animations.push(animations[i])
        }
        return par
    }
    
    // Pause animation
    function pauseAnimation(duration) {
        return PauseAnimation {
            duration: duration || style.durationNormal
        }
    }
    
    // Common behaviors
    
    // Hover behavior
    function hoverBehavior(target, normalColor, hoverColor, duration) {
        return Behavior on target.color {
            ColorAnimation {
                duration: duration || style.durationFast
            }
        }
    }
    
    // Scale behavior
    function scaleBehavior(target, duration) {
        return Behavior on target.scale {
            NumberAnimation {
                duration: duration || style.durationFast
                easing.type: Easing.OutBack
            }
        }
    }
    
    // Opacity behavior
    function opacityBehavior(target, duration) {
        return Behavior on target.opacity {
            NumberAnimation {
                duration: duration || style.durationFast
            }
        }
    }
    
    // Position behavior
    function positionBehavior(target, property, duration) {
        return Behavior on target[property] {
            NumberAnimation {
                duration: duration || style.durationNormal
                easing.type: Easing.OutCubic
            }
        }
    }
    
    // Common gradients
    
    // Linear gradient
    function linearGradient(startColor, endColor, direction) {
        return LinearGradient {
            start: direction === "vertical" ? Qt.point(0, 0) : Qt.point(0, 0)
            end: direction === "vertical" ? Qt.point(0, 1) : Qt.point(1, 0)
            gradient: Gradient {
                GradientStop { position: 0.0; color: startColor }
                GradientStop { position: 1.0; color: endColor }
            }
        }
    }
    
    // Radial gradient
    function radialGradient(centerColor, edgeColor) {
        return RadialGradient {
            center: Qt.point(0.5, 0.5)
            radius: 0.5
            gradient: Gradient {
                GradientStop { position: 0.0; color: centerColor }
                GradientStop { position: 1.0; color: edgeColor }
            }
        }
    }
    
    // Conical gradient
    function conicalGradient(angle, centerColor, edgeColor) {
        return ConicalGradient {
            angle: angle || 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: centerColor }
                GradientStop { position: 1.0; color: edgeColor }
            }
        }
    }
    
    // Common shapes
    
    // Rounded rectangle
    function roundedRectangle(parent, width, height, radius, color) {
        return Rectangle {
            parent: parent
            width: width
            height: height
            color: color
            radius: radius
        }
    }
    
    // Circle
    function circle(parent, diameter, color) {
        return Rectangle {
            parent: parent
            width: diameter
            height: diameter
            color: color
            radius: diameter / 2
        }
    }
    
    // Triangle
    function triangle(parent, base, height, color) {
        return Canvas {
            parent: parent
            width: base
            height: height
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.fillStyle = color
                ctx.beginPath()
                ctx.moveTo(base / 2, 0)
                ctx.lineTo(0, height)
                ctx.lineTo(base, height)
                ctx.closePath()
                ctx.fill()
            }
        }
    }
    
    // Common utility functions
    
    // Convert hex color to rgba
    function hexToRgba(hex, alpha) {
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
        return result ? Qt.rgba(
            parseInt(result[1], 16) / 255,
            parseInt(result[2], 16) / 255,
            parseInt(result[3], 16) / 255,
            alpha || 1.0
        ) : "transparent"
    }
    
    // Get luminance of color
    function getLuminance(color) {
        return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
    }
    
    // Determine if color is light or dark
    function isLightColor(color) {
        return getLuminance(color) > 0.5
    }
    
    // Get contrasting text color
    function getContrastingTextColor(backgroundColor) {
        return isLightColor(backgroundColor) ? "#000000" : "#ffffff"
    }
    
    // Generate random color
    function randomColor(saturation, lightness) {
        return Qt.hsla(Math.random(), saturation || 0.5, lightness || 0.5, 1.0)
    }
    
    // Interpolate between two values
    function interpolate(start, end, factor) {
        return start + (end - start) * factor
    }
    
    // Clamp value between min and max
    function clamp(value, min, max) {
        return Math.min(Math.max(value, min), max)
    }
    
    // Map value from one range to another
    function map(value, start1, stop1, start2, stop2) {
        return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))
    }
    
    // Easing functions
    function easeInQuad(t) {
        return t * t
    }
    
    function easeOutQuad(t) {
        return t * (2 - t)
    }
    
    function easeInOutQuad(t) {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    }
    
    function easeInCubic(t) {
        return t * t * t
    }
    
    function easeOutCubic(t) {
        return (--t) * t * t + 1
    }
    
    function easeInOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
    }
}
