$( function () { 
  $("#tabs > li > a").click( function (e){
        var mapId = '#' + (this.text).trim();
        $(mapId).trigger('active');
  });
  $(".mapjs-node span").keydown (function (e) {
        switch (e.keyCode) {
            case 192://`
                if (e.shiftKey) {
                    $("#prompt").val(this.textContent);
                    $("#prompt").attr("value", this.textContent);
                    $("#prompt").trigger('change');
                }
                $("#prompt").focus();
                break;
        }
  });

});