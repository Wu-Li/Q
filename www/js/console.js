window.onerror = alert;

var Q = Q || {};
Q.models = {};
Q.lines = [];
Q.li = 0;
Q.panels = {};

$( function () { 
  Q.panels.console = $("#console-panel");
  Q.console = $("#console");
  Q.prompt = $("#prompt");
  Q.panels.console.nice = Q.panels.console.niceScroll({ 
      cursorwidth:'1px',
      cursorborder:'groove rgba(200,200,200,0.25)',
      cursor:'radial-gradient(ellipse at center, #ffffee 40%,#ddbbbb 100%)'
  });
  
  Q.panels.console.on('change', function() { 
      if(Q.console.height() > Q.panels.console.height()){
        Q.console.css("position","relative");
        Q.panels.console.nice.resize();
        Q.panels.console.nice.doScrollTo(Q.console.height());      
      } else {
        Q.console.css("position","absolute");
      }
  });
  
  $("#prompt").keydown( function(e) {
        switch (e.keyCode) {
                case 13://enter
                var entry = this.value;
                if (entry) {
                    Q.lines.push(entry);
                    Q.li = 0;
                    submit.click();
                }
                break;
            case 38://up
                if (Q.lines.length == 0) {break;}
                if (Q.li == 0) {
                    Q.li = (Q.lines.length - 1);
                } else { Q.li--; }
                this.value = Q.lines[Q.li];
                return false;
            case 40://down
                if (Q.lines.length == 0) {break;}
                if (Q.li == Q.lines.length - 1) {
                    Q.li = 0;
                } else { Q.li++; }
                this.value = Q.lines[Q.li];
                return false;
        }
  });
  
  $("#prompt").focus();
});