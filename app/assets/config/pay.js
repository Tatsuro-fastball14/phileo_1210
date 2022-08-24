<script src="https://js.pay.jp/v2/pay.js"></script>
<style></style>
/* 必要に応じてフォームの外側のデザインを用意します */
div.payjs-outer {
  border: thin solid #198fcc;
}
</style>
<div id="v2-demo" class="payjs-outer"><!-- ここにフォームが生成されます --></div>
<button onclick="onSubmit(event)">トークン作成</button>
<span id="token"></span>
<script>
// 公開鍵を登録し、起点となるオブジェクトを取得します
var payjp = Payjp('pk_test_0383a1b8f91e8a6e3ea0e2a9')

// elementsを取得します。ページ内に複数フォーム用意する場合は複数取得ください
var elements = payjp.elements()

// element(入力フォームの単位)を生成します
var cardElement = elements.create('card')

// elementをDOM上に配置します
cardElement.mount('#v2-demo')

// ボタンが押されたらtokenを生成する関数を用意します
function onSubmit(event) {
  payjp.createToken(cardElement).then(function(r) {
    document.querySelector('#token').innerText = r.error ? r.error.message : r.id
  })
}
</script>