// import axios from 'axios'

//   async function getdata(url,list){
//        //送信処理
//        await axios.get(
//           url,
//           {
//             headers:{
//               'content-type':'application/json'
//             },
//             responseType:'json'

//           //送信成功時処理
//           }).then(responce =>{
//              list.push(responce["data"]);
//              console.log(list)
//           //送信失敗時処理
//           }).catch(e=>{
//              alert(e);
//         });
//       }

// export { getdata }


// //地図範囲取得
// var latlngBounds = this.map.getBounds();
// var swLatlng = latlngBounds.getSouthWest();
// var swlat = String(swLatlng.lat());
// var swlng = String(swLatlng.lng());

// var neLatlng = latlngBounds.getNorthEast();
// var nelat = String(neLatlng.lat());
// var nelng = String(neLatlng.lng());

// //情報取得
// var exifdata=[];
// var url='【APIのURL】/?minlat='+swlat+'&minlng='+swlng+'&maxlat='+nelat+'&maxlng='+nelng;
// await getdata(url,exifdata);



// //marker設置
// marker=new google.maps.Marker({
//   position:{lat: parseFloat, lng:parseFloat} ,
//   map: this.map,
//   icon: {
//     url: require('【ピンの画像パス】'),
//     scaledSize: new google.maps.Size(45, 45),
//     labelOrigin: new this.google.maps.Point(15,30)
//   },
//   label: {
//     text: 20220206,         
//     color: '#ff0000',          
//     fontFamily: 'sans-serif',  
//     fontWeight: 'bold',       
//     fontSize: '14px'           
//   }
// });