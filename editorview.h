#ifndef EDITORVIEW_H
#define EDITORVIEW_H

#include <QQuickPaintedItem>
#include <QPainter>
#include <QFont>
#include <QFontMetrics>
#include <vector>
#include <string>

class EditorView : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString dummyText READ dummyText WRITE setDummyText NOTIFY dummyTextChanged)

public:
    explicit EditorView(QQuickItem *parent = nullptr);
    ~EditorView();

    // QQuickPaintedItem interface
    void paint(QPainter *painter) override;

    // Property accessors
    QString dummyText() const;
    void setDummyText(const QString &text);

    // Text manipulation methods
    Q_INVOKABLE void insertText(int line, int column, const QString &text);
    Q_INVOKABLE void deleteText(int startLine, int startColumn, int endLine, int endColumn);
    Q_INVOKABLE QString getText(int startLine, int startColumn, int endLine, int endColumn) const;
    Q_INVOKABLE int lineCount() const;
    Q_INVOKABLE int lineLength(int line) const;

signals:
    void dummyTextChanged();
    void textChanged();
    void cursorPositionChanged();

protected:
    // Mouse and keyboard event handlers
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;
    void keyReleaseEvent(QKeyEvent *event) override;
    void focusInEvent(QFocusEvent *event) override;
    void focusOutEvent(QFocusEvent *event) override;

private:
    // Internal methods
    void updateContentSize();
    QPointF cursorPositionToPoint(int line, int column) const;
    QPointF pointToCursorPosition(const QPointF &point) const;
    void ensureCursorVisible();

    // Text content
    std::vector<QString> m_lines;
    QString m_dummyText;

    // Rendering parameters
    QFont m_font;
    int m_charWidth;
    int m_lineHeight;
    int m_margin;

    // Cursor and selection
    QPoint m_cursorPosition;
    QPoint m_selectionStart;
    QPoint m_selectionEnd;
    bool m_hasSelection;
    bool m_focused;

    // Colors
    QColor m_textColor;
    QColor m_backgroundColor;
    QColor m_cursorColor;
    QColor m_selectionColor;
};

#endif // EDITORVIEW_H