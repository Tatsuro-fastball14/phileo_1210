//vuetest.js
// import Vue from "Vue"

  const exp = new "Vue"({
      el: '#test',
      data:{
        cook:[
          "title"
          "store"
          "cooksentence"
          "address"
          "phone_number"
          "open_day"
          "holiday_day"
          "regular_hoilday"
        ]
      }
  })


    <div id="test">
        <ul>
            <li v-for="cooks in cook">
              @{{cooks}}
            </li>
        </ul>
    </div>
    <script src="{{asset('js/vuetest.js')}}"></script>


  //vuetest.js
  const exp =new Vue({
        el: "#test",
        date:{
          cook:[
            {information: "title"},
            {information: "store"},
            {information: "cooksentence"},
            {information: "address"},
            {information: "phone_number"},
            {information: "open_day"},
            {information: "holiday_day"},
            {information: "regular_hoilday"},   
          ]                   
        },          
   })

















