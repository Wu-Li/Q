$( function () { 
  $(".save button").click( function( event ) {
        var container = $(".active > .qmap");   
        saveMap(container);
  });
  $(".load button").click( function( event ) {
        var container = $(".active > .qmap");   
        var map =  $("#query").val();
        var mapJSON = $.parseJSON( map );
        loadMap(container,mapJSON);
  });
  $("#tabs > li > a").click( function (e){
        var mapId = '#' + (this.text).trim();
        $(mapId).trigger('active');
  });
  $(document).keydown( function(e) {
        switch (e.keyCode) {
            case 192://grave
                $("#prompt").focus();
                return false;
        }
  });
  $(".mapjs-node span").keydown (function (e) {
        switch (e.keyCode) {
             case 186://:
                $(this).siblings().remove();
                $(this).parent().append("<p>"+this.textContent+":</p>");
                $(this).text("");
                break;
            case 192://`
                if (e.shiftKey) {
                    $("#prompt").val(this.textContent);
                }
                $("#prompt").focus();
                break;
        }
  });
});