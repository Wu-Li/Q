var Q = Q || {};
Q.models = {};
Q.lines = [];
Q.li = 0;
Q.panels = {};
Q.js = '';

$( function () {   
    
    //Console
    Q.console = $("#console");
    Q.console.map = $("#consoleMap");
    Q.panels.console = $("#console-panel");
    Q.panels.console.nice = Q.panels.console.niceScroll({ 
        cursorwidth:'5px',
        cursorborder:'groove rgba(200,200,200,0.25)',
        railalign:'left'
    });
    Q.panels.console.on('change', function() { 
        $("p.in").before("<hr>");
        if(Q.console.height() > Q.panels.console.height()){
            Q.console.css("position","relative");
            Q.panels.console.nice.resize();
            Q.panels.console.nice.doScrollTo(Q.console.height());    
        } else {
            Q.console.css("position","absolute");
        }
    }); 
    $(".shiny-datatable-output").niceScroll({
        cursorwidth:'1px',
        cursorborder:'groove rgba(200,200,200,0.25)',
        railalign:'right',
        cursoropacitymax:.5
    });          
    
    //Prompt
    Q.prompt = $("#prompt");
    $(window).keydown( function(e) {
        switch (e.keyCode) {
            case 192://`
                $("#prompt").focus();
                return false;
        }
    });
    Q.prompt.keydown( function(e) {
        if(this.value.length == 0) {
            switch(e.keyCode){
                case 107:
                    this.value = 'ans+';
                    return false;
                case 109:
                    this.value = 'ans-';
                    return false;
                case 106:
                    this.value = 'ans*';
                    return false;
                case 111:
                    this.value = 'ans/';
                    return false;
                case 187:
                    if(e.shiftKey){
                        this.value = 'ans+';
                        return false;
                    } else return true;
                case 189:
                    if(!e.shiftKey){
                        this.value = 'ans-';
                        return false;
                    } else return true;
                case 56:
                    if(e.shiftKey) {
                        this.value = 'ans*';
                        return false;
                    } else return true;
                case 191:
                    if(!e.shiftKey) {
                        this.value = 'ans/';
                        return false;
                    } else return true;
            }
        }
        switch (e.keyCode) {
            case 13://enter
                var entry = this.value;
                if (entry) {
                    Q.lines.push(entry);
                    Q.li = 0;
                    $('#submit').click();
                }
                break;
            case 9://tab
                $('#tabs + .tab-content .active .qmap .selected').focus();
                return false;
            case 38://up
                if (Q.lines.length == 0) { break; }
                if (Q.li == 0) { Q.li = (Q.lines.length - 1); } 
                else { Q.li--; }
                this.value = Q.lines[Q.li];
                return false;
            case 40://down
                if (Q.lines.length == 0) { break; }
                if (Q.li == Q.lines.length - 1) { Q.li = 0; } 
                else { Q.li++; }
                this.value = Q.lines[Q.li];
                return false;
            case 192://`
                this.value = this.value + String.fromCharCode(96);
                return false;
        }
    });
    
    $("#tabs > li > a").click( function (e){
        var mapId = '#' + (this.text).trim();
        $(mapId).trigger('active');
    });
    
    $("#tabs-wrapper").resizable({
        alsoResize: "#tabs-wrapper",
        handles:"w",
        minWidth: 240,
        containment: 'parent',
        animate:true,
        distance:10,
        start: function (event, ui){
            $("#help").each(function (index, element) {
            var d = $('<div class="iframeCover" style="z-index:99;position:absolute;width:100%;top:0px;left:0px;height:' +
            $(element).height() + 'px"></div>');
            $(element).append(d);
            });
            var w = $("#plot img").width();
            console.log(w);
            $("#plot img").width(w + 'px');
        },
        stop: function (event, ui) {
            var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
            var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
            var ph = $("#panelHeight");
            var pw = $("#panelWidth");
            c = w - ui.size.width;
            if (c < 200) { pw.val(200/8); }
            else { pw.val(c/8) }
            ph.val(h);
            Shiny.onInputChange("panelWidth",pw.val());
            Shiny.onInputChange("panelHeight",ph.val());
            $("#panels + .tab-content").css("width",c);
            $("#plot img").css('width',c);
            $('.iframeCover').remove();
        }
    });
    $(window).resize( function() {
        var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
        var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
        var ph = $("#panelHeight");
        var pw = $("#panelWidth");
        var tw = $('#tabs-wrapper').width();
        var c = w - tw
        if (c < 200) { pw.val(200/8); }
        else { pw.val(c/8)}
        ph.val(h);
        $("#plot img").css('width',c);
        $("#panels + .tab-content").css("width",c);
    });
    $(window).resize();
    
    $('.tab-content').resize( function() {
        var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
        var ph = $("#panelHeight");
        ph.val(h);
        Shiny.onInputChange("panelHeight",ph.val());
    });
    
    //Tray
    $('#undo').click(function(){window.mapModel.undo()})
    $('#redo').click(function(){window.mapModel.redo()})
    setTimeout(function() { Q.prompt.focus() }, 2000);
});