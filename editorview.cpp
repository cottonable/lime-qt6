#include "editorview.h"
#include <QMouseEvent>
#include <QKeyEvent>
#include <QFocusEvent>
#include <QDebug>

EditorView::EditorView(QQuickItem *parent)
    : QQuickPaintedItem(parent)
    , m_margin(10)
    , m_hasSelection(false)
    , m_focused(false)
    , m_textColor(Qt::black)
    , m_backgroundColor(Qt::white)
    , m_cursorColor(Qt::blue)
    , m_selectionColor(QColor(173, 216, 230)) // Light blue
{
    // Set up font for crisp rendering
    m_font.setFamily("Consolas, Monaco, monospace");
    m_font.setPixelSize(14);
    m_font.setStyleHint(QFont::Monospace, QFont::PreferAntialias);

    // Calculate font metrics
    QFontMetrics fm(m_font);
    m_charWidth = fm.horizontalAdvance('M');
    m_lineHeight = fm.height() + 2; // Add small spacing

    // Set default dummy text
    m_dummyText = "Line 1: Welcome to Lime Editor - A modern text editor\n"
                  "Line 2: Built with Qt6 and Go for high performance\n"
                  "Line 3: Features syntax highlighting and code completion\n"
                  "Line 4: Multiple cursor support for efficient editing\n"
                  "Line 5: Integrated file explorer and project management\n"
                  "Line 6: Customizable themes and keyboard shortcuts\n"
                  "Line 7: Git integration for version control\n"
                  "Line 8: Plugin system for extensibility\n"
                  "Line 9: Fast and responsive user interface\n"
                  "Line 10: Cross-platform compatibility";

    // Initialize lines
    QStringList lines = m_dummyText.split('\n');
    for (const QString &line : lines) {
        m_lines.push_back(line);
    }

    // Set rendering hints
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
    setAntialiasing(false);
    setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);
    setFlag(QQuickItem::ItemAcceptsInputMethod, true);
    setFlag(QQuickItem::ItemIsFocusScope, true);

    // Update content size
    updateContentSize();
}

EditorView::~EditorView()
{
}

void EditorView::paint(QPainter *painter)
{
    // Fill background
    painter->fillRect(boundingRect(), m_backgroundColor);

    // Set up font
    painter->setFont(m_font);
    painter->setPen(m_textColor);

    // Draw text lines
    for (size_t i = 0; i < m_lines.size() && i < 10; ++i) {
        int y = m_margin + (i + 1) * m_lineHeight;
        painter->drawText(m_margin, y, m_lines[i]);
    }

    // Draw cursor if focused
    if (m_focused) {
        painter->setPen(m_cursorColor);
        int cursorX = m_margin + m_cursorPosition.x() * m_charWidth;
        int cursorY = m_margin + m_cursorPosition.y() * m_lineHeight;
        painter->drawLine(cursorX, cursorY, cursorX, cursorY + m_lineHeight);
    }
}

QString EditorView::dummyText() const
{
    return m_dummyText;
}

void EditorView::setDummyText(const QString &text)
{
    if (m_dummyText != text) {
        m_dummyText = text;
        
        // Update lines
        m_lines.clear();
        QStringList lines = text.split('\n');
        for (const QString &line : lines) {
            m_lines.push_back(line);
        }
        
        updateContentSize();
        update();
        emit dummyTextChanged();
        emit textChanged();
    }
}

void EditorView::insertText(int line, int column, const QString &text)
{
    if (line < 0 || line >= static_cast<int>(m_lines.size())) {
        return;
    }

    QString &currentLine = m_lines[line];
    if (column < 0 || column > currentLine.length()) {
        return;
    }

    currentLine.insert(column, text);
    updateContentSize();
    update();
    emit textChanged();
}

void EditorView::deleteText(int startLine, int startColumn, int endLine, int endColumn)
{
    if (startLine < 0 || startLine >= static_cast<int>(m_lines.size()) ||
        endLine < 0 || endLine >= static_cast<int>(m_lines.size())) {
        return;
    }

    if (startLine == endLine) {
        // Single line deletion
        QString &line = m_lines[startLine];
        if (startColumn >= 0 && endColumn <= line.length() && startColumn < endColumn) {
            line.remove(startColumn, endColumn - startColumn);
        }
    } else {
        // Multi-line deletion (simplified)
        for (int i = startLine; i <= endLine && i < static_cast<int>(m_lines.size()); ++i) {
            if (i == startLine) {
                m_lines[i].truncate(startColumn);
            } else if (i == endLine) {
                m_lines[startLine] += m_lines[i].mid(endColumn);
                m_lines.erase(m_lines.begin() + i);
            } else {
                m_lines.erase(m_lines.begin() + i);
                --i;
                --endLine;
            }
        }
    }

    updateContentSize();
    update();
    emit textChanged();
}

QString EditorView::getText(int startLine, int startColumn, int endLine, int endColumn) const
{
    if (startLine < 0 || startLine >= static_cast<int>(m_lines.size()) ||
        endLine < 0 || endLine >= static_cast<int>(m_lines.size())) {
        return QString();
    }

    QString result;
    for (int i = startLine; i <= endLine && i < static_cast<int>(m_lines.size()); ++i) {
        const QString &line = m_lines[i];
        if (i == startLine && i == endLine) {
            // Single line
            if (startColumn >= 0 && endColumn <= line.length()) {
                result = line.mid(startColumn, endColumn - startColumn);
            }
        } else if (i == startLine) {
            // First line
            if (startColumn >= 0 && startColumn <= line.length()) {
                result = line.mid(startColumn) + "\n";
            }
        } else if (i == endLine) {
            // Last line
            if (endColumn >= 0 && endColumn <= line.length()) {
                result += line.left(endColumn);
            }
        } else {
            // Middle lines
            result += line + "\n";
        }
    }
    return result;
}

int EditorView::lineCount() const
{
    return static_cast<int>(m_lines.size());
}

int EditorView::lineLength(int line) const
{
    if (line < 0 || line >= static_cast<int>(m_lines.size())) {
        return 0;
    }
    return m_lines[line].length();
}

void EditorView::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::LeftButton) {
        QPointF pos = event->pos();
        QPoint cursorPos = pointToCursorPosition(pos);
        m_cursorPosition = cursorPos;
        m_selectionStart = cursorPos;
        m_selectionEnd = cursorPos;
        m_hasSelection = false;
        emit cursorPositionChanged();
        update();
        event->accept();
    }
}

void EditorView::mouseMoveEvent(QMouseEvent *event)
{
    if (event->buttons() & Qt::LeftButton) {
        QPointF pos = event->pos();
        QPoint cursorPos = pointToCursorPosition(pos);
        m_cursorPosition = cursorPos;
        m_selectionEnd = cursorPos;
        m_hasSelection = (m_selectionStart != m_selectionEnd);
        emit cursorPositionChanged();
        update();
        event->accept();
    }
}

void EditorView::keyPressEvent(QKeyEvent *event)
{
    bool handled = false;

    switch (event->key()) {
    case Qt::Key_Left:
        if (m_cursorPosition.x() > 0) {
            m_cursorPosition.setX(m_cursorPosition.x() - 1);
        } else if (m_cursorPosition.y() > 0) {
            m_cursorPosition.setY(m_cursorPosition.y() - 1);
            m_cursorPosition.setX(lineLength(m_cursorPosition.y()));
        }
        handled = true;
        break;

    case Qt::Key_Right:
        if (m_cursorPosition.x() < lineLength(m_cursorPosition.y())) {
            m_cursorPosition.setX(m_cursorPosition.x() + 1);
        } else if (m_cursorPosition.y() < lineCount() - 1) {
            m_cursorPosition.setY(m_cursorPosition.y() + 1);
            m_cursorPosition.setX(0);
        }
        handled = true;
        break;

    case Qt::Key_Up:
        if (m_cursorPosition.y() > 0) {
            m_cursorPosition.setY(m_cursorPosition.y() - 1);
            m_cursorPosition.setX(qMin(m_cursorPosition.x(), lineLength(m_cursorPosition.y())));
        }
        handled = true;
        break;

    case Qt::Key_Down:
        if (m_cursorPosition.y() < lineCount() - 1) {
            m_cursorPosition.setY(m_cursorPosition.y() + 1);
            m_cursorPosition.setX(qMin(m_cursorPosition.x(), lineLength(m_cursorPosition.y())));
        }
        handled = true;
        break;
    }

    if (handled) {
        emit cursorPositionChanged();
        update();
        event->accept();
    }
}

void EditorView::keyReleaseEvent(QKeyEvent *event)
{
    QQuickPaintedItem::keyReleaseEvent(event);
}

void EditorView::focusInEvent(QFocusEvent *event)
{
    m_focused = true;
    update();
    QQuickPaintedItem::focusInEvent(event);
}

void EditorView::focusOutEvent(QFocusEvent *event)
{
    m_focused = false;
    update();
    QQuickPaintedItem::focusOutEvent(event);
}

void EditorView::updateContentSize()
{
    // Calculate content size based on text
    int contentWidth = 800; // Default width
    for (const QString &line : m_lines) {
        int lineWidth = m_margin * 2 + line.length() * m_charWidth;
        contentWidth = qMax(contentWidth, lineWidth);
    }

    int contentHeight = m_margin * 2 + m_lines.size() * m_lineHeight;
    setImplicitSize(contentWidth, contentHeight);
}

QPointF EditorView::cursorPositionToPoint(int line, int column) const
{
    int x = m_margin + column * m_charWidth;
    int y = m_margin + line * m_lineHeight;
    return QPointF(x, y);
}

QPoint EditorView::pointToCursorPosition(const QPointF &point) const
{
    int line = qBound(0, static_cast<int>((point.y() - m_margin) / m_lineHeight), lineCount() - 1);
    int column = qBound(0, static_cast<int>((point.x() - m_margin) / m_charWidth), lineLength(line));
    return QPoint(column, line);
}

void EditorView::ensureCursorVisible()
{
    // This would be implemented to ensure cursor is visible within viewport
    // For now, just trigger an update
    update();
}