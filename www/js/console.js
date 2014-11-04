window.onerror = alert;
var Q = Q || {};
Q.models = {};
Q.lines = [];
Q.li = 0;

$( function () { 
  
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
                break;
            case 40://down
                if (Q.lines.length == 0) {break;}
                if (Q.li == Q.lines.length - 1) {
                    Q.li = 0;
                } else { Q.li++; }
                this.value = Q.lines[Q.li];
                break;
            case 192://`
                if (e.shiftKey) {
                    $(".active .qmap .selected ").val($("#prompt").val());
                    $(".active .qmap .selected span").text($("#prompt").val());
                }
                $(".active .qmap .selected").focus();
                break;
        }
  });
  
  $("#prompt").focus();
});