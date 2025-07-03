#!/bin/bash

# Claude Code hook: Dartファイルの変更後にdart formatを実行
# このhookは、Editツールが実行された後に自動的に実行されます

# 引数: 編集されたファイルのパス
FILE_PATH="$1"

# ファイルパスが.dartで終わる場合のみ処理を実行
if [[ "$FILE_PATH" == *.dart ]]; then
    echo "🎯 Dartファイルが編集されました: $FILE_PATH"
    echo "📝 dart formatを実行中..."
    
    # dart formatを実行
    dart format "$FILE_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ dart formatが正常に完了しました"
    else
        echo "❌ dart formatでエラーが発生しました"
        exit 1
    fi
else
    echo "ℹ️  非Dartファイルのため、フォーマットをスキップします: $FILE_PATH"
fi