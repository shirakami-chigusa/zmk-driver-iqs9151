# Scroll Inertia Stop Tap Suppression

このドキュメントは、このフォークで追加した scroll inertia 停止時の 2F tap 抑止仕様を記録する。
フォーク元の `gesture_spec.md` とのコンフリクトを避けるため、追加仕様だけを分離している。

## 目的

scroll inertia 動作中に 2F tap でスクロールを止めた場合、通常の 2F tap として `BTN1` を送出しない。
Mac のトラックパッドと同様に、停止ジェスチャーはスクロール停止だけを行い、コンテキストメニューを開かない。

## 挙動

- scroll inertia 動作中に、全指離し状態から新しい接触列が始まった場合、その接触列を停止ジェスチャーとして扱う。
- 停止ジェスチャー扱いは全指離し (`finger_count == 0`) まで維持する。
- その接触列から派生した 2F tap は `BTN1` を送出しない。
- 直接 `0->2->0` で入った場合も、段階的に `0->1->2->0` で入った場合も抑止する。
- scroll inertia の停止自体は既存の慣性キャンセル処理で行う。

## 回帰テスト

`tests/iqs9151_work_cb/src/main.c` に以下のケースを追加している。

- `test_two_finger_tap_stops_scroll_inertia_without_btn1`
- `test_staggered_two_finger_tap_stops_scroll_inertia_without_btn1`
