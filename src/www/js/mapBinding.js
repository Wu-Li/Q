function buildMap(container,mapJSON) {
  
  var idea = MAPJS.content(mapJSON),
  mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []),
  imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
  
  mapModel.id = container.attr('id');
  
  container.domMapWidget(console, mapModel, false, imageInsertController);
  $('body').mapToolbarWidget(mapModel);
  $('body').attachmentEditorWidget(mapModel);
  
  $("[data-mm-action='export-image']").click(function () {
    MAPJS.pngExport(idea).then(function (url) {
      window.open(url, '_blank');
    });
  });
  mapModel.setIdea(idea);
  $('#linkEditWidget').linkEditWidget(mapModel);
  window.mapModel = mapModel;
  $('.arrow').click(function () {
    $(this).toggleClass('active');
  });
  imageInsertController.addEventListener('imageInsertError', function (reason) {
    console.log('image insert error', reason);
  });
  container.on('drop', function (e) {
    var dataTransfer = e.originalEvent.dataTransfer;
    e.stopPropagation();
    e.preventDefault();
    if (dataTransfer && dataTransfer.files && dataTransfer.files.length > 0) {
      var fileInfo = dataTransfer.files[0];
      if (/\.mup$/.test(fileInfo.name)) {
        var oFReader = new FileReader();
        oFReader.onload = function (oFREvent) {
          mapModel.setIdea(MAPJS.content(JSON.parse(oFREvent.target.result)));
        };
        oFReader.readAsText(fileInfo, 'UTF-8');
      }
    }
  });
  container.on('active', function (e) {
    window.mapModel = Q.models[this.id];
  })
  return mapModel;
};

function saveMap(container) { 
  var mapId = container.attr("id");
  var mapJSON = Q.models[mapId].getIdea();
  var query = $("#query");
  query.val(JSON.stringify(mapJSON));
  query.trigger('change');
};

var mapBinding = new Shiny.InputBinding();
$.extend(mapBinding, {
  find: function(scope) { return $(".qmap"); },  
  getNode: function getNode(el, qpid) {
    var mapIdea = Q.models[el.id].getIdea();
    if (qpid == 1) { var nodeIdea = mapIdea; } 
    else { var nodeIdea = mapIdea.findSubIdeaById(qpid); }
    if (nodeIdea) {
      var node = {
            name: nodeIdea.title,
            value: nodeIdea.title,
            qpid: qpid,
            path: 'domain.user.project.' + mapIdea.title + '/' + nodeIdea.id,
            kids: mapIdea.getSubTreeIds(qpid)
        };
      return node;
    } else {return null;}
  },
  getNodeValue: function getNodeValue(el, qpid) {
    var mapIdea = Q.models[el.id].getIdea();
    if (qpid == 1) { var nodeIdea = mapIdea; } 
    else { var nodeIdea = mapIdea.findSubIdeaById(qpid); }
    if (nodeIdea) {
      var value = nodeIdea.title;
      return value;
    } else {return null;}
  },
  getNodeChildren: function getNodeChildren(el, qpid) {
    var mapIdea = Q.models[el.id].getIdea();
    if (qpid == 1) { var nodeIdea = mapIdea; } 
    else { var nodeIdea = mapIdea.findSubIdeaById(qpid); }
    if (nodeIdea) {
      var childIdeas = nodeIdea.sortedSubIdeas();
      var childNodes = [];
      childIdeas.forEach(function (idea) {
        childNodes.push(getNode(el, idea.id));
      });
      return childNodes;
    } else {return null;}
  },
  getNodeWithChildren: function getNodeWithChildren(el, qpid) {
    var mapIdea = Q.models[el.id].getIdea();
    if (qpid == 1) { var nodeIdea = mapIdea; } 
    else { var nodeIdea = mapIdea.findSubIdeaById(qpid); }
    if (nodeIdea) {
      var node = getNode(el, qpid);
      node.kids.forEach(function(qpid){
          node.children.push(getNodeWithChildren(el, qpid));
      });
    } else {return null;}
  },
  getValue: function(el) {
    if (Q.models[el.id]) {
      idea = Q.models[el.id].getIdea();
    } else {idea = "";}
    return idea;
  },
  setValue: function(el, value) {
    el.text("");
    Q.models[el.attr('id')] = buildMap(el,value);
  },
  subscribe: function(el, callback){
    var subscribe = function(e) { callback(); }
    Q.models[el.id].addEventListener('layoutChangeComplete', subscribe);
  },
  unsubscribe: function(el) {
    Q.models[el.id].removeEventListener('layoutChangeComplete', subscribe);
  }
});

Shiny.inputBindings.register(mapBinding);