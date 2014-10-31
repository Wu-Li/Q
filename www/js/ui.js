window.onerror = alert;
var models = {};
var plines = 300;

$( function () { 
  $(".save").click( function( event ) {
        var container = $(".active > .qmap");   
        saveMap(container);
  });
  $(".load").click( function( event ) {
        var container = $(".active > .qmap");   
        var map =  $("#query").val();
        var mapJSON = $.parseJSON( map );
        loadMap(container,mapJSON);
  });
  $("#tabs > li > a").click( function (e){
        var mapId = '#' + (this.text).trim();
        $(mapId).trigger('active');
  });
  $(".qmap").keydown( function(e) {
        switch (e.keyCode) {
            case 192://grave
                $("#prompt").focus();
                return false;
        }
  });
  $("#prompt").keydown( function(e) {
        switch (e.keyCode) {
            case 13://enter
                pline = 0;
                $("#submit").click();
        }
  });
  $("#prompt").keydown( function (e) {
        switch (e.keyCode) {
            case 38://up
                var lines = $("#out li").filter(function () {
                    return $(this).text().indexOf('>') == 0;
                });
                var line = lines[pline-- % lines.length].textContent;
                this.value = line.substring(2);
                break;
            case 40://down
                var lines = $("#out li").filter(function () {
                    return $(this).text().indexOf('>') == 0;
                });
                var line = lines[pline++ % lines.length].textContent;
                this.value = line.substring(2);
                break;
            case 192://`
                $(".active .qmap .selected ").val($("#prompt").val());
                $(".active .qmap .selected span").text($("#prompt").val());
                $(".active .qmap .selected").focus();
                return false;
                break;
        }
  });
  $(".mapjs-node > span").keydown (function (e) {
        switch (e.keyCode) {
             case 186://:
                $(this).siblings().remove();
                $(this).parent().append("<p>"+this.textContent+":</p>");
                $(this).text("");
                return false;
             case 192://`
                if (e.shiftKey) {
                    $("#prompt").val(this.textContent);
                    $("#prompt").focus();
                    return true;
                }
        }
  });
  $("#prompt").focus();
});