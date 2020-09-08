/**
 * Created by Administrator on 2017/4/15 0015.
 */
$('.visit-control-btn').on('click',function () {
   if($(this).hasClass('visit-control-active')){
       $(this).removeClass('visit-control-active')
   }
   else {
       $(this).addClass('visit-control-active')
   }
});