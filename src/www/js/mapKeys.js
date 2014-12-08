$( function () { 
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
  
  $(".mapjs-node span").on('change', function(){
    MathJax.Hub.Queue(["Typeset",MathJax.Hub,"MathExample"]);
  })

});