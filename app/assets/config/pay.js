<div id="number-form" class="payjs-outer"><!-- ここにカード番号入力フォームが生成されます --></div>
<div id="expiry-form" class="payjs-outer"><!-- ここに有効期限入力フォームが生成されます --></div>
<div id="cvc-form" class="payjs-outer"><!-- ここにCVC入力フォームが生成されます --></div>
<button onclick="onSubmit2(event)">トークン作成</button>
<span id="token2"></span>
<script>
var elements4 = payjp.elements()

// 入力フォームを分解して管理・配置できます
var numberElement = elements4.create('cardNumber')
var expiryElement = elements4.create('cardExpiry')
var cvcElement = elements4.create('cardCvc')
numberElement.mount('#number-form')
expiryElement.mount('#expiry-form')
cvcElement.mount('#cvc-form')

// createTokenの引数には任意のElement1つを渡します
function onSubmit2(event) {
  payjp.createToken(numberElement).then(function(r) {
    document.querySelector('#token2').innerText = r.error ? r.error.message : r.id
  })
}
</script>