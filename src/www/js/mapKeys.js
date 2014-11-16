$( function () { 
  $(".save button").click( function( event ) {
        var container = $(".active > .qmap");   
        saveMap(container);
  });
  $(".load button").click( function( event ) {
        var container = $(".active > .qmap");   
        var mapId = container.attr('id');
        var map =  $("#query").val();
        var mapJSON = $.parseJSON( map );
        mapBinding.setValue(container, mapJSON);
        Shiny.onInputChange(mapId,mapJSON);
  });
  $("#tabs > li > a").click( function (e){
        var mapId = '#' + (this.text).trim();
        $(mapId).trigger('active');
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
                    $("#prompt").attr("value", this.textContent);
                    $("#prompt").trigger('change');
                }
                $("#prompt").focus();
                break;
        }
  });
});