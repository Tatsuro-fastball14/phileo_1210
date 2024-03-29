$(function () {
  //URLにcardsが含まれている際に発火します。
  if (document.URL.match(/cards/)){

    //公開鍵を記述
    var payjp = Payjp('pk_test_bdc8b66f1293fd3bd5821143');
    //Elements インスタンスを生成します。
    var elements = payjp.elements();
    var numberElement = elements.create('cardNumber');
    var expiryElement = elements.create('cardExpiry');
    var cvcElement = elements.create('cardCvc');

    numberElement.mount('#number-form');
    expiryElement.mount('#expiry-form');
    cvcElement.mount('#cvc-form');

    var submit_btn = $("#info_submit");
    submit_btn.on('click', function (e) {
      e.preventDefault();
      payjp.createToken(numberElement).then(function (response) {

        console.log('111')

        if (response.error) {  //  通信に失敗したとき
          alert(response.error.message)
          regist_card.prop('disabled', false)

          console.log('222')
        } else {

          console.log('333')
          $("#card_token").append(
            `<input type="hidden" name="payjp_token" value=${response.id}>'
            '<input type="hidden" name="card_token" value=${response.card.id}>`
          );
          
          
          $('#card_form').submit()
          $("#card_number").removeAttr("name");
          $("#cvc-from").removeAttr("name");
          $("#exp_month").removeAttr("name");
          $("#exp_year").removeAttr("name");
        };
      });
    }); 
  }
  
});





